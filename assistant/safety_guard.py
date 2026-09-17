#!/usr/bin/env python3
"""Minimal safety gate for authorized security-lab tasks."""

from dataclasses import dataclass


@dataclass(frozen=True)
class Scope:
    target: str
    authorized: bool
    allowed_action: str


def validate(scope: Scope) -> tuple[bool, str]:
    if not scope.target.strip():
        return False, "Target is required."
    if not scope.authorized:
        return False, "Explicit authorization is required."
    if not scope.allowed_action.strip():
        return False, "Allowed action is required."
    return True, "Scope accepted."


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Validate an authorized lab scope")
    parser.add_argument("--target", required=True)
    parser.add_argument("--action", required=True)
    parser.add_argument("--authorized", action="store_true")
    args = parser.parse_args()

    ok, message = validate(Scope(args.target, args.authorized, args.action))
    print(message)
    raise SystemExit(0 if ok else 2)
