# GitHub Copilot Instructions

This repository uses a unified workspace configuration. `workspace.yaml` is the
single source of truth for packages, agent roles, tasks, and shared knowledge.
See `AGENTS.md` at the repo root for the full rules — this file summarizes them
for Copilot.

## Before Every Task

0. Run `scripts/setup.sh` (or `.ps1`) once per fresh checkout instead of
   manually probing git/private-workspace state with ad-hoc shell
   commands — it already resolves this safely in one call, and avoids
   hitting a tool's own command-approval/sandbox limits.
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
Trigger it proactively at 70% context usage, at the latest — don't wait
until it's nearly exhausted.

## Business Requirements Lifecycle

Admin writes a draft (`docs/requirements/<slug>.md`) → Architect refines it
into a spec → admin approves → agents implement via Plan Mode/Team Mode.
See `shared/requirements.md`. Every requirement must explicitly list which
`packages/<name>/` it concerns; ask the admin if unclear, and split
multi-package requirements into one per-package sub-requirement before
implementation. Requirements that change how a package is built
(`architecture_impact: true`) need the admin/project lead's explicit
answer to every open question, not just a quick skim.

## Communication with the Admin/Project Lead

Every question, request, or approval ask directed at the admin/project
lead is always explained like they're 5 first — plain words, no jargon,
short sentences, everyday comparisons — with more technical detail
available underneath or on request. See `shared/rules.md`,
"Communication".
