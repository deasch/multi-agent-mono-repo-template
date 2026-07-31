# Agent Roles

This directory contains the agent role definitions used by the unified workspace.

Each file describes a persona, responsibilities, constraints, allowed tools, and a
brief prompt. AI tools should read the relevant role file before acting on a task.

## Roles

- `architect.md` — high-level design and technology decisions.
- `developer.md` — implementation, bug fixes, and tests.
- `reviewer.md` — code review, security, and quality.
- `tester.md` — test strategy, automation, and verification.
- `documentarian.md` — documentation and knowledge management.

## Canonical Source

Roles are also summarized in `workspace.yaml` under `agents`. When the two
conflict, `workspace.yaml` is canonical; update the markdown file to match.

## Handing Off Incomplete Work

If a role's work is incomplete when a session ends or ownership needs to
change (including switching roles or worktrees in Team Mode, see
`shared/workflows.md`), use the handoff protocol in `shared/handover.md`
instead of leaving context only in conversation history.
