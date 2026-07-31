# Conventions

## File Organization

- `workspace.yaml` is the canonical workspace definition.
- `agents/` contains agent role definitions.
- `shared/` contains shared rules, conventions, security, task documentation,
  and `handover.md` (the session/agent handoff protocol).
- `docs/handover/` contains tracked, ephemeral handover documents generated
  from `shared/handover.md`'s template; delete/archive after merge.
- `docs/requirements/` contains tracked business requirements moving
  through the draft/refined/approved/in-progress/done lifecycle defined in
  `shared/requirements.md`; each names the package(s) it concerns
  explicitly.
- `packages/` is the monorepo package directory.
- IDE/tool-specific configuration lives in `.vscode/`, `.cursor/`, `.windsurf/`,
  `.claude/`, `.devin/`, and `.github/copilot-instructions.md`.
- `private/` holds only public schema/example templates; real private
  context lives outside this repo in the private workspace. See
  "Public Knowledge vs. Private Context" below and `private/README.md`.

## Public Knowledge vs. Private Context

Key: public knowledge lives in each repo; private context and workflow
rules live in the private workspace.

- **Public knowledge** — `workspace.yaml`, `agents/`, `shared/`, `AGENTS.md`:
  committed in this repo, generic, safe to publish or share as part of this
  template.
- **Private context** — the four categories in `private/README.md`: live in
  the private workspace, a separate directory outside this repo, resolved
  via `AGENT_PRIVATE_WORKSPACE`, `~/.agent-private-workspace/<project-key>/`,
  or an optional `private-workspace/` git submodule mounted in this repo
  (see `.gitmodules`). Never committed in this repo or the private
  workspace. Read if present; never copy its content into public knowledge
  files, commit messages, or PR descriptions.
- Only `private/README.md` and `private/*.example` files are committed in
  this repo.

## Naming

- Directories and files: `kebab-case`.
- Markdown documentation: descriptive, kebab-case names.
- Agent role files: `agents/<role>.md`.
- Cursor rules: `.cursor/rules/<NN>-<name>.mdc`.
- Windsurf rules: `.windsurf/rules/<name>.md`.

## Tasks

- Tasks are defined in `workspace.yaml` under `tasks`.
- Use them for build, test, lint, and workspace synchronization.
- Keep task commands deterministic and safe to run from the repository root.

## Git

- Work on feature branches.
- Write descriptive commits focused on "why", not just "what".
- Open pull requests for review; do not merge your own changes without review.
- Do not commit `.env`, local override files, or secrets.

## Documentation

- Link to canonical sources instead of duplicating information.
- Update READMEs and agent docs when the workspace changes.
- Keep `workspace.yaml` accurate; it is the source of truth.
