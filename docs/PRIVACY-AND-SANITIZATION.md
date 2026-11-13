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
.local/personal-rules/
.local/chatgpt-custom-instructions.source.txt
```

The repository `.gitignore` excludes `.local/`. Do not force-add it.

## 4. Initialize local values

Initialize once, review and adjust the settings, then install in section 5. If `.local/user-settings.psd1` already exists, skip initialization and preserve it; do not use `-Force` just to follow this guide.

Interactive:

```powershell
pwsh -NoProfile -File .\scripts\Initialize-LocalWorkspace.ps1
```

Non-interactive example:

```powershell
pwsh -NoProfile -File .\scripts\Initialize-LocalWorkspace.ps1 `
  -WorkspaceRoot 'D:\Codex' `
  -GitHubUsername 'example-user' `
  -PreferredLanguage 'Simplified Chinese'
```

Both examples create local settings and a private strict source under `.local/` without installing global instructions. Choose the global profile in section 5. Adding `-InstallGlobal` would install immediately through the same installer; it is intentionally omitted here to avoid installing twice.

## 5. Configure placeholder replacement and install safely

Use the supported installer instead of writing directly to the global file. Manually edit `.local/user-settings.psd1` created in section 4, or create it from `examples/user-settings.example.psd1` if it does not exist. Preserve existing local settings. The file contains a PowerShell data hashtable such as:

```powershell
@{
    WorkspaceRoot      = 'D:\Codex'
    ProjectsDir        = 'D:\Codex\01-Projects'
    AutomationsDir     = 'D:\Codex\02-Automations'
    SandboxDir         = 'D:\Codex\03-Sandbox'
    ArchivedDir        = 'D:\Codex\04-Archived'
    TemplatesDir       = 'D:\Codex\_templates'
    GitHubUsername     = 'example-user'
    PreferredLanguage  = 'Simplified Chinese'
}
```

Replace the example paths, GitHub identity, and language with your own values. Each directory can be customized independently; omitted or empty directory settings are derived from `WorkspaceRoot`. `WorkspaceRoot`, `GitHubUsername`, and `PreferredLanguage` must be present and non-empty. The installer obtains `{{USER_PROFILE}}` from `$env:USERPROFILE`. Keep private values in `.local/`, not in committed templates.

Run from the repository root:

```powershell
pwsh -NoProfile -File .\scripts\Install-CodexAgents.ps1 `
  -Profile standard `
  -SettingsPath .\.local\user-settings.psd1
```

The default target is `%USERPROFILE%\.codex\AGENTS.md`. For another location, pass `-TargetPath` including a parent directory. The installer validates the entire rendered package and rejects unresolved placeholders before modifying targets. Strict installs the entry and eight supporting files under sibling `personal-rules/`. Every existing file being replaced is backed up with a common timestamp-and-random suffix before any install write; backup failure stops installation. Unrelated files are retained. Writes are sequential, not transactional: keep the affected entry/module backups together and restore that set after an interrupted install. Avoid concurrent installs; do not bypass the supported flow with direct overwrites.

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

## 9. Modular and ChatGPT publication review

Keep the installed entry and its supporting modules as source inputs; never overwrite
the installed global file during release preparation. Back up an existing ignored
source before reconciling it. If no private source/settings exist, record that fact
and establish them from verified inputs; do not claim an earlier source was backed up.

The modular snapshot reads each required module relative to the private source.
It replaces configured values, normalizes stale candidate/staging metadata and
translates the human-only index. It also preserves Minimal's explicit prohibition
on unauthorized history rewriting or branch deletion in the Strict Git module.
This narrow profile-inheritance safeguard does not change the installed source.
Review all generated modules, not just the entry.

Generate the companion from the actual supplied text:

```powershell
pwsh -NoProfile -File .\scripts\New-PublicSnapshot.ps1 -Kind ChatGPT
```

No source means no generated companion. The generator removes presentation separators
and heading markers, keeps the instructions in the supplied language, and checks the
5,000-character release budget. It rejects empty/over-budget content, sensitive
patterns and remaining placeholders before replacing any public output.

The scanner accepts in-memory candidates for this pre-write check. Public scans
exclude ignored `.local/` and `.ai/`; local task evidence must not be published.
Check `git ls-files .local .ai` and the staged diff: ignored directories already
tracked by mistake are still a publication blocker. Review personal names, profile
paths, private project references, hostnames, email addresses and private links
independently; configured-literal and regex scans are incomplete.

Only source-derived instruction artifacts, reviewed tooling and documentation are
publication candidates. Public project URLs are intentional project identity, not
a downstream user's identity. Live account settings and private operational records
are not release artifacts. See the [paired consistency review](PAIRED-WORKFLOW.md).
