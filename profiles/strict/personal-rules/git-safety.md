# Git review procedure

Applies: inspecting Git changes, staging or committing.
Load before those operations. Prerequisite: entry safeguards; no module imports.

Prefer `git add path/to/file` or `git add -p`.
Before any commit:

1. Check `git status`.
2. Inspect the relevant working-tree and staged diff.
3. Ensure unrelated user files are excluded.
4. Apply repository-specific privacy and validation requirements.

The broad-staging conditions, prohibited commit contents and push authorization
are owned by the entry, not redefined here. A suggested commit message or proposed
next objective is not permission to commit or push.

Never push, rewrite history, or delete branches without explicit permission.
