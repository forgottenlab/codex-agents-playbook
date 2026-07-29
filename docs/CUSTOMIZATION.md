# Customization Guide

[English](CUSTOMIZATION.md) | [简体中文](CUSTOMIZATION.zh-CN.md)

## Choose a profile

- Use **minimal** for disposable or small tasks.
- Use **standard** for most projects.
- Use **strict** when task continuity, remote-operation boundaries, detailed `.ai` history, or UI-history recovery materially matters.

## Override order

A practical order is:

```text
Public profile template
        ↓
Private machine values
        ↓
Repository-level AGENTS.md
        ↓
More deeply nested AGENTS.md
        ↓
Latest explicit task instruction
```

Do not use a machine-level rule to encode a project-specific exception that belongs in the repository.

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
