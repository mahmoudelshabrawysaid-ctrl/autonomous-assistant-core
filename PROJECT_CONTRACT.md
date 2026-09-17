# Independent Project Contract

Every tool or project created under this workspace follows the same lifecycle:

1. Define scope, inputs, outputs, and acceptance criteria.
2. Keep the project independently runnable and documented.
3. Add deterministic tests for core behavior and failure paths.
4. Run syntax/static checks and project tests in CI.
5. If a check fails, diagnose, patch, and re-run the relevant checks automatically when the environment permits.
6. Never claim a project is complete unless all configured acceptance checks pass.
7. Record unresolved external dependencies or permission blockers instead of hiding them.

## Completion states

- `PASS`: all configured checks passed.
- `RETRY`: a failure is retryable and the system may attempt recovery.
- `BLOCKED`: execution requires unavailable credentials, permissions, external services, or human input.
- `FAIL`: a non-recoverable check failed.

A passing test suite is evidence for the tested scope; it is not a mathematical guarantee of zero defects.

## Security scope

Security tooling is restricted to localhost, explicitly allowlisted private targets, CTF/lab assets, or systems for which the operator has authorization. The project must not weaken or bypass its Safety Guard to reach public targets.
