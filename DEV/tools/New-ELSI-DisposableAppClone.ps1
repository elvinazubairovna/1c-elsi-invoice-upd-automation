[CmdletBinding()]
param(
    [switch] $RunClone
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:Phase = 'P0_PREFLIGHT'
$script:LastCompletedPhase = 'NONE'
$script:CloneState = 'UNVERIFIED'
$script:SourceFinal = 'UNVERIFIED'
$script:ClonePaths = $null

function New-CloneException {
    param([Parameter(Mandatory)][ValidateSet('ACCESS_DENIED','SHARING_OR_LOCK','PATH_OR_TARGET','CAPACITY','UNSUPPORTED_ENTRY','SOURCE_CHANGED','PARITY_MISMATCH','RESOURCE_LIMIT','OTHER_IO','POWER_SHELL_RUNTIME','UNCLASSIFIED')][string] $Category)
    $exception = [IO.InvalidDataException]::new()
    $exception.Data['CloneCategory'] = $Category
    return $exception
}

function Get-SafeFailureCategory {
    param([Parameter(Mandatory)][object] $Failure)
    $exception = if ($Failure -is [System.Management.Automation.ErrorRecord]) { $Failure.Exception } else { $Failure }
    if ($exception -isnot [Exception]) { return 'UNCLASSIFIED' }
    $base = $exception.GetBaseException()
    if ($base.Data.Contains('CloneCategory')) {
        $allowed = @('ACCESS_DENIED','SHARING_OR_LOCK','PATH_OR_TARGET','CAPACITY','UNSUPPORTED_ENTRY','SOURCE_CHANGED','PARITY_MISMATCH','RESOURCE_LIMIT','OTHER_IO','POWER_SHELL_RUNTIME','UNCLASSIFIED')
        if ($allowed -contains [string]$base.Data['CloneCategory']) { return [string]$base.Data['CloneCategory'] }
        return 'UNCLASSIFIED'
    }
    $hr = [BitConverter]::ToUInt32([BitConverter]::GetBytes([int32]$base.HResult), 0)
    $code = [uint32]($hr -band [uint32]0xFFFF)
    switch ($base.GetType().FullName) {
        'System.UnauthorizedAccessException' { return 'ACCESS_DENIED' }
        'System.Security.SecurityException' { return 'ACCESS_DENIED' }
        'System.IO.FileNotFoundException' { return 'PATH_OR_TARGET' }
        'System.IO.DirectoryNotFoundException' { return 'PATH_OR_TARGET' }
        'System.ArgumentException' { return 'PATH_OR_TARGET' }
        'System.IO.PathTooLongException' { return 'PATH_OR_TARGET' }
        'System.NotSupportedException' { return 'UNSUPPORTED_ENTRY' }
        'System.IO.InvalidDataException' { return 'PARITY_MISMATCH' }
        'System.IO.IOException' {
            if ($code -in 32,33) { return 'SHARING_OR_LOCK' }
            if ($code -eq 5) { return 'ACCESS_DENIED' }
            if ($code -in 2,3,80,123,183,206) { return 'PATH_OR_TARGET' }
            return 'OTHER_IO'
        }
        'System.OutOfMemoryException' { return 'RESOURCE_LIMIT' }
        'System.PlatformNotSupportedException' { return 'POWER_SHELL_RUNTIME' }
        default { return 'UNCLASSIFIED' }
    }
}

function Test-PathWithin {
    param([Parameter(Mandatory)][string] $Candidate, [Parameter(Mandatory)][string] $Container)
    $root = [IO.Path]::GetFullPath($Container)
    $path = [IO.Path]::GetFullPath($Candidate)
    $rootPrefix = $root.TrimEnd([IO.Path]::DirectorySeparatorChar, [IO.Path]::AltDirectorySeparatorChar) + [IO.Path]::DirectorySeparatorChar
    return $path.Equals($root, [StringComparison]::OrdinalIgnoreCase) -or $path.StartsWith($rootPrefix, [StringComparison]::OrdinalIgnoreCase)
}

function Test-OrdinaryAttributes {
    param([Parameter(Mandatory)][IO.FileAttributes] $Attributes, [Parameter(Mandatory)][bool] $Directory)
    $supported = [IO.FileAttributes]::ReadOnly -bor [IO.FileAttributes]::Hidden -bor [IO.FileAttributes]::System -bor [IO.FileAttributes]::Directory -bor [IO.FileAttributes]::Archive -bor [IO.FileAttributes]::Normal -bor [IO.FileAttributes]::NotContentIndexed
    $actual = [uint32]$Attributes
    if (($actual -band [uint32]$supported) -ne $actual) { return $false }
    if ($Directory) { return (($Attributes -band [IO.FileAttributes]::Directory) -ne 0) }
    return (($Attributes -band [IO.FileAttributes]::Directory) -eq 0)
}

function Get-DirectItemState {
    param([Parameter(Mandatory)][string] $LiteralPath)
    try {
        $attributes = [IO.File]::GetAttributes($LiteralPath)
        if (($attributes -band ([IO.FileAttributes]::ReparsePoint -bor [IO.FileAttributes]::Device)) -ne 0) { return 'UNSUPPORTED' }
        if (($attributes -band [IO.FileAttributes]::Directory) -ne 0) { return 'DIRECTORY' }
        return 'FILE'
    }
    catch [IO.FileNotFoundException] { return 'ABSENT' }
    catch [IO.DirectoryNotFoundException] { return 'ABSENT' }
}

function Assert-NoNamedStreams {
    param([Parameter(Mandatory)][string] $LiteralPath)
    $streams = @(Get-Item -LiteralPath $LiteralPath -Stream * -ErrorAction Stop)
    if ($streams.Count -ne 1 -or $streams[0].Stream -notin @(':$DATA','$DATA','::$DATA')) {
        throw (New-CloneException 'UNSUPPORTED_ENTRY')
    }
}

function Get-TreeMetadata {
    param([Parameter(Mandatory)][string] $Root)
    $rootFull = [IO.Path]::GetFullPath($Root)
    $rootAttributes = [IO.File]::GetAttributes($rootFull)
    if (-not (Test-OrdinaryAttributes -Attributes $rootAttributes -Directory $true)) { throw (New-CloneException 'UNSUPPORTED_ENTRY') }
    $records = [Collections.Generic.List[object]]::new()
    $seen = [Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
    $records.Add([pscustomobject]@{ RelativePath=''; Kind='D'; Length=[long]0; LastWriteUtc=[IO.Directory]::GetLastWriteTimeUtc($rootFull) })
    $pending = [Collections.Generic.Stack[string]]::new()
    $pending.Push($rootFull)
    while ($pending.Count -gt 0) {
        $current = $pending.Pop()
        $currentAttributes = [IO.File]::GetAttributes($current)
        if (-not (Test-OrdinaryAttributes -Attributes $currentAttributes -Directory $true)) { throw (New-CloneException 'UNSUPPORTED_ENTRY') }
        foreach ($entry in [IO.Directory]::EnumerateFileSystemEntries($current)) {
            $full = [IO.Path]::GetFullPath($entry)
            if (-not (Test-PathWithin -Candidate $full -Container $rootFull) -or $full.Equals($rootFull, [StringComparison]::OrdinalIgnoreCase)) { throw (New-CloneException 'UNSUPPORTED_ENTRY') }
            $attributes = [IO.File]::GetAttributes($full)
            $relative = [IO.Path]::GetRelativePath($rootFull, $full).Replace('\','/')
            if ([IO.Path]::IsPathRooted($relative) -or $relative -eq '..' -or $relative.StartsWith('../',[StringComparison]::Ordinal) -or $relative.Contains(':')) { throw (New-CloneException 'UNSUPPORTED_ENTRY') }
            if (-not $seen.Add($relative)) { throw (New-CloneException 'UNSUPPORTED_ENTRY') }
            foreach ($segment in $relative.Split('/')) {
                if ($segment -match '[. ]$' -or $segment -match '[<>"|?*\x00-\x1F]') { throw (New-CloneException 'UNSUPPORTED_ENTRY') }
            }
            $isDirectory = (($attributes -band [IO.FileAttributes]::Directory) -ne 0)
            if (-not (Test-OrdinaryAttributes -Attributes $attributes -Directory $isDirectory)) { throw (New-CloneException 'UNSUPPORTED_ENTRY') }
            if ($isDirectory) {
                $records.Add([pscustomobject]@{ RelativePath=$relative; Kind='D'; Length=[long]0; LastWriteUtc=[IO.Directory]::GetLastWriteTimeUtc($full) })
                $pending.Push($full)
            }
            else {
                $info = [IO.FileInfo]::new($full)
                if ($info.Length -lt 0) { throw (New-CloneException 'UNSUPPORTED_ENTRY') }
                Assert-NoNamedStreams -LiteralPath $full
                $records.Add([pscustomobject]@{ RelativePath=$relative; Kind='F'; Length=[long]$info.Length; LastWriteUtc=$info.LastWriteTimeUtc })
            }
        }
    }
    $ordered = @($records | Sort-Object -Property RelativePath)
    $db = @($ordered | Where-Object { $_.Kind -eq 'F' -and $_.RelativePath -ceq '1Cv8.1CD' })
    if ($db.Count -ne 1 -or $db[0].Length -le 0) { throw (New-CloneException 'UNSUPPORTED_ENTRY') }
    return ,$ordered
}

function Test-MetadataParity {
    param([Parameter(Mandatory)][object[]] $Left, [Parameter(Mandatory)][object[]] $Right)
    if ($Left.Count -ne $Right.Count) { return $false }
    for ($i=0; $i -lt $Left.Count; $i++) {
        if ($Left[$i].RelativePath -cne $Right[$i].RelativePath -or $Left[$i].Kind -cne $Right[$i].Kind -or $Left[$i].Length -ne $Right[$i].Length -or $Left[$i].LastWriteUtc -ne $Right[$i].LastWriteUtc) { return $false }
    }
    return $true
}

function Get-TreeDigestInventory {
    param([Parameter(Mandatory)][string] $Root)
    $before = Get-TreeMetadata -Root $Root
    $result = [Collections.Generic.List[object]]::new()
    foreach ($record in $before) {
        if ($record.Kind -eq 'D') {
            $result.Add([pscustomobject]@{ RelativePath=$record.RelativePath; Kind='D'; Length=[long]0; Digest='' })
            continue
        }
        $full = [IO.Path]::GetFullPath([IO.Path]::Combine($Root, $record.RelativePath.Replace('/',[IO.Path]::DirectorySeparatorChar)))
        if (-not (Test-PathWithin -Candidate $full -Container $Root)) { throw (New-CloneException 'UNSUPPORTED_ENTRY') }
        $attrs = [IO.File]::GetAttributes($full)
        if (-not (Test-OrdinaryAttributes -Attributes $attrs -Directory $false)) { throw (New-CloneException 'UNSUPPORTED_ENTRY') }
        $info = [IO.FileInfo]::new($full)
        if ($info.Length -ne $record.Length -or $info.LastWriteTimeUtc -ne $record.LastWriteUtc) { throw (New-CloneException 'SOURCE_CHANGED') }
        Assert-NoNamedStreams -LiteralPath $full
        $stream = [IO.File]::Open($full,[IO.FileMode]::Open,[IO.FileAccess]::Read,[IO.FileShare]::None)
        try { $digest = [Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($stream)) }
        finally { $stream.Dispose() }
        $info.Refresh()
        $attrsAfter = [IO.File]::GetAttributes($full)
        if (-not (Test-OrdinaryAttributes -Attributes $attrsAfter -Directory $false) -or $info.Length -ne $record.Length -or $info.LastWriteTimeUtc -ne $record.LastWriteUtc) { throw (New-CloneException 'SOURCE_CHANGED') }
        Assert-NoNamedStreams -LiteralPath $full
        $result.Add([pscustomobject]@{ RelativePath=$record.RelativePath; Kind='F'; Length=[long]$info.Length; Digest=$digest })
    }
    if (-not (Test-MetadataParity -Left $before -Right (Get-TreeMetadata -Root $Root))) { throw (New-CloneException 'SOURCE_CHANGED') }
    return ,@($result | Sort-Object -Property RelativePath)
}

function Test-TreeParity {
    param([Parameter(Mandatory)][object[]] $Left, [Parameter(Mandatory)][object[]] $Right)
    if ($Left.Count -ne $Right.Count) { return $false }
    for ($i=0; $i -lt $Left.Count; $i++) {
        if ($Left[$i].RelativePath -cne $Right[$i].RelativePath -or $Left[$i].Kind -cne $Right[$i].Kind -or $Left[$i].Length -ne $Right[$i].Length -or $Left[$i].Digest -cne $Right[$i].Digest) { return $false }
    }
    return $true
}

function Initialize-ExclusiveDirectoryApi {
    if (-not ('ELSICloneDirectoryNative' -as [type])) {
        Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class ELSICloneDirectoryNative {
    [DllImport("kernel32.dll", CharSet=CharSet.Unicode, SetLastError=true)]
    public static extern bool CreateDirectory(string path, IntPtr securityAttributes);
}
'@ -ErrorAction Stop
    }
}

function New-DirectoryExclusive {
    param([Parameter(Mandatory)][string] $LiteralPath, [Parameter(Mandatory)][string] $Boundary)
    $full = [IO.Path]::GetFullPath($LiteralPath)
    if (-not (Test-PathWithin -Candidate $full -Container $Boundary)) { throw (New-CloneException 'UNSUPPORTED_ENTRY') }
    Initialize-ExclusiveDirectoryApi
    if (-not [ELSICloneDirectoryNative]::CreateDirectory($full,[IntPtr]::Zero)) {
        $win32 = [Runtime.InteropServices.Marshal]::GetLastWin32Error()
        if ($win32 -eq 183) { throw (New-CloneException 'PATH_OR_TARGET') }
        if ($win32 -eq 5) { throw (New-CloneException 'ACCESS_DENIED') }
        throw (New-CloneException 'OTHER_IO')
    }
}

function Copy-TreeNonOverwriting {
    param([Parameter(Mandatory)][string] $SourceRoot, [Parameter(Mandatory)][string] $DestinationRoot, [Parameter(Mandatory)][object[]] $Metadata)
    $directories = @($Metadata | Where-Object { $_.Kind -eq 'D' -and $_.RelativePath } | Sort-Object { $_.RelativePath.Split('/').Count })
    foreach ($directory in $directories) {
        $relative = $directory.RelativePath.Replace('/',[IO.Path]::DirectorySeparatorChar)
        $destination = [IO.Path]::GetFullPath([IO.Path]::Combine($DestinationRoot,$relative))
        if (-not (Test-PathWithin -Candidate $destination -Container $DestinationRoot)) { throw (New-CloneException 'UNSUPPORTED_ENTRY') }
        $parent = [IO.Path]::GetDirectoryName($destination)
        if ($parent -and (Get-DirectItemState -LiteralPath $parent) -ne 'DIRECTORY') { throw (New-CloneException 'UNSUPPORTED_ENTRY') }
        New-DirectoryExclusive -LiteralPath $destination -Boundary $DestinationRoot
    }
    foreach ($record in $Metadata) {
        if ($record.Kind -ne 'F') { continue }
        $relative = $record.RelativePath.Replace('/',[IO.Path]::DirectorySeparatorChar)
        $source = [IO.Path]::GetFullPath([IO.Path]::Combine($SourceRoot,$relative))
        $destination = [IO.Path]::GetFullPath([IO.Path]::Combine($DestinationRoot,$relative))
        if (-not (Test-PathWithin -Candidate $source -Container $SourceRoot) -or -not (Test-PathWithin -Candidate $destination -Container $DestinationRoot)) { throw (New-CloneException 'UNSUPPORTED_ENTRY') }
        $attrs = [IO.File]::GetAttributes($source)
        if (-not (Test-OrdinaryAttributes -Attributes $attrs -Directory $false)) { throw (New-CloneException 'UNSUPPORTED_ENTRY') }
        Assert-NoNamedStreams -LiteralPath $source
        $sourceInfo = [IO.FileInfo]::new($source)
        if ($sourceInfo.Length -ne $record.Length -or $sourceInfo.LastWriteTimeUtc -ne $record.LastWriteUtc) { throw (New-CloneException 'SOURCE_CHANGED') }
        $destinationParent = [IO.Path]::GetDirectoryName($destination)
        $parentAttributes = [IO.File]::GetAttributes($destinationParent)
        if (-not (Test-OrdinaryAttributes -Attributes $parentAttributes -Directory $true) -or (Get-DirectItemState -LiteralPath $destination) -ne 'ABSENT') { throw (New-CloneException 'UNSUPPORTED_ENTRY') }
        $input = [IO.File]::Open($source,[IO.FileMode]::Open,[IO.FileAccess]::Read,[IO.FileShare]::None)
        try {
            $output = [IO.File]::Open($destination,[IO.FileMode]::CreateNew,[IO.FileAccess]::Write,[IO.FileShare]::None)
            try { $input.CopyTo($output,1048576); $output.Flush($true) }
            finally { $output.Dispose() }
        }
        finally { $input.Dispose() }
        [IO.File]::SetLastWriteTimeUtc($destination,$record.LastWriteUtc)
    }
    foreach ($directory in @($directories | Sort-Object { $_.RelativePath.Split('/').Count } -Descending)) {
        $destination = [IO.Path]::GetFullPath([IO.Path]::Combine($DestinationRoot,$directory.RelativePath.Replace('/',[IO.Path]::DirectorySeparatorChar)))
        [IO.Directory]::SetLastWriteTimeUtc($destination,$directory.LastWriteUtc)
    }
    $rootRecord = @($Metadata | Where-Object { $_.Kind -eq 'D' -and -not $_.RelativePath })
    if ($rootRecord.Count -ne 1) { throw (New-CloneException 'UNSUPPORTED_ENTRY') }
    [IO.Directory]::SetLastWriteTimeUtc($DestinationRoot,$rootRecord[0].LastWriteUtc)
}

function Get-FixedClonePaths {
    if ($PSVersionTable.PSVersion.Major -lt 7) { throw (New-CloneException 'POWER_SHELL_RUNTIME') }
    if (-not [Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([Runtime.InteropServices.OSPlatform]::Windows)) { throw (New-CloneException 'POWER_SHELL_RUNTIME') }
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    $isElevated = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    $identity.Dispose()
    if ($isElevated) { throw (New-CloneException 'POWER_SHELL_RUNTIME') }
    $systemDrive = [Environment]::GetEnvironmentVariable('SystemDrive')
    if ([string]::IsNullOrWhiteSpace($systemDrive) -or $systemDrive -notmatch '^[A-Za-z]:$') { throw (New-CloneException 'PATH_OR_TARGET') }
    $volumeRoot = [IO.Path]::GetFullPath($systemDrive + [IO.Path]::DirectorySeparatorChar)
    $drive = [IO.DriveInfo]::new($volumeRoot)
    if (-not $drive.IsReady -or $drive.DriveType -ne [IO.DriveType]::Fixed -or [string]::IsNullOrWhiteSpace($drive.DriveFormat)) { throw (New-CloneException 'UNSUPPORTED_ENTRY') }
    $parent = [IO.Path]::GetFullPath([IO.Path]::Combine($volumeRoot,'1C_TEST'))
    $source = [IO.Path]::GetFullPath([IO.Path]::Combine($parent,'_RESTORE_CHECK_014'))
    $target = [IO.Path]::GetFullPath([IO.Path]::Combine($parent,'_APP_SMOKE_016'))
    if (-not $parent.Equals([IO.Path]::Combine($volumeRoot,'1C_TEST'),[StringComparison]::OrdinalIgnoreCase) -or
        -not $source.Equals([IO.Path]::Combine($parent,'_RESTORE_CHECK_014'),[StringComparison]::OrdinalIgnoreCase) -or
        -not $target.Equals([IO.Path]::Combine($parent,'_APP_SMOKE_016'),[StringComparison]::OrdinalIgnoreCase)) { throw (New-CloneException 'PATH_OR_TARGET') }
    $syncPattern = '(?i)(?:^|[\\/])(?:OneDrive(?: - [^\\/]+)?|Dropbox|Google Drive|iCloud Drive|SharePoint)(?:[\\/]|$)'
    if ($parent -match $syncPattern -or $source -match $syncPattern -or $target -match $syncPattern) { throw (New-CloneException 'PATH_OR_TARGET') }
    $repo = [IO.Path]::GetFullPath([IO.Path]::Combine($PSScriptRoot,'..','..'))
    foreach ($candidate in @($parent,$source,$target)) {
        if ((Test-PathWithin -Candidate $candidate -Container $repo) -or (Test-PathWithin -Candidate $repo -Container $candidate)) { throw (New-CloneException 'PATH_OR_TARGET') }
    }
    return [pscustomobject]@{ Root=$volumeRoot; Parent=$parent; Source=$source; Target=$target; Drive=$drive }
}

function Invoke-ClonePreflight {
    $paths = Get-FixedClonePaths
    foreach ($path in @($paths.Root,$paths.Parent,$paths.Source)) {
        $attrs = [IO.File]::GetAttributes($path)
        if (-not (Test-OrdinaryAttributes -Attributes $attrs -Directory $true)) { throw (New-CloneException 'UNSUPPORTED_ENTRY') }
    }
    $script:CloneState = 'UNVERIFIED'
    $targetState = Get-DirectItemState -LiteralPath $paths.Target
    if ($targetState -eq 'ABSENT') { $script:CloneState = 'ABSENT' }
    else { $script:CloneState = 'PREEXISTING_UNTOUCHED'; throw (New-CloneException 'PATH_OR_TARGET') }
    $metadata1 = Get-TreeMetadata -Root $paths.Source
    $metadata2 = Get-TreeMetadata -Root $paths.Source
    if (-not (Test-MetadataParity -Left $metadata1 -Right $metadata2)) { throw (New-CloneException 'SOURCE_CHANGED') }
    $database = [IO.Path]::Combine($paths.Source,'1Cv8.1CD')
    $dbHandle = [IO.File]::Open($database,[IO.FileMode]::Open,[IO.FileAccess]::Read,[IO.FileShare]::None)
    try { } finally { $dbHandle.Dispose() }
    $sourceBytes = [Numerics.BigInteger]::Zero
    foreach ($record in $metadata2) { if ($record.Kind -eq 'F') { $sourceBytes += [Numerics.BigInteger]$record.Length } }
    $reservePercent = [Numerics.BigInteger]([decimal]::Ceiling([decimal]$paths.Drive.TotalSize * [decimal]0.15))
    $reserve = [Numerics.BigInteger]::Max([Numerics.BigInteger]::Parse('1073741824'),$reservePercent)
    $available = [Numerics.BigInteger]$paths.Drive.AvailableFreeSpace
    if ($paths.Drive.TotalSize -le 0 -or $paths.Drive.AvailableFreeSpace -lt 0 -or ($sourceBytes + $reserve) -gt $available) { throw (New-CloneException 'CAPACITY') }
    return [pscustomobject]@{ Paths=$paths; Metadata=$metadata2 }
}

function Write-CloneFailure {
    param([Parameter(Mandatory)][object] $Failure)
    $category = Get-SafeFailureCategory -Failure $Failure
    [Console]::Out.WriteLine("CLONE_PHASE=$script:Phase")
    [Console]::Out.WriteLine("LAST_COMPLETED_PHASE=$script:LastCompletedPhase")
    [Console]::Out.WriteLine("FAILED_PHASE=$script:Phase")
    [Console]::Out.WriteLine("ERROR_CATEGORY=$category")
    [Console]::Out.WriteLine("CLONE_016=$script:CloneState")
    [Console]::Out.WriteLine("SOURCE_FINAL=$script:SourceFinal")
    [Console]::Out.WriteLine('APPLICATION_RESTORE=NOT_ATTEMPTED')
    [Console]::Out.WriteLine('OUTBOUND_ISOLATION=UNVERIFIED')
    [Console]::Out.WriteLine('PRODUCTION_ACCESS=NONE')
    [Console]::Out.WriteLine('STATUS=FAIL')
    exit 1
}

function Invoke-DisposableClone {
    try {
        $preflight = Invoke-ClonePreflight
        $script:ClonePaths = $preflight.Paths
        $script:LastCompletedPhase = 'P0_PREFLIGHT'

        $script:Phase = 'P1_SOURCE_BASELINE'
        $baseline = Get-TreeDigestInventory -Root $script:ClonePaths.Source
        if (-not (Test-MetadataParity -Left $preflight.Metadata -Right (Get-TreeMetadata -Root $script:ClonePaths.Source))) { throw (New-CloneException 'SOURCE_CHANGED') }
        $script:LastCompletedPhase = $script:Phase

        $script:Phase = 'P2_CREATE_CLONE_ROOT'
        $script:CloneState = 'UNVERIFIED'
        $targetState = Get-DirectItemState -LiteralPath $script:ClonePaths.Target
        if ($targetState -ne 'ABSENT') {
            if ($targetState -in @('FILE','DIRECTORY','UNSUPPORTED')) { $script:CloneState = 'PREEXISTING_UNTOUCHED' }
            throw (New-CloneException 'PATH_OR_TARGET')
        }
        $parentAttributes = [IO.File]::GetAttributes($script:ClonePaths.Parent)
        $sourceAttributes = [IO.File]::GetAttributes($script:ClonePaths.Source)
        if (-not (Test-OrdinaryAttributes -Attributes $parentAttributes -Directory $true) -or -not (Test-OrdinaryAttributes -Attributes $sourceAttributes -Directory $true) -or
            (Get-DirectItemState -LiteralPath $script:ClonePaths.Source) -ne 'DIRECTORY' -or (Get-DirectItemState -LiteralPath $script:ClonePaths.Parent) -ne 'DIRECTORY' -or
            -not (Test-MetadataParity -Left $preflight.Metadata -Right (Get-TreeMetadata -Root $script:ClonePaths.Source))) {
            throw (New-CloneException 'PATH_OR_TARGET')
        }
        New-DirectoryExclusive -LiteralPath $script:ClonePaths.Target -Boundary $script:ClonePaths.Parent
        $script:CloneState = 'CREATED_UNVERIFIED'
        $script:LastCompletedPhase = $script:Phase

        $script:Phase = 'P3_COPY_TREE'
        Copy-TreeNonOverwriting -SourceRoot $script:ClonePaths.Source -DestinationRoot $script:ClonePaths.Target -Metadata $preflight.Metadata
        $script:LastCompletedPhase = $script:Phase

        $script:Phase = 'P4_VERIFY_CLONE'
        $cloneInventory = Get-TreeDigestInventory -Root $script:ClonePaths.Target
        if (-not (Test-TreeParity -Left $baseline -Right $cloneInventory)) { throw (New-CloneException 'PARITY_MISMATCH') }
        $script:LastCompletedPhase = $script:Phase

        $script:Phase = 'P5_SOURCE_FINAL'
        $final = Get-TreeDigestInventory -Root $script:ClonePaths.Source
        $metadataFinal = Get-TreeMetadata -Root $script:ClonePaths.Source
        if (-not (Test-TreeParity -Left $baseline -Right $final) -or -not (Test-MetadataParity -Left $preflight.Metadata -Right $metadataFinal)) { throw (New-CloneException 'SOURCE_CHANGED') }
        $dbHandle = [IO.File]::Open([IO.Path]::Combine($script:ClonePaths.Source,'1Cv8.1CD'),[IO.FileMode]::Open,[IO.FileAccess]::Read,[IO.FileShare]::None)
        try { } finally { $dbHandle.Dispose() }
        $script:SourceFinal = 'PASS'
        $script:CloneState = 'PASS'
        $script:LastCompletedPhase = $script:Phase
        [Console]::Out.WriteLine('CLONE_PHASE=P5_SOURCE_FINAL')
        [Console]::Out.WriteLine('LAST_COMPLETED_PHASE=P5_SOURCE_FINAL')
        [Console]::Out.WriteLine('FAILED_PHASE=NONE')
        [Console]::Out.WriteLine('ERROR_CATEGORY=NONE')
        [Console]::Out.WriteLine('CLONE_016=PASS')
        [Console]::Out.WriteLine('FILE_LEVEL_CLONE_PARITY=PASS')
        [Console]::Out.WriteLine('SOURCE_FINAL=PASS')
        [Console]::Out.WriteLine('APPLICATION_RESTORE=NOT_ATTEMPTED')
        [Console]::Out.WriteLine('OUTBOUND_ISOLATION=UNVERIFIED')
        [Console]::Out.WriteLine('PRODUCTION_ACCESS=NONE')
        [Console]::Out.WriteLine('STATUS=SUCCESS')
    }
    catch { Write-CloneFailure -Failure $_ }
}

if (-not $RunClone) {
    [Console]::Out.WriteLine('USAGE=New-ELSI-DisposableAppClone.ps1 -RunClone')
    [Console]::Out.WriteLine('STATUS=READY_FOR_AUDIT')
    exit 0
}

Invoke-DisposableClone
