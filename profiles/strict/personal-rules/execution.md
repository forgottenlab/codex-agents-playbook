# Execution and workspace

Applies: repository-aware work, workspace choice, or uncertain execution routing.
Load before that work. Prerequisite: the entry AGENTS.md; no module-to-module imports.

## Workspace placement

Defaults:

| Purpose | Path |
|---|---|
| Long-term projects | `{{PROJECTS_DIR}}` |
| Automation | `{{AUTOMATIONS_DIR}}` |
| Temporary experiments | `{{SANDBOX_DIR}}` |
| Archives | `{{ARCHIVED_DIR}}` |
| Templates | `{{TEMPLATES_DIR}}` |

`{{WORKSPACE_ROOT}}` is not a project workspace. Long-lived work needs a specific project
directory. Global `C:\Users\<user>\.codex\AGENTS.md` is configuration, not a project:
do not place project source, logs, build outputs or long-term project documents
beside it. Do not create long-term project files under `C:\Users`, Desktop,
Documents, Downloads, OneDrive or iCloudDrive without explicit approval.
The Owner-authorized `personal-rules/` is a global configuration extension containing
private rule modules, not project evidence, logs, source or history. This directory exception does not authorize unrelated configuration changes.

## Routing criteria

ChatGPT normally routes before creating an execution prompt; Codex checks routing
again when the task arrives. Agent execution is justified by context dependence,
iteration, modification or evidence collection, not the existence of a command.

Use the entry's Direct Shell procedure for small deterministic operations without:
repository understanding; source or multi-file modification; protection of unrelated
worktree changes; iterative diagnosis; test/fix/retest; architecture, migration or
compatibility reasoning; substantial agent-side evidence collection.

Examples: tool versions, ordinary directory creation, archive extraction, isolated
file existence/content checks, Git config/remote/branch operations, environment/path
inspection or one-step configuration when no repository reasoning is needed.
These examples do not waive the entry's authorization requirements.

Use Codex Task Mode when any of those context-dependent requirements exists.
A simple command within an audit, debug, migration, testing or evidence workflow
can be executed as part of that task. Prefer the simpler transparent option when
both modes work reliably.

For mixed tasks, separate deterministic setup when practical: give the prerequisite
to the user, inspect returned output only if needed, then perform repository-aware
work. Do not split mechanically when that harms safety, reproducibility or validation.

## Efficient inspection

Prefer: applicable AGENTS.md → existing `.ai/` → README → maintained docs →
build configuration → targeted source.
Use available context rather than reconstructing the entire project.
Avoid unnecessary scans, especially `node_modules`, `.venv`, `venv`, `dist`,
`build`, `.cache`, logs, backups, generated files and dependency directories.

## Project evidence boundaries

The explicitly targeted project is the active context. Do not transfer implementation
facts, versions, branches, commits, tests, accepted decisions, roadmap status or
issues from another project. A comparison or analogy is not authorization to inspect
or change that other project.

For explicit cross-project work: identify each project; label its evidence; verify
each checkout independently where applicable; separate shared assumptions from
project facts; support every transferred conclusion with evidence.
When the latest task shifts to independent work in another repository, report the
scope change and stop treating the previous repository as the implementation target.
Conversation routing belongs to ChatGPT; factual isolation remains Codex's duty.
