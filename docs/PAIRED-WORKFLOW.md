# Paired ChatGPT / Codex Workflow

[English](PAIRED-WORKFLOW.md) | [简体中文](PAIRED-WORKFLOW.zh-CN.md)

## Scope and evidence

This review compares the [source-derived ChatGPT companion](../chatgpt/custom-instructions.zh-CN.txt) with the [Strict entry](../profiles/strict/AGENTS.template.md) and its supporting modules. Minimal and Standard are lighter alternatives, not equivalent copies.

The Codex source is the actual installed modular entry and its sibling modules, copied privately for publication. The ChatGPT source is the user-supplied local text file. File provenance does not establish which settings a live ChatGPT account currently has enabled. The owner explicitly approved publishing the modular Strict structure. Release preparation did not reinstall global rules; a later separately authorized local status correction changed entry metadata only, preserving the supporting modules.

Generation normalizes the installed entry's stale candidate title and staging-only description, translates the human-only module index into English, replaces configured environment values, and normalizes line endings. The execution module's obsolete candidate-installation sentence becomes a general boundary against unrelated configuration changes. Strict also retains Minimal's existing prohibition on unauthorized history rewriting and branch deletion in its Git module, as required by profile inheritance. ChatGPT transformations remove presentation separators, heading markers and trailing presentation whitespace without changing its task rules. Private raw inputs are retained.

## Responsibilities

ChatGPT determines conversation scope and prepares an authorized execution task. It discusses architecture, decomposes work, recommends model/reasoning settings outside the prompt, plans across sessions and reviews results.

Before naming a Codex model, check current official model and product information. A release announcement establishes release status. Product support and the choices visible in the current account and client need separate evidence. Choose among available options by task fit, reasoning effort and usage cost. If current evidence is unavailable, state the uncertainty and recommend a capability level conditionally.

Codex verifies local facts, makes scoped changes and provides command/test evidence. Its local execution plan does not take over conversation routing or long-term architecture ownership. The ChatGPT source's “architecture design” Codex trigger means repository-dependent inspection, feasibility checks or implementation work; a conceptual architecture discussion remains with ChatGPT and the user. Major decisions still require confirmation.

A comparison with another project does not authorize inspecting or modifying it. A new independent implementation task should identify its repository explicitly.

## Consistency review

Allowed classifications: CONSISTENT, INTENTIONAL_SEPARATION, MINOR_DRIFT, CONFLICT, NEEDS_USER_DECISION. Different detail levels alone do not constitute a conflict.

| Check | Classification | Evidence and operational meaning |
|---|---|---|
| Conversation Scope / Project Context Isolation | INTENTIONAL_SEPARATION | ChatGPT source's conversation section routes discussion; Strict entry and execution module independently verify and isolate project facts. Codex does not select the ChatGPT chat. |
| Direct Shell definitions and exceptions | CONSISTENT | Both use repository independence and deterministic work as the criteria. The Strict entry exempts obvious commands from unrelated module loading; high-risk safeguards still apply. |
| Codex Task triggers | INTENTIONAL_SEPARATION | ChatGPT routes actual repository work; execution.md rechecks context dependence. Architecture discussion and user decisions stay with ChatGPT; Codex supplies evidence and authorized execution. |
| Mixed tasks | CONSISTENT | Both separate simple prerequisites when useful and keep them together when splitting harms safety, reproducibility or validation. |
| Windows conventions | CONSISTENT | Both default to PowerShell and use the appropriate shell for explicitly identified Linux/macOS targets. Paths and identifiers keep their original form. |
| High-risk operations | INTENTIONAL_SEPARATION | ChatGPT proposes read-only checks, dry-runs and backups. Strict defines execution-time confirmation, environment-change boundaries and explicit remote markers. Marker strings belong in the authorized task when needed. |
| Git and worktree safety | CONSISTENT | ChatGPT routes worktree-sensitive work to Codex; the Strict entry and git-safety.md require status/diff review, preservation of unrelated work and controlled staging. |
| Prompt ownership | CONSISTENT | ChatGPT creates task-specific prompts only when implementation is settled. Strict entry/handoff.md reject automatic complete next-round prompts; explicit user requests remain possible. |
| Model / Reasoning separation | INTENTIONAL_SEPARATION | ChatGPT recommends UI choices outside the task prompt. Codex owns execution, not model selection; the Strict rules do not duplicate model catalogs. |
| Task history | INTENTIONAL_SEPARATION | ChatGPT avoids artifacts for simple commands. Strict history.md defines non-trivial task continuity, Direct Shell exceptions, read-only restrictions and privacy. Temporary experiments need persistence authorization. |
| Final handoff | CONSISTENT | ChatGPT reviews results; Strict handoff.md requires changed files, behavior, commands, validation, remaining risks and one short next objective. Unrun checks remain unverified. |
| Cross-project fact isolation | CONSISTENT | ChatGPT separates project facts during broad discussions. Strict requires independent checkout verification and prevents transferring versions, tests or accepted decisions without evidence. |

