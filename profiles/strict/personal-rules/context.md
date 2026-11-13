# Durable project context

Applies: new long-lived projects or persistent automation, planning/context files, context initialization or recovery.
Load before context decisions or writes. Prerequisite: entry authority order; no imports.

## Location, naming and truth

`.ai` bridges ChatGPT planning and Codex execution. Sidebar/chat history is a
convenience; continuity must be recoverable from local files and Git.
Resolve context directory in order:

1. Latest user-provided path.
2. Existing workspace-level `<workspace-root>/.ai/<project-name>/`.
3. Existing repository-local `<repository-root>/.ai/`.
4. For a new long-lived project without an established context, create the smallest
   necessary repository-local `.ai` within authorized write scope. Confirm before
   creating a context directory outside the repository.

Reuse the established location; do not silently create competing contexts.
Preserve existing filenames, rather than renaming for style.

## Defaults by project type and write scope

- `{{PROJECTS_DIR}}`: new long-lived projects default to a minimal necessary
  `.ai`; existing projects reuse established context and retain documents/history.
- `{{AUTOMATIONS_DIR}}`: new persistent automation projects likewise create
  or reuse `.ai` for objectives, configuration explanations, execution evidence and
  handoff. This does not imply moving the Codex Desktop internal task database.
- `{{SANDBOX_DIR}}`: temporary experiments do not initialize `.ai` by default.
  Initialize only when the user explicitly requests persistence or approves conversion
  to a long-lived project. A non-trivial experiment alone does not waive this condition.

Create only needed files with real content (for example context and current handoff),
not empty copies of every possible planning file. History for an experiment may use
an explicitly authorized output location; its requirement never authorizes creating
`.ai` in a temporary experiment against the rule above. If no location is authorized,
report the continuity gap and seek the needed decision before dependent risky work.

Normal development may maintain context within authorized scope. If business source
is read-only but audit output is explicitly allowed, write only in that output location.
Strict read-only/no-write tasks cannot create or update `.ai` or other files. Ambiguous
write scope is not resolved by assuming history permission. Preserve existing context
and history; report whether anything was saved.

Detailed convention: `README.md`, `project_context.md`, `codex_rules.md`,
`decisions.md`, `roadmap.md`, `architecture.md`, `ideas.md`, `compatibility.md`,
`migration-plan.md`, `documentation-plan.md`, `next_codex_task.md`,
`codex_result.md`, `history/`.
Compact convention: `CONTEXT.md`, `DECISIONS.md`, `RULES.md`, `NEXT.md`,
`RESULT.md`, `history/`.
Small projects may use only context, rules, next-task and result files.
Never create empty planning files without a real need.

When local evidence and UI history disagree, prefer:
current repository/build/test evidence → accepted `.ai` decisions →
current context/next task → recent summaries/command evidence →
README/maintained docs → visible chat history.
Do not reconstruct from memory a fact that can be verified locally.
This truth hierarchy is distinct from the entry's implementation-authority order.

Enable appropriate planning files for open-source repositories, libraries,
frameworks, SDKs, reusable tools, multi-module systems and compatibility-sensitive
projects, not empty structures for small experiments.

## File responsibilities

| File | Required meaning and content |
|---|---|
| `project_context.md` | Verified purpose, stack, architecture, current status, constraints, testing expectations; no speculation |
| `decisions.md` | Accepted decisions only: date, decision, reason, alternatives, consequences; ideas are not decisions |
| `roadmap.md` | Future direction; neither authorization nor release promise; separate future from current state |
| `architecture.md` | Current and target architecture, module boundaries, dependency direction, migration stages, open questions; never call planned work implemented |
| `ideas.md` | Each idea: status, problem, value, cost, risk, dependencies; never coding authorization |
| `compatibility.md` | Verified versions, supported environments, API compatibility, breaking-change rules, known risks; no unsupported claims |
| `migration-plan.md` | Steps, rollback strategy, compatibility notes, validation checklist; prefer incremental migration |
| `documentation-plan.md` | Structure, bilingual policy, synchronization rules, missing documents |

Idea statuses: Candidate; Under Discussion; Accepted for Roadmap; Deferred;
Rejected; Implemented.

## Context initialization

`dotai init`, `init ai context` and `build ai` mean context initialization only,
not building AI products, integrating AI APIs or creating agents.
Read global and project rules, inspect lightweight docs, then create or refresh
`.ai` within the authorized location; do not modify source code.
Preserve user content. Never overwrite `next_codex_task.md`, user-written decisions
or existing planning documents without approval.
If routine handoff updates would conflict with that protection, retain existing content
and report the required decision; lifecycle requirements do not silently grant overwrite permission.
Initialization reporting is triggered through the entry's handoff route.

## Project Context Location

- The default `.ai` location is the actual project root,
  which is not necessarily the Git repository root.

- Independently maintained subprojects may have their
  own `.ai` directories when they have separate goals,
  assets, workflows, or lifecycles.

- Ordinary feature directories must reuse their parent
  project's established `.ai` context.

- Always reuse existing context before creating a new one.

- Do not relocate, merge, or delete existing `.ai`
  directories without explicit authorization.

- Strict read-only tasks must not create or update `.ai`.
