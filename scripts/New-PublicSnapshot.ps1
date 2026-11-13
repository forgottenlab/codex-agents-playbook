[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string]$SourcePath,
    [string]$SettingsPath,
    [string]$OutputPath,
    [ValidateSet('Strict', 'ChatGPT')] [string]$Kind = 'Strict'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'InstructionTools.psm1') -Force
$RepoRoot = Split-Path -Parent $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($SourcePath)) {
    $SourcePath = Join-Path $RepoRoot $(if ($Kind -eq 'ChatGPT') { '.local/chatgpt-custom-instructions.source.txt' } else { '.local/AGENTS.source.md' })
}
if ([string]::IsNullOrWhiteSpace($SettingsPath)) { $SettingsPath = Join-Path $RepoRoot '.local/user-settings.psd1' }
if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    $OutputPath = Join-Path $RepoRoot $(if ($Kind -eq 'ChatGPT') { 'chatgpt/custom-instructions.zh-CN.txt' } else { 'profiles/strict/AGENTS.template.md' })
}
$OutputPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputPath)
foreach ($RequiredPath in @($SourcePath, $SettingsPath)) {
    if (-not (Test-Path -LiteralPath $RequiredPath -PathType Leaf)) { throw "Required private input not found: $RequiredPath" }
}
$Source = Get-Content -LiteralPath $SourcePath -Raw
if ([string]::IsNullOrWhiteSpace($Source)) { throw 'Private instruction source is empty; no public output was written.' }
$Replacements = Get-InstructionReplacements -SettingsPath $SettingsPath
$Outputs = [ordered]@{}
$Outputs[$OutputPath] = Convert-InstructionContent -Content $Source -Replacements $Replacements -Sanitize
if ($Kind -eq 'Strict') {
    # Normalize operational status independently of whether input came from an installation or private source.
    $Outputs[$OutputPath] = [regex]::Replace($Outputs[$OutputPath],
        '(?m)^# (?:Personal Codex Rules — Modular (?:Candidate|Entry) v2|Codex AGENTS Playbook — Strict (?:Local Profile|Profile Template))$',
        '# Codex AGENTS Playbook — Strict Profile Template')
    foreach ($Notice in @(
        'Private candidate, not installed. Preserve the active global file until Owner approves migration.',
        'Active global Codex instructions. Read the relevant sibling personal-rules modules according to the routing table below.',
        'Private generation source for the Strict profile; this file is not necessarily the installed global entry. Generate a sanitized public snapshot before distribution.'
    )) {
        $Outputs[$OutputPath] = $Outputs[$OutputPath].Replace($Notice, 'Render this entry and its sibling personal-rules/ through the installer. Keep private values in .local/; never commit rendered local instructions.')
    }
    $Outputs[$OutputPath] = $Outputs[$OutputPath].Replace(
        "The layout is a global AGENTS.md with sibling ``personal-rules/``; during candidate`nreview use this staging directory's siblings. The private module directory is an`nOwner-authorized extension of global configuration, never a project evidence directory.",
        "The layout is a global AGENTS.md with sibling ``personal-rules/``. This supporting`nmodule directory extends global configuration; it is never a project evidence directory.")
    $Outputs[$OutputPath] = $Outputs[$OutputPath].Replace('Strict Local Profile', 'Strict Profile Template')
    $PrivatePolicyPattern = 'This local file may contain machine-specific paths and preferences\. It is a private\r?\noperational source and must not be committed directly to a public repository\. Generate a\r?\npublic snapshot through the repository sanitization script, then run the public-safety scan\.'
    $Outputs[$OutputPath] = [regex]::Replace($Outputs[$OutputPath], $PrivatePolicyPattern,
        "This template intentionally uses documented placeholders for machine-specific paths and`npreferences. Render it through the installation script before using it as a global Codex`ninstruction file. Do not replace placeholders in the committed template with private values.")
    foreach ($Name in @(Get-InstructionModuleNames -Content $Source)) {
        $ModuleSource = Join-Path (Split-Path -Parent $SourcePath) "personal-rules/$Name"
        if (-not (Test-Path -LiteralPath $ModuleSource -PathType Leaf)) { throw "Required supporting module not found: $ModuleSource" }
        $Text = Get-Content -LiteralPath $ModuleSource -Raw
        if ([string]::IsNullOrWhiteSpace($Text)) { throw "Required supporting module is empty: $Name" }
        if ($Name -eq 'INDEX.md') {
            # Human-only index: translate stale private candidate metadata, not execution rules.
            $Text = @'
# Supporting rule modules

This index is for human maintenance and audits. The entry AGENTS.md owns the complete
execution routing table; this index is not an execution prerequisite.
Modules are explicitly read with a file-reading tool when triggered. Markdown links
do not automatically import files or register Skills.

| Module | When to read |
|---|---|
| [execution.md](execution.md) | Repository-aware work, workspace choice or uncertain routing |
| [git-safety.md](git-safety.md) | Reviewing Git changes, staging or commits |
| [verification.md](verification.md) | Editing, testing, compatibility or public documentation |
| [context.md](context.md) | Durable context, long-lived projects, initialization or recovery |
| [history.md](history.md) | Non-trivial, staged, risky or continuing work; available-session archive |
| [recovery.md](recovery.md) | Missing UI tasks or conversations; also load context and history |
| [handoff.md](handoff.md) | Non-trivial completion, blocked handoff or initialization report |

Load the entry first, then only triggered modules. Modules do not recursively import
one another. History data contracts and handoff validation fields are not imports.
Complex tasks can require several modules; splitting files does not guarantee fewer
tokens for every task. Authorization remains in the entry. Skills conversion and
a deployment pipeline would require a separate task.
'@
        }
        # Retain the lighter profile's existing Git safeguard when synchronizing Strict.
        if ($Name -eq 'git-safety.md' -and $Text -notmatch 'rewrite history') {
            $Text = $Text.TrimEnd() + "`n`nNever push, rewrite history, or delete branches without explicit permission.`n"
        }
        $Text = $Text.Replace('The directory' + "`n" + 'exception does not authorize installation during candidate preparation.',
            'This directory exception does not authorize unrelated configuration changes.')
        $Outputs[(Join-Path (Split-Path -Parent $OutputPath) "personal-rules/$Name")] =
            Convert-InstructionContent -Content $Text -Replacements $Replacements -Sanitize
    }
}
else {
    # Preserve the supplied instructions; remove presentation separators/headings only.
    $Outputs[$OutputPath] = [regex]::Replace($Outputs[$OutputPath], '(?m)^---\s*\n', '')
    $Outputs[$OutputPath] = [regex]::Replace($Outputs[$OutputPath], '(?m)^### (.+)$', '【$1】')
    $Outputs[$OutputPath] = [regex]::Replace($Outputs[$OutputPath], '(?m)[\t ]+$', '')
    $Outputs[$OutputPath] = [regex]::Replace($Outputs[$OutputPath], '\n{3,}', "`n`n").TrimEnd() + "`n"
    if ($Outputs[$OutputPath].Length -gt 5000) { throw 'ChatGPT instructions exceed the requested 5000-character budget.' }
    if ($Outputs[$OutputPath] -match '\{\{[A-Z0-9_]+\}\}') {
        throw 'ChatGPT copyable instructions require manual privacy editing; placeholders remain.'
    }
}
# Scan every candidate before writing any public output. WhatIf remains read-only.
foreach ($Candidate in $Outputs.Values) {
    & (Join-Path $PSScriptRoot 'Test-PublicSafety.ps1') -Content $Candidate -SettingsPath $SettingsPath
    if (-not $?) { throw 'Candidate public-safety validation failed.' }
}
if (-not $PSCmdlet.ShouldProcess($OutputPath, "Write sanitized $Kind instruction package ($($Outputs.Count) files)")) { return }
foreach ($Entry in $Outputs.GetEnumerator()) {
    New-Item -ItemType Directory -Path (Split-Path -Parent $Entry.Key) -Force -Confirm:$false | Out-Null
    [IO.File]::WriteAllText($Entry.Key, $Entry.Value, [Text.UTF8Encoding]::new($false))
}
Write-Host "Validated and wrote $($Outputs.Count) file(s) for $Kind."
