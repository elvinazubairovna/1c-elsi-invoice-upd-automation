#requires -Version 7.0
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$WarningPreference = 'SilentlyContinue'
$InformationPreference = 'SilentlyContinue'
$VerbosePreference = 'SilentlyContinue'
$ProgressPreference = 'SilentlyContinue'

function ConvertTo-EditionClass {
    param([AllowNull()][object] $Value)
    if ($null -eq $Value -or $Value -isnot [string] -or [string]::IsNullOrWhiteSpace($Value)) { return 'UNVERIFIED' }
    $edition = $Value.Trim().ToUpperInvariant()
    if ($edition -match '^SERVER') { return 'SERVER' }
    if ($edition -match '^(?:EDUCATION|EDUCATIONN|PROFESSIONALSTUDENT)$') { return 'EDUCATION' }
    if ($edition -match '^(?:ENTERPRISE|ENTERPRISES|ENTERPRISESN|ENTERPRISEG|ENTERPRISEGN|ENTERPRISEEVALUATION)$') { return 'ENTERPRISE' }
    if ($edition -match '^(?:PROFESSIONAL|PROFESSIONALN|PROFESSIONALWORKSTATION|PROFESSIONALWORKSTATIONN|PROFESSIONALEDUCATION|PROFESSIONALEDUCATIONN)$') { return 'PRO' }
    if ($edition -match '^(?:CORE|COREN|CORESINGLELANGUAGE|CORECOUNTRYSPECIFIC|CORECONNECTED|CORECONNECTEDN)$') { return 'HOME' }
    return 'OTHER'
}

function ConvertTo-FeatureStatus {
    param([AllowNull()][object] $Value)
    if ($null -eq $Value -or $Value -isnot [string]) { return 'UNVERIFIED' }
    switch ($Value.Trim().ToUpperInvariant()) {
        'ENABLED' { return 'ENABLED' }
        'DISABLED' { return 'DISABLED' }
        'NOT_AVAILABLE' { return 'NOT_AVAILABLE' }
        default { return 'UNVERIFIED' }
    }
}

function ConvertTo-VirtualizationStatus {
    param([AllowNull()][object[]] $Flags)
    if ($null -eq $Flags -or $Flags.Count -eq 0) { return 'UNVERIFIED' }
    foreach ($flag in $Flags) { if ($flag -isnot [bool]) { return 'UNVERIFIED' } }
    if (@($Flags | Where-Object { $_ -eq $false }).Count -gt 0) { return 'UNSUPPORTED' }
    return 'SUPPORTED'
}

function Invoke-SafeCallback {
    param([Parameter(Mandatory)][scriptblock] $Callback)
    try {
        return [pscustomobject]@{ Succeeded=$true; Value=(& $Callback); Failure=$null }
    }
    catch {
        return [pscustomobject]@{ Succeeded=$false; Value=$null; Failure=$_.Exception }
    }
}

function Resolve-RunGate {
    param(
        [Parameter(Mandatory)][object] $PlatformProbe,
        [AllowNull()][object] $IdentityProbe
    )
    if (-not $PlatformProbe.Succeeded -or $PlatformProbe.Value -isnot [bool]) { return 'UNVERIFIED' }
    if (-not $PlatformProbe.Value) { return 'NON_WINDOWS' }
    if ($null -eq $IdentityProbe -or -not $IdentityProbe.Succeeded -or $IdentityProbe.Value -isnot [bool]) { return 'IDENTITY_CHECK_FAILED' }
    if ($IdentityProbe.Value) { return 'ELEVATED_BLOCKED' }
    return 'NON_ELEVATED_PASS'
}

function Get-SafeFailureCategory {
    param([AllowNull()][object] $Failure)
    if ($null -eq $Failure) { return 'QUERY_ERROR' }
    if ($Failure -is [System.Management.Automation.ErrorRecord]) { $exception = $Failure.Exception } else { $exception = $Failure }
    if ($exception -isnot [Exception]) { return 'QUERY_ERROR' }
    $base = $exception.GetBaseException()
    switch ($base.GetType().FullName) {
        'System.UnauthorizedAccessException' { return 'ACCESS_DENIED' }
        'System.Security.SecurityException' { return 'ACCESS_DENIED' }
        'System.Management.Automation.CommandNotFoundException' { return 'API_UNAVAILABLE' }
        'System.PlatformNotSupportedException' { return 'API_UNAVAILABLE' }
        default { return 'QUERY_ERROR' }
    }
}

