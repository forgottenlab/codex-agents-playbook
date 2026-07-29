[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string]$SourcePath,
    [string]$SettingsPath,
    [string]$OutputPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$RepoRoot = Split-Path -Parent $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($SourcePath)) {
    $SourcePath = Join-Path $RepoRoot '.local\AGENTS.source.md'
}
if ([string]::IsNullOrWhiteSpace($SettingsPath)) {
    $SettingsPath = Join-Path $RepoRoot '.local\user-settings.psd1'
}
if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    $OutputPath = Join-Path $RepoRoot 'profiles\strict\AGENTS.template.md'
}

foreach ($RequiredPath in @($SourcePath, $SettingsPath)) {
    if (-not (Test-Path -LiteralPath $RequiredPath -PathType Leaf)) {
        throw "Required private input not found: $RequiredPath"
    }
}

$Settings = Import-PowerShellDataFile -LiteralPath $SettingsPath
$Mapping = @(
    @{ Name = 'ProjectsDir';        Placeholder = '{{PROJECTS_DIR}}' },
    @{ Name = 'AutomationsDir';     Placeholder = '{{AUTOMATIONS_DIR}}' },
    @{ Name = 'SandboxDir';         Placeholder = '{{SANDBOX_DIR}}' },
    @{ Name = 'ArchivedDir';        Placeholder = '{{ARCHIVED_DIR}}' },
    @{ Name = 'TemplatesDir';       Placeholder = '{{TEMPLATES_DIR}}' },
    @{ Name = 'WorkspaceRoot';      Placeholder = '{{WORKSPACE_ROOT}}' },
    @{ Name = 'GitHubUsername';     Placeholder = '{{GITHUB_USERNAME}}' },
    @{ Name = 'PreferredLanguage';  Placeholder = '{{PREFERRED_LANGUAGE}}' }
)

$Items = foreach ($Item in $Mapping) {
    if (-not $Settings.ContainsKey($Item.Name)) {
        throw "Required setting is missing: $($Item.Name)"
    }
    $Literal = [string]$Settings[$Item.Name]
    if ([string]::IsNullOrWhiteSpace($Literal)) {
        throw "Required setting is empty: $($Item.Name)"
    }
    [pscustomobject]@{
        Literal     = $Literal
        Placeholder = $Item.Placeholder
    }
}

if (-not [string]::IsNullOrWhiteSpace($env:USERPROFILE)) {
    $Items += [pscustomobject]@{
        Literal     = $env:USERPROFILE
        Placeholder = '{{USER_PROFILE}}'
    }
}

# Replace longer values first so a workspace root does not partially consume a child path.
$Items = $Items | Sort-Object { $_.Literal.Length } -Descending
$Content = Get-Content -LiteralPath $SourcePath -Raw
foreach ($Item in $Items) {
    $Pattern = [regex]::Escape($Item.Literal)
    $Content = [regex]::Replace(
        $Content,
        $Pattern,
        [System.Text.RegularExpressions.MatchEvaluator]{ param($Match) $Item.Placeholder },
        [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
    )
}

# Normalize the private title without leaking owner-specific wording.
$Content = $Content.Replace('Strict Local Profile', 'Strict Profile Template')
$PrivatePolicyPattern = 'This local file may contain machine-specific paths and preferences\. It is a private\r?\noperational source and must not be committed directly to a public repository\. Generate a\r?\npublic snapshot through the repository sanitization script, then run the public-safety scan\.'
$PublicPolicy = "This template intentionally uses documented placeholders for machine-specific paths and`npreferences. Render it through the installation script before using it as a global Codex`ninstruction file. Do not replace placeholders in the committed template with private values."
$Content = [regex]::Replace($Content, $PrivatePolicyPattern, $PublicPolicy)

$Remaining = @()
foreach ($Item in $Items) {
    if ($Content.IndexOf($Item.Literal, [System.StringComparison]::OrdinalIgnoreCase) -ge 0) {
        $Remaining += $Item.Placeholder
    }
}
if ($Remaining) {
    throw "Sanitization failed; configured private values remain for: $($Remaining -join ', ')"
}

if ($PSCmdlet.ShouldProcess($OutputPath, 'Write sanitized strict profile template')) {
    New-Item -ItemType Directory -Path (Split-Path -Parent $OutputPath) -Force | Out-Null
    Set-Content -LiteralPath $OutputPath -Value $Content -Encoding utf8
    Write-Host "Sanitized snapshot written: $OutputPath"
}

$SafetyScript = Join-Path $PSScriptRoot 'Test-PublicSafety.ps1'
& $SafetyScript -Path $OutputPath -SettingsPath $SettingsPath
