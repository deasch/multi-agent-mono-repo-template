# Business Requirements

This directory holds business requirements moving through the lifecycle
defined in `shared/requirements.md`: **Admin writes (draft) → Agent refines
(refined) → Admin approves (approved) → Agents implement (in-progress →
done)**.

- One file per requirement: `docs/requirements/<slug>.md`, copied from
  `docs/requirements/TEMPLATE.md`.
- Every requirement **must** list exactly which `packages/<name>/` it
  concerns in its `packages:` frontmatter — never leave this implicit. See
  `shared/requirements.md`, "Required: Every Requirement Names Its
  Package(s) Explicitly" and "Multi-Package Requirements".
- Files here are **tracked** (committed) so any role or teammate can see
  requirement status without extra setup, but are not permanent: archive
  or delete once `status: done` and merged. Don't let stale requirements
  accumulate.
- Never commit secrets, tokens, or private-workspace content here — see
  `private/README.md`.
- Never let this content leak into a package's own repo — see
  `packages/README.md`'s guardrails.
