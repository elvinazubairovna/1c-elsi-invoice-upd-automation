#requires -Version 7.0
[CmdletBinding()]
param(
    [switch] $RunProbe
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# OPERATOR-RUN EMPTY-FOLDER DIAGNOSTIC ONLY.
# This is not a backup, restore, or evidence that a 1C database is safe to modify.
# Run only after independent review. Administrator mode is neither needed nor approved.
# If access is denied, stop and report the sanitized result; never change permissions.
# This script never opens 1C, reads database contents, logs, or performs network access.

function Test-PathWithin {
    param(
        [Parameter(Mandatory)][string] $Candidate,
        [Parameter(Mandatory)][string] $Container
    )

    $containerPath = [IO.Path]::GetFullPath($Container).TrimEnd([IO.Path]::DirectorySeparatorChar)
    $candidatePath = [IO.Path]::GetFullPath($Candidate).TrimEnd([IO.Path]::DirectorySeparatorChar)
    $prefix = $containerPath + [IO.Path]::DirectorySeparatorChar
    return $candidatePath.Equals($containerPath, [StringComparison]::OrdinalIgnoreCase) -or
        $candidatePath.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)
}

function Get-DirectItemInfo {
    param([Parameter(Mandatory)][string] $LiteralPath)

    try {
        $attributes = [IO.File]::GetAttributes($LiteralPath)
        return [pscustomobject]@{
            State = 'PRESENT'
            Attributes = $attributes
            Exception = $null
        }
    }
    catch [IO.FileNotFoundException] {
        return [pscustomobject]@{ State = 'ABSENT'; Attributes = $null; Exception = $null }
    }
    catch [IO.DirectoryNotFoundException] {
        return [pscustomobject]@{ State = 'ABSENT'; Attributes = $null; Exception = $null }
    }
    catch {
        return [pscustomobject]@{ State = 'UNVERIFIED'; Attributes = $null; Exception = $_.Exception }
    }
}

function Get-SafeFailureInfo {
    param([Parameter(Mandatory)][object] $Failure)

    $exception = if ($Failure -is [System.Management.Automation.ErrorRecord]) {
        $Failure.Exception
    }
    else {
        $Failure
    }
    if ($exception -isnot [Exception]) {
        return [pscustomobject]@{
            Category = 'UNCLASSIFIED'; ExceptionType = 'UNVERIFIED'; HResult = 'UNVERIFIED'
        }
    }

    # GetBaseException unwraps TargetInvocationException, MethodInvocationException,
    # and other common wrappers without rendering their messages or target paths.
    $baseException = $exception.GetBaseException()
    $typeName = $baseException.GetType().FullName
    $hResultValue = [BitConverter]::ToUInt32([BitConverter]::GetBytes([int32] $baseException.HResult), 0)
    $win32Code = [uint32] ($hResultValue -band [uint32] 0x0000FFFF)
    $safeTypes = @(
        'System.UnauthorizedAccessException',
        'System.Security.SecurityException',
        'System.IO.DirectoryNotFoundException',
        'System.IO.FileNotFoundException',
        'System.IO.PathTooLongException',
        'System.ArgumentException',
        'System.IO.IOException',
        'System.Management.Automation.RuntimeException',
        'System.Management.Automation.MethodInvocationException',
        'System.Reflection.TargetInvocationException',
        'System.PlatformNotSupportedException'
    )

    $category = switch ($typeName) {
        'System.UnauthorizedAccessException' { 'ACCESS_DENIED'; break }
        'System.Security.SecurityException' { 'SANDBOX_OR_POLICY'; break }
        'System.IO.DirectoryNotFoundException' { 'PATH_OR_TARGET'; break }
        'System.IO.FileNotFoundException' { 'PATH_OR_TARGET'; break }
        'System.IO.PathTooLongException' { 'PATH_OR_TARGET'; break }
        'System.ArgumentException' { 'PATH_OR_TARGET'; break }
        'System.PlatformNotSupportedException' { 'POWER_SHELL_RUNTIME'; break }
        'System.Management.Automation.RuntimeException' { 'POWER_SHELL_RUNTIME'; break }
        'System.Management.Automation.MethodInvocationException' { 'POWER_SHELL_RUNTIME'; break }
        'System.Reflection.TargetInvocationException' { 'POWER_SHELL_RUNTIME'; break }
        'System.IO.IOException' {
            if ($win32Code -eq 5) { 'ACCESS_DENIED' }
            elseif ($win32Code -in 2, 3, 80, 123, 183, 206) { 'PATH_OR_TARGET' }
            else { 'OTHER_IO' }
            break
        }
        default { 'UNCLASSIFIED' }
    }

    $printType = if ($safeTypes -contains $typeName) { $typeName } else { 'UNVERIFIED' }
    $printHResult = if ($safeTypes -contains $typeName) {
        '0x{0:X8}' -f $hResultValue
    }
    else {
        'UNVERIFIED'
    }

    return [pscustomobject]@{
        Category = $category
        ExceptionType = $printType
        HResult = $printHResult
    }
}

