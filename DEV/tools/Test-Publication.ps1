[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('Index', 'Tracked', 'Outgoing')]
    [string] $Mode
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:Findings = 0
$script:Root = $null
$script:Utf8Strict = [System.Text.UTF8Encoding]::new($false, $true)

function Invoke-GitBytes {
    param(
        [Parameter(Mandatory = $true)][string[]] $Arguments,
        [byte[]] $InputBytes = @(),
        [switch] $AllowFailure
    )

    $start = [System.Diagnostics.ProcessStartInfo]::new()
    $start.FileName = 'git'
    $start.WorkingDirectory = if ($script:Root) { $script:Root } else { (Get-Location).Path }
    $start.UseShellExecute = $false
    $start.RedirectStandardOutput = $true
    $start.RedirectStandardError = $true
    $start.RedirectStandardInput = $true
    $start.StandardOutputEncoding = [System.Text.Encoding]::UTF8
    $start.StandardErrorEncoding = [System.Text.Encoding]::UTF8
    foreach ($argument in $Arguments) { [void] $start.ArgumentList.Add($argument) }

    try {
        $process = [System.Diagnostics.Process]::new()
        $process.StartInfo = $start
        if (-not $process.Start()) { throw 'Git process did not start.' }
        $out = [System.IO.MemoryStream]::new()
        $err = [System.IO.MemoryStream]::new()
        $outTask = $process.StandardOutput.BaseStream.CopyToAsync($out)
        $errTask = $process.StandardError.BaseStream.CopyToAsync($err)
        if ($InputBytes.Length -gt 0) {
            $process.StandardInput.BaseStream.Write($InputBytes, 0, $InputBytes.Length)
            $process.StandardInput.BaseStream.Flush()
        }
        $process.StandardInput.Close()
        $process.WaitForExit()
        [System.Threading.Tasks.Task]::WaitAll(@($outTask, $errTask))
        $code = $process.ExitCode
        $stdout = $out.ToArray()
        $stderr = [System.Text.Encoding]::UTF8.GetString($err.ToArray())
        $out.Dispose(); $err.Dispose(); $process.Dispose()
        if (($code -ne 0) -and (-not $AllowFailure)) {
            throw "git-command-$($Arguments[0])-exit-$code"
        }
        return [pscustomobject]@{ ExitCode = $code; Bytes = $stdout; Text = $script:Utf8Strict.GetString($stdout); Error = $stderr }
    }
    catch {
        if ($_.Exception.Message -match '^git-command-[a-z-]+-exit-[0-9]+$') { throw }
        throw 'git-operation-failed-safely'
    }
}

function Write-Failure {
    param([string] $Rule, [string] $Path = '')
    $safePath = $Path
    if ($safePath -match '\d{5,}|@|\+\d{6,}|(?i:passport|phone|inn|taxpayer)|\p{IsCyrillic}') { $safePath = '[masked-path]' }
    if ($safePath) { [Console]::Error.WriteLine("FAIL rule=$Rule path=$safePath count=1") }
    else { [Console]::Error.WriteLine("FAIL rule=$Rule count=1") }
    $script:Findings++
}

function Test-ValidInn {
    param([string] $Digits)
    $numbers = @($Digits.ToCharArray() | ForEach-Object { [int]::Parse([string]$_, [Globalization.CultureInfo]::InvariantCulture) })
    if ($numbers.Count -eq 10) {
        $weights = @(2,4,10,3,5,9,4,6,8)
        $sum = 0
        for ($i = 0; $i -lt 9; $i++) { $sum += $numbers[$i] * $weights[$i] }
        return (($sum % 11) % 10) -eq $numbers[9]
    }
    if ($numbers.Count -eq 12) {
        $weights11 = @(7,2,4,10,3,5,9,4,6,8)
        $weights12 = @(3,7,2,4,10,3,5,9,4,6,8)
        $sum11 = 0; $sum12 = 0
        for ($i = 0; $i -lt 10; $i++) { $sum11 += $numbers[$i] * $weights11[$i] }
        for ($i = 0; $i -lt 11; $i++) { $sum12 += $numbers[$i] * $weights12[$i] }
        return (((($sum11 % 11) % 10) -eq $numbers[10]) -and (((($sum12 % 11) % 10) -eq $numbers[11])))
    }
    return $false
}

