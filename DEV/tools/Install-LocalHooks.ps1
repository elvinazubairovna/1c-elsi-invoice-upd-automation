[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Invoke-GitText {
    param([string[]] $Arguments, [string] $Directory)
    $start = [System.Diagnostics.ProcessStartInfo]::new()
    $start.FileName = 'git'; $start.WorkingDirectory = $Directory; $start.UseShellExecute = $false
    $start.RedirectStandardOutput = $true; $start.RedirectStandardError = $true
    foreach ($arg in $Arguments) { [void] $start.ArgumentList.Add($arg) }
    $p = [System.Diagnostics.Process]::new(); $p.StartInfo = $start
    if (-not $p.Start()) { throw 'Git could not start.' }
    $out = $p.StandardOutput.ReadToEnd(); $err = $p.StandardError.ReadToEnd(); $p.WaitForExit()
    $code = $p.ExitCode; $p.Dispose()
    return [pscustomobject]@{ ExitCode = $code; Out = $out.Trim(); Err = $err }
}

function Invoke-Hook {
    param([string] $Root, [string[]] $Arguments, [string] $InputText = '')
    $start = [System.Diagnostics.ProcessStartInfo]::new()
    $start.FileName = 'git'; $start.WorkingDirectory = $Root; $start.UseShellExecute = $false
    $start.RedirectStandardOutput = $true; $start.RedirectStandardError = $true; $start.RedirectStandardInput = $true
    foreach ($arg in $Arguments) { [void] $start.ArgumentList.Add($arg) }
    $p = [System.Diagnostics.Process]::new(); $p.StartInfo = $start
    if (-not $p.Start()) { throw 'Git hook runner could not start.' }
    $outTask = $p.StandardOutput.ReadToEndAsync(); $errTask = $p.StandardError.ReadToEndAsync()
    if ($InputText) { $p.StandardInput.Write($InputText); $p.StandardInput.Flush() }
    $p.StandardInput.Close(); $p.WaitForExit(); [System.Threading.Tasks.Task]::WaitAll(@($outTask, $errTask))
    $result = [pscustomobject]@{ ExitCode = $p.ExitCode; Out = $outTask.Result; Err = $errTask.Result }
    $p.Dispose(); return $result
}

function Invoke-OutgoingMode {
    param([string] $Root, [string] $InputText)
    $start = [System.Diagnostics.ProcessStartInfo]::new()
    $start.FileName = 'pwsh'; $start.WorkingDirectory = $Root; $start.UseShellExecute = $false
    $start.RedirectStandardOutput = $true; $start.RedirectStandardError = $true; $start.RedirectStandardInput = $true
    foreach ($arg in @('-NoProfile','-File','DEV/tools/Test-Publication.ps1','-Mode','Outgoing')) { [void] $start.ArgumentList.Add($arg) }
    $p = [System.Diagnostics.Process]::new(); $p.StartInfo = $start
    if (-not $p.Start()) { throw 'PowerShell outgoing checker could not start.' }
    $outTask = $p.StandardOutput.ReadToEndAsync(); $errTask = $p.StandardError.ReadToEndAsync()
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($InputText)
    $p.StandardInput.BaseStream.Write($bytes, 0, $bytes.Length); $p.StandardInput.Flush(); $p.StandardInput.Close()
    $p.WaitForExit(); [System.Threading.Tasks.Task]::WaitAll(@($outTask, $errTask))
    $result = [pscustomobject]@{ ExitCode = $p.ExitCode; Out = $outTask.Result; Err = $errTask.Result }
    $p.Dispose(); return $result
}

try {
    $pwsh = Get-Command pwsh -ErrorAction SilentlyContinue
    if (-not $pwsh) { throw 'PowerShell 7 (pwsh) is required; hooks remain unchanged.' }
    if ($PSVersionTable.PSVersion.Major -ne 7) { throw 'PowerShell 7 is required; hooks remain unchanged.' }
    $rootResult = Invoke-GitText -Arguments @('rev-parse','--show-toplevel') -Directory (Get-Location).Path
    if ($rootResult.ExitCode -ne 0 -or -not $rootResult.Out) { throw 'Current directory is not a Git worktree.' }
    $root = $rootResult.Out
    $desired = 'DEV/hooks'
    $oldResult = Invoke-GitText -Arguments @('config','--local','--get','core.hooksPath') -Directory $root
    if ($oldResult.ExitCode -eq 0 -and $oldResult.Out -ne $desired) {
        throw 'A different core.hooksPath is configured; it was not replaced.'
    }
    if ($oldResult.ExitCode -gt 1) { throw 'Could not read local core.hooksPath.' }

    $gitHooksResult = Invoke-GitText -Arguments @('rev-parse','--git-path','hooks') -Directory $root
    if ($gitHooksResult.ExitCode -ne 0) { throw 'Could not inspect the default Git hooks directory.' }
    $defaultHooks = $gitHooksResult.Out
    if (-not [System.IO.Path]::IsPathRooted($defaultHooks)) { $defaultHooks = Join-Path $root $defaultHooks }
    foreach ($hookName in @('pre-commit','pre-push')) {
        $candidate = Join-Path $defaultHooks $hookName
        if (($oldResult.ExitCode -ne 0) -and (Test-Path -LiteralPath $candidate -PathType Leaf)) {
            throw "An existing default $hookName hook would be bypassed; it was not changed."
        }
    }

    foreach ($hookName in @('pre-commit','pre-push')) {
        $hookPath = Join-Path $root (Join-Path 'DEV\hooks' $hookName)
        if (-not (Test-Path -LiteralPath $hookPath -PathType Leaf)) { throw "Required hook is missing: $hookName." }
        $body = Get-Content -LiteralPath $hookPath -Raw
        if (-not $body.StartsWith('#!/bin/sh') -or $body -notmatch 'pwsh -NoProfile -File DEV/tools/Test-Publication\.ps1') {
            throw "Hook content check failed: $hookName."
        }
    }

    if ($oldResult.ExitCode -ne 0) {
        $set = Invoke-GitText -Arguments @('config','--local','core.hooksPath',$desired) -Directory $root
        if ($set.ExitCode -ne 0) { throw 'Could not configure local core.hooksPath.' }
    }
    $confirm = Invoke-GitText -Arguments @('config','--local','--get','core.hooksPath') -Directory $root
    if ($confirm.ExitCode -ne 0 -or $confirm.Out -ne $desired) { throw 'Configured hooks path did not verify.' }

    $preCommit = Invoke-Hook -Root $root -Arguments @('hook','run','pre-commit')
    if ($preCommit.ExitCode -ne 0) { throw 'Installed pre-commit hook failed its live check.' }
    $head = Invoke-GitText -Arguments @('rev-parse','HEAD') -Directory $root
    if ($head.ExitCode -ne 0 -or $head.Out -notmatch '^(?:[0-9a-f]{40}|[0-9a-f]{64})$') { throw 'Could not resolve HEAD for pre-push check.' }
    $line = "refs/heads/main $($head.Out) refs/heads/main $($head.Out)`n"
    $prePush = Invoke-OutgoingMode -Root $root -InputText $line
    if ($prePush.ExitCode -ne 0) { throw 'Installed pre-push hook failed its live check.' }

    [Console]::Out.WriteLine('PASS local-hooks path=DEV/hooks pre-commit=verified pre-push-mode=verified')
    exit 0
}
catch {
    [Console]::Error.WriteLine('FAIL local-hooks rule=installation-or-verification-error count=1')
    exit 2
}
