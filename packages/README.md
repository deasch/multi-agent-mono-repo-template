# Packages

This directory holds the application and shared packages for the monorepo.

Each package should be a self-contained directory with its own dependency
manifest (e.g. `package.json`, `pyproject.toml`) and, where applicable, its
own `lint` / `test` / `build` scripts that the root `workspace.yaml` tasks can
invoke or aggregate.

## Adding a Package

1. Create a new directory under `packages/<name>`.
2. Give it a clear `README.md` describing its purpose.
3. Wire its build/test/lint commands into the root `workspace.yaml` `tasks`
   section (and `shared/tasks.md`) so agents and IDEs can discover them.
4. Follow the naming and organization rules in `shared/conventions.md`.

Packages can also be their own git repositories, added as submodules
(`git submodule add <package-repo-url> packages/<name>`) instead of plain
directories, when a package needs independent versioning/history. This is
separate from, and composes with, the private-workspace submodule pattern
described in `private/README.md`.

This directory is intentionally empty in the template. Remove the
`.gitkeep` file once the first real package is added.
