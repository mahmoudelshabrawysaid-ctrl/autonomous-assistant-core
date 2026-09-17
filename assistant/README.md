# Assistant Command Center v1

This directory defines the human-facing control layer for `autonomous-assistant-core`.

It is intentionally documentation-first: commands describe workflows, while execution remains behind explicit project tools and authorization checks.

## Design principles

- **One entry point:** short commands map to repeatable workflows.
- **Least necessary access:** use the smallest tool and permission needed.
- **Read before write:** inspect the current state before changing it.
- **Validation:** every meaningful change should have a check or test.
- **Secret hygiene:** credentials stay in environment variables or platform Secrets.
- **Security scope:** security testing is limited to explicitly authorized targets.
- **Human control:** destructive, costly, or high-impact actions require explicit confirmation when the platform permits it.

See `commands.md`, `tasks.md`, `report_template.md`, and `safety_guard.py` for the v1 building blocks.