function Resolve-QueryOutcome {
    param(
        [Parameter(Mandatory)][ValidateSet('EDITION','FEATURE','VIRTUALIZATION')][string] $Kind,
        [Parameter(Mandatory)][AllowNull()][object] $Probe,
        [Parameter(Mandatory)][bool] $Succeeded,
        [AllowNull()][object] $Failure
    )
    if (-not $Succeeded) {
        $failureCategory = Get-SafeFailureCategory -Failure $Failure
        if ($failureCategory -eq 'ACCESS_DENIED') { return [pscustomobject]@{ Status='ACCESS_DENIED'; Value='UNVERIFIED' } }
        if ($failureCategory -eq 'API_UNAVAILABLE') { return [pscustomobject]@{ Status='API_UNAVAILABLE'; Value='UNVERIFIED' } }
        return [pscustomobject]@{ Status='QUERY_ERROR'; Value='UNVERIFIED' }
    }
    if ($null -eq $Probe -or $Probe.ApiAvailable -isnot [bool]) { return [pscustomobject]@{ Status='QUERY_ERROR'; Value='UNVERIFIED' } }
    if (-not $Probe.ApiAvailable) { return [pscustomobject]@{ Status='API_UNAVAILABLE'; Value='UNVERIFIED' } }
    if ($Probe.HasValue -isnot [bool]) { return [pscustomobject]@{ Status='QUERY_ERROR'; Value='UNVERIFIED' } }

    if ($Kind -eq 'EDITION') {
        if (-not $Probe.HasValue -or $null -eq $Probe.Value) { return [pscustomobject]@{ Status='NO_VALUE'; Value='UNVERIFIED' } }
        if ($Probe.Value -isnot [string]) { return [pscustomobject]@{ Status='QUERY_ERROR'; Value='UNVERIFIED' } }
        if ([string]::IsNullOrWhiteSpace($Probe.Value)) { return [pscustomobject]@{ Status='NO_VALUE'; Value='UNVERIFIED' } }
        return [pscustomobject]@{ Status='PASS'; Value=(ConvertTo-EditionClass -Value $Probe.Value) }
    }

    if (-not $Probe.HasValue -or $null -eq $Probe.Value) { return [pscustomobject]@{ Status='QUERY_ERROR'; Value='UNVERIFIED' } }
    if ($Kind -eq 'FEATURE') {
        if ($null -eq $Probe.Value.PSObject.Properties['State']) { return [pscustomobject]@{ Status='QUERY_ERROR'; Value='UNVERIFIED' } }
        $normalizedFeature = ConvertTo-FeatureStatus -Value $Probe.Value.State
        if ($normalizedFeature -eq 'UNVERIFIED') { return [pscustomobject]@{ Status='QUERY_ERROR'; Value='UNVERIFIED' } }
        return [pscustomobject]@{ Status='PASS'; Value=$normalizedFeature }
    }

    if ($Probe.Value -isnot [array]) { return [pscustomobject]@{ Status='QUERY_ERROR'; Value='UNVERIFIED' } }
    $normalizedVirtualization = ConvertTo-VirtualizationStatus -Flags $Probe.Value
    if ($normalizedVirtualization -eq 'UNVERIFIED') { return [pscustomobject]@{ Status='QUERY_ERROR'; Value='UNVERIFIED' } }
    return [pscustomobject]@{ Status='PASS'; Value=$normalizedVirtualization }
}

