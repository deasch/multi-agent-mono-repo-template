# Shared Rules

All AI agents and IDEs must follow these rules when working in this repository.

## Before Every Task

1. Read `workspace.yaml` at the start of every session or task.
2. Identify the relevant `agents/<role>.md` for the work and read it.
3. Read `shared/security.md` for guardrails before writing code or configuration.

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
