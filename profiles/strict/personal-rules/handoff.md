# Evidence-first handoff

Applies: non-trivial task completion, blocked handoff or initialization report.
Load before reporting. Prerequisite: entry language and prompt-output rules; no imports.

For completed tasks report: changed files; what changed; commands executed;
test results; remaining risks; recommended commit message when relevant; one short
next objective. Concise recommendations belong in the handoff; detailed next-prompt
design and orchestration remain ChatGPT's responsibility.

For context initialization also include sources inspected, project understanding
and what was not modified. Combine these with the normal fields rather than
duplicating reports.

Do not repeat long policy excerpts, the entire task, available context, or command
output already summarized. Refer to "per AGENTS.md" or "per current NEXT.md" when
sufficient. Do not include speculative multi-phase plans not needed for handoff.

When blocked, report the exact missing decision or evidence, not hypothetical
execution prompts. Stop after the authorized work and handoff. The entry's
explicit-request exception for future prompt drafting applies only to that task.
