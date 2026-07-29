# Privacy and Sanitization

[English](PRIVACY-AND-SANITIZATION.md) | [简体中文](PRIVACY-AND-SANITIZATION.zh-CN.md)

## 1. Data classes

Treat repository data in three classes:

1. **Secrets** — API keys, passwords, tokens, private keys, cookies, private links, production credentials. Never store these in the playbook source, including `.local/` when avoidable.
2. **Private environment values** — local paths, operating-system account directories, private repository names, internal hosts, and personal workflow preferences. Store these only in `.local/` and sanitize before publication.
3. **Public identity values** — a public GitHub username, project name, or public repository URL. These may remain public when intentional, but should still be configurable for downstream users.

## 2. Placeholder map

| Placeholder | Meaning | Example local value |
|---|---|---|
| `{{WORKSPACE_ROOT}}` | Workspace root | `D:\Codex` |
| `{{PROJECTS_DIR}}` | Long-term projects | `D:\Codex\01-Projects` |
| `{{AUTOMATIONS_DIR}}` | Automation projects | `D:\Codex\02-Automations` |
| `{{SANDBOX_DIR}}` | Temporary experiments | `D:\Codex\03-Sandbox` |
| `{{ARCHIVED_DIR}}` | Archived projects | `D:\Codex\04-Archived` |
| `{{TEMPLATES_DIR}}` | Reusable templates | `D:\Codex\_templates` |
| `{{USER_PROFILE}}` | Current OS user profile | `C:\Users\example-user` |
| `{{GITHUB_USERNAME}}` | GitHub user or organization | `example-user` |
| `{{PREFERRED_LANGUAGE}}` | User-facing explanation language | `Simplified Chinese` |

Templates under `profiles/` intentionally keep placeholders. Rendered local files must contain none.

## 3. Recommended private files

```text
.local/user-settings.psd1
.local/AGENTS.source.md
```

The repository `.gitignore` excludes `.local/`. Do not force-add it.

## 4. Initialize local values

Interactive:

```powershell
pwsh -NoProfile -File .\scripts\Initialize-LocalWorkspace.ps1
```

Non-interactive example:

```powershell
pwsh -NoProfile -File .\scripts\Initialize-LocalWorkspace.ps1 `
  -WorkspaceRoot 'D:\Codex' `
  -GitHubUsername 'example-user' `
  -PreferredLanguage 'Simplified Chinese' `
  -Profile standard `
  -InstallGlobal
```

## 5. Manual placeholder replacement

The supported installer is preferred, but the same transformation can be performed manually:

```powershell
$TemplatePath = '.\profiles\standard\AGENTS.template.md'
$OutputPath = Join-Path $env:USERPROFILE '.codex\AGENTS.md'

$WorkspaceRoot = 'D:\Codex'
$Replacements = [ordered]@{
    '{{WORKSPACE_ROOT}}'    = $WorkspaceRoot
    '{{PROJECTS_DIR}}'      = Join-Path $WorkspaceRoot '01-Projects'
    '{{AUTOMATIONS_DIR}}'   = Join-Path $WorkspaceRoot '02-Automations'
    '{{SANDBOX_DIR}}'       = Join-Path $WorkspaceRoot '03-Sandbox'
    '{{ARCHIVED_DIR}}'      = Join-Path $WorkspaceRoot '04-Archived'
    '{{TEMPLATES_DIR}}'     = Join-Path $WorkspaceRoot '_templates'
    '{{USER_PROFILE}}'      = $env:USERPROFILE
    '{{GITHUB_USERNAME}}'   = 'example-user'
    '{{PREFERRED_LANGUAGE}}'= 'Simplified Chinese'
}

$Content = Get-Content -LiteralPath $TemplatePath -Raw
foreach ($Entry in $Replacements.GetEnumerator()) {
    $Content = $Content.Replace($Entry.Key, [string]$Entry.Value)
}

$Unresolved = [regex]::Matches($Content, '\{\{[A-Z0-9_]+\}\}') | ForEach-Object Value | Sort-Object -Unique
if ($Unresolved) {
    throw "Unresolved placeholders: $($Unresolved -join ', ')"
}

New-Item -ItemType Directory -Path (Split-Path -Parent $OutputPath) -Force | Out-Null
Set-Content -LiteralPath $OutputPath -Value $Content -Encoding utf8
```

## 6. Generate a public snapshot from the private source

```powershell
pwsh -NoProfile -File .\scripts\New-PublicSnapshot.ps1
pwsh -NoProfile -File .\scripts\Test-PublicSafety.ps1
```

The sanitization script replaces configured local values with placeholders, longest path first, then refuses to finish if a configured private literal remains.

## 7. Pre-commit review

```powershell
git status --short --branch
git diff --check
git diff
git diff --cached
```

Stage explicit public files. Never stage `.local/`.

## 8. Limitations

- Literal and regex scanning cannot prove that a repository contains no secret.
- Prompt-level authorization markers are not OS permissions or sandbox controls.
- A local path is not necessarily a secret, but it is environment-specific and should not be imposed on downstream users.
- Review generated diffs and use a dedicated secret scanner for high-risk repositories.
