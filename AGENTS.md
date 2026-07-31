# Project Rules for AI Agents

This repository uses a unified workspace configuration defined in `workspace.yaml`.
These rules apply to all AI agents and IDEs working here, including Devin CLI,
Cursor, Claude Code, Windsurf, GitHub Copilot, and VS Code.

## Required First Steps

1. Read `workspace.yaml` at the start of every session.
2. If it's unclear which project this task concerns (e.g. multiple project
   repos/checkouts are in scope, or you're working from the private
   workspace), ask which project before doing anything else. See
   "Multi-Project Discipline" below.
3. Determine which agent role from `agents/` applies to the task, or ask if unclear.
4. Read that role file before acting.
5. Read `shared/security.md` and `shared/conventions.md` before writing code or
   configuration.

## Multi-Project Discipline

This repo is a **template**: it's the basis for every project's own
independent repo, not a project itself, and not a container for other
project repos. Each project gets its own repo, instantiated from this
template, with its own history and its own submodules where useful.

- Always establish which single project a task concerns before making any
  change. Ask if it isn't already clear.
- Once established, confine all reads and writes to that one project's
  repo for the rest of the task.
- Never modify files in more than one project repo within the same task,
  even if a private workspace or cross-service command references several
  projects (see `private/README.md` and `private/AGENTS.md.example`).
- Cross-project context (tokens, service relationships, team design,
  workflow rules) lives in the private workspace, not in code changes
  spanning multiple project repos.

This repo can also act as the single place you pull, work on, and push
back multiple **separate project repos** from, each mounted under
`packages/<name>` as its own git submodule (its own remote/history,
possibly on a different host — GitHub, GHE, GitLab, etc.). See
`packages/README.md`, "Working in a Package (Pull → Work → Push Back)".
When working inside `packages/<name>`:

- You are inside that project's own repo — commits and pushes there go to
  its own remote, never to this root repo.
- Never create or leave this root repo's proprietary/internal content
  (backlog items, roadmap notes, handover documents, private context, team
  design, workflow rules) inside `packages/<name>/` — it must never leave
  through that project's own repo. See `packages/README.md`'s guardrails.
- Run `scripts/check-package-clean.sh <name>` before pushing a package back
  to its own remote.

## Project Architecture, API & Build

