# Security Guardrails

## Secrets Management

- Never hardcode secrets, API keys, tokens, passwords, or connection strings.
- Keep credentials in environment variables or a dedicated secrets manager.
- Never commit `.env` files; ensure they are in `.gitignore`.
- Never include secrets in log output, error messages, API responses, or URL parameters.
- Use clearly fake placeholders in tests and fixtures (e.g., `FAKE-KEY-FOR-TESTING`).
- If a secret may have been exposed, flag it immediately and recommend rotation.

## Injection Prevention

- Never concatenate user input into SQL queries; use parameterized queries or ORM methods.
- Never concatenate user input into OS commands; use allowlists and safe APIs.
- Never pass user input to `eval()`, `exec()`, `Function()`, or dynamic code execution.
- Never deserialize untrusted data without strict type validation.

## Input Validation

- Validate all user input at system boundaries before processing.
- Use schema-based validation where available.
- Reject invalid input with clear, safe error messages; fail fast.
- Never trust external data (API responses, user input, file content, headers).

## Output Safety

- Never render user input in HTML without encoding; use framework-provided auto-escaping.
- Never use `innerHTML`, `dangerouslySetInnerHTML`, or raw template injection with user data.
- Do not expose stack traces, internal paths, database schema, or framework details.
- Map all exceptions to safe, generic client-facing error messages.

## Authentication & Authorization

- Never implement custom cryptography; use established, audited libraries.
- Store passwords with bcrypt or Argon2; never MD5, SHA1, or SHA256 for password hashing.
- Never log passwords, tokens, session IDs, or personally identifiable information (PII).
- Enforce authentication and authorization at every endpoint that accesses protected resources.

## Dependencies

- Pin exact versions in production; avoid floating ranges like `latest`, `*`, or unbounded `>=`.
- Verify dependencies have no known CVEs before adding them.
- Avoid deprecated, abandoned, or archived packages.
- Check license compatibility before adding dependencies.

## Quality Gates

- Never disable, bypass, or weaken existing security tools, linters, or CI/CD quality gates.
- Do not modify branch protection rules or repository security policies without human approval.
- Suppress lint/build/test errors only with explicit human approval.
- All code changes must be committed to feature branches and merged via pull request after review.
