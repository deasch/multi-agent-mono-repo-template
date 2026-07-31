# Claude Code Project Instructions

This repository uses a unified workspace configuration. `workspace.yaml` is the
single source of truth for packages, agent roles, tasks, and shared knowledge.

## Before Every Task

1. Read `workspace.yaml`.
2. Identify the relevant agent role from `agents/`.
3. Read that role file.
4. Read `shared/security.md` and `shared/conventions.md` before writing code.

## Directories

- `workspace.yaml` — canonical workspace definition.
- `agents/` — agent role definitions.
- `shared/` — shared rules, conventions, security, and tasks.
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

Use the tasks defined in `workspace.yaml` under `tasks`:

- `lint`
- `test`
- `build`
- `sync`

Run the relevant task before declaring work complete.

## Multi-Agent Collaboration

- **Architect** owns design.
- **Developer** owns implementation.
- **Reviewer** owns quality and security review.
- **Tester** owns verification.
- **Documentarian** owns documentation.

If a task spans roles, consult the relevant agent files and keep pull requests
focused and reviewable.
