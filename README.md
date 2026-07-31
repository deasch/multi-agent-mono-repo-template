# Multi-Agent Monorepo Template

A monorepo template with a **single, unified workspace configuration**
(`workspace.yaml`) that drives consistent behavior across AI coding agents
(Devin, Claude Code, Cursor, Windsurf, GitHub Copilot) and IDEs (VS Code),
plus a multi-agent-role workflow for humans and AI to collaborate on the
same codebase. It's meant to be the single foundation you develop many
projects from — each project its own git repo, on any host (GitHub, GHE,
GitLab, ...), pulled in under `packages/<name>` as a submodule so you can
work on it here and push changes back to its own repo without ever leaking
this root repo's proprietary content into it.

## Why

Most repos duplicate the same rules across `.cursor/rules`, `.windsurf/rules`,
`CLAUDE.md`, `AGENTS.md`, etc., and they drift out of sync. This template
makes `workspace.yaml` the single source of truth, with each tool's
integration file generated from (and kept in sync with) it.

## Structure

- `workspace.yaml` — canonical workspace definition: packages, agent roles,
  tasks, shared knowledge, and IDE integration points.
- `agents/` — agent role definitions (architect, developer, reviewer, tester,
  documentarian): responsibilities, constraints, allowed tools, prompts.
- `shared/` — shared rules, conventions, security guardrails, task docs,
  `workflows.md` (Worktree + Plan Mode + Team Mode), `handover.md` (the
  session/agent handoff protocol), and `requirements.md` (the business
  requirements lifecycle) referenced by every agent and IDE.
- `docs/handover/` — tracked, ephemeral handover documents produced from
  `shared/handover.md`'s template (deleted/archived after merge).
- `docs/requirements/` — tracked business requirements moving through
  draft → refined → approved → in-progress → done (see
  `shared/requirements.md`); each explicitly lists the package(s) it
  concerns.
- `packages/` — your monorepo packages go here. Add new code directly, or
  import an existing repo with `scripts/add-package.sh`/`.ps1` (see
  `packages/README.md`).
- `private/` — public schema/example templates only by default; real
  private context and workflow rules live in the private workspace,
  outside this repo — unless this repo instance opts into "in-repo" mode
  (`context.private.mode` in `workspace.yaml`). See `private/README.md`.
- `AGENTS.md` — cross-tool agent rules (read by Devin, Cursor, etc.).
- `.claude/CLAUDE.md` — Claude Code instructions.
- `.cursor/rules/` — Cursor rules.
- `.windsurf/rules/` — Windsurf rules.
- `.windsurf/workflows/` — runnable Windsurf slash-command workflows (e.g.
  `/team-worktree`).
- `.devin/config.json` — Devin configuration.
- `.devin/skills/handover/SKILL.md` — the `/handover` skill (session/agent
  handoff, see `shared/handover.md`).
- `.devin/skills/refine-requirement/SKILL.md` — the `/refine-requirement`
  skill (drafts the Refined Spec for a business requirement, see
  `shared/requirements.md`).
- `.github/copilot-instructions.md` — GitHub Copilot instructions.
- `.vscode/` — editor settings, recommended extensions, and tasks wired to
  `workspace.yaml`.
- `.gitmodules` — optional pointer to mount your private workspace inside
  this repo at `private-workspace/` as a git submodule (separate git
  history, unified checkout). See `private/README.md`.
- `scripts/setup.sh` / `scripts/setup.ps1` — one-command environment setup
  (submodule init, private workspace resolution, dependency install) on
  macOS/Linux/Git-Bash/WSL or native Windows respectively.
- `scripts/add-package.sh` / `scripts/add-package.ps1` — import an existing
  GitHub/GHE/GitLab repo into `packages/<name>` as a git submodule.
- `scripts/check-package-clean.sh` — scan a package's changes for this root
  repo's proprietary content before pushing it back to its own remote. See
  `packages/README.md`, "Working in a Package (Pull → Work → Push Back)".
- `scripts/check-sync.sh` — verify every AI tool's instruction file still
  references the same canonical `shared/*.md` docs (`workspace.yaml`'s
  `tasks.sync`). Run it after adding/renaming a shared doc.

## Getting Started

1. Run `bash scripts/setup.sh` (macOS/Linux/Git Bash/WSL) or
   `scripts/setup.ps1` (native Windows/PowerShell) once.
2. Read `workspace.yaml` — it explains the whole workspace.
3. Add packages under `packages/`: write new code directly, or import an
   existing repo with `scripts/add-package.sh <git-url> [name]` (see
   `packages/README.md`).
4. Replace the placeholder commands in `workspace.yaml` under `tasks`
   (`lint`, `test`, `build`) with real commands, and update
   `shared/tasks.md` and `.vscode/tasks.json` to match. `sync` is already
   wired to `scripts/check-sync.sh` — run it whenever you add/rename a
   `shared/*.md` doc, to catch any AI tool that wasn't updated to reference
   it (see "Keeping All Agents in Sync" below).