This section is what makes this file the **public per-project AGENTS.md**
when this template is instantiated for a real project (as opposed to the
private-workspace `AGENTS.md` described in `private/README.md` and
`private/AGENTS.md.example`, which covers tokens, local paths, and
cross-service relationships instead — see "Public Knowledge vs. Private
Context" below). Fill it in per project:

- **Architecture** — high-level system design, major components, and how
  they interact. Link to `docs/architecture.md` or equivalent if it's more
  than a few paragraphs.
- **API** — public interfaces this project exposes (HTTP/gRPC/library API),
  and where their contracts are defined (OpenAPI spec, proto files, etc.).
- **Build** — how to build, run, and test this project locally (commands
  should match `workspace.yaml` under `tasks`).

## Workspace Navigation

- `workspace.yaml` — canonical workspace definition (packages, agents, tasks).
- `agents/` — agent role definitions.
- `shared/` — shared rules, conventions, security, and tasks.
- `packages/` — monorepo packages.
- `private/` — public schema/example templates only; real private context
  lives in the private workspace (see below).

## Public Knowledge vs. Private Context

**Key: public knowledge lives in each repo; private context and workflow
rules live in the private workspace.**

- `workspace.yaml`, `agents/`, `shared/`, and this file are **public
  knowledge**: committed in this repo, generic, and safe to publish or share.
- Private context (the four categories in `private/README.md`) lives in
  **the private workspace**: a separate directory outside this repo,
  resolved via the `AGENT_PRIVATE_WORKSPACE` env var or the default
  `~/.agent-private-workspace/<project-key>/`. It is never committed here or
  anywhere.
- The private workspace can optionally be mounted inside this repo at
  `private-workspace/` as a git submodule (see `.gitmodules` and
  `private/README.md`), unifying public and private context into one
  checkout while keeping them as separate git histories.
- If this repo instance is itself access-controlled and won't be
  redistributed as a template, it may instead use **"in-repo" mode**
  (`context.private.mode: "in-repo"` in `workspace.yaml`) and commit real
  private context directly under `private/*.local.*` — see
  `private/README.md`, "In-Repo Mode". Check this setting before assuming
  "external" mode applies.
- Read private-workspace files if present, but never copy their content
  into `shared/`, `agents/`, READMEs, commit messages, PR descriptions, or
  any other committed/public artifact.
- If the private workspace doesn't exist, proceed with public knowledge
  only; do not assume it exists.

## Universal Guardrails

- Never hardcode secrets, API keys, tokens, passwords, or credentials.
- Never commit `.env` files or local override files.
- Never disable, bypass, or weaken linters, tests, or security controls.
- Validate all user/external input at system boundaries.
- Use parameterized queries, safe APIs, and framework auto-escaping.
- Do not expose stack traces, internal paths, or secrets in error messages.
- Never implement custom cryptography; use established, audited libraries.
- Pin exact dependency versions and verify no known CVEs before adding.
- All code changes must be committed to feature branches and merged via pull
  request after review.

## Task Execution

- Use the tasks defined in `workspace.yaml` under `tasks`.
- Run the relevant task before claiming a feature, fix, or refactor is complete.
- Update `workspace.yaml` and `shared/tasks.md` when tasks change.

## Multi-Agent Collaboration

- If a task spans multiple roles, consult the relevant agent files.
- The Architect owns design; the Developer owns implementation; the Reviewer owns
  quality; the Tester owns verification; the Documentarian owns docs.
- Escalate conflicts or security concerns to the Reviewer.
- To maximize throughput on multi-role tasks, use the Worktree + Plan Mode +
  Team Mode pattern in `shared/workflows.md`: decompose the task (Plan
  Mode), give each parallelizable subtask its own git worktree, and run
  roles concurrently (Team Mode).

## Session Handover

When a task is incomplete and control needs to change hands — a session
ending, a role/worktree switch in Team Mode, or escalating a blocker to a
human — follow the handoff protocol in `shared/handover.md`. Trigger it
proactively once the session's context window hits 70% usage, at the
latest — don't wait until it's nearly exhausted. It defines the required
package (objective, progress, decisions, files touched, open questions,
next steps) and where it's stored (`docs/handover/<task-slug>.md`). Use the
`/handover` skill (`.devin/skills/handover/SKILL.md`) to produce or resume
one.

## Business Requirements Lifecycle

Business requirements flow: admin writes a draft → an agent (Architect)
refines it into a structured spec → admin approves → agents implement via
Plan Mode → Team Mode. Full protocol, frontmatter schema, and template in
`shared/requirements.md`; files live in `docs/requirements/<slug>.md`. Every
requirement **must** explicitly list which `packages/<name>/` it concerns —
never leave this implicit, and never guess if it's ambiguous; ask the admin.
A requirement touching more than one package must be split into one
per-package sub-requirement before implementation, per Multi-Project
Discipline above. Use the `/refine-requirement` skill
(`.devin/skills/refine-requirement/SKILL.md`) to produce the Refined Spec.

Any requirement that changes how a package is built — not just what it
does (new data stores/dependencies, breaking API/schema changes,
service-to-service changes, security-model changes) — must be flagged
`architecture_impact: true`, per `shared/requirements.md`,
"Architecture-Critical Requirements". These require the admin/project
lead's explicit answer to every open question, not just a quick skim,
before approval.

## Communication with the Admin/Project Lead

Every question, request, or approval ask directed at the admin/project
lead is always explained like they're 5 first — plain words, no jargon or
acronyms, short sentences, everyday comparisons — with more technical
detail available underneath or on request, never required to decide. See
`shared/rules.md`, "Communication". This applies everywhere: requirement
open questions, handover documents for a human, escalations, and PR
descriptions.