function Get-EntriesForMode {
    param([string] $SelectedMode, [string] $Commit = '')
    if ($SelectedMode -eq 'Index') {
        $listing = Invoke-GitBytes -Arguments @('ls-files', '--stage', '-z')
        $records = @($listing.Text.Split([char]0, [StringSplitOptions]::RemoveEmptyEntries))
        $result = [System.Collections.Generic.List[object]]::new()
        foreach ($record in $records) {
            $tab = $record.IndexOf("`t")
            if ($tab -lt 0) { throw 'Index record has no path separator.' }
            $meta = $record.Substring(0, $tab)
            $path = $record.Substring($tab + 1)
            if ($meta -notmatch '^(?<mode>[0-7]{6}) (?<sha>[0-9a-f]{40,64}) (?<stage>[0-3])$') { throw 'Index record is ambiguous.' }
            if ($Matches.stage -ne '0') { throw 'Unmerged index entries are ambiguous.' }
            $result.Add([pscustomobject]@{ Path = $path; Sha = $Matches.sha; Mode = $Matches.mode; Type = 'blob' })
        }
        return $result.ToArray()
    }

    $tree = Invoke-GitBytes -Arguments @('ls-tree', '-r', '-z', '--full-tree', $Commit)
    $records = @($tree.Text.Split([char]0, [StringSplitOptions]::RemoveEmptyEntries))
    $result = [System.Collections.Generic.List[object]]::new()
    foreach ($record in $records) {
        $tab = $record.IndexOf("`t")
        if ($tab -lt 0) { throw 'Tree record has no path separator.' }
        $meta = $record.Substring(0, $tab)
        $path = $record.Substring($tab + 1)
        if ($meta -notmatch '^(?<mode>[0-7]{6}) (?<type>blob|commit|tree) (?<sha>[0-9a-f]{40,64})$') { throw 'Tree record is ambiguous.' }
        $result.Add([pscustomobject]@{ Path = $path; Sha = $Matches.sha; Mode = $Matches.mode; Type = $Matches.type })
    }
    return $result.ToArray()
}

