[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string]$WorkspaceRoot,
    [string]$GitHubUsername,
    [string]$PreferredLanguage = 'Simplified Chinese',

    [ValidateSet('minimal', 'standard', 'strict')]
    [string]$Profile = 'strict',

    [switch]$InstallGlobal,
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Read-Value {
    param(
        [Parameter(Mandatory)] [string]$Prompt,
        [string]$DefaultValue
    )
    $Suffix = if ([string]::IsNullOrWhiteSpace($DefaultValue)) { '' } else { " [$DefaultValue]" }
    $Value = Read-Host "$Prompt$Suffix"
    if ([string]::IsNullOrWhiteSpace($Value)) { return $DefaultValue }
    return $Value.Trim()
}

function ConvertTo-SingleQuotedLiteral {
    param([Parameter(Mandatory)] [string]$Value)
    return "'" + $Value.Replace("'", "''") + "'"
}

$RepoRoot = Split-Path -Parent $PSScriptRoot
$LocalDirectory = Join-Path $RepoRoot '.local'
$SettingsPath = Join-Path $LocalDirectory 'user-settings.psd1'
$LocalSourcePath = Join-Path $LocalDirectory 'AGENTS.source.md'

if ([string]::IsNullOrWhiteSpace($WorkspaceRoot)) {
    $DefaultWorkspace = if (Test-Path -LiteralPath 'D:\') { 'D:\Codex' } else { Join-Path $env:USERPROFILE 'Codex' }
    $WorkspaceRoot = Read-Value -Prompt 'Workspace root' -DefaultValue $DefaultWorkspace
}
if ([string]::IsNullOrWhiteSpace($GitHubUsername)) {
    $GitHubUsername = Read-Value -Prompt 'GitHub username or organization' -DefaultValue 'example-user'
}
if ([string]::IsNullOrWhiteSpace($PreferredLanguage)) {
    $PreferredLanguage = Read-Value -Prompt 'Preferred user-facing language' -DefaultValue 'Simplified Chinese'
}

$Settings = [ordered]@{
    WorkspaceRoot      = $WorkspaceRoot
    ProjectsDir        = Join-Path $WorkspaceRoot '01-Projects'
    AutomationsDir     = Join-Path $WorkspaceRoot '02-Automations'
    SandboxDir         = Join-Path $WorkspaceRoot '03-Sandbox'
    ArchivedDir        = Join-Path $WorkspaceRoot '04-Archived'
    TemplatesDir       = Join-Path $WorkspaceRoot '_templates'
    GitHubUsername     = $GitHubUsername
    PreferredLanguage = $PreferredLanguage
}

if ((Test-Path -LiteralPath $SettingsPath) -and -not $Force) {
    throw "Local settings already exist: $SettingsPath. Re-run with -Force to replace them."
}

$Lines = @('@{')
foreach ($Entry in $Settings.GetEnumerator()) {
    $Lines += "    $($Entry.Key) = $(ConvertTo-SingleQuotedLiteral -Value ([string]$Entry.Value))"
}
$Lines += '}'

if ($PSCmdlet.ShouldProcess($SettingsPath, 'Create private local settings')) {
    New-Item -ItemType Directory -Path $LocalDirectory -Force | Out-Null
    Set-Content -LiteralPath $SettingsPath -Value ($Lines -join [Environment]::NewLine) -Encoding utf8
    Write-Host "Private settings created: $SettingsPath"
}

if ($WhatIfPreference) { Write-Host 'WhatIf: private sources and global instructions were not written.'; return }

$Installer = Join-Path $PSScriptRoot 'Install-CodexAgents.ps1'
& $Installer -Profile 'strict' -SettingsPath $SettingsPath -TargetPath $LocalSourcePath -Force:$Force

# Mark the generated strict source as private/local while keeping publication reversible.
$LocalContent = Get-Content -LiteralPath $LocalSourcePath -Raw
$LocalContent = $LocalContent.Replace('# Personal Codex Rules — Modular Entry v2', '# Codex AGENTS Playbook — Strict Local Profile')
$LocalContent = $LocalContent.Replace('Active global Codex instructions. Read the relevant sibling personal-rules modules according to the routing table below.', 'Private generation source for the Strict profile; this file is not necessarily the installed global entry. Generate a sanitized public snapshot before distribution.')
$PublicPolicyPattern = 'This template intentionally uses documented placeholders for machine-specific paths and\r?\npreferences\. Render it through the installation script before using it as a global Codex\r?\ninstruction file\. Do not replace placeholders in the committed template with private values\.'
$PrivatePolicy = "This local file may contain machine-specific paths and preferences. It is a private`noperational source and must not be committed directly to a public repository. Generate a`npublic snapshot through the repository sanitization script, then run the public-safety scan."
$LocalContent = [regex]::Replace($LocalContent, $PublicPolicyPattern, $PrivatePolicy)
Set-Content -LiteralPath $LocalSourcePath -Value $LocalContent -Encoding utf8
Write-Host "Private strict source created: $LocalSourcePath"

if ($WhatIfPreference) {
    Write-Host 'WhatIf: skipping global installation.'
    return
}

if ($InstallGlobal) {
    & $Installer -Profile $Profile -SettingsPath $SettingsPath -Force:$Force
}
else {
    Write-Host "Global installation was not requested. Run Install-CodexAgents.ps1 when ready."
}
