# Independent Project Template

Use this directory as the baseline for every standalone tool/project.

## Required

- Clear README with scope and usage
- Deterministic tests
- CI validation
- Security/scope notes where applicable
- Failure/retry behavior documented
- Final acceptance checklist

## Acceptance

A project is only marked `PASS` when its configured checks succeed. External credentials, network services, or permissions that cannot be verified locally are recorded as `BLOCKED` rather than guessed.
