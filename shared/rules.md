# Shared Rules

All AI agents and IDEs must follow these rules when working in this repository.

## Before Every Task

0. Run `scripts/setup.sh` (or `.ps1`) once per fresh checkout instead of
   manually probing git/private-workspace state with ad-hoc shell
   commands — it already resolves submodules, the private workspace, and
   root git status safely in one call. Chaining several unrelated
   commands together (reading `.gitmodules`, listing `$HOME`, checking env
   vars, `git rev-parse`, ...) is more likely to hit a tool's own
   command-approval/sandbox limits than to actually be necessary. Same
   principle for importing a package: run `scripts/add-package.sh`/`.ps1
<git-url>` directly rather than pre-checking with your own `cd`/`git
rev-parse`/`ls` commands first — it already detects
   submodule-vs-plain-clone mode internally.
1. Read `workspace.yaml` at the start of every session or task.
2. Identify the relevant `agents/<role>.md` for the work and read it.
3. Read `shared/security.md` for guardrails before writing code or configuration.

## Root Repo Git Is Optional, Permanently

It is completely fine, on first use and forever, for this project root to
have no `.git` at all — never treat that as an error. It's meant to stay a
plain local folder for config/orchestration; real project work and its
commit history live inside each `packages/<name>/`, each with its own
independent git repo. See `AGENTS.md`, "This Root Repo Never Needs Its Own
git init", and `packages/README.md`, "Note on git activity".

## Keeping All Agents in Sync

All agents/IDEs must see the same information at all times. If you add,
rename, or retire a `shared/*.md` doc, or change what an agent role does,
update every tool's integration file (`AGENTS.md`, `.claude/CLAUDE.md`,
`.cursor/rules/`, `.windsurf/rules/`, `.github/copilot-instructions.md`) to
match, then run `scripts/check-sync.sh` (task `sync`) to confirm none of
them fell out of sync.

## Code Quality

- Follow the conventions in `shared/conventions.md`.
- Keep files focused and under 500 lines when practical.
- Do not duplicate logic; prefer shared packages and utilities.
- Write tests for new behavior where applicable.
- Use clear, descriptive names for files, functions, and variables.

## Security & Safety

- See `shared/security.md` for detailed security guardrails.
- Never commit secrets, tokens, passwords, or credentials in any file.
- Never disable, bypass, or weaken linters, tests, or security controls.
- Map exceptions to safe, generic client-facing error messages.

## Communication

- Be concise and direct in responses.
- Cite files and lines when referencing code.
- Ask clarifying questions if the task or scope is ambiguous.
- **Any question, request, or approval ask directed at the admin/project
  lead is always explained like they're 5 first**: plain words, no jargon
  or acronyms, short sentences, everyday comparisons. Offer more technical
  detail underneath or on request, but never require the admin to read the
  technical version to make a decision. See `shared/requirements.md` for
  how this applies to business requirements specifically.
