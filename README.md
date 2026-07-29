# Codex AGENTS Playbook

> A safety-first, evidence-based collection of reusable `AGENTS.md` profiles, privacy-aware publishing tools, and local installation workflows for Codex.

[English](README.md) | [简体中文](README.zh-CN.md)

> [!IMPORTANT]
> This is a community-maintained project based on real development experience. It is not an official OpenAI project, an operating-system security boundary, or a substitute for reviewing commands and code changes.

## ✨ Why this project exists

Codex can use `AGENTS.md` to understand how to navigate a repository, which commands to run, and which project practices to follow. A useful ruleset therefore needs more than tone preferences: it needs explicit scope, Git safety, validation evidence, privacy controls, durable project context, and a reliable handoff model.

This repository turns those concerns into three reusable profiles and a two-layer publishing workflow:

```text
Private local source
        ↓  sanitize and verify
Public profile templates
        ↓  configure and render
User's installed AGENTS.md
```

The project does not claim to be a “magic prompt.” It is an opinionated operating playbook designed to make agent-assisted engineering more bounded, reviewable, evidence-based, and recoverable.

## 🚀 What is included

| Component | Purpose |
|---|---|
| `profiles/minimal` | Essential scope, secret, Git, validation, and handoff safeguards |
| `profiles/standard` | Recommended default with workspace, remote-operation, documentation, and compact `.ai` guidance |
| `profiles/strict` | Complete workflow with authorization markers, detailed context governance, task history, and UI-history recovery |
| `scripts/Initialize-LocalWorkspace.ps1` | Creates ignored local settings and a usable private source file |
| `scripts/Install-CodexAgents.ps1` | Renders a selected profile and installs it with backup protection |
| `scripts/New-PublicSnapshot.ps1` | Converts the private strict source into a sanitized public template |
| `scripts/Test-PublicSafety.ps1` | Scans public files for configured private values and common credential patterns |
| `scripts/Test-PowerShellSyntax.ps1` | Parses every PowerShell script without executing it |
| `scripts/Test-Repository.ps1` | Runs syntax and public-safety validation together |
| `scripts/Bootstrap-CodexAgents.ps1` | Clones or updates the repository, then invokes the visible local installer |
| `.local/` | Ignored private values and the owner's local operational source; never commit it |

## 🌐 Why the canonical rules are in English

The installable rule layer is English because commands, paths, API identifiers, Git terms, error messages, and upstream engineering documentation are predominantly English. A single canonical rule language reduces drift and mixed-language ambiguity. Chinese documentation is maintained separately for explanation and onboarding.

This is not a claim that English is inherently better for model behavior. Explicit authority, narrow scope, concrete constraints, and verifiable checks matter more than language alone.

## 🧭 Profiles

| Profile | Best for | Main trade-off |
|---|---|---|
| Minimal | Small repositories, experiments, short tasks | Lowest overhead, limited continuity |
| Standard | Most personal and open-source projects | Balanced safety and context |
| Strict | Long-running, risky, multi-stage, or recovery-sensitive work | More files, more process, more tokens |

The repository root `AGENTS.md` contains maintenance instructions for this repository. End-user templates live under `profiles/`.

## 📦 Quick start after cloning

Requirements:

- Git
- PowerShell 7.2 or newer

```powershell
git clone https://github.com/forgottenlab/codex-agents-playbook.git
Set-Location .\codex-agents-playbook

pwsh -NoProfile -File .\scripts\Initialize-LocalWorkspace.ps1
```

The initializer asks for environment-specific values, writes them only under the ignored `.local/` directory, renders a private strict source, and can optionally install a selected profile globally.

To install later:

```powershell
pwsh -NoProfile -File .\scripts\Install-CodexAgents.ps1 `
  -Profile standard `
  -SettingsPath .\.local\user-settings.psd1
```

The default target is:

```text
%USERPROFILE%\.codex\AGENTS.md
```

An existing file is backed up before replacement.

## 🔐 Private local source and public snapshot

Machine paths and user-specific settings belong in:

```text
.local/user-settings.psd1
.local/AGENTS.source.md
```

Both are ignored by Git. Never force-add `.local/`.

After intentionally editing the private strict source, create a public sanitized snapshot:

```powershell
pwsh -NoProfile -File .\scripts\New-PublicSnapshot.ps1
pwsh -NoProfile -File .\scripts\Test-PublicSafety.ps1
```

Then review the exact diff:

```powershell
git status --short
git diff -- profiles/strict/AGENTS.template.md
git diff --check
```

See [Privacy and sanitization](docs/PRIVACY-AND-SANITIZATION.md) for the complete placeholder map and manual replacement examples.

## 🧩 Documented placeholders

| Placeholder | User-specific value |
|---|---|
| `{{WORKSPACE_ROOT}}` | Root directory used for Codex workspaces |
| `{{PROJECTS_DIR}}` | Long-term project directory |
| `{{AUTOMATIONS_DIR}}` | Automation project directory |
| `{{SANDBOX_DIR}}` | Temporary experiment directory |
| `{{ARCHIVED_DIR}}` | Archived project directory |
| `{{TEMPLATES_DIR}}` | Reusable template directory |
| `{{USER_PROFILE}}` | Current operating-system user profile |
| `{{GITHUB_USERNAME}}` | GitHub username or organization name |
| `{{PREFERRED_LANGUAGE}}` | Preferred user-facing explanation language |

Committed templates intentionally retain these placeholders. Installed local files must not.

## 🛡️ Authorization markers are not a sandbox

The strict profile can use markers such as `ALLOW_DEPLOY=true` as visible task-policy signals. They do not grant operating-system permissions, bypass the Codex sandbox, authenticate a user, or make a command safe. Platform permissions, the actual command, and the latest explicit user instruction must still be reviewed.

## 🧪 Validation

Run the public-safety scan before every public commit that changes profiles, scripts, examples, or privacy documentation:

```powershell
pwsh -NoProfile -File .\scripts\Test-Repository.ps1
```

The repository test first parses every PowerShell script, then runs the public-safety scan. The scan checks configured private literals when `.local/user-settings.psd1` exists and also detects common private-key and credential formats. It is a guardrail, not a complete secret-scanning product.

## 🧱 Repository layout

```text
codex-agents-playbook/
├─ AGENTS.md
├─ README.md
├─ README.zh-CN.md
├─ LICENSE
├─ CHANGELOG.md
├─ SECURITY.md
├─ CONTRIBUTING.md
├─ profiles/
│  ├─ minimal/AGENTS.template.md
│  ├─ standard/AGENTS.template.md
│  └─ strict/AGENTS.template.md
├─ scripts/
├─ examples/
├─ docs/
└─ .local/                 # ignored, private, local only
```

## 🗺️ Roadmap

- Scenario-based behavioral tests for each profile
- macOS and Linux render/install scripts
- Tagged bootstrap releases with checksums
- Optional profile composition instead of full-file duplication
- CI validation for placeholders, Markdown links, and sensitive literals
- Versioned migration notes for installed local rules

Roadmap items are proposals, not implementation promises.

## 🤝 Contributing

A useful rule change should describe the observed failure mode, affected environment, proposed wording, trade-offs, and a way to validate behavior. Avoid adding rules only because they sound stricter; every rule consumes context and reduces flexibility.

Read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a change.

## 📜 License

MIT License. See [LICENSE](LICENSE).

## 🙏 Acknowledgements

This playbook grew from repeated use of ChatGPT and Codex across local development, automation, documentation, Git workflows, testing, and long-running project recovery.
