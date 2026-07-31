# Private Context

**The key: public knowledge lives in each repo; private context and workflow
rules live in the private workspace.**

This `private/` directory in the repo is intentionally **public**: it only
ships the README (this file) and `.example` schema templates so every repo
using this pattern documents the same shape of private context. The actual,
filled-in private files must **not** live inside this repo at all — not even
gitignored — they live in **the private workspace**: a separate directory
maintained outside any individual repo (per developer or per org), so it
survives repo deletion/re-clone and can be shared consistently across every
repo that uses this template.

## Public Knowledge vs. Private Context

|                        | Public Knowledge                                                       | Private Context                                                             |
| ---------------------- | ---------------------------------------------------------------------- | --------------------------------------------------------------------------- |
| Location               | `workspace.yaml`, `agents/`, `shared/`, `AGENTS.md` — **in this repo** | The four categories below — **in the private workspace, outside this repo** |
| Committed to git?      | Yes                                                                    | Never — not committed in this repo or the private workspace                 |
| Contains               | Generic roles, conventions, security guardrails, task definitions      | The four categories below                                                   |
| Safe to publish/share? | Yes                                                                    | No — never                                                                  |
| Read by agents?        | Always                                                                 | If the private workspace exists; agents must not assume it does             |

## This Repo Is a Template — Each Project Is Its Own Independent Repo

This repo is the **template and rulebook**, not a project itself. Each real
project gets **its own independent repo**, instantiated from this template,
with its own git history, its own public `AGENTS.md` (architecture, API,
build — filled in for that project), and its own submodules under
`packages/` where useful. Project repos are never nested inside one
another, and there is no "hub" repo that contains other project repos as
submodules.

**Work on one project at a time.** If it's ever unclear which project a
task concerns (e.g. multiple project checkouts exist, or the private
workspace references several projects), ask which project before making
any change, then confine all reads/writes to that single project's repo
for the rest of the task. Never modify files across more than one project
repo in the same task. See `AGENTS.md` in the repo root, "Multi-Project
Discipline".

The **private workspace** is a separate concern from project-to-project
relationships: it's where a developer or org keeps context that spans
projects without living inside any single one of them (tokens, cross-service
relationships, team design, workflow rules — the four categories below). A
given project repo may optionally mount it as its own submodule (see
below) purely for convenience/unified checkout; that doesn't change the
rule that each project repo is still edited independently.

## In-Repo Mode: Keeping Private Context Inside This Repo

Everything above describes **"external" mode** (the default, see
`workspace.yaml` → `context.private.mode`): the right choice whenever this
specific repo instance might itself be redistributed, forked, or used as a
generic starting point by others — real private content must never be
committed in a repo that could end up public or widely shared.

If, instead, **this specific repo instance** is already access-controlled
(private, internal-only) and you don't intend to redistribute it as a
template, you can switch to **"in-repo" mode** and commit real private
context directly here instead of maintaining a separate external workspace:

1. Set `context.private.mode: "in-repo"` in `workspace.yaml`.
2. Copy the `.example` templates in this directory to their real names
   (e.g. `workflow-rules.local.md.example` → `workflow-rules.local.md`) and
   fill them in.
3. Remove (or narrow) the `private/*.local.*` line in `.gitignore` — it
   exists specifically to keep real `*.local.*` files out of a repo running
   in "external" mode; in "in-repo" mode you want these files tracked.
4. Commit the real files normally.

Agents resolve private context by checking `context.private.mode` in
`workspace.yaml` first: if `"in-repo"`, read real files directly from
`private/*.local.*` in this repo; if `"external"` (or unset), use the
resolution order below instead. Never mix the two — pick one mode per repo
instance.

This choice is per-repo-instance, not part of the generic template's
contract: a fresh copy of this template defaults to `"external"` and ships
no real private content, keeping the template itself safe to publish.

## Where the Private Workspace Lives (From a Project Repo's Perspective)

Agents resolve the private workspace location in this order:

1. `private-workspace/` in this repo, if mounted as a git submodule and
   non-empty (see below).
2. The `AGENT_PRIVATE_WORKSPACE` environment variable, if set.
3. `~/.agent-private-workspace/` as the default root.
4. Within whichever root applies, this project's private files live under a
   folder named after `workspace.name` from `workspace.yaml` (e.g.
   `~/.agent-private-workspace/unified-ai-workspace/`).

If none of the above exist, treat private context as unavailable and
proceed using only the public knowledge in `workspace.yaml`, `agents/`, and
`shared/`.

## Private Workspace as a Submodule

You can mount a private repo **inside a project** as a git submodule at
`private-workspace/`. This unifies public and private context into a
single checkout for that project — clone the project repo, run
`git submodule update --init`, and (if you have access to the private repo)
`private-workspace/` appears populated — while keeping the two completely
separate git histories. The same private repo can be mounted this way in
multiple project repos independently; it isn't a container for them.