5. Update `agents/*.md` if your team needs different roles or constraints.
6. Review `shared/security.md` and adapt it to your stack.
7. Decide how private/proprietary context will be stored: keep the default
   "external" mode (nothing proprietary ever committed here, see
   `private/README.md`), or switch this repo instance to "in-repo" mode if
   it's already private and won't be redistributed as a template.

## Agent Roles

| Role          | Owns                                     |
| ------------- | ---------------------------------------- |
| Architect     | Design, technology choices, architecture |
| Developer     | Implementation, bug fixes, tests         |
| Reviewer      | Code review, security, quality           |
| Tester        | Test strategy, automation, verification  |
| Documentarian | Documentation and knowledge              |

Each role is defined in `agents/<role>.md` and summarized in `workspace.yaml`
under `agents`. When they conflict, `workspace.yaml` is canonical.

## Public Knowledge vs. Private Context

**Key: public knowledge lives in each repo; private context and workflow
rules live in the private workspace.**

`workspace.yaml`, `agents/`, `shared/`, and `AGENTS.md` are **public
knowledge**: generic, committed, and safe to publish as part of this
template. Private context — the four categories described in
`private/README.md` (local environment & credentials, cross-service
relationships & change patterns, team mode agent design, workflow rules) —
lives in **the private workspace**: a separate directory outside this repo,
resolved via `AGENT_PRIVATE_WORKSPACE`, `~/.agent-private-workspace/<project-key>/`,
or an optional `private-workspace/` git submodule mounted in this repo (see
`.gitmodules`). It is never committed, and is shared consistently across
every repo that uses this template. Agents may read it if present but must
never copy its content into public files.

If this repo instance is itself private/access-controlled and won't be
redistributed as a template, it can instead switch to **"in-repo" mode**
(`context.private.mode: "in-repo"` in `workspace.yaml`) and commit real
private context directly under `private/*.local.*`. See `private/README.md`,
"In-Repo Mode", for the switch-over steps. The template always defaults to
"external" mode and ships no real private content.

## Maximizing AI Agent Workflows

For multi-role tasks, combine **Worktree + Plan Mode + Team Mode**: Plan
Mode decomposes the task across agent roles, each parallelizable subtask
gets its own git worktree, and Team Mode runs the roles concurrently. See
`shared/workflows.md` for the pattern and `.windsurf/workflows/team-worktree.md`
for the runnable steps.

When a task is incomplete and needs to change hands — a session ending, a
role/worktree switch, or escalating to a human — use the handoff protocol in
`shared/handover.md` (automated by the `/handover` Devin CLI skill) so
context, decisions, and next steps aren't lost. Trigger it proactively at
70% context-window usage, at the latest — don't wait until it's nearly
exhausted.

## Business Requirements: Admin → Agent → Admin → Agents

Business requirements flow through `docs/requirements/<slug>.md`: an admin
writes a plain-language draft, an agent (Architect) refines it into a
structured spec (scope, acceptance criteria, open questions) without
implementing anything, the admin reviews and approves it, and only then do
agents implement it via Plan Mode → Team Mode. Every requirement must
explicitly list which `packages/<name>/` it concerns — requirements
touching multiple packages are split into one per-package sub-requirement
first, so each implementation task still stays confined to a single
project repo. Requirements that change _how_ a package is built (new data
stores/dependencies, breaking API changes, security-model changes) are
flagged `architecture_impact: true` and need the admin/project lead's
explicit answer to every open question, not just a quick skim. See
`shared/requirements.md` (automated by the `/refine-requirement` Devin CLI
skill).

## Communication with the Admin/Project Lead

Every question, request, or approval ask directed at the admin/project
lead — requirement open questions, handover documents for a human,
escalations — is always explained like they're 5 first: plain words, no
jargon or acronyms, short sentences, everyday comparisons. More technical
detail is available underneath or on request, but never required to
decide. See `shared/rules.md`, "Communication".

## Keeping All Agents in Sync

Every AI tool reads its own integration file (`AGENTS.md`, `.claude/CLAUDE.md`,
`.cursor/rules/`, `.windsurf/rules/`, `.github/copilot-instructions.md`,
`.devin/config.json`) but all of them are meant to point at the same
canonical `shared/*.md` docs, so switching tools never means switching
information. `scripts/check-sync.sh` (task `sync`) checks that every one of
those files still references each canonical doc — run it whenever you add,
rename, or retire a `shared/*.md` file, and after editing any one tool's
instructions, to make sure the others didn't silently fall behind.

## Conventions & Security

See `shared/conventions.md` for naming/organization rules and
`shared/security.md` for security guardrails (secrets management, injection
prevention, input validation, dependency hygiene) that all agents must follow.
