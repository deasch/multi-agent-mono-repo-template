# AI Agent Handover Protocol

This defines how an AI session or agent compresses, packages, and transfers
its in-progress context, state, and task objectives to another AI session,
another agent role, or a human operator — without losing continuity. Use it
whenever work is incomplete and control is about to change hands.

This happens **within a single project repo** — see `AGENTS.md`,
"Multi-Project Discipline". A handover never spans more than one project's
context; if multiple projects are involved, produce a separate handover per
project.

## When to Hand Off

Trigger this protocol when:

- A session is ending (or its context window is nearly exhausted) with the
  task still incomplete.
- Work is moving between agent roles or worktrees in **Team Mode** (see
  `shared/workflows.md`) — e.g. Developer finishing a subtask that Reviewer
  or Tester needs to pick up.
- A blocker or ambiguous decision needs to be escalated to a human operator.
- Ownership of a task is otherwise changing hands (different machine,
  different agent, different day).

## The Handover Package

Every handover is a single Markdown document with these fixed sections,
whether the receiver is another agent or a human:

1. **Task Objective & Scope** — what was asked, and the boundaries of what
   this handover covers (link the originating issue/ticket if any).
2. **Current State / Progress** — what's done, what's in progress, what
   hasn't been started. Be concrete: reference commits, branches, and files,
   not vague summaries.
3. **Key Decisions & Rationale** — choices made so far and why, especially
   anything a fresh reader would otherwise re-litigate.
4. **Files & Paths Touched** — the files changed or under active work,
   cross-referenced against `workspace.yaml`'s `agents.<role>.owns_paths` so
   the receiver knows whose lane each file is in.
5. **Open Questions / Blockers** — anything unresolved that the receiver
   (agent or human) needs to decide or unblock before continuing.
6. **Next Steps** — a concrete, ordered list of what to do next.
7. **Related Context (Pointers Only)** — links to the branch/worktree/PR,
   and, if relevant, *paths* into the private workspace (e.g. "see
   `team-mode-design.local.md` for role overrides"). **Never** inline private
   workspace content here — see "Private Context" below.

A minimal template:

```markdown
# Handover: <task-slug>

## Task Objective & Scope
## Current State / Progress
## Key Decisions & Rationale
## Files & Paths Touched
## Open Questions / Blockers
## Next Steps
## Related Context
```

## Storage & Lifecycle

- Write the filled-in handover to `docs/handover/<task-slug>.md` on the
  current working branch — it is **tracked** (committed), not gitignored,
  so any role, worktree, or teammate can pick it up without extra setup.
  See `docs/handover/README.md`.
- Treat handover files as ephemeral: delete or archive
  (e.g. squash the summary into the PR description) once the task or PR
  merges. Do not let stale handovers accumulate in `docs/handover/`.
- If the task spans a Team Mode worktree hand-off (see
  `shared/workflows.md`), the handover file travels with that
  branch/worktree, not the main branch.

## Receiving a Handover

The receiving agent or human must:

1. Read the handover document fully before taking any action.
2. **Re-verify, don't trust blindly**: run `git status`, `git diff`, and
   `git log` (and re-read the actual files listed) to confirm the described
   state still matches reality — the handover is a summary, not ground
   truth, and may be stale (another session may have changed things since).
3. Resolve any "Open Questions / Blockers" before proceeding, or escalate
   them per `shared/rules.md`'s "Communication" guidance if they require a
   human decision.
4. Continue from "Next Steps," updating or replacing the handover doc if the
   plan changes materially.

## Human Handoff Variant

When the receiver is a human operator rather than another agent, use the
same document and sections, but write "Current State / Progress," "Open
Questions / Blockers," and "Next Steps" so a non-agent reader can act on
them without re-reading the whole session: plain language, no assumption the
reader has the original conversation, and explicit callouts for anything
that needs a human decision (e.g. approving a design choice, providing
credentials, resolving a merge conflict). This same content can be pasted
into a PR description or comment instead of (or in addition to) the
standalone file, per `shared/conventions.md`'s Git conventions.

## Private Context

Per `private/README.md`, a handover must **never** copy private-workspace
content (tokens, cross-service context, team design, workflow rules) into
the committed handover file. Reference it by file name/path only (e.g.
"private workspace has updated deployment ordering in
`cross-service-context.local.md`") and let the receiver resolve the private
workspace themselves.

## Automation

The `/handover` Devin CLI skill (`.devin/skills/handover/SKILL.md`)
automates producing and resuming from a handover document following this
protocol.
