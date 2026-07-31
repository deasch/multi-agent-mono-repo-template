# Packages

This directory holds the application and shared packages for the monorepo.

Each package should be a self-contained directory with its own dependency
manifest (e.g. `package.json`, `pyproject.toml`) and, where applicable, its
own `lint` / `test` / `build` scripts that the root `workspace.yaml` tasks can
invoke or aggregate.

## Adding a New Package (Written Here)

1. Create a new directory under `packages/<name>`.
2. Give it a clear `README.md` describing its purpose.
3. Wire its build/test/lint commands into the root `workspace.yaml` `tasks`
   section (and `shared/tasks.md`) so agents and IDEs can discover them.
4. Follow the naming and organization rules in `shared/conventions.md`.

## Importing an Existing Repo as a Package

To bring an existing GitHub, GHE, GitLab, or other git-hosted repo into
`packages/<name>` as its own git repository (own history, own remote),
run:

```
scripts/add-package.sh <git-url> [package-name]      # macOS/Linux/Git Bash/WSL
scripts/add-package.ps1 <git-url> [package-name]     # native Windows
```

This adds it as a **git submodule** — the package keeps its own commit
history and remote, and this repo only tracks a pointer (URL + pinned
commit SHA) to it, so nothing proprietary from the package's own repo
leaks into this repo beyond that reference. After running it:

1. Commit `.gitmodules` and the new submodule gitlink (the script tells you
   the exact commands).
2. Wire its build/test/lint commands into `workspace.yaml` `tasks`.
3. `git submodule update --init --recursive` (or `scripts/setup.sh`) is how
   anyone else cloning this repo pulls the package's contents in.

This is separate from, and composes with, the private-workspace submodule
pattern described in `private/README.md`.

## Working in a Package (Pull → Work → Push Back)

This root repo is meant to be the single place you work from across many
projects, each living on its own host (GitHub, GHE, GitLab, ...) as its own
git repo mounted under `packages/<name>`. The workflow for any one project:

1. **Pull**: `git submodule update --init --remote packages/<name>` (or just
   clone this repo with `git clone --recurse-submodules`, or run
   `scripts/setup.sh`).
2. **Work**: `cd packages/<name>` — you are now inside that project's own,
   independent git repository (its own remote, branches, and history,
   completely separate from this root repo's). Branch, commit, and test as
   normal, following that project's own conventions/`AGENTS.md` if it has one.
3. **Check before pushing**: run
   `scripts/check-package-clean.sh <name>` from the root repo. It scans the
   package's changes for markers of this root repo's own proprietary/
   internal content (see Guardrails below) and fails if it finds any.
4. **Push back**: still inside `packages/<name>`, `git push` — this goes to
   _that project's own remote_, not this root repo's. Open a PR there as
   usual.
5. **Record the pointer**: back in the root repo, `git add packages/<name>`
   and commit — this only records the package's URL and the new commit SHA
   (a gitlink), never its file contents, so it's always safe to commit here.

### Guardrails: What Must Never Leave Through a Package

A package's own repo may be public, third-party, or otherwise outside your
control once pushed. Never create or leave any of the following **inside**
`packages/<name>/`, even temporarily:

- Backlog items, sprint/roadmap notes, or planning content.
- Handover documents (`docs/handover/*.md`) — those belong only in this
  root repo.
- Private context of any kind (`private/*.local.*`, or content copied from
  it) — see `private/README.md`.
- Team-mode design, workflow rules, or cross-service relationship notes.
- Anything referencing other projects, internal tooling, or org structure
  that isn't relevant to that package on its own.

If a task naturally produces this kind of content while you're working
inside a package, write it in the root repo (`docs/handover/`, or the
private workspace) instead — never inside `packages/<name>/`.

This directory is intentionally empty in the template. Remove the
`.gitkeep` file once the first real package is added.
