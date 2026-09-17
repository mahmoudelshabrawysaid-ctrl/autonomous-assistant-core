#!/usr/bin/env python3
"""Small, dependency-free OpenAI Responses API client."""

import json
import os
import sys
import urllib.error
import urllib.request

API_URL = os.getenv("OPENAI_API_URL", "https://api.openai.com/v1/responses")
MODEL = os.getenv("OPENAI_MODEL", "gpt-4.1-mini")


def chat(prompt: str) -> str:
    api_key = os.environ.get("OPENAI_API_KEY")
    if not api_key:
        raise RuntimeError("OPENAI_API_KEY is not set in the environment.")

    payload = {"model": MODEL, "input": prompt}
    request = urllib.request.Request(
        API_URL,
        data=json.dumps(payload).encode("utf-8"),
        headers={
            "Content-Type": "application/json",
            "Authorization": f"Bearer {api_key}",
        },
        method="POST",
    )

    try:
        with urllib.request.urlopen(request, timeout=60) as response:
            data = json.loads(response.read().decode("utf-8"))
    except urllib.error.HTTPError as exc:
        detail = exc.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"OpenAI API HTTP {exc.code}: {detail[:500]}") from exc
    except urllib.error.URLError as exc:
        raise RuntimeError(f"Could not reach OpenAI API: {exc.reason}") from exc

    text = data.get("output_text")
    if not text:
        raise RuntimeError("OpenAI response did not contain output_text.")
    return text.strip()


def main() -> int:
    if len(sys.argv) < 2:
        print('Usage: python3 openai_client.py "Your prompt"', file=sys.stderr)
        return 1

    try:
        print(chat(" ".join(sys.argv[1:])))
    except RuntimeError as exc:
        print(f"Error: {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
