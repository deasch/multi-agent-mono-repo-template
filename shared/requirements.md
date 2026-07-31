# Business Requirements Lifecycle: Draft → Refined → Approved → Implemented

This defines how a business requirement moves from an admin's raw idea to
implemented code: **Admin writes → Agent refines → Admin approves → Agents
implement**. One requirement = one Markdown file with a `status` field as
the state machine; no extra tooling required.

## Required: Every Requirement Names Its Package(s) Explicitly

Every requirement file **must** carry a `packages:` list in its frontmatter
naming exactly which package(s) under `packages/<name>/` it concerns. Never
leave this implicit or vague — if it's unclear which package a requirement
targets, that must be resolved (ask the admin) during refinement, before
`status` can move to `refined`.

- **Single package**: `packages: [payments-api]` — the common case.
- **Multiple packages**: `packages: [payments-api, billing-worker]` — allowed
  in the requirement doc itself (e.g. "add a new event both services need"),
  but see "Multi-Package Requirements" below for how this affects
  implementation.
- **Root-repo-only** (workspace tooling/process changes, not a package):
  `packages: []` with a one-line note in the body explaining why.

## Lifecycle

1. **`draft`** (admin) — Copy `docs/requirements/TEMPLATE.md` to
   `docs/requirements/<slug>.md`. Fill in `packages:` and "Business
   Request" in plain language. Nothing else is required at this stage.
2. **`refined`** (agent) — Ask an agent (any AI tool, typically the
   Architect role, see `agents/architect.md`) to refine the draft. The
   agent:
   - Confirms `packages:` is correct and complete — if ambiguous, it asks
     the admin rather than guessing, per `AGENTS.md`, "Multi-Project
     Discipline".
   - Fills in "Refined Spec" (scope, acceptance criteria, dependencies,
     affected `owns_paths`, open questions) — **without implementing
     anything**.
   - Sets `status: refined`.
3. **`approved`** (admin) — Admin reads the Refined Spec, which is always
   written explain-like-I'm-5 first (see `shared/rules.md`,
   "Communication") so approving is a quick, plain-language check by
   default, with more technical detail available underneath or on
   request. Admin resolves any open questions and flips `status: approved`.
   If not satisfied, admin adds notes under "Admin Notes" and sets
   `status` back to `draft` for another refinement pass. If
   `architecture_impact: true`, approving is not a skim regardless of how
   simply it's explained — see "Architecture-Critical Requirements"
   below; the admin/project lead must explicitly answer the open
   question(s) before `status` can become `approved`.
4. **`in-progress`** (agents) — Once `approved`, feed it into **Plan Mode →
   Team Mode** (`shared/workflows.md`): decompose into role-assigned
   subtasks by `owns_paths`/`depends_on`, run each parallelizable subtask
   in its own worktree, implement, review, test, document. Set
   `status: in-progress` when work starts.
5. **`done`** (agent or admin) — Once merged into the target package(s),
   set `status: done`. Archive or delete per "Storage & Lifecycle" below.

## Multi-Package Requirements

A requirement naming more than one package is a valid **umbrella**
requirement, but implementation must still respect Multi-Project
Discipline (`AGENTS.md`): **never modify files across more than one
project/package repo in the same task.**

During refinement, an agent handling a multi-package requirement must:

1. Split it into one **per-package sub-requirement** file — the umbrella's
   Refined Spec references them (e.g. "See
   `docs/requirements/add-event-payments-api.md` and
   `docs/requirements/add-event-billing-worker.md`") instead of describing
   implementation work directly.
2. Each sub-requirement gets its own `packages:` list with exactly one
   entry, and goes through its own `refined` → `approved` →
   `in-progress` → `done` cycle independently, in its own task/session
   confined to that one package's repo.
3. The umbrella requirement's own `status` only reaches `done` once every
   sub-requirement referencing it is `done`.

This keeps "which package(s) does this affect" always explicit and keeps
every actual implementation task scoped to exactly one project repo.

## Architecture-Critical Requirements

Some requirements change how a package is built, not just what it does —
new data stores, new external dependencies, breaking API/schema changes,
changes to how services talk to each other, security-model changes, and
the like. These need the admin/project lead's real attention, not just a
quick skim, because they're expensive to reverse later.

During refinement, the agent (Architect) must:

1. Set `architecture_impact: true` in the frontmatter if the requirement
   involves anything like the above. When in doubt, set it `true` — the
   cost of an extra admin check is much lower than an unreviewed
   architecture decision.
2. Every "Open Questions" entry is already explain-like-I'm-5 by default
   (see `shared/rules.md`, "Communication") — no jargon, no acronyms,
   short sentences, everyday comparisons, with technical detail available
   underneath or on request. Architecture-impact requirements don't need
   different wording, just extra rigor about what counts as "answered."

   Example:
   - Not ELI5: "Should we introduce an event bus (Kafka) between
     `payments-api` and `billing-worker`, or keep the synchronous REST
     call?"
   - ELI5: "Right now, when someone pays, `payments-api` calls
     `billing-worker` directly and waits for an answer, like calling a
     friend and staying on the phone until they finish a task. We could
     instead leave a note for them to read whenever they're free (an
     event bus). Notes are more reliable if the friend is busy or away,
     but you don't get an instant answer back. Which do we want here?"

3. `status` **cannot** move to `approved` while `architecture_impact:
true` until the admin/project lead has explicitly answered every open
   question in "Admin Notes" — a bare `status: approved` flip without
   that response is not sufficient for this class of requirement.

A multi-package umbrella requirement (see above) inherits
`architecture_impact: true` automatically if any of its per-package
sub-requirements does.

## Frontmatter Schema

```yaml
---
status: draft # draft | refined | approved | in-progress | done
packages: [] # list of package names under packages/<name>/, or [] for root-repo-only
architecture_impact: false # true if this changes how a package is built, not just what it does
owner: admin # who to route "Admin Notes" / approval questions to
created: 2026-01-01
updated: 2026-01-01
---
```

## Template

```markdown
---
status: draft
packages: []
architecture_impact: false
owner: admin
created: <date>
updated: <date>
---

# Requirement: <short title>

## Business Request (Admin)

<Plain-language description of what's needed and why, written by the admin.>

## Refined Spec (Agent)

### Scope

### Acceptance Criteria

### Affected Packages / Paths

### Dependencies / Sequencing

### Open Questions (always explain-like-I'm-5 first, detail on request)

## Admin Notes

<Admin's approval notes, or reasons for sending back to draft. If
architecture_impact: true, this must include an explicit answer to every
open question before status can become approved.>
```

See `docs/requirements/TEMPLATE.md` for the copyable version and
`docs/requirements/README.md` for storage conventions.

## Storage & Lifecycle

- Live in `docs/requirements/<slug>.md` in this root repo — **never**
  inside `packages/<name>/` (see `packages/README.md`'s guardrails: business
  requirements are exactly the kind of proprietary/planning content that
  must not leak into a package's own repo).
- Tracked (committed), like `docs/handover/`. Archive or delete once
  `status: done` and merged — don't let stale requirements accumulate.
- A requirement in progress may reference (never inline) a handover
  document (`shared/handover.md`) if work on it pauses mid-implementation.

## Automation

The `/refine-requirement` skill (`.devin/skills/refine-requirement/SKILL.md`)
automates step 2 (drafting the Refined Spec explain-like-I'm-5 first,
including the multi-package split and the architecture-impact flag) for
any AI tool that supports invoking it.
