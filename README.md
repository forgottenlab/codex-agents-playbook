# Codex AGENTS Playbook

> Reusable Codex instruction profiles and a source-derived ChatGPT companion for a scoped, evidence-based engineering workflow.

[English](README.md) | [简体中文](README.zh-CN.md)

> [!IMPORTANT]
> Community-maintained and opinionated; not an official OpenAI project. Instructions do not provide a security sandbox or replace command review, platform permissions and backups.

## ✨ Why this project exists

ChatGPT prepares a bounded task; Codex inspects the actual checkout, executes that task and returns evidence for review. Separating these responsibilities helps keep proposals distinct from repository facts, avoids turning simple commands into agent workflows, and makes continued work easier to review.

These are workflow responsibilities, not changes to platform instruction priority. Codex can still plan the local steps needed to execute an authorized task.

## 🤝 Paired ChatGPT / Codex workflow

| System | Owns |
|---|---|
| ChatGPT | Accuracy, conversation scope, Direct Shell / Codex routing, architecture discussion, model/reasoning recommendations, prompt design, cross-session planning and result review |
| Codex | Repository inspection, scoped changes, context-dependent commands, worktree protection, tests, project fact isolation and concise factual handoff |

Small deterministic commands normally stay in Direct Shell Mode: give the user a copyable command, purpose and expected result. Repository-dependent investigation, edits, worktree protection and test/fix/retest belong in Codex Task Mode. Keep simple commands inside a larger audit when splitting would harm safety or reproducibility.

Model and reasoning recommendations stay **outside** the copyable execution prompt. They are choices for the user's UI; the prompt must not tell Codex to switch models.

See the [paired workflow and 12-point consistency review](docs/PAIRED-WORKFLOW.md).

## 🚀 What is included

| Component | Purpose |
|---|---|
| `profiles/minimal` | Essential scope, privacy, Git, validation and handoff safeguards |
| `profiles/standard` | Recommended default with workspace, remote-operation, documentation and compact context guidance |
| `profiles/strict` | Modular entry plus `personal-rules/` for routing, Git review, verification, context, history, recovery and handoff |
| `chatgpt/custom-instructions.zh-CN.txt` | Plain, directly copyable instructions generated from the supplied ChatGPT source |
| `scripts/Initialize-LocalWorkspace.ps1` | Creates ignored private settings and a rendered Strict source package |
| `scripts/Install-CodexAgents.ps1` | Renders a profile and backs up every existing destination file before replacement |
| `scripts/New-PublicSnapshot.ps1` | Sanitizes private Strict or ChatGPT inputs, checking all candidates before writing |
| `scripts/Test-Repository.ps1` | Runs syntax, privacy, artifact and isolated workflow checks |
| `scripts/Bootstrap-CodexAgents.ps1` | Visible clone/update and initialization flow; no pipe-to-shell execution |
| `.local/` and `.ai/` | Ignored private inputs, test fixtures and local operational records |

The repository root `AGENTS.md` governs maintenance of this repository. Installable instructions live under `profiles/`.

## 🌐 Rule language

English is canonical for the installable Codex rules. User-facing explanations use the configured language. The ChatGPT companion preserves its supplied Simplified Chinese language. English and Chinese documentation explain the same setup and boundaries; language alone does not ensure reliable behavior.

## 🧭 Profiles and personal choices

| Profile | Best for | Main trade-off |
|---|---|---|
| Minimal | Small repositories and short tasks | Least process, limited continuity |
| Standard | Most personal and open-source projects | Balanced safety and context |
| Strict | Continuing, staged or recovery-sensitive work | More files and explicit module-reading duties |

Strict now installs an entry and eight supporting files. Modules are **not automatically imported by Markdown links**: the entry tells Codex when to read them with a file-reading tool. Missing required modules stop dependent work. `INDEX.md` is for humans and is not a mandatory execution step.

Workspace layout, Chinese explanations, the ChatGPT/Codex split, authorization markers, detailed history and the two-cycle repair budget in Strict are personal workflow choices. Review them before adopting them. Minimal and Standard retain their existing templates; they do not promise Strict's detailed routing and history rules.

## 📦 Install the Codex profile

Requirements: Git and PowerShell 7.2 or newer. Checks were executed with PowerShell 7.6.3; the minimum version was not separately tested.

```powershell
git clone https://github.com/forgottenlab/codex-agents-playbook.git
Set-Location .\codex-agents-playbook
pwsh -NoProfile -File .\scripts\Initialize-LocalWorkspace.ps1
```

Initialize once. If `.local/user-settings.psd1` already exists, review and preserve it rather than rerunning with `-Force`. Initialization creates private inputs; it does not install global rules unless `-InstallGlobal` is explicitly supplied.

Review paths, identity and language in the settings, then preview and install:

```powershell
pwsh -NoProfile -File .\scripts\Install-CodexAgents.ps1 `
  -Profile strict -SettingsPath .\.local\user-settings.psd1 -WhatIf

pwsh -NoProfile -File .\scripts\Install-CodexAgents.ps1 `
  -Profile strict -SettingsPath .\.local\user-settings.psd1
```

Choose `standard` for the recommended lighter default. The default target is `%USERPROFILE%\.codex\AGENTS.md`; use `-TargetPath` for another Codex home or a local preview. Strict's modules go into `personal-rules/` beside that target. Do not copy only the Strict entry.

Existing files being replaced receive a shared timestamp-and-random-suffix backup. Unrelated files remain in place. Installation is a sequence of writes, not a transactional update; if interrupted, inspect the backups and restore the affected entry and modules as a set before retrying.

