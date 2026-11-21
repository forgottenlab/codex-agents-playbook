# Customization Guide

[English](CUSTOMIZATION.md) | [简体中文](CUSTOMIZATION.zh-CN.md)

## Choose a profile

- Use **minimal** for disposable or small tasks.
- Use **standard** for most projects.
- Use **strict** when task continuity, remote-operation boundaries, detailed `.ai` history, or UI-history recovery materially matters.

## Rendering, discovery, and authority are different mechanisms

Do not treat template rendering, instruction discovery, and instruction priority as one override chain.

1. **Rendering (before installation):** Select one public profile and substitute private machine values from ignored local settings. Those values configure the generated file; they are not a higher-priority instruction layer.
2. **Discovery (when Codex starts):** Codex reads applicable global and project instructions. Check the effective `CODEX_HOME` (or its default), any `AGENTS.override.md`, and the `AGENTS.md` files along the repository-to-working-directory path. More specific directory guidance can refine broader guidance; verify the files actually selected in a new session.
3. **Authority (while executing):** Project instructions and user tasks operate within platform instruction and permission boundaries. A later task request does not automatically override higher-priority instructions, authorization limits, or safeguards.

These profiles are **alternative installation choices**, not three simultaneously active modes. Direct Shell and Codex Task are task-routing decisions, not installation profiles. Under modular Strict, the entry must explicitly load relevant `personal-rules/` files; Markdown links alone do not import them.

Do not use a global rule for a project-specific exception that belongs in the repository.

## Grok Strict updates and recovery

Use `-Client Grok -Profile strict -SettingsPath <settings>` with the installer. `-TargetDirectory` selects the Grok home, while `-TargetPath` selects a Codex entry file. Grok Minimal, Standard and project installs are unsupported. Bootstrap and initialization still target Codex.

The installer renders the public Strict companions with your settings and checks all seven routes before writing. Each route is relative to `rules/playbook-entry.md`. To customize workflow text, edit the Grok entry template or the shared Strict module source in your checkout. Shared module edits also affect future Codex Strict renders. Keep private values in the settings file. Extra native Markdown rules belong in `rules/` and Skills have their own `skills/<name>/SKILL.md` layout. The installer only manages the playbook entry and its companions.

Preview with `-WhatIf`. Identical files keep their timestamps. A same-name user file, a manually edited installed file or a linked destination stops installation before backup. Preserve a conflicting file separately and reconcile it yourself. The installer's content checksum detects edits. It is not a signature.

For each changed run, `playbook/backups/<batch>/manifest.json` records relative paths and SHA-256 hashes before and after the change. The same directory holds copies of replaced files. Keep it private. Backup preparation precedes all instruction writes. A preparation failure may leave an incomplete backup directory. Once prepared, the installer writes modules first and publishes the entry last. An interruption can leave a mix of versions.

Use the home and batch ID printed by the installer. Restore newer batches first. Preview the recovery, then run the same command without `-WhatIf` to apply it.

```powershell
.\scripts\Restore-GrokAgents.ps1 -TargetDirectory $grokDirectory -Batch $batchId -WhatIf
```

Recovery checks the batch before writing. It skips files already at their prior hash, restores replaced files and removes files created by the batch if their installed hashes still match. A later manual edit or damaged required backup stops recovery. Resolve the difference before retrying. Recovery can be resumed and leaves backups and directories in place.

## Values to review

- Workspace paths
- Preferred explanation language
- Git push and release policy
- Remote-operation policy
- `.ai` layout and history retention
- Required test commands
- Documentation synchronization rules
- Project-specific generated folders and sensitive files

## Keep rules testable

Prefer an observable rule such as “run the targeted test and report the command” over an abstract rule such as “be careful.” Every major rule should correspond to a failure mode or validation scenario.
