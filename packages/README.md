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

This directory is intentionally empty in the template. Remove the
`.gitkeep` file once the first real package is added.
