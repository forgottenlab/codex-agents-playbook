# Supporting rule modules

This index is for human maintenance and audits. The entry AGENTS.md owns the complete
execution routing table; this index is not an execution prerequisite.
Modules are explicitly read with a file-reading tool when triggered. Markdown links
do not automatically import files or register Skills.

| Module | When to read |
|---|---|
| [execution.md](execution.md) | Repository-aware work, workspace choice or uncertain routing |
| [git-safety.md](git-safety.md) | Reviewing Git changes, staging or commits |
| [verification.md](verification.md) | Editing, testing, compatibility or public documentation |
| [context.md](context.md) | Durable context, long-lived projects, initialization or recovery |
| [history.md](history.md) | Non-trivial, staged, risky or continuing work; available-session archive |
| [recovery.md](recovery.md) | Missing UI tasks or conversations; also load context and history |
| [handoff.md](handoff.md) | Non-trivial completion, blocked handoff or initialization report |

Load the entry first, then only triggered modules. Modules do not recursively import
one another. History data contracts and handoff validation fields are not imports.
Complex tasks can require several modules; splitting files does not guarantee fewer
tokens for every task. Authorization remains in the entry. Skills conversion and
a deployment pipeline would require a separate task.