function Invoke-ReadinessAssessment {
    param(
        [Parameter(Mandatory)][scriptblock] $PlatformProbe,
        [Parameter(Mandatory)][scriptblock] $IdentityProbe,
        [Parameter(Mandatory)][scriptblock] $EditionProbe,
        [Parameter(Mandatory)][scriptblock] $SandboxProbe,
        [Parameter(Mandatory)][scriptblock] $HyperVProbe,
        [Parameter(Mandatory)][scriptblock] $VirtualizationProbe
    )
    $platform = Invoke-SafeCallback -Callback $PlatformProbe
    $identity = $null
    if ($platform.Succeeded -and $platform.Value -is [bool] -and $platform.Value) {
        $identity = Invoke-SafeCallback -Callback $IdentityProbe
    }
    $runGate = Resolve-RunGate -PlatformProbe $platform -IdentityProbe $identity

    $edition = [pscustomobject]@{ Status='SKIPPED'; Value='UNVERIFIED' }
    $sandbox = [pscustomobject]@{ Status='SKIPPED'; Value='UNVERIFIED' }
    $hyperV = [pscustomobject]@{ Status='SKIPPED'; Value='UNVERIFIED' }
    $virtualization = [pscustomobject]@{ Status='SKIPPED'; Value='UNVERIFIED' }
    $reportStatus = 'UNVERIFIED'

    if ($runGate -eq 'NON_WINDOWS' -or $runGate -eq 'ELEVATED_BLOCKED') {
        $reportStatus = 'BLOCKED_BY_RUN_GATE'
    }
    elseif ($runGate -eq 'NON_ELEVATED_PASS') {
        $editionCall = Invoke-SafeCallback -Callback $EditionProbe
        $sandboxCall = Invoke-SafeCallback -Callback $SandboxProbe
        $hyperVCall = Invoke-SafeCallback -Callback $HyperVProbe
        $virtualizationCall = Invoke-SafeCallback -Callback $VirtualizationProbe
        $edition = Resolve-QueryOutcome -Kind EDITION -Probe $editionCall.Value -Succeeded $editionCall.Succeeded -Failure $editionCall.Failure
        $sandbox = Resolve-QueryOutcome -Kind FEATURE -Probe $sandboxCall.Value -Succeeded $sandboxCall.Succeeded -Failure $sandboxCall.Failure
        $hyperV = Resolve-QueryOutcome -Kind FEATURE -Probe $hyperVCall.Value -Succeeded $hyperVCall.Succeeded -Failure $hyperVCall.Failure
        $virtualization = Resolve-QueryOutcome -Kind VIRTUALIZATION -Probe $virtualizationCall.Value -Succeeded $virtualizationCall.Succeeded -Failure $virtualizationCall.Failure
        $queryStatuses = @($edition.Status,$sandbox.Status,$hyperV.Status,$virtualization.Status)
        if (@($queryStatuses | Where-Object { $_ -ne 'PASS' }).Count -eq 0) {
            $reportStatus = 'READ_ONLY_REPORT'
        }
        else { $reportStatus = 'PARTIAL_REPORT' }
    }

    return [pscustomobject]@{
        RunGate=$runGate
        Edition=$edition
        Sandbox=$sandbox
        HyperV=$hyperV
        Virtualization=$virtualization
        Status=$reportStatus
    }
}

function Test-ExactCommandAvailable {
    param([Parameter(Mandatory)][string] $CommandName)
    try {
        $command = Get-Command -Name $CommandName -CommandType Cmdlet -ErrorAction Stop
        return ($null -ne $command)
    }
    catch [System.Management.Automation.CommandNotFoundException] { return $false }
}