function Test-PathPolicy {
    param([object] $Entry)
    $path = $Entry.Path.Replace('\', '/')
    if ($path.Contains("`t") -or $path.Contains("`r") -or $path.Contains("`n")) {
        Write-Failure -Rule 'ambiguous-path'
        return
    }
    if ($Entry.Type -ne 'blob' -or $Entry.Mode -eq '120000') {
        Write-Failure -Rule 'unsupported-object' -Path $path
        return
    }
    $extension = [System.IO.Path]::GetExtension($path).ToLowerInvariant()
    $blockedExtensions = @('.pdf','.xls','.xlsx','.doc','.docx','.csv','.dt','.1cd','.bak','.backup','.key','.pem','.pfx','.p12','.zip','.rar','.7z')
    if ($blockedExtensions -contains $extension) {
        Write-Failure -Rule 'blocked-extension' -Path $path
        return
    }
    $segments = @($path.Split('/'))
    $sensitiveSegments = @($segments | Where-Object { $_ -match '^(?i:private|secrets|backups|exports)$' })
    if ($sensitiveSegments.Count -gt 0 -or
        $path -match '(?i)(^|/)data/real(/|$)') {
        Write-Failure -Rule 'blocked-directory' -Path $path
        return
    }
}

function Test-ContentPolicy {
    param([object] $Entry)
    $size = Invoke-GitBytes -Arguments @('cat-file', '-s', $Entry.Sha)
    $length = 0L
    if (-not [long]::TryParse($size.Text.Trim(), [ref]$length) -or $length -gt 20971520) {
        Write-Failure -Rule 'unsupported-content-size' -Path $Entry.Path
        return
    }
    $blob = Invoke-GitBytes -Arguments @('cat-file', 'blob', $Entry.Sha)
    if ($blob.Bytes -contains [byte]0) {
        Write-Failure -Rule 'binary-content' -Path $Entry.Path
        return
    }
    try { $content = $script:Utf8Strict.GetString($blob.Bytes) }
    catch { Write-Failure -Rule 'unsupported-text-encoding' -Path $Entry.Path; return }

    $patterns = @(
        [pscustomobject]@{ Name = 'private-key-header'; Regex = '-----BEGIN\s+(?:(?:RSA|EC|OPENSSH|DSA)\s+)?PRIVATE KEY-----' },
        [pscustomobject]@{ Name = 'github-token'; Regex = '\bgh[pousr]_[A-Za-z0-9]{20,}\b|\bgithub_pat_[A-Za-z0-9_]{20,}\b' },
        [pscustomobject]@{ Name = 'cloud-token'; Regex = '\bAKIA[0-9A-Z]{16}\b|\bAIza[0-9A-Za-z_-]{30,}\b|\bsk-proj-[A-Za-z0-9_-]{20,}\b|\bsk-[A-Za-z0-9]{32,}\b|\bya29\.[A-Za-z0-9_-]{30,}\b' }
    )
    foreach ($pattern in $patterns) {
        if ([regex]::IsMatch($content, $pattern.Regex)) { Write-Failure -Rule $pattern.Name -Path $Entry.Path; return }
    }

    $assignmentPattern = '(?im)\b(?:password|token|api[_-]?key|secret)\b\s*[:=]\s*["'']?([A-Za-z0-9_./+=:-]{4,})'
    foreach ($assignment in [regex]::Matches($content, $assignmentPattern)) {
        $value = $assignment.Groups[1].Value
        $placeholder = $value -match '(?i)^(?:example|placeholder|changeme|change[-_]?me|replace[-_]?me|your(?:[-_].*)?|dummy|redacted|todo|none|null|x{3,}|<[^>]+>)$'
        if (-not $placeholder) { Write-Failure -Rule 'explicit-secret-assignment' -Path $Entry.Path; return }
    }

    foreach ($match in [regex]::Matches($content, '(?<!\d)(?:\d{10}|\d{12})(?!\d)')) {
        if (Test-ValidInn -Digits $match.Value) { Write-Failure -Rule 'validated-inn' -Path $Entry.Path; return }
    }

    $documentName = [System.IO.Path]::GetFileName($Entry.Path)
    $documentHeading = $content -match '(?im)^\s*(?:сч[её]т\s+на\s+оплату|универсальный передаточный документ|упд|акт\s+(?:выполненных работ|оказанных услуг)|реестр\s+(?:счетов|документов))\s*(?:№|от|$)'
    $namedDocument = $documentName -match '(?i)(сч[её]т|упд|акт|договор|реестр)'
    $structuredValues = $content -match '(?im)\b(?:ИНН|КПП|БИК|р/с|к/с)\b\s*[:№]\s*[A-ZА-Я0-9-]{5,}|\b(?:сумма|итого|к оплате)\b\s*[:=]\s*\d{4,}'
    if (($documentHeading -or $namedDocument) -and $structuredValues) {
        Write-Failure -Rule 'accounting-document-pattern' -Path $Entry.Path
        return
    }
}

function Test-Entries {
    param([object[]] $Entries)
    foreach ($entry in $Entries) {
        Test-PathPolicy -Entry $entry
        if ($script:Findings -gt 0) { continue }
        Test-ContentPolicy -Entry $entry
    }
}

try {
    $rootResult = Invoke-GitBytes -Arguments @('rev-parse', '--show-toplevel')
    $script:Root = $rootResult.Text.Trim()
    if (-not $script:Root) { throw 'Git repository root is empty.' }
    Set-Location -LiteralPath $script:Root

    switch ($Mode) {
        'Index' {
            $entries = @(Get-EntriesForMode -SelectedMode 'Index')
            Test-Entries -Entries $entries
        }
        'Tracked' {
            $head = Invoke-GitBytes -Arguments @('rev-parse', '--verify', 'HEAD^{commit}')
            $entries = @(Get-EntriesForMode -SelectedMode 'Tracked' -Commit $head.Text.Trim())
            Test-Entries -Entries $entries
        }
        'Outgoing' {
            $inputText = [Console]::In.ReadToEnd()
            if (-not $inputText.Trim()) { throw 'Outgoing ref input is missing.' }
            $lines = @($inputText -split "`r?`n" | Where-Object { $_.Length -gt 0 })
            foreach ($line in $lines) {
                if ($line.Contains("`t")) { throw 'Outgoing ref line contains an ambiguous separator.' }
                $parts = @($line.Split(' ', [StringSplitOptions]::RemoveEmptyEntries))
                if ($parts.Count -ne 4 -or $line -match '\s{2,}') { throw 'Outgoing ref line is ambiguous.' }
                $localRef = $parts[0]; $localSha = $parts[1]; $remoteRef = $parts[2]; $remoteSha = $parts[3]
                if ($localRef -notmatch '^(?:refs/heads|refs/tags)/[^\s]+$' -or $remoteRef -notmatch '^refs/[^\s]+$') { throw 'Outgoing ref name is invalid.' }
                if ($localSha -notmatch '^(?:[0-9a-f]{40}|[0-9a-f]{64})$' -or $remoteSha -notmatch '^(?:[0-9a-f]{40}|[0-9a-f]{64})$') { throw 'Outgoing SHA is invalid.' }
                if ($localSha -match '^0+$') { continue }
                $localCommit = Invoke-GitBytes -Arguments @('rev-parse', '--verify', "$localSha^{commit}")
                if ($localRef -match '^refs/heads/') {
                    $resolvedRef = Invoke-GitBytes -Arguments @('rev-parse', '--verify', "$localRef^{commit}")
                    if ($resolvedRef.Text.Trim() -ne $localCommit.Text.Trim()) { throw 'Local ref and supplied object disagree.' }
                }
                if ($remoteSha -match '^0+$') {
                    $commitsText = Invoke-GitBytes -Arguments @('rev-list', '--reverse', $localCommit.Text.Trim())
                }
                else {
                    $remoteCommit = Invoke-GitBytes -Arguments @('rev-parse', '--verify', "$remoteSha^{commit}")
                    $commitsText = Invoke-GitBytes -Arguments @('rev-list', '--reverse', $localCommit.Text.Trim(), "^$($remoteCommit.Text.Trim())")
                }
                foreach ($commit in @($commitsText.Text -split "`r?`n" | Where-Object { $_ })) {
                    $entries = @(Get-EntriesForMode -SelectedMode 'Tracked' -Commit $commit)
                    Test-Entries -Entries $entries
                }
            }
        }
    }

    if ($script:Findings -gt 0) { [Console]::Error.WriteLine("FAIL mode=$Mode findings=$script:Findings"); exit 1 }
    [Console]::Out.WriteLine("PASS mode=$Mode")
    exit 0
}
catch {
    $reason = $_.Exception.Message
    if ($reason -notmatch '^(?:git-command-[a-z-]+-exit-[0-9]+|git-operation-failed-safely|Index record has no path separator\.|Index record is ambiguous\.|Unmerged index entries are ambiguous\.|Tree record has no path separator\.|Tree record is ambiguous\.|Outgoing ref input is missing\.|Outgoing ref line contains an ambiguous separator\.|Outgoing ref line is ambiguous\.|Outgoing ref name is invalid\.|Outgoing SHA is invalid\.|Local ref and supplied object disagree\.|Git repository root is empty\.)$') { $reason = 'unspecified' }
    $errorType = $_.Exception.GetType().Name
    $errorLine = $_.InvocationInfo.ScriptLineNumber
    [Console]::Error.WriteLine("FAIL mode=$Mode rule=verification-error reason=$reason type=$errorType line=$errorLine count=1")
    exit 2
}
