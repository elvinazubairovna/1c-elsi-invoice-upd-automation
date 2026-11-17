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

function ConvertTo-FeatureQueryStatus {
    param([AllowNull()][object] $Result, [Parameter(Mandatory)][bool] $QuerySucceeded)
    if (-not $QuerySucceeded) { return 'UNVERIFIED' }
    if ($null -eq $Result) { return 'NOT_AVAILABLE' }
    return ConvertTo-FeatureStatus -Value $Result.State
}

function ConvertTo-VirtualizationStatus {
    param([AllowNull()][object[]] $Flags)
    if ($null -eq $Flags -or $Flags.Count -eq 0) { return 'UNVERIFIED' }
    foreach ($flag in $Flags) { if ($flag -isnot [bool]) { return 'UNVERIFIED' } }
    if (@($Flags | Where-Object { $_ -eq $false }).Count -gt 0) { return 'UNSUPPORTED' }
    return 'SUPPORTED'
}

function Get-ExactFeatureStatus {
    param([Parameter(Mandatory)][string] $FeatureName)
    try {
        $feature = Get-WindowsOptionalFeature -Online -FeatureName $FeatureName -ErrorAction Stop -WarningAction SilentlyContinue -InformationAction SilentlyContinue
        return ConvertTo-FeatureQueryStatus -Result $feature -QuerySucceeded $true
    }
    catch { return ConvertTo-FeatureQueryStatus -Result $null -QuerySucceeded $false }
}

$editionClass = 'UNVERIFIED'
$sandboxFeature = 'UNVERIFIED'
$hyperVFeature = 'UNVERIFIED'
$virtualizationSupport = 'UNVERIFIED'
$reportStatus = 'UNVERIFIED'

try {
    $isWindows = [Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([Runtime.InteropServices.OSPlatform]::Windows)
    if ($isWindows) {
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
        try {
            $principal = [Security.Principal.WindowsPrincipal]::new($identity)
            $isElevated = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        }
        finally { $identity.Dispose() }

        if (-not $isElevated) {
            try {
                $key = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey('SOFTWARE\Microsoft\Windows NT\CurrentVersion', $false)
                if ($null -ne $key) {
                    try {
                        $editionId = $key.GetValue('EditionID', $null, [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
                        $editionClass = ConvertTo-EditionClass -Value $editionId
                    }
                    finally { $key.Dispose() }
                }
            }
            catch { $editionClass = 'UNVERIFIED' }

            $featureCommand = Get-Command -Name 'Get-WindowsOptionalFeature' -CommandType Cmdlet -ErrorAction SilentlyContinue
            if ($null -eq $featureCommand) {
                $sandboxFeature = 'UNVERIFIED'
                $hyperVFeature = 'UNVERIFIED'
            }
            else {
                $sandboxFeature = Get-ExactFeatureStatus -FeatureName 'Containers-DisposableClientVM'
                $hyperVFeature = Get-ExactFeatureStatus -FeatureName 'Microsoft-Hyper-V-All'
            }

            try {
                $processors = @(Get-CimInstance -ClassName 'Win32_Processor' -Property @('VMMonitorModeExtensions','SecondLevelAddressTranslationExtensions','VirtualizationFirmwareEnabled') -ErrorAction Stop -WarningAction SilentlyContinue -InformationAction SilentlyContinue)
                if ($processors.Count -gt 0) {
                    $allFlags = [Collections.Generic.List[object]]::new()
                    foreach ($processor in $processors) {
                        $allFlags.Add($processor.VMMonitorModeExtensions)
                        $allFlags.Add($processor.SecondLevelAddressTranslationExtensions)
                        $allFlags.Add($processor.VirtualizationFirmwareEnabled)
                    }
                    $virtualizationSupport = ConvertTo-VirtualizationStatus -Flags @($allFlags.ToArray())
                }
            }
            catch { $virtualizationSupport = 'UNVERIFIED' }
            $reportStatus = 'READ_ONLY_REPORT'
        }
    }
}
catch { $reportStatus = 'UNVERIFIED' }

[Console]::Out.WriteLine("OS_EDITION_CLASS=$editionClass")
[Console]::Out.WriteLine("WINDOWS_SANDBOX_FEATURE=$sandboxFeature")
[Console]::Out.WriteLine("HYPERV_FEATURE=$hyperVFeature")
[Console]::Out.WriteLine("VIRTUALIZATION_SUPPORT=$virtualizationSupport")
[Console]::Out.WriteLine('HOST_ISOLATION=NOT_CONFIGURED_OR_UNVERIFIED')
[Console]::Out.WriteLine('OUTBOUND_ISOLATION=UNVERIFIED')
[Console]::Out.WriteLine('APPLICATION_RESTORE=NOT_ATTEMPTED')
[Console]::Out.WriteLine('PRODUCTION_ACCESS=NONE')
[Console]::Out.WriteLine("STATUS=$reportStatus")
