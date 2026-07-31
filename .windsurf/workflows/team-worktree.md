---
description: Run a task with Plan Mode + Team Mode across isolated git worktrees
---

0. Confirm which single project repo this task concerns (see `AGENTS.md`,
   "Multi-Project Discipline"). Everything below happens inside that one
   project only.
1. Read `workspace.yaml` (`agents.<role>.owns_paths`, `depends_on`), the
   relevant `agents/<role>.md` files, and (if the private workspace is
   available, see `private/README.md`) `team-mode-design.local.md`.
2. Decompose the task into subtasks: who (role by `owns_paths`), what
   (scope, no overlapping files), in what order (`depends_on`). This is
   Plan Mode — see `shared/workflows.md`.
3. For every subtask that runs in parallel with another, create an isolated
   worktree — this is required, not optional, whenever more than one role
   is active at once:

// turbo

```
git worktree add ../$(basename "$PWD")-<role>-<task-slug> -b <role>/<task-slug>
```

4. Assign each worktree to the agent role responsible for that subtask
   (Team Mode). Work proceeds concurrently across worktrees.
5. Within each worktree, follow `shared/conventions.md` and
   `shared/security.md` before writing code.
6. Reviewer reviews each branch; Tester verifies it; only then open a pull
   request per `shared/conventions.md`.
7. After a branch merges, remove its worktree:

// turbo

```
git worktree remove ../$(basename "$PWD")-<role>-<task-slug>
```

8. Documentarian updates docs once all subtasks have merged.