Result: **7 CONSISTENT, 5 INTENTIONAL_SEPARATION**. No unresolved CONFLICT or NEEDS_USER_DECISION in this comparison. Stale candidate metadata was MINOR_DRIFT and was normalized in public output. These are manual content-review conclusions, not proof of model behavior.

## Installation migration

The previous public Strict was a single Complete Edition. The modular form keeps safeguards in the entry and loads detailed procedures only when triggered. Install the entry and all eight supporting files together using the [installer](../scripts/Install-CodexAgents.ps1).

1. Review settings and existing instruction overrides.
2. Use `-WhatIf` and an explicit `-TargetPath` for a local preview.
3. Authorize the actual global installation separately.
4. Keep backups of the entry and affected modules together. Restore that set if an installation is interrupted; the script is not transactional.
5. Start a new session and verify active instructions and required module readability.

Unrelated custom modules are retained. Switching to a lighter profile does not delete `personal-rules/`; review obsolete files separately rather than automatically cleaning them up. This release-preparation task does not install global instructions.

## Review scenarios and limits

The repository suite checks script syntax, privacy patterns, placeholder validity, relative file links and isolated install/generate behavior. Workflow cases cover three profiles, backups, unrelated-file preservation, no-write previews, missing modules, reproducible Strict rendering, missing/empty/over-budget ChatGPT inputs and sensitive-content refusal before output replacement.

Manual scenarios used for the rule review:

- A standalone version check returns a command without a task archive.
- The same simple Git command inside an audit can be executed as evidence collection.
- A project comparison keeps facts separate without automatically switching chats.
- A full implementation prompt excludes model/reasoning UI settings.
- A new release is announced, while the client's picker still shows only an older supported model. Check official product support and recommend the visible model if it fits the task and cost.
- Current official information and the picker are unavailable. Identify both unknowns and give conditional capability and effort guidance outside the executable prompt.
- A strict read-only task writes neither context nor history.
- A missing required module stops dependent execution rather than silently loading another copy.

These scenarios were reviewed against the text; no model evaluation or live ChatGPT UI test was performed. They are not an automated semantic consistency proof. Review account-specific UI limits before pasting the companion and recheck facts when environment or model availability changes.

## Limited runtime smoke checks (2026-11-13)

The owner subsequently supplied Windows Codex session results for two narrow checks:

- **Module access:** A fresh session located the effective global `AGENTS.md`, explicitly read the sibling `personal-rules/execution.md`, and reported the relevant Direct Shell / Codex Task boundaries with file locations and line ranges. This confirms that the module was readable when requested, not that every task automatically loads it.
- **Natural Direct Shell response:** Without mentioning rules, the owner asked how to check the installed Git version. Codex returned the copyable PowerShell command `git --version` with an explanation; the observed reply did not initiate a repository audit or task-history write.

These are owner-provided manual observations, not an automated model benchmark, an independent runtime trace, or a guarantee of future compliance. Live ChatGPT account behavior was not tested.
