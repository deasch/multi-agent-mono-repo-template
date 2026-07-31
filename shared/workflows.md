# AI Agent Workflows: Worktree + Plan Mode + Team Mode

This is a **required process** for any task that involves more than one
agent role working at the same time, not an optional optimization. It
combines three things: isolated working directories (**Worktree**),
upfront task decomposition (**Plan Mode**), and concurrent multi-role
execution (**Team Mode**). The overall process is **Plan Mode → Team
Mode**: Plan Mode always runs first and produces the plan that Team Mode
executes.

This all happens **within a single project repo** — see `AGENTS.md`,
"Multi-Project Discipline": always establish which one project a task
concerns first, and never make changes across more than one project repo
in the same task. Worktrees are how you get multiple roles/subtasks
running in parallel safely **inside** that one project.

## Worktree (Required for Parallel Work)

If a task will have more than one role or subtask active at the same time
within a single project, each parallel subtask **must** get its own git
worktree — never share one working directory across concurrent agents.
Use `git worktree` instead of separate clones or repeated branch switches:

```
git worktree add ../<repo-name>-<role>-<task-slug> -b <role>/<task-slug>
```

- Naming convention: `../<repo-name>-<role>-<task-slug>` (e.g.
  `../multi-agent-mono-repo-template-developer-auth-fix`).
- Every worktree shares the same public knowledge (`workspace.yaml`,
  `agents/`, `shared/`) and resolves the same private workspace (see
  `private/README.md`) since neither is tied to a single worktree.
- Remove worktrees after merge: `git worktree remove <path>`.

## Plan Mode

Before implementation, analyze **who, what, and in what order**, based on
the pre-defined team design:

1. Read `workspace.yaml` (`agents.<role>.owns_paths` and `depends_on`), the
   relevant `agents/<role>.md` files, and (if the private workspace is
   available) `team-mode-design.local.md` for org-specific team
   structure/overrides.
2. **Who**: assign each subtask to the agent role whose `owns_paths` covers
   the affected files (or the closest org-specific role override).
3. **What**: define the scope of each subtask precisely enough that two
   roles never need to edit the same files.
4. **In what order**: use `depends_on` to sequence subtasks — a role's
   subtask can't start until every role it `depends_on` has finished the
   part it depends on (e.g. Developer waits on Architect; Documentarian
   waits on Developer and Reviewer).
5. Assign each subtask that can run in parallel with others its own
   worktree; keep sequential subtasks in the same worktree.

Plan Mode is what "Team Mode Agent Design" (category 3 in
`private/README.md`, and the private workspace's own `AGENTS.md`) is for:
it's the org-specific team structure — responsibilities, directories,
dependencies — that Plan Mode reads to decide how work is decomposed and
assigned.

## Team Mode

Once a plan exists, agents execute concurrently, one per role/worktree:

- **Architect** finalizes design decisions subtasks depend on, before
  Developer work starts on those subtasks.
- **Developer** implements in its worktree, following `shared/conventions.md`
  and `shared/security.md`.
- **Reviewer** reviews diffs per worktree/branch before merge.
- **Tester** verifies each branch independently; failing tests block merge.
- **Documentarian** updates docs once behavior is finalized.

When one role's subtask output needs to be consumed by another (e.g.
Developer handing a finished worktree to Reviewer or Tester), or a
role's session ends mid-subtask, use the handoff protocol in
`shared/handover.md` so the receiving role has the objective, current
state, decisions, and next steps without re-deriving them from scratch.

## Putting It Together: Plan Mode → Team Mode

1. **Plan Mode** decomposes the task into role-assigned subtasks (who),
   scoped by owned paths (what), and sequenced by dependencies (order).
2. Create a worktree per subtask that can run in parallel with others.
3. **Team Mode** executes: agents work concurrently, each confined to its
   own worktree — this is what makes it conflict-free.
4. Reviewer/Tester validate each branch; merge via pull request
   (`shared/conventions.md`).
5. Remove worktrees once merged.

See `.windsurf/workflows/team-worktree.md` for the concrete, runnable steps.
