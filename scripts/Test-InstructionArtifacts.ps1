[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$RepoRoot = Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $PSScriptRoot 'InstructionTools.psm1') -Force
$Allowed = @('WORKSPACE_ROOT','PROJECTS_DIR','AUTOMATIONS_DIR','SANDBOX_DIR','ARCHIVED_DIR',
    'TEMPLATES_DIR','USER_PROFILE','GITHUB_USERNAME','PREFERRED_LANGUAGE')
foreach ($File in Get-ChildItem (Join-Path $RepoRoot 'profiles') -File -Recurse) {
    foreach ($Match in [regex]::Matches((Get-Content $File.FullName -Raw), '\{\{([^{}]+)\}\}')) {
        if ($Match.Groups[1].Value -notin $Allowed) { throw "Unknown placeholder in $($File.Name)" }
    }
}
$Strict = Join-Path $RepoRoot 'profiles/strict/AGENTS.template.md'
foreach ($Name in @(Get-InstructionModuleNames -Content (Get-Content $Strict -Raw))) {
    if (-not (Test-Path -LiteralPath (Join-Path (Split-Path $Strict) "personal-rules/$Name") -PathType Leaf)) {
        throw "Missing strict module: $Name"
    }
}
$Chat = Get-Content -LiteralPath (Join-Path $RepoRoot 'chatgpt/custom-instructions.zh-CN.txt') -Raw
if ([string]::IsNullOrWhiteSpace($Chat) -or $Chat.Length -gt 5000) { throw 'Invalid ChatGPT instruction length.' }
if ($Chat -match '(?m)^#|^```|\{\{[A-Z0-9_]+\}\}') { throw 'ChatGPT wrappers or unresolved placeholders remain.' }
$Count = 0
$Markdown = Get-ChildItem -LiteralPath $RepoRoot -Filter '*.md' -Recurse -File |
    Where-Object { $_.FullName -notmatch '[\\/](?:\.git|\.local|\.ai)([\\/]|$)' }
foreach ($File in $Markdown) {
    # Only relative file links are checked; external URLs and anchors are not fetched.
    foreach ($Match in [regex]::Matches((Get-Content $File.FullName -Raw), '\]\(([^)\s]+)\)')) {
        $Link = $Match.Groups[1].Value
        if ($Link -match '^[a-z][a-z0-9+.-]*:|^#|^/') { continue }
        $Target = [uri]::UnescapeDataString(($Link -split '#',2)[0])
        if ($Target -and -not (Test-Path -LiteralPath (Join-Path $File.DirectoryName $Target))) {
            throw "Broken relative link in $($File.Name): $Link"
        }
        $Count++
    }
}
Write-Host "Instruction artifacts passed: placeholders, modules, ChatGPT $($Chat.Length)/5000 UTF-16 units, $Count relative links."
