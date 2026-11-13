# Verification and documentation

Applies: edits, testing, compatibility conclusions or public behavior/documentation.
Load before planning validation. Prerequisite: entry evidence constraint; no imports.

## Validation

After changes, run the smallest relevant check first: changed-logic unit tests,
compile checks, lint or targeted integration tests. Report concrete commands and
results. An unexecuted test is not a pass; static inspection does not establish
runtime or remote behavior. Apply the entry's not-run / reason / risk reporting.

## Documentation maintenance

When public behavior changes, check and update relevant README, localized README,
docs, changelog, migration guide, compatibility documentation,
`.ai/project_context.md` and `.ai/decisions.md`.
This is a relevance check, not permission to invent decisions or expand scope.
Do not create unnecessary documentation systems for temporary projects.

For public projects, `README.md` is English and `README.zh-CN.md` is Chinese.
Keep their structure synchronized; do not mix languages in one README or
mechanically translate technical concepts.

## Risk-Based Validation and Test Budget

Default validation mode: Standard.

### Shared Principles — All Modes

- Default to at most two automatic fix-and-retest cycles in Fast, Standard
  and Thorough. This repair budget is not a limit on test commands and does
  not permit skipping necessary acceptance checks.
- Additional repair cycles require explicit user approval. For high-risk tasks,
  explain why an extension is needed and obtain the corresponding authorization
  before exceeding the default budget. A higher validation mode does not itself
  authorize additional repair cycles.
- Do not repeat a successful relevant test without a reason when the code state,
  inputs and environment conditions are unchanged. Re-run relevant tests only
  for code or environment changes, new evidence, necessary acceptance requirements,
  or an explicit user request.
- One completed test command may satisfy several rule requirements. Reuse the
  same valid result instead of mechanically executing the same test again.
- Every mode preserves higher-priority safety rules, explicit acceptance criteria
  and project-mandated checks. For example, run Test-Repository.ps1 when the project
  requires it; reuse an existing valid result if its inputs, code and execution
  conditions have not changed.

### Fast
Use for trivial, isolated, low-risk changes.

- Run the smallest relevant checks.
- Avoid unrelated suites and redundant tests.
- Do not expand scope merely to increase coverage.

### Standard
Use for ordinary development tasks.

- Identify affected behavior before testing.
- Run the smallest sufficient validation.
- Apply the shared repetition and repair-budget rules above.

### Thorough
Use when explicitly requested or when the actual change materially affects safety
controls, permissions, authentication, sensitive data, data migration, production
deployment, or another substantively high-risk operation.

- Do not escalate ordinary changes merely because software development carries
  theoretical risks.
- Run necessary regression, integration, compatibility,
  security, or failure-path tests.
- Explain why broader verification is required.

### Stop Conditions

Successful validation requires all of the following:

1. Required relevant checks have passed.
2. Explicit acceptance criteria have been satisfied.
3. No unresolved material verification risk remains.
4. No change or new evidence requires further validation.

When the repair budget is exhausted, the environment is blocked, or necessary
validation cannot be completed, stop automatic attempts and expansion and report
an incomplete or blocked status. State failed checks, checks not run and remaining
risks. If failures remain at the repair limit, do not claim task success; further
repair cycles require the approval described above.

Stopping further testing does not mean all tests passed.
Never report failing or skipped tests as passing.

A test budget does not override safety requirements,
explicit acceptance criteria, or higher-priority rules.
