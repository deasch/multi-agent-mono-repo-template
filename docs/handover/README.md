# Handover Documents

This directory holds task handover documents produced per the protocol in
`shared/handover.md` — structured packages of task objective, progress,
decisions, open questions, and next steps, used to transfer an in-progress
task between AI sessions, agent roles/worktrees, or to a human operator.

- Generate one with the `/handover` skill (`.devin/skills/handover/SKILL.md`)
  or manually, following the template in `shared/handover.md`.
- Files here are **tracked** (committed) so any role, worktree, or teammate
  can pick up the task without extra setup — but they are **ephemeral**:
  delete or archive a handover once its task/PR merges. Don't let stale
  handovers accumulate.
- Never commit secrets, tokens, or private-workspace content here — see
  `private/README.md`. Reference private-workspace files by path only.
- Naming: `<task-slug>.md`, matching the task's branch/worktree slug (see
  `shared/workflows.md`).
