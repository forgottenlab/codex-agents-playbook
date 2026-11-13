# Missing UI history recovery

Applies: project remains visible but earlier tasks/conversations are missing.
Load before changes; entry also selects context and history. No recursive imports.

Treat this as an indexing/visibility problem until local and account-level evidence
proves otherwise. Do not assume source or context was deleted.

1. Confirm the same account and workspace are in use, without exposing credentials.
2. Read global AGENTS.md.
3. Read current project `.ai` context.
4. Read the two most recent task-history directories.
5. Run `git status --short --branch`, `git log -8 --oneline --decorate`,
   and `git diff --check`.
6. Read README, build configuration and targeted source files.
7. Produce a read-only report: Git baseline, recovered state, completed phases,
   accepted decisions, next task and unresolved uncertainties.
8. Stop and wait for confirmation before modifying source code.

Do not clear application data, delete local databases, reinstall the application,
overwrite `.ai`, recreate history from assumptions or expose private session files
unless explicitly authorized after a backup and recovery plan. Entry secret
protections remain applicable; this wording does not authorize disclosure.
