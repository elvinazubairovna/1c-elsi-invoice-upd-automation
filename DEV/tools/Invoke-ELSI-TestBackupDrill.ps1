#requires -Version 7.0
[CmdletBinding()]
param(
    [switch] $RunDrill
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

class DrillException : Exception {
    [string] $SafeCategory
    DrillException([string] $category) : base('controlled drill failure') {
        $this.SafeCategory = $category
    }
}

# OPERATOR-RUN OFFLINE FILE-LEVEL BACKUP / RESTORE-COPY PARITY DRILL ONLY.
# This does not prove that a copied database opens in 1C or is safe to modify.
# Administrator mode is neither needed nor approved. Never alter permissions.
# The script never launches 1C, uses a network, or reads database contents.

function Test-PathWithin {
    param([Parameter(Mandatory)][string] $Candidate, [Parameter(Mandatory)][string] $Container)
    $containerPath = [IO.Path]::GetFullPath($Container).TrimEnd([IO.Path]::DirectorySeparatorChar)
    $candidatePath = [IO.Path]::GetFullPath($Candidate).TrimEnd([IO.Path]::DirectorySeparatorChar)
    return $candidatePath.Equals($containerPath, [StringComparison]::OrdinalIgnoreCase) -or
        $candidatePath.StartsWith(($containerPath + [IO.Path]::DirectorySeparatorChar), [StringComparison]::OrdinalIgnoreCase)
}

function Get-SafeFailureCategory {
    param([Parameter(Mandatory)][object] $Failure)
    $exception = if ($Failure -is [System.Management.Automation.ErrorRecord]) { $Failure.Exception } else { $Failure }
    if ($exception -isnot [Exception]) { return 'UNCLASSIFIED' }
    $baseException = $exception.GetBaseException()
    $name = $baseException.GetType().FullName
    $hr = [BitConverter]::ToUInt32([BitConverter]::GetBytes([int32]$baseException.HResult), 0)
    $code = [uint32]($hr -band [uint32]0xFFFF)
    if ($baseException -is [DrillException]) {
        $allowed = @('ACCESS_DENIED','SHARING_OR_LOCK','PATH_OR_TARGET','CAPACITY','UNSUPPORTED_ENTRY','SOURCE_CHANGED','PARITY_MISMATCH','RESOURCE_LIMIT','OTHER_IO','POWER_SHELL_RUNTIME','UNCLASSIFIED')
        if ($allowed -contains $baseException.SafeCategory) { return $baseException.SafeCategory }
        return 'UNCLASSIFIED'
    }
    switch ($name) {
        'System.UnauthorizedAccessException' { return 'ACCESS_DENIED' }
        'System.Security.SecurityException' { return 'ACCESS_DENIED' }
        'System.IO.FileNotFoundException' { return 'PATH_OR_TARGET' }
        'System.IO.DirectoryNotFoundException' { return 'PATH_OR_TARGET' }
        'System.ArgumentException' { return 'PATH_OR_TARGET' }
        'System.IO.PathTooLongException' { return 'PATH_OR_TARGET' }
        'System.NotSupportedException' { return 'UNSUPPORTED_ENTRY' }
        'System.IO.InvalidDataException' { return 'PARITY_MISMATCH' }
        'System.IO.IOException' {
            if ($code -in 32, 33) { return 'SHARING_OR_LOCK' }
            if ($code -eq 5) { return 'ACCESS_DENIED' }
            if ($code -in 2, 3, 80, 123, 183, 206) { return 'PATH_OR_TARGET' }
            return 'OTHER_IO'
        }
        'System.Management.Automation.RuntimeException' { return 'POWER_SHELL_RUNTIME' }
        'System.Management.Automation.MethodInvocationException' { return 'POWER_SHELL_RUNTIME' }
        'System.Reflection.TargetInvocationException' { return 'POWER_SHELL_RUNTIME' }
        'System.PlatformNotSupportedException' { return 'POWER_SHELL_RUNTIME' }
        'System.OutOfMemoryException' { return 'RESOURCE_LIMIT' }
        default { return 'UNCLASSIFIED' }
    }
}

function New-DrillException {
    param([Parameter(Mandatory)][ValidateSet('ACCESS_DENIED','SHARING_OR_LOCK','PATH_OR_TARGET','CAPACITY','UNSUPPORTED_ENTRY','SOURCE_CHANGED','PARITY_MISMATCH','RESOURCE_LIMIT','OTHER_IO','POWER_SHELL_RUNTIME','UNCLASSIFIED')][string] $Category)
    return [DrillException]::new($Category)
}

function Test-OrdinaryEntryAttributes {
    param([Parameter(Mandatory)][IO.FileAttributes] $Attributes)
    return (($Attributes -band [IO.FileAttributes]::ReparsePoint) -eq 0) -and
        (($Attributes -band [IO.FileAttributes]::Device) -eq 0)
}

function Get-DirectItemState {
    param([Parameter(Mandatory)][string] $LiteralPath)
    try {
        $attributes = [IO.File]::GetAttributes($LiteralPath)
        if (-not (Test-OrdinaryEntryAttributes -Attributes $attributes)) { return 'UNSUPPORTED' }
        if (($attributes -band [IO.FileAttributes]::Directory) -ne 0) { return 'DIRECTORY' }
        return 'FILE'
    }
    catch [IO.FileNotFoundException] { return 'ABSENT' }
    catch [IO.DirectoryNotFoundException] { return 'ABSENT' }
    catch { throw }
}

function New-DirectoryNonOverwriting {
    param([Parameter(Mandatory)][string] $LiteralPath)
    $initialState = Get-DirectItemState -LiteralPath $LiteralPath
    if ($initialState -ne 'ABSENT') {
        if ($script:PhaseData.Backup -and $LiteralPath -ceq $script:PhaseData.Backup) { $script:BackupState = 'PREEXISTING_UNTOUCHED' }
        if ($script:PhaseData.Restore -and $LiteralPath -ceq $script:PhaseData.Restore) { $script:RestoreState = 'PREEXISTING_UNTOUCHED' }
        throw (New-DrillException -Category PATH_OR_TARGET)
    }
    try {
        $null = New-Item -ItemType Directory -Path $LiteralPath -ErrorAction Stop
    }
    catch {
        # This exact-item metadata check is only to classify a possible race; never use it to proceed.
        try {
            $afterFailure = Get-DirectItemState -LiteralPath $LiteralPath
            $state = if ($afterFailure -eq 'ABSENT') { 'ABSENT' } else { 'UNVERIFIED' }
            if ($script:PhaseData.Backup -and $LiteralPath -ceq $script:PhaseData.Backup) { $script:BackupState = $state }
            if ($script:PhaseData.Restore -and $LiteralPath -ceq $script:PhaseData.Restore) { $script:RestoreState = $state }
            if ($afterFailure -ne 'ABSENT') {
                throw (New-DrillException -Category PATH_OR_TARGET)
            }
        }
        catch { throw }
        throw
    }
    if ($script:PhaseData.Backup -and $LiteralPath -ceq $script:PhaseData.Backup) { $script:BackupState = 'CREATED_UNVERIFIED' }
    if ($script:PhaseData.Restore -and $LiteralPath -ceq $script:PhaseData.Restore) { $script:RestoreState = 'CREATED_UNVERIFIED' }
    if ((Get-DirectItemState -LiteralPath $LiteralPath) -ne 'DIRECTORY') {
        throw (New-DrillException -Category PATH_OR_TARGET)
    }
}

function Get-TreeInventory {
    param([Parameter(Mandatory)][string] $Root)
    $rootFull = [IO.Path]::GetFullPath($Root)
    $rootAttr = [IO.File]::GetAttributes($rootFull)
    if (-not (Test-OrdinaryEntryAttributes -Attributes $rootAttr) -or
        ($rootAttr -band [IO.FileAttributes]::Directory) -eq 0) {
        throw [NotSupportedException]::new('unsupported root entry')
    }
    $records = [Collections.Generic.List[object]]::new()
    $pending = [Collections.Generic.Stack[string]]::new()
    $pending.Push($rootFull)
    while ($pending.Count -gt 0) {
        $current = $pending.Pop()
        foreach ($entry in [IO.Directory]::EnumerateFileSystemEntries($current)) {
            $attributes = [IO.File]::GetAttributes($entry)
            if (-not (Test-OrdinaryEntryAttributes -Attributes $attributes)) {
                throw [NotSupportedException]::new('unsupported entry')
            }
            $relative = [IO.Path]::GetRelativePath($rootFull, $entry).Replace('\', '/')
            if ([IO.Path]::IsPathRooted($relative) -or $relative -eq '..' -or $relative.StartsWith('../', [StringComparison]::Ordinal)) {
                throw [NotSupportedException]::new('entry outside root')
            }
            if (($attributes -band [IO.FileAttributes]::Directory) -ne 0) {
                $records.Add([pscustomobject]@{ RelativePath=$relative; Kind='D'; Length=[long]0; LastWriteUtc=[IO.Directory]::GetLastWriteTimeUtc($entry) })
                $pending.Push($entry)
            }
            else {
                $item = [IO.FileInfo]::new($entry)
                $records.Add([pscustomobject]@{ RelativePath=$relative; Kind='F'; Length=$item.Length; LastWriteUtc=$item.LastWriteTimeUtc })
            }
        }
    }
    $ordered = @($records | Sort-Object -Property RelativePath)
    if (@($ordered | Where-Object { $_.Kind -eq 'F' -and $_.RelativePath -ceq '1Cv8.1CD' }).Count -ne 1) {
        throw [NotSupportedException]::new('expected database file missing or duplicated')
    }
    if (@($ordered | Where-Object { $_.Kind -eq 'F' -and $_.RelativePath -ceq '1Cv8.1CD' -and $_.Length -gt 0 }).Count -ne 1) {
        throw [NotSupportedException]::new('expected database file empty')
    }
    return ,$ordered
}

function Get-TreeDigestInventory {
    param([Parameter(Mandatory)][string] $Root)
    $metadata = Get-TreeInventory -Root $Root
    $result = [Collections.Generic.List[object]]::new()
    foreach ($record in $metadata) {
        if ($record.Kind -eq 'D') {
            $result.Add([pscustomobject]@{ RelativePath=$record.RelativePath; Kind='D'; Length=[long]0; Digest='' })
            continue
        }
        $full = [IO.Path]::Combine($Root, $record.RelativePath.Replace('/', [IO.Path]::DirectorySeparatorChar))
        $attrs = [IO.File]::GetAttributes($full)
        if (-not (Test-OrdinaryEntryAttributes -Attributes $attrs) -or ($attrs -band [IO.FileAttributes]::Directory) -ne 0) {
            throw [NotSupportedException]::new('file identity changed')
        }
        $info = [IO.FileInfo]::new($full)
        $lengthBefore = $info.Length
        $writeBefore = $info.LastWriteTimeUtc
        $stream = [IO.File]::Open($full, [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::Read)
        try { $digest = [Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($stream)) }
        finally { $stream.Dispose() }
        $info.Refresh()
        if ($info.Length -ne $lengthBefore -or $info.LastWriteTimeUtc -ne $writeBefore -or $lengthBefore -ne $record.Length -or $writeBefore -ne $record.LastWriteUtc) {
            throw (New-DrillException -Category SOURCE_CHANGED)
        }
        $result.Add([pscustomobject]@{ RelativePath=$record.RelativePath; Kind='F'; Length=$info.Length; Digest=$digest })
    }
    $after = Get-TreeInventory -Root $Root
    if (-not (Test-MetadataParity -Left $metadata -Right $after)) { throw (New-DrillException -Category SOURCE_CHANGED) }
    return ,@($result | Sort-Object -Property RelativePath)
}

function Test-TreeParity {
    param([Parameter(Mandatory)][object[]] $Left, [Parameter(Mandatory)][object[]] $Right)
    if ($Left.Count -ne $Right.Count) { return $false }
    for ($i=0; $i -lt $Left.Count; $i++) {
        if ($Left[$i].RelativePath -cne $Right[$i].RelativePath -or $Left[$i].Kind -cne $Right[$i].Kind -or
            $Left[$i].Length -ne $Right[$i].Length -or $Left[$i].Digest -cne $Right[$i].Digest) { return $false }
    }
    return $true
}

function Test-MetadataParity {
    param([Parameter(Mandatory)][object[]] $Left, [Parameter(Mandatory)][object[]] $Right)
    if ($Left.Count -ne $Right.Count) { return $false }
    for ($i=0; $i -lt $Left.Count; $i++) {
        if ($Left[$i].RelativePath -cne $Right[$i].RelativePath -or $Left[$i].Kind -cne $Right[$i].Kind -or
            $Left[$i].Length -ne $Right[$i].Length -or $Left[$i].LastWriteUtc -ne $Right[$i].LastWriteUtc) { return $false }
    }
    return $true
}

function Copy-TreeNonOverwriting {
    param([Parameter(Mandatory)][string] $SourceRoot, [Parameter(Mandatory)][string] $DestinationRoot)
    $sourceRecords = Get-TreeInventory -Root $SourceRoot
    $directories = [Collections.Generic.List[object]]::new()
    foreach ($record in $sourceRecords) {
        $relative = $record.RelativePath.Replace('/', [IO.Path]::DirectorySeparatorChar)
        $destination = [IO.Path]::Combine($DestinationRoot, $relative)
        if (-not (Test-PathWithin -Candidate $destination -Container $DestinationRoot)) {
            throw [NotSupportedException]::new('destination outside root')
        }
        if ($record.Kind -eq 'D') {
            $parent = [IO.Path]::GetDirectoryName($destination)
            if (-not (Test-PathWithin -Candidate $parent -Container $DestinationRoot)) {
                throw [NotSupportedException]::new('directory outside root')
            }
            if ((Get-DirectItemState -LiteralPath $destination) -ne 'ABSENT') {
                throw (New-DrillException -Category PATH_OR_TARGET)
            }
            New-DirectoryNonOverwriting -LiteralPath $destination
            $directories.Add($record)
            continue
        }
        $parentPath = [IO.Path]::GetDirectoryName($destination)
        if ((Get-DirectItemState -LiteralPath $parentPath) -ne 'DIRECTORY') {
            throw [NotSupportedException]::new('destination parent invalid')
        }
        if ((Get-DirectItemState -LiteralPath $destination) -ne 'ABSENT') {
            throw (New-DrillException -Category PATH_OR_TARGET)
        }
        $source = [IO.Path]::Combine($SourceRoot, $relative)
        $sourceAttributes = [IO.File]::GetAttributes($source)
        if (-not (Test-OrdinaryEntryAttributes -Attributes $sourceAttributes) -or
            ($sourceAttributes -band [IO.FileAttributes]::Directory) -ne 0) {
            throw [NotSupportedException]::new('source entry changed')
        }
        $input = [IO.File]::Open($source, [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::Read)
        try {
            $output = [IO.File]::Open($destination, [IO.FileMode]::CreateNew, [IO.FileAccess]::Write, [IO.FileShare]::None)
            try { $input.CopyTo($output, 1048576); $output.Flush($true) }
            finally { $output.Dispose() }
        }
        finally { $input.Dispose() }
        [IO.File]::SetLastWriteTimeUtc($destination, $record.LastWriteUtc)
    }
    foreach ($directory in @($directories | Sort-Object { $_.RelativePath.Split('/').Count } -Descending)) {
        $relative = $directory.RelativePath.Replace('/', [IO.Path]::DirectorySeparatorChar)
        $destination = [IO.Path]::Combine($DestinationRoot, $relative)
        [IO.Directory]::SetLastWriteTimeUtc($destination, $directory.LastWriteUtc)
    }
    [IO.Directory]::SetLastWriteTimeUtc($DestinationRoot, [IO.Directory]::GetLastWriteTimeUtc($SourceRoot))
}

function Write-DrillFailure {
    param([Parameter(Mandatory)][string] $Phase, [Parameter(Mandatory)][object] $Failure)
    $category = Get-SafeFailureCategory -Failure $Failure
    [Console]::Out.WriteLine("DRILL_PHASE=$Phase")
    [Console]::Out.WriteLine("LAST_COMPLETED_PHASE=$script:LastCompletedPhase")
    [Console]::Out.WriteLine("FAILED_PHASE=$Phase")
    [Console]::Out.WriteLine("ERROR_CATEGORY=$category")
    [Console]::Out.WriteLine("TEST_BOUNDARY=$script:TestBoundaryState")
    [Console]::Out.WriteLine("TEST_IDLE_CHECK=$script:TestIdleState")
    [Console]::Out.WriteLine("BACKUP_014=$script:BackupState")
    [Console]::Out.WriteLine("RESTORE_014=$script:RestoreState")
    [Console]::Out.WriteLine('FILE_LEVEL_BACKUP=UNVERIFIED')
    [Console]::Out.WriteLine('FILE_LEVEL_RESTORE=UNVERIFIED')
    [Console]::Out.WriteLine('SOURCE_FINAL=UNVERIFIED')
    [Console]::Out.WriteLine('APPLICATION_RESTORE=NOT_ATTEMPTED')
    [Console]::Out.WriteLine('INTEGRATIONS=UNVERIFIED')
    [Console]::Out.WriteLine('PRODUCTION_ACCESS=NONE')
    [Console]::Out.WriteLine('OPERATOR_RUN=ATTEMPTED')
    [Console]::Out.WriteLine('STATUS=FAIL')
    exit 1
}

function Invoke-DrillPhase {
    param([Parameter(Mandatory)][string] $Name, [Parameter(Mandatory)][scriptblock] $Action)
    try { & $Action; $script:LastCompletedPhase = $Name }
    catch { Write-DrillFailure -Phase $Name -Failure $_ }
}

function Invoke-OfflineDrill {
    $script:LastCompletedPhase = 'NONE'
    $script:PhaseData = @{}
    $script:BackupState = 'UNVERIFIED'
    $script:RestoreState = 'UNVERIFIED'
    $script:TestBoundaryState = 'UNVERIFIED'
    $script:TestIdleState = 'NOT_ATTEMPTED'
    Invoke-DrillPhase -Name 'P0_PREFLIGHT' -Action {
        if (-not [Runtime.InteropServices.RuntimeInformation]::IsOSPlatform([Runtime.InteropServices.OSPlatform]::Windows)) {
            throw (New-DrillException -Category POWER_SHELL_RUNTIME)
        }
        $systemDrive = [Environment]::GetEnvironmentVariable('SystemDrive')
        if ([string]::IsNullOrWhiteSpace($systemDrive) -or $systemDrive -notmatch '^[A-Za-z]:$') {
            throw (New-DrillException -Category PATH_OR_TARGET)
        }
        $volumeRoot = [IO.Path]::GetFullPath($systemDrive + [IO.Path]::DirectorySeparatorChar)
        $drive = [IO.DriveInfo]::new($volumeRoot)
        if (-not $drive.IsReady -or $drive.DriveType -ne [IO.DriveType]::Fixed -or [string]::IsNullOrWhiteSpace($drive.DriveFormat)) {
            throw (New-DrillException -Category UNSUPPORTED_ENTRY)
        }
        $parent = [IO.Path]::GetFullPath([IO.Path]::Combine($volumeRoot, '1C_TEST'))
        $source = [IO.Path]::GetFullPath([IO.Path]::Combine($parent, 'ELSI_TEST'))
        $backup = [IO.Path]::GetFullPath([IO.Path]::Combine($parent, '_BACKUP_014'))
        $restore = [IO.Path]::GetFullPath([IO.Path]::Combine($parent, '_RESTORE_CHECK_014'))
        if (-not $parent.Equals([IO.Path]::GetFullPath([IO.Path]::Combine($volumeRoot, '1C_TEST')), [StringComparison]::OrdinalIgnoreCase) -or
            -not $source.Equals([IO.Path]::GetFullPath([IO.Path]::Combine($parent, 'ELSI_TEST')), [StringComparison]::OrdinalIgnoreCase) -or
            -not $backup.Equals([IO.Path]::GetFullPath([IO.Path]::Combine($parent, '_BACKUP_014')), [StringComparison]::OrdinalIgnoreCase) -or
            -not $restore.Equals([IO.Path]::GetFullPath([IO.Path]::Combine($parent, '_RESTORE_CHECK_014')), [StringComparison]::OrdinalIgnoreCase)) {
            throw (New-DrillException -Category PATH_OR_TARGET)
        }
        $syncPattern = '(?i)(?:^|[\\/])(?:OneDrive(?: - [^\\/]+)?|Dropbox|Google Drive|iCloud Drive|SharePoint)(?:[\\/]|$)'
        $projectRoot = [IO.Path]::GetFullPath([IO.Path]::Combine($PSScriptRoot, '..', '..'))
        foreach ($path in @($parent, $source, $backup, $restore)) {
            if ($path -match $syncPattern -or (Test-PathWithin -Candidate $path -Container $projectRoot) -or
                (Test-PathWithin -Candidate $projectRoot -Container $path)) {
                throw (New-DrillException -Category PATH_OR_TARGET)
            }
        }
        foreach ($path in @($volumeRoot, $parent, $source)) {
            $attributes = [IO.File]::GetAttributes($path)
            if (-not (Test-OrdinaryEntryAttributes -Attributes $attributes) -or
                ($attributes -band [IO.FileAttributes]::Directory) -eq 0) {
                throw (New-DrillException -Category UNSUPPORTED_ENTRY)
            }
        }
        $backupInitial = Get-DirectItemState -LiteralPath $backup
        $restoreInitial = Get-DirectItemState -LiteralPath $restore
        if ($backupInitial -ne 'ABSENT') { $script:BackupState = 'PREEXISTING_UNTOUCHED' }
        else { $script:BackupState = 'ABSENT' }
        if ($restoreInitial -ne 'ABSENT') { $script:RestoreState = 'PREEXISTING_UNTOUCHED' }
        else { $script:RestoreState = 'ABSENT' }
        if ($backupInitial -ne 'ABSENT' -or $restoreInitial -ne 'ABSENT') {
            throw (New-DrillException -Category PATH_OR_TARGET)
        }
        $script:TestBoundaryState = 'PASS'
        $standardDb = [IO.Path]::Combine($source, '1Cv8.1CD')
        $dbAttributes = [IO.File]::GetAttributes($standardDb)
        if (-not (Test-OrdinaryEntryAttributes -Attributes $dbAttributes) -or
            ($dbAttributes -band [IO.FileAttributes]::Directory) -ne 0 -or ([IO.FileInfo]::new($standardDb)).Length -le 0) {
            throw (New-DrillException -Category UNSUPPORTED_ENTRY)
        }
        $metadata1 = Get-TreeInventory -Root $source
        $metadata2 = Get-TreeInventory -Root $source
        if (-not (Test-MetadataParity -Left $metadata1 -Right $metadata2)) { throw (New-DrillException -Category SOURCE_CHANGED) }
        $handle = [IO.File]::Open($standardDb, [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::None)
        try { } finally { $handle.Dispose() }
        $script:TestIdleState = 'PASS'
        $volume = [IO.DriveInfo]::new($volumeRoot)
        $required = [Math]::Max([long]1073741824, [long][Math]::Ceiling($volume.TotalSize * 0.15))
        $sourceLength = [long]0
        foreach ($entry in $metadata2) { if ($entry.Kind -eq 'F') { $sourceLength += [long]$entry.Length } }
        if ($volume.TotalSize -le 0 -or $volume.AvailableFreeSpace -lt 0 -or ($sourceLength * 2) -gt ($volume.AvailableFreeSpace - $required)) {
            throw (New-DrillException -Category CAPACITY)
        }
        $script:PhaseData.Source=$source; $script:PhaseData.Backup=$backup; $script:PhaseData.Restore=$restore
        $script:PhaseData.SourceMetadata=$metadata2
    }
    Invoke-DrillPhase -Name 'P1_SOURCE_BASELINE' -Action {
        $metadataNow = Get-TreeInventory -Root $script:PhaseData.Source
        if (-not (Test-MetadataParity -Left $script:PhaseData.SourceMetadata -Right $metadataNow)) {
            throw (New-DrillException -Category SOURCE_CHANGED)
        }
        $script:PhaseData.Baseline = Get-TreeDigestInventory -Root $script:PhaseData.Source
    }
    Invoke-DrillPhase -Name 'P2_CREATE_BACKUP_DIR' -Action {
        $script:BackupState = 'UNVERIFIED'
        $parentAttributes = [IO.File]::GetAttributes([IO.Path]::GetDirectoryName($script:PhaseData.Backup))
        if (-not (Test-OrdinaryEntryAttributes -Attributes $parentAttributes) -or ($parentAttributes -band [IO.FileAttributes]::Directory) -eq 0 -or
            (Get-DirectItemState -LiteralPath $script:PhaseData.Source) -ne 'DIRECTORY') { throw (New-DrillException -Category PATH_OR_TARGET) }
        if ((Get-DirectItemState -LiteralPath $script:PhaseData.Restore) -ne 'ABSENT') {
            $script:RestoreState = 'PREEXISTING_UNTOUCHED'
            throw (New-DrillException -Category PATH_OR_TARGET)
        }
        if ((Get-DirectItemState -LiteralPath $script:PhaseData.Backup) -ne 'ABSENT') {
            $script:BackupState = 'PREEXISTING_UNTOUCHED'
            throw (New-DrillException -Category PATH_OR_TARGET)
        }
        $script:BackupState = 'ABSENT'
        New-DirectoryNonOverwriting -LiteralPath $script:PhaseData.Backup
    }
    Invoke-DrillPhase -Name 'P3_COPY_SOURCE_TO_BACKUP' -Action {
        Copy-TreeNonOverwriting -SourceRoot $script:PhaseData.Source -DestinationRoot $script:PhaseData.Backup
    }
    Invoke-DrillPhase -Name 'P4_VERIFY_BACKUP' -Action {
        $backupInventory = Get-TreeDigestInventory -Root $script:PhaseData.Backup
        if (-not (Test-TreeParity -Left $script:PhaseData.Baseline -Right $backupInventory)) { throw [IO.InvalidDataException]::new('backup parity mismatch') }
        $script:PhaseData.BackupInventory=$backupInventory
        $script:BackupState = 'VERIFIED'
    }
    Invoke-DrillPhase -Name 'P5_CREATE_RESTORE_DIR' -Action {
        $script:RestoreState = 'UNVERIFIED'
        $parentAttributes = [IO.File]::GetAttributes([IO.Path]::GetDirectoryName($script:PhaseData.Restore))
        if (-not (Test-OrdinaryEntryAttributes -Attributes $parentAttributes) -or ($parentAttributes -band [IO.FileAttributes]::Directory) -eq 0 -or
            (Get-DirectItemState -LiteralPath $script:PhaseData.Backup) -ne 'DIRECTORY') { throw (New-DrillException -Category PATH_OR_TARGET) }
        if ((Get-DirectItemState -LiteralPath $script:PhaseData.Restore) -ne 'ABSENT') {
            $script:RestoreState = 'PREEXISTING_UNTOUCHED'
            throw (New-DrillException -Category PATH_OR_TARGET)
        }
        $script:RestoreState = 'ABSENT'
        New-DirectoryNonOverwriting -LiteralPath $script:PhaseData.Restore
    }
    Invoke-DrillPhase -Name 'P6_COPY_BACKUP_TO_RESTORE' -Action {
        Copy-TreeNonOverwriting -SourceRoot $script:PhaseData.Backup -DestinationRoot $script:PhaseData.Restore
    }
    Invoke-DrillPhase -Name 'P7_VERIFY_RESTORE' -Action {
        $restoreInventory = Get-TreeDigestInventory -Root $script:PhaseData.Restore
        if (-not (Test-TreeParity -Left $script:PhaseData.Baseline -Right $restoreInventory)) { throw [IO.InvalidDataException]::new('restore parity mismatch') }
        $script:RestoreState = 'VERIFIED'
    }
    Invoke-DrillPhase -Name 'P8_SOURCE_FINAL' -Action {
        $final = Get-TreeDigestInventory -Root $script:PhaseData.Source
        if (-not (Test-TreeParity -Left $script:PhaseData.Baseline -Right $final) -or
            -not (Test-MetadataParity -Left $script:PhaseData.SourceMetadata -Right (Get-TreeInventory -Root $script:PhaseData.Source))) {
            throw (New-DrillException -Category SOURCE_CHANGED)
        }
        $handle = [IO.File]::Open([IO.Path]::Combine($script:PhaseData.Source, '1Cv8.1CD'), [IO.FileMode]::Open, [IO.FileAccess]::Read, [IO.FileShare]::None)
        try { } finally { $handle.Dispose() }
    }
    $script:BackupState = 'PASS'
    $script:RestoreState = 'PASS'
    [Console]::Out.WriteLine('DRILL_PHASE=P8_SOURCE_FINAL')
    [Console]::Out.WriteLine('LAST_COMPLETED_PHASE=P8_SOURCE_FINAL')
    [Console]::Out.WriteLine('FAILED_PHASE=NONE')
    [Console]::Out.WriteLine('ERROR_CATEGORY=NONE')
    [Console]::Out.WriteLine('TEST_BOUNDARY=PASS')
    [Console]::Out.WriteLine('TEST_IDLE_CHECK=PASS')
    [Console]::Out.WriteLine('BACKUP_014=PASS')
    [Console]::Out.WriteLine('RESTORE_014=PASS')
    [Console]::Out.WriteLine('FILE_LEVEL_BACKUP=PASS')
    [Console]::Out.WriteLine('FILE_LEVEL_RESTORE=PASS')
    [Console]::Out.WriteLine('SOURCE_FINAL=PASS')
    [Console]::Out.WriteLine('APPLICATION_RESTORE=NOT_ATTEMPTED')
    [Console]::Out.WriteLine('INTEGRATIONS=UNVERIFIED')
    [Console]::Out.WriteLine('PRODUCTION_ACCESS=NONE')
    [Console]::Out.WriteLine('OPERATOR_RUN=ATTEMPTED')
    [Console]::Out.WriteLine('STATUS=SUCCESS')
}

if (-not $RunDrill) {
    [Console]::Out.WriteLine('USAGE=Invoke-ELSI-TestBackupDrill.ps1 -RunDrill')
    [Console]::Out.WriteLine('STATUS=READY_FOR_OPERATOR_AUDIT')
    exit 0
}

Invoke-OfflineDrill
