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
