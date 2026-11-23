Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-ELSIProbePlan {
    param([Parameter(Mandatory)][string] $HostRunGate)

    if ($HostRunGate -cne 'NON_ELEVATED_PASS') { return @() }
    return @('OS_VERSION', 'OS_ARCHITECTURE', 'RAM_BYTES', 'DISK_FREE_BYTES', 'CPU_PHYSICAL_CORES')
}

function ConvertTo-ELSIInvariantNumber {
    param([AllowNull()][object] $Value)

    if ($null -eq $Value -or $Value -is [bool]) { return $null }
    $text = [System.Convert]::ToString($Value, [System.Globalization.CultureInfo]::InvariantCulture)
    if ([string]::IsNullOrWhiteSpace($text)) { return $null }
    $number = [decimal]0
    $styles = [System.Globalization.NumberStyles]::Number
    $culture = [System.Globalization.CultureInfo]::InvariantCulture
    if (-not [decimal]::TryParse($text, $styles, $culture, [ref]$number)) { return $null }
    return $number
}

function Get-ELSIOSVersionStatus {
    param([AllowNull()][object] $Version)

    if ($Version -isnot [version] -or $Version.Build -lt 0) { return 'UNVERIFIED' }
    if ($Version.Major -eq 10) {
        if ($Version.Build -ge 18362) { return 'PASS' }
        return 'FAIL'
    }
    if ($Version.Major -lt 10) { return 'FAIL' }
    return 'UNVERIFIED'
}

function Get-ELSIOSArchitectureStatus {
    param(
        [AllowNull()][object] $Architecture,
        [AllowNull()][object] $Version
    )

    if ($Architecture -isnot [string]) { return 'UNVERIFIED' }
    if ($Architecture -ceq 'X64') { return 'PASS' }
    if ($Architecture -ceq 'Arm64') {
        if ($Version -isnot [version] -or $Version.Build -lt 0) { return 'UNVERIFIED' }
        if ($Version.Major -eq 10 -and $Version.Build -ge 22621) { return 'PASS' }
        if ($Version.Major -eq 10 -and $Version.Build -ge 22000) { return 'FAIL' }
        if ($Version.Major -lt 10 -or ($Version.Major -eq 10 -and $Version.Build -lt 22000)) { return 'FAIL' }
        return 'UNVERIFIED'
    }
    if ($Architecture -cin @('X86', 'Arm', 'IA64')) { return 'FAIL' }
    return 'UNVERIFIED'
}

function Get-ELSIMinimumStatus {
    param(
        [AllowNull()][object] $Value,
        [Parameter(Mandatory)][decimal] $Minimum
    )

    $number = ConvertTo-ELSIInvariantNumber -Value $Value
    if ($null -eq $number) { return 'UNVERIFIED' }
    if ($number -ge $Minimum) { return 'PASS' }
    return 'FAIL'
}

function Get-ELSIRecommendationStatus {
    param(
        [AllowNull()][object] $Value,
        [Parameter(Mandatory)][decimal] $Recommended
    )

    $number = ConvertTo-ELSIInvariantNumber -Value $Value
    if ($null -eq $number) { return 'UNVERIFIED' }
    if ($number -ge $Recommended) { return 'PASS' }
    return 'BELOW_RECOMMENDED'
}

function Get-ELSIHostPreflightResult {
    param(
        [Parameter(Mandatory)][string] $HostRunGate,
        [Parameter(Mandatory)][System.Collections.IDictionary] $ProbeValues
    )

    $allowedGates = @('NON_ELEVATED_PASS', 'ELEVATED_BLOCKED', 'NON_WINDOWS', 'UNVERIFIED')
    if ($HostRunGate -cnotin $allowedGates) { $HostRunGate = 'UNVERIFIED' }

    $osStatus = 'UNVERIFIED'
    $architectureStatus = 'UNVERIFIED'
    $ramMinimumStatus = 'UNVERIFIED'
    $ramRecommendedStatus = 'UNVERIFIED'
    $diskMinimumStatus = 'UNVERIFIED'
    $diskPracticalStatus = 'UNVERIFIED'
    $cpuMinimumStatus = 'UNVERIFIED'

    if ($HostRunGate -ceq 'NON_ELEVATED_PASS') {
        $version = $ProbeValues['OS_VERSION']
        $osStatus = Get-ELSIOSVersionStatus -Version $version
        $architectureStatus = Get-ELSIOSArchitectureStatus -Architecture $ProbeValues['OS_ARCHITECTURE'] -Version $version

        $ramBytes = $ProbeValues['RAM_BYTES']
        $ramMinimumStatus = Get-ELSIMinimumStatus -Value $ramBytes -Minimum ([decimal](4GB))
        $ramRecommendedStatus = Get-ELSIRecommendationStatus -Value $ramBytes -Recommended ([decimal](8GB))

        $diskBytes = $ProbeValues['DISK_FREE_BYTES']
        $diskMinimumStatus = Get-ELSIMinimumStatus -Value $diskBytes -Minimum ([decimal](1GB))
        $diskPracticalStatus = Get-ELSIRecommendationStatus -Value $diskBytes -Recommended ([decimal](5GB))

        $cpuMinimumStatus = Get-ELSIMinimumStatus -Value $ProbeValues['CPU_PHYSICAL_CORES'] -Minimum ([decimal]2)
    }

    $reportStatus = 'UNVERIFIED'
    if ($HostRunGate -cin @('ELEVATED_BLOCKED', 'NON_WINDOWS')) {
        $reportStatus = 'BLOCKED_BY_RUN_GATE'
    }
    elseif ($HostRunGate -ceq 'NON_ELEVATED_PASS') {
        $eligibility = @($osStatus, $architectureStatus, $ramMinimumStatus, $ramRecommendedStatus, $diskMinimumStatus, $diskPracticalStatus, $cpuMinimumStatus)
        if ($eligibility -notcontains 'UNVERIFIED') { $reportStatus = 'READ_ONLY_REPORT' }
        else { $reportStatus = 'PARTIAL_REPORT' }
    }

    return [ordered]@{
        HOST_RUN_GATE = $HostRunGate
        OS_VERSION_ELIGIBILITY = $osStatus
        OS_ARCH_ELIGIBILITY = $architectureStatus
        RAM_MIN_4GB = $ramMinimumStatus
        RAM_RECOMMENDED_8GB = $ramRecommendedStatus
        DISK_MIN_1GB = $diskMinimumStatus
        DISK_PRACTICAL_5GB = $diskPracticalStatus
        CPU_CORE_MIN_2 = $cpuMinimumStatus
        HOST_FEATURE_STATE = 'OWNER_GUI_UNCHECKED_NOT_REVERIFIED'
        VIRTUALIZATION_SUPPORT = 'OWNER_REPORTED_SUPPORTED_NOT_REVERIFIED'
        HOST_FEATURE_ACTIVATION = 'NOT_ATTEMPTED'
        GUEST_LAUNCH = 'NOT_ATTEMPTED'
        GUEST_NETWORK_ISOLATION = 'UNVERIFIED'
        APPLICATION_RESTORE = 'NOT_ATTEMPTED'
        PRODUCTION_ACCESS = 'NONE'
        STATUS = $reportStatus
    }
}

