# Workspace Rules

This repository uses a unified workspace configuration defined in `workspace.yaml`.
Read it at the start of every session.

## Required Reading

1. `workspace.yaml`
2. `shared/security.md`
3. `shared/conventions.md`
4. The relevant `agents/<role>.md` for the task

## Key Directives

- Follow the agent role assigned to the task.
- Use the tasks defined in `workspace.yaml`.
- Never commit secrets, tokens, or credentials.
- Validate external input and reject invalid input safely.
- Work on feature branches and merge via pull request after review.

## Directories

- `agents/` — agent role definitions.
- `shared/` — shared rules, conventions, security, and tasks.
- `packages/` — monorepo packages.
- `private/` — public schema/example templates only; real private context
  lives in the private workspace, outside this repo.

## Public Knowledge vs. Private Context

Key: public knowledge lives in each repo; private context and workflow
rules live in the private workspace.

- `workspace.yaml`, `agents/`, `shared/`, `AGENTS.md` are public knowledge.
- Private context (see `private/README.md`) lives in the private workspace
  (`AGENT_PRIVATE_WORKSPACE`, `~/.agent-private-workspace/<project-key>/`,
  or the optional `private-workspace/` git submodule, see `.gitmodules`):
  read if present, never copy into committed/public files.
