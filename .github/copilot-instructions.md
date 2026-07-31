# GitHub Copilot Instructions

This repository uses a unified workspace configuration. `workspace.yaml` is the
single source of truth for packages, agent roles, tasks, and shared knowledge.
See `AGENTS.md` at the repo root for the full rules — this file summarizes them
for Copilot.

## Before Every Task

1. Read `workspace.yaml`.
2. Confirm which single project repo this task concerns (see `AGENTS.md`,
   "Multi-Project Discipline") — never edit more than one project repo in
   the same task.
3. Identify the relevant agent role from `agents/` and read that role file.
4. Read `shared/security.md` and `shared/conventions.md` before writing code.

## Directories

- `workspace.yaml` — canonical workspace definition.
- `agents/` — agent role definitions.
- `shared/` — shared rules, conventions, security, tasks, and `handover.md`
  (session/agent handoff protocol).
- `docs/handover/` — tracked, ephemeral handover documents (see
  `shared/handover.md`).
- `packages/` — monorepo packages.
- `private/` — public schema/example templates only; real private context
  lives in the private workspace, outside this repo.

## Public Knowledge vs. Private Context

Key: public knowledge lives in each repo; private context and workflow
rules live in the private workspace.

- `workspace.yaml`, `agents/`, `shared/`, `AGENTS.md` are public knowledge:
  committed here, generic, safe to publish.
- Private context (see `private/README.md`) lives in the private workspace:
  resolved via `AGENT_PRIVATE_WORKSPACE` or
  `~/.agent-private-workspace/<project-key>/`, or an optional
  `private-workspace/` git submodule mounted in this repo (see
  `.gitmodules`). Never committed. Read it if present, but never copy its
  content into any committed or public file.

## Universal Rules

- Never hardcode secrets, API keys, tokens, passwords, or credentials.
- Never commit `.env` files or local override files.
- Never disable, bypass, or weaken linters, tests, or security controls.
- Validate all user and external input before processing.
- Use parameterized queries, safe APIs, and framework auto-escaping.
- Do not expose stack traces, internal paths, or secrets in error messages.
- Pin exact dependency versions and verify no known CVEs before adding.

## Tasks

Use the tasks defined in `workspace.yaml` under `tasks`: `setup`, `lint`,
`test`, `build`, `sync`. Run the relevant task before declaring work complete.

## Multi-Agent Collaboration

- **Architect** owns design.
- **Developer** owns implementation.
- **Reviewer** owns quality and security review.
- **Tester** owns verification.
- **Documentarian** owns documentation.

If a task spans roles, consult the relevant agent files and keep pull requests
focused and reviewable. For multi-role work, follow Worktree + Plan Mode +
Team Mode in `shared/workflows.md`.

## Session Handover

If work is incomplete when a session ends or ownership changes hands
(role/worktree switch, escalation to a human), follow the handoff protocol
in `shared/handover.md`. Write the handover to `docs/handover/<task-slug>.md`.
