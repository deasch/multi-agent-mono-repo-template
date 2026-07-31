# Tasks

Tasks are defined in `workspace.yaml` under the `tasks` key. They are the canonical commands for building, testing, linting, and syncing this workspace.

## How to Use

- Run the command listed for the relevant task.
- Add new tasks when they are useful across multiple packages or IDEs.
- Keep task commands deterministic and safe to run from the repository root.
- Update `shared/tasks.md` and the IDE task files when `workspace.yaml` tasks change.

## Current Tasks

- `lint` — placeholder; replace with your linter command.
- `test` — placeholder; replace with your test runner command.
- `build` — placeholder; replace with your build command.
- `sync` — placeholder for a workspace-to-IDE synchronization command.

## Extending

When you add a new task to `workspace.yaml`, consider adding a matching task to:

- `.vscode/tasks.json` for VS Code users.
- `.claude/CLAUDE.md` for Claude Code instructions.
- `AGENTS.md` for Devin / Cursor shared rules.

See `shared/workflows.md` for how to run multi-role tasks concurrently
using Worktree + Plan Mode + Team Mode.
