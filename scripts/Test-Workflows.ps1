[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$RepoRoot = Split-Path -Parent $PSScriptRoot
$Executable = (Get-Process -Id $PID).Path
$Fixture = Join-Path $RepoRoot ('.local/validation-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $Fixture | Out-Null
foreach ($Name in @('scripts','profiles','examples','chatgpt')) {
    Copy-Item -LiteralPath (Join-Path $RepoRoot $Name) -Destination $Fixture -Recurse
}
function Invoke-Fixture {
    param([string]$Script, [string[]]$Arguments = @(), [switch]$ExpectFailure)
    $Output = & $Executable -NoLogo -NoProfile -NonInteractive -File (Join-Path $Fixture "scripts/$Script") @Arguments 2>&1 | Out-String
    $Code = $LASTEXITCODE
    if ($ExpectFailure) {
        if ($Code -eq 0) { throw "Expected failure was accepted: $Script" }
    }
    elseif ($Code -ne 0) { throw "Fixture check failed: $Script`n$Output" }
    return $Output
}
function Assert-True {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw $Message }
}
$Settings = Join-Path $Fixture '.local/user-settings.psd1'
$InitArgs = @('-WorkspaceRoot',(Join-Path $Fixture 'private-root'),'-GitHubUsername','fixture-user')
Invoke-Fixture 'Initialize-LocalWorkspace.ps1' ($InitArgs + '-WhatIf') | Out-Null
Assert-True (-not (Test-Path $Settings)) 'Initializer WhatIf wrote settings.'
Invoke-Fixture 'Initialize-LocalWorkspace.ps1' $InitArgs | Out-Null
Assert-True (Test-Path (Join-Path $Fixture '.local/AGENTS.source.md')) 'Private source missing.'
Assert-True (Test-Path (Join-Path $Fixture '.local/personal-rules/history.md')) 'Private supporting module missing.'
$PrivateStatus = Get-Content (Join-Path $Fixture '.local/AGENTS.source.md') -Raw
Assert-True ($PrivateStatus.Contains('Private generation source') -and -not $PrivateStatus.Contains('Active global Codex instructions.')) 'Private source misrepresents installed status.'
foreach ($Profile in @('minimal','standard','strict')) {
    $Target = Join-Path $Fixture "installed-$Profile/AGENTS.md"
    Invoke-Fixture 'Install-CodexAgents.ps1' @('-Profile',$Profile,'-SettingsPath',$Settings,'-TargetPath',$Target) | Out-Null
    if ($Profile -eq 'strict') {
        $Status = Get-Content $Target -Raw
        Assert-True ($Status.StartsWith('# Personal Codex Rules — Modular Entry v2') -and $Status.Contains('Active global Codex instructions.')) 'Strict installation status incorrect.'
        Assert-True ($Status -notmatch 'during candidate|not installed|Render this entry') 'Stale status survives installation.'
    }
    $Installed = @(Get-ChildItem (Split-Path $Target) -File -Recurse)
    $Expected = if ($Profile -eq 'strict') { 9 } else { 1 }
    Assert-True ($Installed.Count -eq $Expected) "Incorrect file inventory for $Profile."
    foreach ($File in $Installed) {
        Assert-True ((Get-Content $File.FullName -Raw) -notmatch '\{\{[A-Z0-9_]+\}\}') 'Unresolved installed placeholder.'
    }
}
$Target = Join-Path $Fixture 'installed-strict/AGENTS.md'
$Module = Join-Path $Fixture 'installed-strict/personal-rules/history.md'
$Unrelated = Join-Path $Fixture 'installed-strict/personal-rules/custom.md'
[IO.File]::WriteAllText($Target, 'existing entry')
[IO.File]::WriteAllText($Module, 'existing module')
[IO.File]::WriteAllText($Unrelated, 'unrelated user module')
Invoke-Fixture 'Install-CodexAgents.ps1' @('-Profile','strict','-SettingsPath',$Settings,'-TargetPath',$Target,'-WhatIf') | Out-Null
Assert-True ((Get-Content $Target -Raw) -eq 'existing entry') 'Installer WhatIf changed the entry.'
Assert-True (@(Get-ChildItem (Split-Path $Target) -Filter '*.bak-*' -Recurse).Count -eq 0) 'WhatIf created backups.'
Invoke-Fixture 'Install-CodexAgents.ps1' @('-Profile','strict','-SettingsPath',$Settings,'-TargetPath',$Target) | Out-Null
Assert-True (@(Get-ChildItem (Split-Path $Target) -Filter 'AGENTS.md.bak-*' | Where-Object { (Get-Content $_.FullName -Raw) -eq 'existing entry' }).Count -eq 1) 'Entry backup missing.'
Assert-True (@(Get-ChildItem (Split-Path $Module) -Filter 'history.md.bak-*' | Where-Object { (Get-Content $_.FullName -Raw) -eq 'existing module' }).Count -eq 1) 'Module backup missing.'
Assert-True ((Get-Content $Unrelated -Raw) -eq 'unrelated user module') 'Unrelated module changed.'
$Missing = Join-Path $Fixture 'profiles/strict/personal-rules/execution.md'
Rename-Item -LiteralPath $Missing -NewName 'execution.held'
$Before = (Get-FileHash $Target).Hash
Invoke-Fixture 'Install-CodexAgents.ps1' @('-Profile','strict','-SettingsPath',$Settings,'-TargetPath',$Target) -ExpectFailure | Out-Null
Assert-True ((Get-FileHash $Target).Hash -eq $Before) 'Missing-module failure changed entry.'
Rename-Item -LiteralPath (Join-Path (Split-Path $Missing) 'execution.held') -NewName 'execution.md'
$Generated = Join-Path $Fixture 'generated/AGENTS.template.md'
Invoke-Fixture 'New-PublicSnapshot.ps1' @('-OutputPath',$Generated) | Out-Null
foreach ($File in Get-ChildItem (Join-Path $Fixture 'profiles/strict') -File -Recurse) {
    $Relative = [IO.Path]::GetRelativePath((Join-Path $Fixture 'profiles/strict'),$File.FullName)
    Assert-True ((Get-FileHash $File.FullName).Hash -eq (Get-FileHash (Join-Path (Split-Path $Generated) $Relative)).Hash) "Strict round-trip mismatch: $Relative"
}
$ChatSource = Join-Path $Fixture '.local/chatgpt-custom-instructions.source.txt'
$ChatOutput = Join-Path $Fixture 'generated/chatgpt.txt'
[IO.File]::WriteAllText($ChatSource, '默认使用简体中文回答。')
Invoke-Fixture 'New-PublicSnapshot.ps1' @('-Kind','ChatGPT','-OutputPath',$ChatOutput) | Out-Null
$ChatBefore = (Get-FileHash $ChatOutput).Hash
Rename-Item -LiteralPath $ChatSource -NewName 'chatgpt.held'
Invoke-Fixture 'New-PublicSnapshot.ps1' @('-Kind','ChatGPT','-OutputPath',$ChatOutput) -ExpectFailure | Out-Null
Rename-Item -LiteralPath (Join-Path (Split-Path $ChatSource) 'chatgpt.held') -NewName 'chatgpt-custom-instructions.source.txt'
[IO.File]::WriteAllText($ChatSource, '')
Invoke-Fixture 'New-PublicSnapshot.ps1' @('-Kind','ChatGPT','-OutputPath',$ChatOutput) -ExpectFailure | Out-Null
[IO.File]::WriteAllText($ChatSource, ('长' * 5001))
Invoke-Fixture 'New-PublicSnapshot.ps1' @('-Kind','ChatGPT','-OutputPath',$ChatOutput) -ExpectFailure | Out-Null
Assert-True ((Get-FileHash $ChatOutput).Hash -eq $ChatBefore) 'Rejected ChatGPT input overwrote output.'
$Secret = 'sk-' + ('X' * 30)
$ModuleSource = Join-Path $Fixture '.local/personal-rules/history.md'
$Original = Get-Content $ModuleSource -Raw
[IO.File]::WriteAllText($ModuleSource, $Original + $Secret)
$GeneratedBefore = (Get-FileHash $Generated).Hash
$Failure = Invoke-Fixture 'New-PublicSnapshot.ps1' @('-OutputPath',$Generated) -ExpectFailure
Assert-True (-not $Failure.Contains($Secret)) 'Safety failure printed the secret.'
Assert-True ((Get-FileHash $Generated).Hash -eq $GeneratedBefore) 'Sensitive module detected after entry publication.'
[IO.File]::WriteAllText($ModuleSource, $Original)
$Template = Join-Path $Fixture 'profiles/minimal/AGENTS.template.md'
Add-Content $Template '{{UNKNOWN_TOKEN}}'
$Rejected = Join-Path $Fixture 'rejected/AGENTS.md'
Invoke-Fixture 'Install-CodexAgents.ps1' @('-Profile','minimal','-SettingsPath',$Settings,'-TargetPath',$Rejected) -ExpectFailure | Out-Null
Assert-True (-not (Test-Path $Rejected)) 'Unknown placeholder installed.'
$PrivateOutput = Join-Path $Fixture 'private-output.txt'
$PrivateValue = Join-Path $Fixture 'private-root'
[IO.File]::WriteAllText($PrivateOutput, $PrivateValue)
$Failure = Invoke-Fixture 'Test-PublicSafety.ps1' @('-Path',$PrivateOutput,'-SettingsPath',$Settings) -ExpectFailure
Assert-True (-not $Failure.Contains($PrivateValue)) 'Private-value failure printed the value.'
# Change only the PowerShell location; .NET process cwd remains elsewhere.
# Relative output paths must still resolve under this isolated fixture.
$Driver = Join-Path $Fixture 'relative-check.ps1'
@'
param([string]$Root)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $Root
& ./scripts/Install-CodexAgents.ps1 -Profile strict -SettingsPath ./.local/user-settings.psd1 -TargetPath './relative install/AGENTS.md'
& ./scripts/New-PublicSnapshot.ps1 -OutputPath './relative generated/AGENTS.template.md'
'@ | Set-Content -LiteralPath $Driver -Encoding utf8
$DriverOutput = & $Executable -NoLogo -NoProfile -NonInteractive -File $Driver -Root $Fixture 2>&1 | Out-String
if ($LASTEXITCODE -ne 0) { throw "Relative-path workflow failed: $DriverOutput" }
Assert-True (Test-Path (Join-Path $Fixture 'relative install/personal-rules/history.md')) 'Relative install escaped the PowerShell location.'
Assert-True (Test-Path (Join-Path $Fixture 'relative generated/personal-rules/history.md')) 'Relative generation escaped the PowerShell location.'

Write-Host 'Workflow checks passed: initialization, three profiles, module/entry backups, unrelated-file preservation, WhatIf, strict round-trip, empty/over-budget ChatGPT, secret rejection, placeholders, private-value rejection and relative paths with spaces.'
Write-Host 'Fixtures retained under ignored .local/validation-*; no global installation or network operations.'
