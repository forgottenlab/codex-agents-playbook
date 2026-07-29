# Repository Instructions for Codex AGENTS Playbook

## Scope

These instructions apply to this repository. They govern maintenance of the playbook,
profiles, PowerShell scripts, documentation, and examples. They are not the installable
end-user profile; installable templates live under `profiles/`.

## Core rules

- Preserve the separation between public templates and private local configuration.
- Never commit `.local/`, `*.local.psd1`, private source files, credentials, or machine-specific values.
- Keep `README.md` and `README.zh-CN.md` structurally synchronized.
- Keep English as the canonical language for installable `AGENTS.template.md` files.
- Do not add an instruction merely because it sounds stricter; document the failure mode, cost, and validation method.
- Prefer narrow, reviewable changes and preserve existing user work.
- Do not push, publish a release, rewrite Git history, or modify repository settings without explicit authorization.

## Profile policy

- `minimal`: essential scope, secret, Git, validation, and handoff safeguards.
- `standard`: the recommended default, adding workspace, remote-operation, documentation, and compact `.ai` guidance.
- `strict`: the complete workflow, adding durable task history, authorization markers, recovery, and detailed context governance.
- A stricter profile may add safeguards, but must not silently weaken rules inherited from a lighter profile.

## Privacy and sanitization

- Private values belong only in `.local/user-settings.psd1` and `.local/AGENTS.source.md`.
- Public templates must use documented placeholders such as `{{WORKSPACE_ROOT}}`.
- Never use `git add -f` to force-add `.local/`.
- After changing templates, scripts, examples, or privacy documentation, run:

```powershell
pwsh -NoProfile -File .\scripts\Test-Repository.ps1
```

- When a private local source is intentionally updated, generate the public strict snapshot with:

```powershell
pwsh -NoProfile -File .\scripts\New-PublicSnapshot.ps1
```

Review the resulting diff before staging it.

## PowerShell scripts

- Target PowerShell 7.2 or newer unless compatibility is explicitly broadened and tested.
- Use `Set-StrictMode -Version Latest` and `$ErrorActionPreference = 'Stop'`.
- Back up an existing global `AGENTS.md` before replacing it.
- Do not download and execute remote code through `Invoke-Expression` or an equivalent pipe-to-shell pattern.
- Bootstrap flows may clone a repository, but must make the destination and subsequent install step visible.
- Scripts must fail when required placeholders remain unresolved in a rendered local file.
- Public-safety scans must not print secret values in error output.

## Git safety

Before committing:

1. Run `git status --short --branch`.
2. Inspect `git diff` and `git diff --cached`.
3. Stage explicit files or use `git add -p`.
4. Confirm `.local/` and generated private files are absent.
5. Run the smallest relevant tests and the public-safety scan.

Do not claim success without command evidence. If PowerShell execution was unavailable,
state that scripts received only static validation and identify the remaining risk.
