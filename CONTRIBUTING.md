# Contributing

Thank you for improving Codex AGENTS Playbook.

A useful change should include:

1. The observed failure mode or workflow problem.
2. The environment where it occurred.
3. The proposed rule, script, or documentation change.
4. Expected trade-offs in context size, flexibility, or execution time.
5. A validation scenario or command.

Before submitting:

```powershell
pwsh -NoProfile -File .\scripts\Test-Repository.ps1
git diff --check
git status --short --branch
```

Keep `README.md` and `README.zh-CN.md` structurally synchronized. Never include `.local/` or private values.

Use focused commits such as:

```text
docs: clarify placeholder replacement workflow
fix: prevent unresolved placeholders during install
test: add private-value scan coverage
```