Review any existing `AGENTS.override.md` and custom `CODEX_HOME`: they can change which global file is read. Start a new Codex session and verify the active instruction sources after installing. See [official instruction discovery](https://learn.chatgpt.com/docs/agent-configuration/agents-md).

## 💬 Copy the ChatGPT instructions

Open [custom-instructions.zh-CN.txt](chatgpt/custom-instructions.zh-CN.txt), select its entire contents and paste them into the ChatGPT custom-instructions field. Copy only the file contents. The file contains instructions without a surrounding explanation or code fence.

The generator enforces this release's 5,000-character budget using conservative UTF-16 counting, including whitespace. The supplied source leaves room below that budget. Verify the field offered by your account; this repository does not test a live ChatGPT UI or change your account settings.

Review the language, workflow and model-selection guidance before saving. The companion uses model capability categories rather than freezing a model catalog.

## 🔐 Private source to public snapshot

```text
Installed/local Codex instructions       User-supplied ChatGPT instructions
             ↓ copy/reconcile privately              ↓
.local/AGENTS.source.md + personal-rules/    .local/chatgpt-custom-instructions.source.txt
             ↓ sanitize and review                   ↓
profiles/strict/ entry + modules           chatgpt/custom-instructions.zh-CN.txt
             ↓ render
User's local Codex installation
```

Keep machine values in `.local/user-settings.psd1`. Before reconciling an existing private source, back it up. Copy and review the installed entry **and its modules**; initialization alone renders the public template and does not discover installed changes.

```powershell
pwsh -NoProfile -File .\scripts\New-PublicSnapshot.ps1
pwsh -NoProfile -File .\scripts\New-PublicSnapshot.ps1 -Kind ChatGPT
pwsh -NoProfile -File .\scripts\Test-Repository.ps1
git diff --check
git status --short
git diff
git diff --cached
```

Missing or empty ChatGPT input fails without replacing its public output. Generation removes presentation separators and Markdown heading syntax, normalizes line endings and sanitizes configured values; it does not invent active instructions. If privacy replacement leaves a placeholder in the copyable ChatGPT text, generation stops for manual review.

See [privacy and sanitization](docs/PRIVACY-AND-SANITIZATION.md) for the transformation boundary and private-source workflow.

## 🧩 Customization and placeholders

| Placeholder | Setting |
|---|---|
| `{{WORKSPACE_ROOT}}` | Workspace root |
| `{{PROJECTS_DIR}}` | Long-term projects |
| `{{AUTOMATIONS_DIR}}` | Persistent automation |
| `{{SANDBOX_DIR}}` | Temporary experiments |
| `{{ARCHIVED_DIR}}` | Archives |
| `{{TEMPLATES_DIR}}` | Reusable templates |
| `{{USER_PROFILE}}` | Current OS user profile, supplied by the installer |
| `{{GITHUB_USERNAME}}` | GitHub identity, when used in a template |
| `{{PREFERRED_LANGUAGE}}` | Language for user-facing explanations |

Use your own values in private settings, starting from [the example](examples/user-settings.example.psd1). Public Codex templates retain placeholders; rendered local files must contain none. The public repository URL identifies this project intentionally; downstream forks should review it. See [customization](docs/CUSTOMIZATION.md).

## 🛡️ Authorization and privacy boundaries

Strict's `ALLOW_REMOTE_READONLY=true`, `ALLOW_REMOTE_VALIDATE=true`, `ALLOW_DEPLOY=true` and `ALLOW_SECRET_FILE_MOVE=true` are task-policy signals. They do not grant OS permissions, authenticate an account or override platform controls. A marker authorizes only its stated scope.

Never publish `.local/`, `.ai/`, rendered private files, credentials, session files or private operational records. Regex scans cannot prove absence of personal data: independently review names, paths, hosts, email addresses, project references and links.

## 🧪 Validation

```powershell
pwsh -NoProfile -File .\scripts\Test-Repository.ps1
```

The suite parses `.ps1` and `.psm1`, scans public files, checks documented placeholders, supporting modules, ChatGPT length and relative file links, then exercises installation and generation under ignored `.local/validation-*` fixtures. Fixtures are retained for review. Tests never install global rules or contact remote services.

The consistency review is a human assessment recorded in [the paired workflow](docs/PAIRED-WORKFLOW.md); automated checks do not establish model compliance. External link availability, ChatGPT UI behavior, interrupted-install recovery and every filesystem failure mode are not integration-tested.

## 🧱 Repository layout

```text
codex-agents-playbook/
├─ AGENTS.md                     # repository maintenance rules
├─ README.md / README.zh-CN.md
├─ profiles/
│  ├─ minimal/AGENTS.template.md
│  ├─ standard/AGENTS.template.md
│  └─ strict/
│     ├─ AGENTS.template.md
│     └─ personal-rules/
├─ chatgpt/custom-instructions.zh-CN.txt
├─ scripts/
├─ examples/
├─ docs/
├─ .local/                       # ignored private source and fixtures
└─ .ai/                          # ignored local continuity
```

## 🗺️ Roadmap

Scenario-based model behavior checks, macOS/Linux installers, tagged bootstrap checksums and versioned migration tooling remain possible future work. A roadmap does not authorize implementation.

## 🤝 Contributing

Read [CONTRIBUTING.md](CONTRIBUTING.md). Rule changes should identify an observed failure mode, cost and validation method. Keep changes focused and review public diffs before staging explicit files.

## 📜 License

MIT License. See [LICENSE](LICENSE).
