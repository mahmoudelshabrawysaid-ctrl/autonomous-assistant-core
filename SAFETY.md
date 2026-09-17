# Safety Contract

This project is for local labs, CTF training, and security testing that the operator is explicitly authorized to perform.

## Non-negotiable boundaries

- Keep `~/bin/guard` and the allowlist model enabled for security commands.
- Localhost and loopback are the default targets.
- Private-network targets require explicit allowlisting.
- Public IPs, public hostnames, and URLs are rejected by the security command layer.
- Do not store API keys, passwords, tokens, session cookies, or other secrets in the repository.
- Do not add automation whose purpose is to bypass authorization, access controls, rate limits, or platform safeguards.
- Synthetic CTF cases are training data and must not be treated as permission to test third-party systems.

## Command-center contract

The `core-command.sh` gateway classifies requests only. It does not grant permissions and does not bypass the security guard. External tools may be used only when the connected integration and the user's authorization permit the action.
