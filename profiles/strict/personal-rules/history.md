# Task continuity and available-session archive

Applies: non-trivial, staged, risky or long-running tasks; available-session archiving.
Load before project modifications. Prerequisite: entry scope and authority; no imports.

## Trigger and lifecycle

A task is non-trivial when it includes source modification, multiple files/modules,
architecture/compatibility decisions, migration, multi-step commands/tools for
repository inspection/modification/testing/debugging/migration/evidence collection,
tests/builds/packaging/deployment preparation, or work that may continue in a later
session. Direct Shell commands and returning deterministic commands alone do not
trigger history.

## Write authorization before history

A. Normal development: maintain `.ai` within authorized project scope, reusing the
established context and preserving prior documents/history.
B. Business-source read-only with explicit audit-output permission: write history
only in that approved output location, not automatically in repository `.ai`.
C. Strict read-only or any explicit no-write task: do not create/update `.ai` or any
other file, even when the task is non-trivial. Report that no history was saved.

Ambiguity is not write authorization. Request the missing scope decision when needed;
do not reinterpret mandatory history as automatic permission. Temporary Sandbox work
does not initialize `.ai` merely because the task is complex; use only explicitly
authorized persistent output or disclose the continuity limitation. State the actual
saved path or the reason history was not saved at handoff.

Before project changes: determine workspace, actual Git root, project name and
established context location; read applicable global/project rules; check status and
protect user work; create task history and save the visible task and execution plan.

After execution: save visible result and concise summary; record commands and
test/build evidence; update current context, result and next-task files; update
decisions only for actually accepted durable decisions; record final status and risks.
A task is not complete until required continuity is updated, except when a higher
priority scope restriction prevents writing: disclose that exception under the entry.

Current `NEXT.md` / `next_codex_task.md` contains only current state, next objective,
scope, acceptance criteria and blocking decisions. Persist a full conversational
next prompt only when explicitly requested.

## Required evidence layout

```text
.ai/history/YYYY-MM-DD_HHmmss-task-slug/
├─ prompt.md
├─ plan.md
├─ conversation.md
├─ result.md
├─ summary.md
├─ metadata.md
└─ logs/
   └─ commands.md
```

- `prompt.md`: original task for this stage.
- `plan.md`: approved or proposed execution plan.
- `conversation.md`: visible prompts, responses and relevant follow-ups available
  in this session. State gaps; never invent earlier messages.
- `result.md`: final visible report.
- `summary.md`: concise next-session handoff.
- `metadata.md`: project, branch, start/end, status, relevant commit identifiers.
- `logs/commands.md`: commands, exit status and concise evidence.

Maintain `.ai/history/INDEX.md` after each significant task: timestamp, slug, branch,
Planned/In Progress/Completed/Blocked/Aborted, one-sentence outcome, task-directory
link and commit/PR when available. It does not replace current context.

## Archive boundary and privacy

Mandatory task continuity is the lifecycle and evidence obligation above, subject to
write authorization. Available-session archiving defines the extent of conversational
material that can be included, not an obligation to recover unavailable messages.
When visible material is available and writing is authorized, preserve original task,
accepted plan, relevant visible follow-ups, final result, command/test evidence and
handoff using the same history layout. Record unavailable material as a gap; do not
invent it or export hidden sessions to fill it. This archive does not create a separate
workflow or override strict read-only scope.

Do not store hidden reasoning, token-by-token generation, internal tool protocol,
secrets/private credentials, or unrelated browser/application logs.
The archive is user-controlled project recovery evidence, not a complete export of
the application's internal conversation database.

Before writing, redact passwords, API keys, access tokens, cookies, session IDs,
private keys, private connection links, production UUIDs, unnecessary private repo
URLs, sensitive logs and unrelated personal data. Use `REDACTED`, `example-token`,
`example.invalid` or `config.example.json`. Never copy terminal secrets into `.ai`.

## Failures and relationship to Git

If context cannot be read/written: do not claim it was saved; stop before risky or
multi-stage modifications when possible; report exact path/error; ask permission
for an alternative directory. A denied write is not authorization to choose one.

Git records source changes; `.ai` records intent, decisions, execution evidence and
handoff. Project-external context must not be added to the repository; local context
follows explicit repository policy. Do not commit task history by default.
Current state, accepted rules and verified tests outrank historical records.
