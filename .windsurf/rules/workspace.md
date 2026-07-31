# Workspace Rules

This repository uses a unified workspace configuration defined in `workspace.yaml`.
Read it at the start of every session.

## Required Reading

0. Run `scripts/setup.sh` (or `.ps1`) once per fresh checkout instead of
   manually probing git/private-workspace state with ad-hoc shell
   commands — it already resolves this safely in one call, and avoids
   hitting a tool's own command-approval/sandbox limits.
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
- For multi-role work, follow Worktree + Plan Mode + Team Mode in
  `shared/workflows.md`.

## Directories

- `agents/` — agent role definitions.
- `shared/` — shared rules, conventions, security, tasks, and `handover.md`
  (session/agent handoff protocol).
- `docs/handover/` — tracked, ephemeral handover documents (see
  `shared/handover.md`).
- `docs/requirements/` — tracked business requirements moving through the
  draft/refined/approved/in-progress/done lifecycle (see
  `shared/requirements.md`).
- `packages/` — monorepo packages.
- `private/` — public schema/example templates only; real private context
  lives in the private workspace, outside this repo.

## Root Repo Git Is Optional, Permanently

It is completely fine, on first use and forever, for this project root to
have no `.git` at all — never treat that as an error. It's meant to stay a
plain local folder for config/orchestration; real project work and its
commit history live inside each `packages/<name>/`, each with its own
independent git repo. `scripts/add-package.sh`/`.ps1` and
`scripts/setup.sh`/`.ps1` detect this automatically and use plain
`git clone` instead of submodules when the root has no `.git`. See
`AGENTS.md`, "This Root Repo Never Needs Its Own git init".

## Handover

If work is incomplete when a session ends or ownership changes hands
(role/worktree switch, escalation to a human), follow the handoff protocol
in `shared/handover.md`. Trigger it proactively at 70% context usage, at
the latest — don't wait until it's nearly exhausted.

## Business Requirements

Admin writes a draft (`docs/requirements/<slug>.md`) → Architect refines it
into a spec → admin approves → agents implement via Plan Mode/Team Mode.
See `shared/requirements.md`. Every requirement must explicitly list which
`packages/<name>/` it concerns; ask if unclear, and split multi-package
requirements into one per-package sub-requirement before implementation.
Requirements that change how a package is built (`architecture_impact:
true`) need the admin/project lead's explicit answer to every open
question, not just a quick skim.

## Communication with the Admin/Project Lead

Every question, request, or approval ask is always explained like they're
5 first — plain words, no jargon, short sentences, everyday comparisons —
with more technical detail available underneath or on request. See
`shared/rules.md`, "Communication".

## Public Knowledge vs. Private Context

Key: public knowledge lives in each repo; private context and workflow
rules live in the private workspace.

- `workspace.yaml`, `agents/`, `shared/`, `AGENTS.md` are public knowledge.
- Private context (see `private/README.md`) lives in the private workspace
  (`AGENT_PRIVATE_WORKSPACE`, `~/.agent-private-workspace/<project-key>/`,
  or the optional `private-workspace/` git submodule, see `.gitmodules`):
  read if present, never copy into committed/public files.
