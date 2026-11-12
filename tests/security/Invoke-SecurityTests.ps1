[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$script:Checker = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..\DEV\tools\Test-Publication.ps1'))
$script:TempBase = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
$script:Sandbox = Join-Path $script:TempBase ('.elsi-security-tests-' + [guid]::NewGuid().ToString('N'))
$script:Passed = 0
$script:Failed = 0

function Invoke-Process {
    param(
        [Parameter(Mandatory = $true)][string] $FileName,
        [Parameter(Mandatory = $true)][string[]] $Arguments,
        [Parameter(Mandatory = $true)][string] $WorkingDirectory,
        [string] $InputText = ''
    )
    $start = [System.Diagnostics.ProcessStartInfo]::new()
    $start.FileName = $FileName
    $start.WorkingDirectory = $WorkingDirectory
    $start.UseShellExecute = $false
    $start.RedirectStandardOutput = $true
    $start.RedirectStandardError = $true
    $start.RedirectStandardInput = $true
    $start.StandardOutputEncoding = [System.Text.Encoding]::UTF8
    $start.StandardErrorEncoding = [System.Text.Encoding]::UTF8
    foreach ($arg in $Arguments) { [void] $start.ArgumentList.Add($arg) }
    $process = [System.Diagnostics.Process]::new()
    $process.StartInfo = $start
    if (-not $process.Start()) { throw 'Child process did not start.' }
    $stdoutTask = $process.StandardOutput.ReadToEndAsync()
    $stderrTask = $process.StandardError.ReadToEndAsync()
    if ($InputText) {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($InputText)
        $process.StandardInput.BaseStream.Write($bytes, 0, $bytes.Length)
        $process.StandardInput.BaseStream.Flush()
    }
    $process.StandardInput.Close()
    if (-not $process.WaitForExit(60000)) { $process.Kill($true); throw 'Child process timed out.' }
    [System.Threading.Tasks.Task]::WaitAll(@($stdoutTask, $stderrTask))
    $result = [pscustomobject]@{ ExitCode = $process.ExitCode; Out = $stdoutTask.Result; Err = $stderrTask.Result }
    $process.Dispose()
    return $result
}

function Invoke-Git {
    param([string[]] $Arguments, [string] $Directory = $script:Repo)
    $r = Invoke-Process -FileName 'git' -Arguments $Arguments -WorkingDirectory $Directory
    if ($r.ExitCode -ne 0) { throw "Git setup command failed with exit code $($r.ExitCode)." }
    return $r.Out.Trim()
}

function New-TestRepo {
    $script:Repo = Join-Path $script:Sandbox ('repo-' + [guid]::NewGuid().ToString('N'))
    [void] (New-Item -ItemType Directory -Path $script:Repo)
    Invoke-Git -Arguments @('init','-q','--initial-branch=main') | Out-Null
    Invoke-Git -Arguments @('config','user.name','Synthetic Test') | Out-Null
    Invoke-Git -Arguments @('config','user.email','synthetic@example.invalid') | Out-Null
    Invoke-Git -Arguments @('config','commit.gpgsign','false') | Out-Null
}

function Write-TestFile {
    param([string] $Path, [string] $Content = 'Synthetic, non-sensitive test fixture.')
    $full = Join-Path $script:Repo $Path
    $parent = Split-Path -Parent $full
    if ($parent) { [void] (New-Item -ItemType Directory -Force -Path $parent) }
    [System.IO.File]::WriteAllText($full, $Content, [System.Text.UTF8Encoding]::new($false))
}

function Invoke-Check {
    param([string] $Mode, [string] $InputText = '', [string] $Directory = $script:Repo, [string] $OverrideMode = '')
    $selected = if ($OverrideMode) { $OverrideMode } else { $Mode }
    return Invoke-Process -FileName 'pwsh' -Arguments @('-NoProfile','-File',$script:Checker,'-Mode',$selected) -WorkingDirectory $Directory -InputText $InputText
}

function Assert-Result {
    param([string] $Name, [int] $ExpectedExit, [object] $Result, [string] $MustNotContain = '')
    $okay = $Result.ExitCode -eq $ExpectedExit
    if ($MustNotContain -and (($Result.Out + $Result.Err).Contains($MustNotContain))) { $okay = $false }
    if ($okay) {
        [Console]::Out.WriteLine("PASS test=$Name")
        $script:Passed++
    }
    else {
        [Console]::Error.WriteLine("FAIL test=$Name expectedExit=$ExpectedExit actualExit=$($Result.ExitCode)")
        $script:Failed++
    }
}

function Get-CheckDigit {
    param([string] $Digits, [int[]] $Weights)
    $sum = 0
    for ($i = 0; $i -lt $Weights.Count; $i++) { $sum += ([int]::Parse([string]$Digits[$i])) * $Weights[$i] }
    return [string](($sum % 11) % 10)
}

try {
    if (-not (Get-Command pwsh -ErrorAction SilentlyContinue)) { throw 'PowerShell 7 is unavailable.' }
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw 'Git is unavailable.' }
    if (-not (Test-Path -LiteralPath $script:Checker -PathType Leaf)) { throw 'Publication checker is unavailable.' }
    [void] (New-Item -ItemType Directory -Path $script:Sandbox)
    $emptyGlobalConfig = Join-Path $script:Sandbox 'empty-git-config'
    [System.IO.File]::WriteAllText($emptyGlobalConfig, '')
    $env:GIT_CONFIG_NOSYSTEM = '1'
    $env:GIT_CONFIG_GLOBAL = $emptyGlobalConfig

    New-TestRepo
    Write-TestFile -Path 'README.md' -Content 'Synthetic guide without credentials.'
    Invoke-Git -Arguments @('add','README.md') | Out-Null
    Assert-Result 'safe-markdown' 0 (Invoke-Check -Mode Index)

    New-TestRepo
    foreach ($extension in @('pdf','xlsx','csv')) { Write-TestFile -Path "fixture.$extension" }
    Invoke-Git -Arguments @('add','-f','fixture.pdf','fixture.xlsx','fixture.csv') | Out-Null
    Assert-Result 'forced-document-extensions' 1 (Invoke-Check -Mode Index)

    New-TestRepo
    Write-TestFile -Path 'nested/secrets/fixture.txt'
    Invoke-Git -Arguments @('add','-f','nested/secrets/fixture.txt') | Out-Null
    Assert-Result 'nested-sensitive-directory' 1 (Invoke-Check -Mode Index)

    New-TestRepo
    $fakeToken = ('gh' + 'p' + '_' + ('x' * 24))
    Write-TestFile -Path 'notes.md' -Content ("Synthetic test token: " + $fakeToken)
    Invoke-Git -Arguments @('add','notes.md') | Out-Null
    Assert-Result 'synthetic-token' 1 (Invoke-Check -Mode Index) -MustNotContain $fakeToken

    New-TestRepo
    $base10 = '123456789'
    $inn10 = $base10 + (Get-CheckDigit -Digits $base10 -Weights @(2,4,10,3,5,9,4,6,8))
    Write-TestFile -Path 'fixture.md' -Content ("Synthetic identifier: " + $inn10)
    Invoke-Git -Arguments @('add','fixture.md') | Out-Null
    Assert-Result 'synthetic-checksummed-identifier' 1 (Invoke-Check -Mode Index) -MustNotContain $inn10

    New-TestRepo
    Write-TestFile -Path 'policy.md' -Content 'The api_key rule is checked; no value is assigned here.'
    Invoke-Git -Arguments @('add','policy.md') | Out-Null
    Assert-Result 'rule-description-without-value' 0 (Invoke-Check -Mode Index)

    New-TestRepo
    Write-TestFile -Path 'template.md' -Content 'api_key=placeholder'
    Invoke-Git -Arguments @('add','template.md') | Out-Null
    Assert-Result 'placeholder-assignment' 0 (Invoke-Check -Mode Index)

    New-TestRepo
    Write-TestFile -Path 'fixture.txt' -Content "Счет на оплату № TEST-001`nИтого: 12345 руб."
    Invoke-Git -Arguments @('add','fixture.txt') | Out-Null
    Assert-Result 'accounting-document-in-unexpected-extension' 1 (Invoke-Check -Mode Index)

    New-TestRepo
    Write-TestFile -Path 'README.md' -Content 'Base revision.'
    Invoke-Git -Arguments @('add','README.md') | Out-Null
    Invoke-Git -Arguments @('commit','-q','-m','Synthetic base') | Out-Null
    $baseSha = Invoke-Git -Arguments @('rev-parse','HEAD')
    Write-TestFile -Path 'temporary.csv' -Content 'Synthetic forbidden fixture.'
    Invoke-Git -Arguments @('add','-f','temporary.csv') | Out-Null
    Invoke-Git -Arguments @('commit','-q','-m','Synthetic add') | Out-Null
    Invoke-Git -Arguments @('rm','-q','temporary.csv') | Out-Null
    Invoke-Git -Arguments @('commit','-q','-m','Synthetic delete') | Out-Null
    $head = Invoke-Git -Arguments @('rev-parse','HEAD')
    $input = "refs/heads/main $head refs/heads/main $baseSha`n"
    Assert-Result 'outgoing-add-then-delete' 1 (Invoke-Check -Mode Outgoing -InputText $input)

    New-TestRepo
    Assert-Result 'ambiguous-outgoing-input' 2 (Invoke-Check -Mode Outgoing -InputText "this is not a pre-push record`n")
    $zeroSha = '0' * 40
    Assert-Result 'tab-separated-outgoing-input' 2 (Invoke-Check -Mode Outgoing -InputText "refs/heads/main`t$zeroSha`trefs/heads/main`t$zeroSha`n")

    $outsideRepo = Join-Path $script:Sandbox 'not-a-repository'
    [void] (New-Item -ItemType Directory -Path $outsideRepo)
    Assert-Result 'git-error-outside-repository' 2 (Invoke-Check -Mode Index -Directory $outsideRepo)

    $invalid = Invoke-Check -Mode Index -OverrideMode 'Unsupported'
    if ($invalid.ExitCode -ne 0) {
        [Console]::Out.WriteLine('PASS test=invalid-mode')
        $script:Passed++
    } else {
        [Console]::Error.WriteLine('FAIL test=invalid-mode expectedNonzero=true')
        $script:Failed++
    }

    $projectRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
    $realIndex = Invoke-Process -FileName 'pwsh' -Arguments @('-NoProfile','-File',$script:Checker,'-Mode','Index') -WorkingDirectory $projectRoot
    Assert-Result 'current-project-index' 0 $realIndex
    $realTracked = Invoke-Process -FileName 'pwsh' -Arguments @('-NoProfile','-File',$script:Checker,'-Mode','Tracked') -WorkingDirectory $projectRoot
    Assert-Result 'current-project-tracked' 0 $realTracked

    if ($script:Failed -gt 0) {
        [Console]::Error.WriteLine("FAIL summary passed=$script:Passed failed=$script:Failed")
        exit 1
    }
    [Console]::Out.WriteLine("PASS summary passed=$script:Passed failed=0")
    exit 0
}
catch {
    [Console]::Error.WriteLine("FAIL test-runner rule=setup-or-execution-error type=$($_.Exception.GetType().Name) line=$($_.InvocationInfo.ScriptLineNumber) count=1")
    exit 2
}
finally {
    if (Test-Path -LiteralPath $script:Sandbox) {
        $resolvedSandbox = [System.IO.Path]::GetFullPath((Resolve-Path -LiteralPath $script:Sandbox).Path)
        $separator = [System.IO.Path]::DirectorySeparatorChar
        $resolvedBase = [System.IO.Path]::GetFullPath($script:TempBase).TrimEnd([char[]]@('\','/')) + $separator
        $pathComparison = if ($separator -eq '/') { [System.StringComparison]::Ordinal } else { [System.StringComparison]::OrdinalIgnoreCase }
        if (-not $resolvedSandbox.StartsWith($resolvedBase, $pathComparison) -or
            [System.IO.Path]::GetFileName($resolvedSandbox) -notmatch '^\.elsi-security-tests-[0-9a-f]{32}$') {
            [Console]::Error.WriteLine('FAIL test-cleanup rule=unsafe-temp-path count=1')
            exit 3
        }
        Remove-Item -LiteralPath $resolvedSandbox -Recurse -Force
    }
}
