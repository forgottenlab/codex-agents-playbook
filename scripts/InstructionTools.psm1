[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-InstructionReplacements {
    param([string]$SettingsPath, [hashtable]$Settings)
    if ($null -eq $Settings) { $Settings = Import-PowerShellDataFile -LiteralPath $SettingsPath }
    $Names = [ordered]@{
        WorkspaceRoot = 'WORKSPACE_ROOT'; ProjectsDir = 'PROJECTS_DIR'
        AutomationsDir = 'AUTOMATIONS_DIR'; SandboxDir = 'SANDBOX_DIR'
        ArchivedDir = 'ARCHIVED_DIR'; TemplatesDir = 'TEMPLATES_DIR'
        GitHubUsername = 'GITHUB_USERNAME'; PreferredLanguage = 'PREFERRED_LANGUAGE'
    }
    if (-not $Settings.ContainsKey('WorkspaceRoot') -or [string]::IsNullOrWhiteSpace([string]$Settings.WorkspaceRoot)) {
        throw 'Required setting is missing or empty: WorkspaceRoot'
    }
    $Defaults = @{
        ProjectsDir = '01-Projects'; AutomationsDir = '02-Automations'
        SandboxDir = '03-Sandbox'; ArchivedDir = '04-Archived'; TemplatesDir = '_templates'
    }
    foreach ($Name in $Defaults.Keys) {
        if (-not $Settings.ContainsKey($Name) -or [string]::IsNullOrWhiteSpace([string]$Settings[$Name])) {
            $Settings[$Name] = Join-Path $Settings.WorkspaceRoot $Defaults[$Name]
        }
    }
    $Result = [ordered]@{}
    foreach ($Name in $Names.Keys) {
        if (-not $Settings.ContainsKey($Name) -or [string]::IsNullOrWhiteSpace([string]$Settings[$Name])) {
            throw "Required setting is missing or empty: $Name"
        }
        $Result["{{$($Names[$Name])}}"] = [string]$Settings[$Name]
    }
    $Result['{{USER_PROFILE}}'] = $env:USERPROFILE
    return $Result
}

function Convert-InstructionContent {
    param(
        [Parameter(Mandatory)] [string]$Content,
        [Parameter(Mandatory)] [System.Collections.IDictionary]$Replacements,
        [switch]$Sanitize
    )
    if ($Sanitize) {
        foreach ($Entry in ($Replacements.GetEnumerator() | Sort-Object { ([string]$_.Value).Length } -Descending)) {
            if ([string]::IsNullOrWhiteSpace([string]$Entry.Value)) { continue }
            $Token = [string]$Entry.Key
            $Content = [regex]::Replace($Content, [regex]::Escape([string]$Entry.Value),
                [System.Text.RegularExpressions.MatchEvaluator]{ param($Match) $Token },
                [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
        }
    }
    else {
        foreach ($Entry in $Replacements.GetEnumerator()) {
            $Content = $Content.Replace([string]$Entry.Key, [string]$Entry.Value)
        }
        if ($Content -match '\{\{[A-Z0-9_]+\}\}') { throw 'Unresolved placeholders; target was not written.' }
    }
    return ($Content.Replace("`r`n", "`n").TrimEnd() + "`n")
}

function Get-InstructionModuleNames {
    param([Parameter(Mandatory)] [string]$Content)
    $Names = @([regex]::Matches($Content, '\]\(personal-rules/([a-z][a-z-]*\.md)\)') |
        ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique)
    if ($Content -match '\]\(personal-rules/' -and $Names.Count -eq 0) {
        throw 'Unsupported supporting-module path.'
    }
    if ($Names.Count -gt 0) { return @($Names) + 'INDEX.md' }
}

Export-ModuleMember -Function Get-InstructionReplacements, Convert-InstructionContent, Get-InstructionModuleNames