function Get-EditionProbe {
    $key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey('SOFTWARE\Microsoft\Windows NT\CurrentVersion', $false)
    if ($null -eq $key) { return [pscustomobject]@{ ApiAvailable=$true; HasValue=$false; Value=$null } }
    try {
        $value = $key.GetValue('EditionID', $null, [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
        return [pscustomobject]@{ ApiAvailable=$true; HasValue=($null -ne $value); Value=$value }
    }
    finally { $key.Dispose() }
}

function Get-FeatureProbe {
    param([Parameter(Mandatory)][string] $FeatureName)
    if (-not (Test-ExactCommandAvailable -CommandName 'Get-WindowsOptionalFeature')) {
        return [pscustomobject]@{ ApiAvailable=$false; HasValue=$false; Value=$null }
    }
    $feature = Get-WindowsOptionalFeature -Online -FeatureName $FeatureName -ErrorAction Stop -WarningAction SilentlyContinue -InformationAction SilentlyContinue
    return [pscustomobject]@{ ApiAvailable=$true; HasValue=($null -ne $feature); Value=$feature }
}

function Get-VirtualizationProbe {
    if (-not (Test-ExactCommandAvailable -CommandName 'Get-CimInstance')) {
        return [pscustomobject]@{ ApiAvailable=$false; HasValue=$false; Value=$null }
    }
    $processors = @(Get-CimInstance -ClassName 'Win32_Processor' -Property @('VMMonitorModeExtensions','SecondLevelAddressTranslationExtensions','VirtualizationFirmwareEnabled') -ErrorAction Stop -WarningAction SilentlyContinue -InformationAction SilentlyContinue)
    if ($processors.Count -eq 0) { return [pscustomobject]@{ ApiAvailable=$true; HasValue=$false; Value=$null } }
    $flags = [Collections.Generic.List[object]]::new()
    foreach ($processor in $processors) {
        $flags.Add($processor.VMMonitorModeExtensions)
        $flags.Add($processor.SecondLevelAddressTranslationExtensions)
        $flags.Add($processor.VirtualizationFirmwareEnabled)
    }
    return [pscustomobject]@{ ApiAvailable=$true; HasValue=$true; Value=@($flags.ToArray()) }
}

function Format-ReadinessReport {
    param([Parameter(Mandatory)][object] $Assessment)
    $allowedEditions = @('HOME','PRO','EDUCATION','ENTERPRISE','SERVER','OTHER','UNVERIFIED')
    $editionValue = if ($Assessment.Edition.Value -in $allowedEditions) { $Assessment.Edition.Value } else { 'UNVERIFIED' }
    $sandboxValue = ConvertTo-FeatureStatus -Value $Assessment.Sandbox.Value
    $hyperVValue = ConvertTo-FeatureStatus -Value $Assessment.HyperV.Value
    $virtualizationValue = if ($Assessment.Virtualization.Value -in @('SUPPORTED','UNSUPPORTED','UNVERIFIED')) { $Assessment.Virtualization.Value } else { 'UNVERIFIED' }
    $allowedGates = @('NON_ELEVATED_PASS','ELEVATED_BLOCKED','NON_WINDOWS','IDENTITY_CHECK_FAILED','UNVERIFIED')
    $allowedStatuses = @('READ_ONLY_REPORT','PARTIAL_REPORT','BLOCKED_BY_RUN_GATE','UNVERIFIED')
    $runGate = if ($Assessment.RunGate -in $allowedGates) { $Assessment.RunGate } else { 'UNVERIFIED' }
    $reportStatus = if ($Assessment.Status -in $allowedStatuses) { $Assessment.Status } else { 'UNVERIFIED' }
    $editionQuery = if ($Assessment.Edition.Status -in @('PASS','NO_VALUE','ACCESS_DENIED','QUERY_ERROR','SKIPPED')) { $Assessment.Edition.Status } else { 'QUERY_ERROR' }
    $sandboxQuery = if ($Assessment.Sandbox.Status -in @('PASS','API_UNAVAILABLE','ACCESS_DENIED','QUERY_ERROR','SKIPPED')) { $Assessment.Sandbox.Status } else { 'QUERY_ERROR' }
    $hyperVQuery = if ($Assessment.HyperV.Status -in @('PASS','API_UNAVAILABLE','ACCESS_DENIED','QUERY_ERROR','SKIPPED')) { $Assessment.HyperV.Status } else { 'QUERY_ERROR' }
    $virtualizationQuery = if ($Assessment.Virtualization.Status -in @('PASS','API_UNAVAILABLE','ACCESS_DENIED','QUERY_ERROR','SKIPPED')) { $Assessment.Virtualization.Status } else { 'QUERY_ERROR' }
    $lines = [Collections.Generic.List[string]]::new()
    $lines.Add("OS_EDITION_CLASS=$editionValue")
    $lines.Add("WINDOWS_SANDBOX_FEATURE=$sandboxValue")
    $lines.Add("HYPERV_FEATURE=$hyperVValue")
    $lines.Add("VIRTUALIZATION_SUPPORT=$virtualizationValue")
    $lines.Add('HOST_ISOLATION=NOT_CONFIGURED_OR_UNVERIFIED')
    $lines.Add('OUTBOUND_ISOLATION=UNVERIFIED')
    $lines.Add('APPLICATION_RESTORE=NOT_ATTEMPTED')
    $lines.Add('PRODUCTION_ACCESS=NONE')
    $lines.Add("STATUS=$reportStatus")
    $lines.Add("RUN_GATE=$runGate")
    $lines.Add("EDITION_QUERY=$editionQuery")
    $lines.Add("SANDBOX_QUERY=$sandboxQuery")
    $lines.Add("HYPERV_QUERY=$hyperVQuery")
    $lines.Add("VIRTUALIZATION_QUERY=$virtualizationQuery")
    return $lines.ToArray()
}

$assessment = Invoke-ReadinessAssessment `
    -PlatformProbe { [Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([Runtime.InteropServices.OSPlatform]::Windows) } `
    -IdentityProbe {
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
        try {
            $principal = [Security.Principal.WindowsPrincipal]::new($identity)
            return [bool]$principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        }
        finally { $identity.Dispose() }
    } `
    -EditionProbe { Get-EditionProbe } `
    -SandboxProbe { Get-FeatureProbe -FeatureName 'Containers-DisposableClientVM' } `
    -HyperVProbe { Get-FeatureProbe -FeatureName 'Microsoft-Hyper-V-All' } `
    -VirtualizationProbe { Get-VirtualizationProbe }

foreach ($line in (Format-ReadinessReport -Assessment $assessment)) { [Console]::Out.WriteLine($line) }
