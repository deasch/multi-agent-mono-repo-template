---
name: handover
description: Package or resume the current task's state, decisions, and next steps for another agent, session, or human, per shared/handover.md
argument-hint: "[task-slug] [--resume <path>]"
allowed-tools:
  - read
  - write
  - grep
  - glob
  - exec
triggers:
  - user
  - model
---

You are producing or resuming a handover per the protocol defined in
`shared/handover.md`. Read that file first if you have not already — it is
the source of truth for required sections, storage location, and the rules
around private-workspace content. This skill only operationalizes it.

## Producing a New Handover

1. Confirm which single project repo this concerns (see `AGENTS.md`,
   "Multi-Project Discipline"). Do not mix context from other projects.
2. Gather the current state:
   - `git status`, `git diff`, `git log --oneline -20` on the current branch.
   - The task objective and any decisions made so far, from this session's
     own context.
   - Which files/paths were touched, cross-referenced against
     `workspace.yaml`'s `agents.<role>.owns_paths`.
3. Fill in every section of the template from `shared/handover.md`: Task
   Objective & Scope, Current State / Progress, Key Decisions & Rationale,
   Files & Paths Touched, Open Questions / Blockers, Next Steps, Related
   Context.
   - For "Related Context," reference the private workspace **by path
     only** if relevant (e.g. `team-mode-design.local.md`) — never copy its
     contents into the handover document. See `private/README.md`.
   - If the receiver is a human operator, write "Current State / Progress,"
     "Open Questions / Blockers," and "Next Steps" in plain language with no
     assumption they read the original conversation, per the "Human Handoff
     Variant" section of `shared/handover.md`.
4. Derive a `task-slug` (kebab-case, short) from the task if one wasn't
   given as an argument.
5. Write the document to `docs/handover/<task-slug>.md`. If the directory
   doesn't exist yet, create it (see `docs/handover/README.md` for what
   belongs there).
6. Tell the user the exact file path you wrote and summarize the "Next
   Steps" section back to them.
7. Remind the user (briefly) that this file is tracked and should be
   deleted or archived once the task/PR merges, per `shared/handover.md`'s
   "Storage & Lifecycle" section — do not delete it yourself unless asked.

## Resuming From an Existing Handover

If invoked with a path to an existing handover file (or the user says
"resume from <file>"):

1. Read the handover document in full.
2. Re-verify against reality — do not trust the document blindly:
   - `git status` / `git diff` / `git log` to see what's actually changed
     since.
   - Re-read the files listed under "Files & Paths Touched" to confirm
     their current content matches what's described.
3. Surface any discrepancies between the handover and the current repo
   state before proceeding.
4. Resolve or surface "Open Questions / Blockers" — escalate to the user if
   they require a human decision, per `shared/rules.md`.
5. Summarize the situation back to the user (what's done, what's next) and
   proceed with "Next Steps," updating the handover document if the plan
   changes materially.

## Constraints

- Never inline private-workspace content into the handover file — pointers
  only.
- Never include secrets, tokens, or credentials in the handover document.
- Keep the handover scoped to a single project repo.
