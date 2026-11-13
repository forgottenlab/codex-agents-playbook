[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [ValidateSet('minimal', 'standard', 'strict')] [string]$Profile = 'standard',
    [string]$SettingsPath,
    [string]$TargetPath = (Join-Path $env:USERPROFILE '.codex/AGENTS.md'),
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'InstructionTools.psm1') -Force
$RepoRoot = Split-Path -Parent $PSScriptRoot
$TemplatePath = Join-Path $RepoRoot "profiles/$Profile/AGENTS.template.md"
if ([string]::IsNullOrWhiteSpace($SettingsPath)) {
    $DefaultWorkspace = if (Test-Path -LiteralPath 'D:\') { 'D:\Codex' } else { Join-Path $env:USERPROFILE 'Codex' }
    $Workspace = Read-Host "Workspace root [$DefaultWorkspace]"
    if ([string]::IsNullOrWhiteSpace($Workspace)) { $Workspace = $DefaultWorkspace }
    $Identity = Read-Host 'GitHub username or organization [example-user]'
    if ([string]::IsNullOrWhiteSpace($Identity)) { $Identity = 'example-user' }
    $Language = Read-Host 'Preferred user-facing language [Simplified Chinese]'
    if ([string]::IsNullOrWhiteSpace($Language)) { $Language = 'Simplified Chinese' }
    $Replacements = Get-InstructionReplacements -Settings @{
        WorkspaceRoot = $Workspace; GitHubUsername = $Identity; PreferredLanguage = $Language
    }
}
else { $Replacements = Get-InstructionReplacements -SettingsPath $SettingsPath }
$Template = Get-Content -LiteralPath $TemplatePath -Raw
if ($Profile -eq 'strict') {
    $Template = $Template.Replace('# Codex AGENTS Playbook — Strict Profile Template', '# Personal Codex Rules — Modular Entry v2')
    $Template = $Template.Replace('Render this entry and its sibling personal-rules/ through the installer. Keep private values in .local/; never commit rendered local instructions.', 'Active global Codex instructions. Read the relevant sibling personal-rules modules according to the routing table below.')
}
$TargetPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($TargetPath)
$TargetDirectory = Split-Path -Parent $TargetPath
if ([string]::IsNullOrWhiteSpace($TargetDirectory)) { throw 'TargetPath must include a parent directory.' }
$Outputs = [ordered]@{}
# Modules first, entry last. Validate the complete package before backups or writes.
foreach ($Name in @(Get-InstructionModuleNames -Content $Template)) {
    $ModulePath = Join-Path (Split-Path -Parent $TemplatePath) "personal-rules/$Name"
    if (-not (Test-Path -LiteralPath $ModulePath -PathType Leaf)) { throw "Required supporting module not found: $Name" }
    $Outputs[(Join-Path $TargetDirectory "personal-rules/$Name")] =
        Convert-InstructionContent -Content (Get-Content -LiteralPath $ModulePath -Raw) -Replacements $Replacements
}
$Outputs[$TargetPath] = Convert-InstructionContent -Content $Template -Replacements $Replacements
# Confirm the whole package once so an existing file can never be replaced after
# its backup was declined separately. WhatIf performs no backup or install writes.
if (-not $PSCmdlet.ShouldProcess($TargetPath, "Back up and install $Profile profile ($($Outputs.Count) files)")) { return }
$BackupSuffix = (Get-Date -Format 'yyyyMMdd-HHmmssfff') + '-' + [guid]::NewGuid().ToString('N')
foreach ($Destination in $Outputs.Keys) {
    if (Test-Path -LiteralPath $Destination) {
        if (-not (Test-Path -LiteralPath $Destination -PathType Leaf)) { throw 'Install destination is not a regular file.' }
        Copy-Item -LiteralPath $Destination -Destination "$Destination.bak-$BackupSuffix" -ErrorAction Stop -Confirm:$false
    }
}
foreach ($Entry in $Outputs.GetEnumerator()) {
    New-Item -ItemType Directory -Path (Split-Path -Parent $Entry.Key) -Force -Confirm:$false | Out-Null
    [IO.File]::WriteAllText($Entry.Key, $Entry.Value, [Text.UTF8Encoding]::new($false))
}
Write-Host "Installed $($Outputs.Count) file(s) for profile '$Profile'."