function Get-ELSIHostRunGate {
    if (-not [System.Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([System.Runtime.InteropServices.OSPlatform]::Windows)) {
        return 'NON_WINDOWS'
    }
    $identity = $null
    try {
        $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
        if ($null -eq $identity) { return 'UNVERIFIED' }
        $principal = [System.Security.Principal.WindowsPrincipal]::new($identity)
        if ($principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) { return 'ELEVATED_BLOCKED' }
        return 'NON_ELEVATED_PASS'
    }
    catch {
        return 'UNVERIFIED'
    }
    finally {
        if ($null -ne $identity) { $identity.Dispose() }
    }
}

function Get-ELSIHostOSVersion {
    return [System.Environment]::OSVersion.Version
}

function Get-ELSIHostOSArchitecture {
    return [System.Runtime.InteropServices.RuntimeInformation]::OSArchitecture.ToString()
}

function Get-ELSIHostRAMBytes {
    $computer = Get-CimInstance -ClassName Win32_ComputerSystem -Property TotalPhysicalMemory -ErrorAction Stop
    if ($null -eq $computer -or $null -eq $computer.TotalPhysicalMemory) { return $null }
    return [decimal]$computer.TotalPhysicalMemory
}

function Get-ELSIHostDiskFreeBytes {
    $windowsDirectory = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Windows)
    if ([string]::IsNullOrWhiteSpace($windowsDirectory)) { return $null }
    $systemRoot = [System.IO.Path]::GetPathRoot($windowsDirectory)
    if ([string]::IsNullOrWhiteSpace($systemRoot)) { return $null }
    $systemDrive = [System.IO.DriveInfo]::new($systemRoot)
    if (-not $systemDrive.IsReady -or $systemDrive.DriveType -ne [System.IO.DriveType]::Fixed) { return $null }
    return [decimal]$systemDrive.AvailableFreeSpace
}

function Get-ELSIHostPhysicalCoreCount {
    $processors = @(Get-CimInstance -ClassName Win32_Processor -Property NumberOfCores -ErrorAction Stop)
    if ($processors.Count -eq 0) { return $null }
    $total = [decimal]0
    foreach ($processor in $processors) {
        if ($null -eq $processor.NumberOfCores) { return $null }
        $cores = ConvertTo-ELSIInvariantNumber -Value $processor.NumberOfCores
        if ($null -eq $cores -or $cores -lt 1 -or [decimal]::Truncate($cores) -ne $cores) { return $null }
        $total += $cores
    }
    return $total
}

$hostRunGate = 'UNVERIFIED'
try { $hostRunGate = Get-ELSIHostRunGate } catch { $hostRunGate = 'UNVERIFIED' }
$probeValues = @{}
$probePlan = @(Get-ELSIProbePlan -HostRunGate $hostRunGate)
foreach ($probeName in $probePlan) {
    try {
        switch -CaseSensitive ($probeName) {
            'OS_VERSION' { $probeValues[$probeName] = Get-ELSIHostOSVersion }
            'OS_ARCHITECTURE' { $probeValues[$probeName] = Get-ELSIHostOSArchitecture }
            'RAM_BYTES' { $probeValues[$probeName] = Get-ELSIHostRAMBytes }
            'DISK_FREE_BYTES' { $probeValues[$probeName] = Get-ELSIHostDiskFreeBytes }
            'CPU_PHYSICAL_CORES' { $probeValues[$probeName] = Get-ELSIHostPhysicalCoreCount }
        }
    }
    catch {
        $probeValues[$probeName] = $null
    }
}

$result = Get-ELSIHostPreflightResult -HostRunGate $hostRunGate -ProbeValues $probeValues
foreach ($key in $result.Keys) { "${key}=$($result[$key])" }