Setup: see `.gitmodules` at the repo root for the exact steps. Once
configured, `private-workspace/` takes priority in the resolution order
above.

`.gitmodules` itself is safe to commit publicly — it only records the
private repo's URL and a pinned commit SHA, never its file contents. If
even the URL/repo name is sensitive, skip committing `.gitmodules` and add
the submodule to local-only git config instead (`git config -f
.git/config submodule...`), or keep using the on-disk workspace approach
above.

## The Four Categories of Private Context

1. **Local Environment & Credentials** — device-specific settings, tokens,
   key paths. Store only references/paths and non-secret configuration here
   (e.g. "API key lives in `~/.config/foo/key`"). Never write raw secret
   values into any file, in this repo or the private workspace — see
   `shared/security.md`. Use a secrets manager or environment variables for
   actual credential values.
2. **Cross-Service Relationships & Change Patterns** — context for AI doing
   cross-service work: which services call which, deployment ordering,
   known breaking-change patterns, non-obvious coupling between packages.
3. **Team Mode Agent Design** — team structure that Plan Mode references:
   which agent roles exist for this project/org, how they map onto the
   roles in `agents/`, and any org-specific additions or overrides. See
   `shared/workflows.md` for how Plan Mode and Team Mode use this together
   with git worktrees to run subtasks concurrently.
4. **Workflow Rules** — instructions on how the AI should approach work for
   this project/org: preferred approach order, escalation paths, review
   expectations beyond what's in `shared/rules.md`.

Each category has a schema/example template in this directory (public,
committed — these are just the shape, not real content):

- `environment.local.md.example`
- `cross-service-context.local.md.example`
- `team-mode-design.local.md.example`
- `workflow-rules.local.md.example`

`AGENTS.md.example` in this directory is a starting point for the private
workspace repo's own `AGENTS.md` (categories 1 and 2 consolidated) — the
file agents read first whenever the private workspace is available,
regardless of which project repo they're currently confined to.

## Rules for Agents

- First check `context.private.mode` in `workspace.yaml` to know which mode
  this repo instance uses ("external" is the default if unset).
- Treat every file matching `*.local.*` — wherever it lives — as
  confidential.
- Never copy content from private context into `shared/`, `agents/`,
  README files, commit messages, PR descriptions, or any other artifact
  intended for publication (this applies in both modes).
- In **"external" mode** (default): never create real (non-`.example`)
  `*.local.*` files inside this repo's `private/` directory — they belong
  only in the private workspace. If the private workspace doesn't exist,
  proceed using only the public knowledge in `workspace.yaml`, `agents/`,
  and `shared/` — do not ask the user to create it unless the task
  explicitly requires org-specific context unavailable anywhere else.
- In **"in-repo" mode**: real `*.local.*` files under `private/` in this
  repo are expected and committed — read them directly, but still never
  propagate their content into files meant to leave this repo (forks,
  extracted templates, shared snippets, etc.).

## Usage

### On-Disk Private Workspace (No Submodule)

1. Set up your private workspace once, e.g.
   `mkdir -p ~/.agent-private-workspace/unified-ai-workspace` (or set
   `AGENT_PRIVATE_WORKSPACE` to a custom root).
2. Copy the `.example` templates from this repo's `private/` directory into
   your private workspace folder, dropping the `.example` suffix (e.g.
   `workflow-rules.local.md.example` → `workflow-rules.local.md`).
3. Fill them in with real, private context for your project/organization.
4. Only fill in the categories that apply; it's fine to leave others out.
5. Because the private workspace lives outside this repo, it is never
   committed, never included in `git clone`, and is naturally shared across
   every repo that uses this template.

### In-Repo Mode

See "In-Repo Mode: Keeping Private Context Inside This Repo" above — set
`context.private.mode: "in-repo"` in `workspace.yaml`, copy the `.example`
templates to real filenames in place, adjust `.gitignore`, and commit them.
No external workspace needed.

### Mounting the Private Workspace Into a Project

1. Create a new, access-controlled private repository on GitHub (or your own
   git server) — this holds your private context. This step is manual;
   these tools can't create hosted repos for you.
2. Clone it locally once, then copy `AGENTS.md.example` and the four
   `.example` templates from this directory into it, dropping the
   `.example` suffix, and fill them in.
3. In each project repo that should see it, run:
   `git submodule add <private-repo-url> private-workspace`
4. Commit `.gitmodules` and the submodule gitlink in that project repo —
   safe to commit, it only records the URL and a pinned commit SHA.
5. `scripts/setup.sh` (or `scripts/setup.ps1` on native Windows) in the
   project repo automates initializing the submodule and resolving the
   private workspace — see the root `README.md`.
