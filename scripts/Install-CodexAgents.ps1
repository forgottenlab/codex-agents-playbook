[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [ValidateSet('minimal', 'standard', 'strict')]
    [string]$Profile = 'standard',

    [string]$SettingsPath,

    [string]$TargetPath = (Join-Path $env:USERPROFILE '.codex\AGENTS.md'),

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

function Get-Settings {
    param([string]$Path)

    if (-not [string]::IsNullOrWhiteSpace($Path)) {
        if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
            throw "Settings file not found: $Path"
        }
        return Import-PowerShellDataFile -LiteralPath $Path
    }

    $DefaultWorkspace = if (Test-Path -LiteralPath 'D:\') { 'D:\Codex' } else { Join-Path $env:USERPROFILE 'Codex' }
    $WorkspaceRoot = Read-Value -Prompt 'Workspace root' -DefaultValue $DefaultWorkspace
    $GitHubUsername = Read-Value -Prompt 'GitHub username or organization' -DefaultValue 'example-user'
    $PreferredLanguage = Read-Value -Prompt 'Preferred user-facing language' -DefaultValue 'Simplified Chinese'

    return @{
        WorkspaceRoot      = $WorkspaceRoot
        ProjectsDir        = Join-Path $WorkspaceRoot '01-Projects'
        AutomationsDir     = Join-Path $WorkspaceRoot '02-Automations'
        SandboxDir         = Join-Path $WorkspaceRoot '03-Sandbox'
        ArchivedDir        = Join-Path $WorkspaceRoot '04-Archived'
        TemplatesDir       = Join-Path $WorkspaceRoot '_templates'
        GitHubUsername     = $GitHubUsername
        PreferredLanguage = $PreferredLanguage
    }
}

function Get-RequiredSetting {
    param(
        [Parameter(Mandatory)] [hashtable]$Settings,
        [Parameter(Mandatory)] [string]$Name
    )

    if (-not $Settings.ContainsKey($Name)) {
        throw "Required setting is missing: $Name"
    }
    $Value = [string]$Settings[$Name]
    if ([string]::IsNullOrWhiteSpace($Value)) {
        throw "Required setting is empty: $Name"
    }
    return $Value
}

$RepoRoot = Split-Path -Parent $PSScriptRoot
$TemplatePath = Join-Path $RepoRoot "profiles\$Profile\AGENTS.template.md"
if (-not (Test-Path -LiteralPath $TemplatePath -PathType Leaf)) {
    throw "Profile template not found: $TemplatePath"
}

$Settings = Get-Settings -Path $SettingsPath
$WorkspaceRoot = Get-RequiredSetting -Settings $Settings -Name 'WorkspaceRoot'

# Allow concise user settings while keeping all placeholders deterministic.
$DerivedDefaults = @{
    ProjectsDir    = Join-Path $WorkspaceRoot '01-Projects'
    AutomationsDir = Join-Path $WorkspaceRoot '02-Automations'
    SandboxDir     = Join-Path $WorkspaceRoot '03-Sandbox'
    ArchivedDir    = Join-Path $WorkspaceRoot '04-Archived'
    TemplatesDir   = Join-Path $WorkspaceRoot '_templates'
}
foreach ($Name in $DerivedDefaults.Keys) {
    if (-not $Settings.ContainsKey($Name) -or [string]::IsNullOrWhiteSpace([string]$Settings[$Name])) {
        $Settings[$Name] = $DerivedDefaults[$Name]
    }
}

$Replacements = [ordered]@{
    '{{WORKSPACE_ROOT}}'     = Get-RequiredSetting -Settings $Settings -Name 'WorkspaceRoot'
    '{{PROJECTS_DIR}}'       = Get-RequiredSetting -Settings $Settings -Name 'ProjectsDir'
    '{{AUTOMATIONS_DIR}}'    = Get-RequiredSetting -Settings $Settings -Name 'AutomationsDir'
    '{{SANDBOX_DIR}}'        = Get-RequiredSetting -Settings $Settings -Name 'SandboxDir'
    '{{ARCHIVED_DIR}}'       = Get-RequiredSetting -Settings $Settings -Name 'ArchivedDir'
    '{{TEMPLATES_DIR}}'      = Get-RequiredSetting -Settings $Settings -Name 'TemplatesDir'
    '{{USER_PROFILE}}'       = $env:USERPROFILE
    '{{GITHUB_USERNAME}}'    = Get-RequiredSetting -Settings $Settings -Name 'GitHubUsername'
    '{{PREFERRED_LANGUAGE}}' = Get-RequiredSetting -Settings $Settings -Name 'PreferredLanguage'
}

$Content = Get-Content -LiteralPath $TemplatePath -Raw
foreach ($Entry in $Replacements.GetEnumerator()) {
    $Content = $Content.Replace($Entry.Key, [string]$Entry.Value)
}

$Unresolved = [regex]::Matches($Content, '\{\{[A-Z0-9_]+\}\}') |
    ForEach-Object Value |
    Sort-Object -Unique
if ($Unresolved) {
    throw "Unresolved placeholders: $($Unresolved -join ', ')"
}

$TargetDirectory = Split-Path -Parent $TargetPath
if ([string]::IsNullOrWhiteSpace($TargetDirectory)) {
    throw "TargetPath must include a parent directory: $TargetPath"
}

if (Test-Path -LiteralPath $TargetPath -PathType Leaf) {
    $Timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $BackupPath = "$TargetPath.bak-$Timestamp"
    if ($PSCmdlet.ShouldProcess($TargetPath, "Back up existing file to $BackupPath")) {
        Copy-Item -LiteralPath $TargetPath -Destination $BackupPath -Force
        Write-Host "Backup created: $BackupPath"
    }
}

if ($PSCmdlet.ShouldProcess($TargetPath, "Install $Profile profile")) {
    New-Item -ItemType Directory -Path $TargetDirectory -Force | Out-Null
    Set-Content -LiteralPath $TargetPath -Value $Content -Encoding utf8
    Write-Host "Installed profile '$Profile': $TargetPath"
}