function Write-ProbeOutcome {
    param(
        [Parameter(Mandatory)][string] $Phase,
        [Parameter(Mandatory)][string] $Precheck,
        [Parameter(Mandatory)][string] $Result,
        [Parameter(Mandatory)][string] $Category,
        [Parameter(Mandatory)][string] $ExceptionType,
        [Parameter(Mandatory)][string] $HResult
    )

    [Console]::Out.WriteLine("PROBE_PHASE=$Phase")
    [Console]::Out.WriteLine("PROBE_PRECHECK=$Precheck")
    [Console]::Out.WriteLine("PROBE_RESULT=$Result")
    [Console]::Out.WriteLine("ERROR_CATEGORY=$Category")
    [Console]::Out.WriteLine("EXCEPTION_TYPE=$ExceptionType")
    [Console]::Out.WriteLine("HRESULT=$HResult")
    [Console]::Out.WriteLine('PRODUCTION_ACCESS=NONE')
}

function Stop-Probe {
    param(
        [Parameter(Mandatory)][string] $Phase,
        [Parameter(Mandatory)][string] $Result,
        [Parameter(Mandatory)][string] $Category,
        [string] $ExceptionType = 'UNVERIFIED',
        [string] $HResult = 'UNVERIFIED'
    )

    Write-ProbeOutcome -Phase $Phase -Precheck 'BLOCKED' -Result $Result `
        -Category $Category -ExceptionType $ExceptionType -HResult $HResult
    exit 1
}

$phase = 'READ_ONLY_BOUNDARY'
if (-not [Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([Runtime.InteropServices.OSPlatform]::Windows)) {
    Stop-Probe -Phase $phase -Result 'UNVERIFIED' -Category 'POWER_SHELL_RUNTIME'
}

try {
    $systemDrive = [Environment]::GetEnvironmentVariable('SystemDrive')
    if ([string]::IsNullOrWhiteSpace($systemDrive) -or $systemDrive -notmatch '^[A-Za-z]:$') {
        Stop-Probe -Phase $phase -Result 'UNVERIFIED' -Category 'PATH_OR_TARGET'
    }

    $systemRoot = [IO.Path]::GetFullPath($systemDrive + [IO.Path]::DirectorySeparatorChar)
    $driveInfo = [IO.DriveInfo]::new($systemRoot)
    if (-not $driveInfo.IsReady -or $driveInfo.DriveType -ne [IO.DriveType]::Fixed -or
        [string]::IsNullOrWhiteSpace($driveInfo.DriveFormat)) {
        Stop-Probe -Phase $phase -Result 'UNVERIFIED' -Category 'PATH_OR_TARGET'
    }

    $parentPath = [IO.Path]::GetFullPath([IO.Path]::Combine($systemRoot, '1C_TEST'))
    $sourcePath = [IO.Path]::GetFullPath([IO.Path]::Combine($parentPath, 'ELSI_TEST'))
    $probePath = [IO.Path]::GetFullPath([IO.Path]::Combine($parentPath, '_DIR_PROBE_013'))

    $expectedParent = [IO.Path]::GetFullPath([IO.Path]::Combine($systemRoot, '1C_TEST'))
    $expectedSource = [IO.Path]::GetFullPath([IO.Path]::Combine($expectedParent, 'ELSI_TEST'))
    $expectedProbe = [IO.Path]::GetFullPath([IO.Path]::Combine($expectedParent, '_DIR_PROBE_013'))
    if (-not $parentPath.Equals($expectedParent, [StringComparison]::OrdinalIgnoreCase) -or
        -not $sourcePath.Equals($expectedSource, [StringComparison]::OrdinalIgnoreCase) -or
        -not $probePath.Equals($expectedProbe, [StringComparison]::OrdinalIgnoreCase)) {
        Stop-Probe -Phase $phase -Result 'UNVERIFIED' -Category 'PATH_OR_TARGET'
    }

    $syncPattern = '(?i)(?:^|[\\/])(?:OneDrive(?: - [^\\/]+)?|Dropbox|Google Drive|iCloud Drive|SharePoint)(?:[\\/]|$)'
    if ($parentPath -match $syncPattern) {
        Stop-Probe -Phase $phase -Result 'UNVERIFIED' -Category 'PATH_OR_TARGET'
    }

    # The script is kept under DEV/tools; derive its containing project root lexically
    # only, without invoking Git or reading anything outside the fixed runtime boundary.
    $scriptProjectRoot = [IO.Path]::GetFullPath([IO.Path]::Combine($PSScriptRoot, '..', '..'))
    if ((Test-PathWithin -Candidate $parentPath -Container $scriptProjectRoot) -or
        (Test-PathWithin -Candidate $scriptProjectRoot -Container $parentPath)) {
        Stop-Probe -Phase $phase -Result 'UNVERIFIED' -Category 'PATH_OR_TARGET'
    }

    $rootInfo = Get-DirectItemInfo -LiteralPath $systemRoot
    $parentInfo = Get-DirectItemInfo -LiteralPath $parentPath
    $sourceInfo = Get-DirectItemInfo -LiteralPath $sourcePath
    foreach ($item in @($rootInfo, $parentInfo, $sourceInfo)) {
        if ($item.State -ne 'PRESENT' -or
            ($item.Attributes -band [IO.FileAttributes]::Directory) -eq 0 -or
            ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
            if ($item.Exception) {
                $failure = Get-SafeFailureInfo -Failure $item.Exception
                Stop-Probe -Phase $phase -Result 'UNVERIFIED' -Category $failure.Category `
                    -ExceptionType $failure.ExceptionType -HResult $failure.HResult
            }
            Stop-Probe -Phase $phase -Result 'UNVERIFIED' -Category 'PATH_OR_TARGET'
        }
    }

    $probeInfo = Get-DirectItemInfo -LiteralPath $probePath
    if ($probeInfo.State -eq 'UNVERIFIED') {
        $failure = Get-SafeFailureInfo -Failure $probeInfo.Exception
        Stop-Probe -Phase 'PROBE_PRECHECK' -Result 'UNVERIFIED' -Category $failure.Category `
            -ExceptionType $failure.ExceptionType -HResult $failure.HResult
    }
    if ($probeInfo.State -eq 'PRESENT') {
        Stop-Probe -Phase 'PROBE_PRECHECK' -Result 'ALREADY_EXISTS' -Category 'PATH_OR_TARGET'
    }

    if (-not $RunProbe) {
        Write-ProbeOutcome -Phase 'READ_ONLY_CHECKS' -Precheck 'PASS' -Result 'ABSENT' `
            -Category 'NONE' -ExceptionType 'UNVERIFIED' -HResult 'UNVERIFIED'
        [Console]::Out.WriteLine('OPERATOR_PROBE=NOT_ATTEMPTED')
        exit 0
    }

    # Repeat the exact target check immediately before the sole create call.
    $phase = 'PROBE_PRECHECK'
    $parentInfo = Get-DirectItemInfo -LiteralPath $parentPath
    $sourceInfo = Get-DirectItemInfo -LiteralPath $sourcePath
    foreach ($item in @($parentInfo, $sourceInfo)) {
        if ($item.State -ne 'PRESENT' -or
            ($item.Attributes -band [IO.FileAttributes]::Directory) -eq 0 -or
            ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
            if ($item.Exception) {
                $failure = Get-SafeFailureInfo -Failure $item.Exception
                Stop-Probe -Phase $phase -Result 'UNVERIFIED' -Category $failure.Category `
                    -ExceptionType $failure.ExceptionType -HResult $failure.HResult
            }
            Stop-Probe -Phase $phase -Result 'UNVERIFIED' -Category 'PATH_OR_TARGET'
        }
    }
    $probeInfo = Get-DirectItemInfo -LiteralPath $probePath
    if ($probeInfo.State -ne 'ABSENT') {
        if ($probeInfo.Exception) {
            $failure = Get-SafeFailureInfo -Failure $probeInfo.Exception
            Stop-Probe -Phase $phase -Result 'UNVERIFIED' -Category $failure.Category `
                -ExceptionType $failure.ExceptionType -HResult $failure.HResult
        }
        Stop-Probe -Phase $phase -Result 'ALREADY_EXISTS' -Category 'PATH_OR_TARGET'
    }

    $phase = 'DIRECTORY_CREATE'
    try {
        $null = [IO.Directory]::CreateDirectory($probePath)
    }
    catch {
        $failure = Get-SafeFailureInfo -Failure $_
        $postFailureInfo = Get-DirectItemInfo -LiteralPath $probePath
        $postFailureResult = if ($postFailureInfo.State -eq 'ABSENT') { 'ABSENT' } else { 'UNVERIFIED' }
        Write-ProbeOutcome -Phase $phase -Precheck 'PASS' -Result $postFailureResult `
            -Category $failure.Category -ExceptionType $failure.ExceptionType -HResult $failure.HResult
        exit 1
    }

    $phase = 'PROBE_VERIFY'
    $verificationInfo = Get-DirectItemInfo -LiteralPath $probePath
    if ($verificationInfo.State -eq 'PRESENT' -and
        ($verificationInfo.Attributes -band [IO.FileAttributes]::Directory) -ne 0 -and
        ($verificationInfo.Attributes -band [IO.FileAttributes]::ReparsePoint) -eq 0) {
        # The single create API creates an empty directory; this script writes no children.
        Write-ProbeOutcome -Phase $phase -Precheck 'PASS' -Result 'CREATED_EMPTY_DIRECTORY' `
            -Category 'NONE' -ExceptionType 'UNVERIFIED' -HResult 'UNVERIFIED'
        exit 0
    }

    if ($verificationInfo.Exception) {
        $failure = Get-SafeFailureInfo -Failure $verificationInfo.Exception
        Stop-Probe -Phase $phase -Result 'UNVERIFIED' -Category $failure.Category `
            -ExceptionType $failure.ExceptionType -HResult $failure.HResult
    }
    Stop-Probe -Phase $phase -Result 'UNVERIFIED' -Category 'PATH_OR_TARGET'
}
catch {
    # Classify structured exception data; never print a message, stack, or path.
    $failure = Get-SafeFailureInfo -Failure $_
    Stop-Probe -Phase $phase -Result 'UNVERIFIED' -Category $failure.Category `
        -ExceptionType $failure.ExceptionType -HResult $failure.HResult
}
