---
name: refine-requirement
description: Refine an admin-written draft business requirement into a structured spec (scope, acceptance criteria, affected packages, open questions), per shared/requirements.md. Never implements anything.
argument-hint: "<requirement-file-path>"
allowed-tools:
  - read
  - write
  - grep
  - glob
triggers:
  - user
  - model
---

You are refining a draft business requirement per the protocol defined in
`shared/requirements.md`. Read that file first if you have not already — it
is the source of truth for the lifecycle, frontmatter schema, and
multi-package rules. This skill only operationalizes it. You are **not**
implementing the requirement — only turning the admin's raw request into a
structured spec for the admin to approve.

## Steps

1. Read the requirement file given as an argument (or ask the admin which
   file, if not given). Confirm its `status` is `draft` — if not, stop and
   tell the admin (only drafts get refined; a `refined`/`approved` file
   should not be silently overwritten).
2. Read the "Business Request" section. If anything is ambiguous or
   underspecified, note it under "Open Questions" rather than guessing —
   phrased explain-like-I'm-5 (see step 4 and `shared/rules.md`,
   "Communication").
3. **Resolve `packages:`** — this is required, not optional:
   - Read `packages/` (and each package's own `README.md`/`AGENTS.md` if
     present) to identify which package(s) the request actually concerns.
   - If the admin already listed `packages:` in frontmatter, verify it's
     correct and complete against the actual codebase.
   - If it's empty or ambiguous, **ask the admin** which package(s) — do
     not guess, per `AGENTS.md`, "Multi-Project Discipline".
   - If it genuinely concerns more than one package, follow "Multi-Package
     Requirements" in `shared/requirements.md`: split into one
     per-package sub-requirement file per package (copy
     `docs/requirements/TEMPLATE.md` for each, with a single-entry
     `packages:` list each), and make the umbrella file's Refined Spec
     reference them by path instead of describing implementation directly.
4. Fill in "Refined Spec":
   - **Scope**: what's in and explicitly out of scope.
   - **Acceptance Criteria**: concrete, testable conditions for "done".
   - **Affected Packages / Paths**: the specific package(s) and, where
     knowable, which `agents.<role>.owns_paths` (see `workspace.yaml`) the
     work will touch.
   - **Dependencies / Sequencing**: anything this depends on, or that
     depends on it.
   - **Open Questions**: anything the admin must resolve before approving
     — always written explain-like-I'm-5 first (plain words, no jargon or
     acronyms, short sentences, everyday comparisons), with more
     technical detail underneath or on request. Never require the admin
     to read the technical version to make a decision. Example:
     - Not ELI5: "Should we introduce an event bus (Kafka) between
       `payments-api` and `billing-worker`, or keep the synchronous REST
       call?"
     - ELI5: "Right now, when someone pays, `payments-api` calls
       `billing-worker` directly and waits for an answer, like calling a
       friend and staying on the phone until they finish. We could
       instead leave them a note to read whenever they're free. Which do
       we want here?"
5. **Decide `architecture_impact`**: set it `true` if this changes _how_ a
   package is built, not just what it does (new data stores/external
   dependencies, breaking API/schema changes, changes to how services talk
   to each other, security-model changes, etc.). When in doubt, set it
   `true` — see `shared/requirements.md`, "Architecture-Critical
   Requirements". This doesn't change how questions are written (they're
   already ELI5 by default) — it raises the bar for approval: tell the
   admin explicitly that every open question needs their real, explicit
   answer, not just a skim, because of the architecture impact.
6. Set `status: refined` and update the `updated` date.
7. Tell the admin the file is ready for review — explain-like-I'm-5 first
   — and summarize the Refined Spec (and any split sub-requirements) back
   to them. Do not set `status: approved` yourself; that is the admin's
   decision alone, and for architecture-critical requirements it requires
   an explicit answer to every open question in "Admin Notes," not just a
   status flip.

## Constraints

- Never implement code, create branches, or start Plan Mode/Team Mode from
  this skill — refining is strictly a spec-writing step.
- Never move `status` past `refined`.
- Never leave `packages:` empty or guessed when the request clearly targets
  specific code — ask instead.
- Never copy private-workspace content (`private/README.md`) into the
  requirement file — reference it by path only, if relevant.
- Never leave `architecture_impact` unconsidered — explicitly decide
  `true`/`false` and justify it briefly in the Refined Spec.
- Never write an Open Question, or any message to the admin, in a
  technical-jargon-first way — explain like they're 5 first, always,
  offering more detail only underneath or on request.
