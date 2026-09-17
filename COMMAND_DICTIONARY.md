# CORE Command Dictionary

`/core` is the single user-facing gateway. Requests are written naturally; the system maps intent to the relevant project area.

## Canonical areas

| Area | Typical words / phrases |
|---|---|
| security | lab, CTF, scan, recon, vuln, target, allowlist, nmap, SQLi, XSS, لاب، سي تي اف، فحص، استطلاع، ثغرة، هدف، أمان، سيبر |
| code | GitHub, repo, commit, branch, workflow, code, bug, fix, build, test, كود، مشروع، إصلاح، جيت |
| report | report, summary, docs, documentation, تقرير، ملخص، توثيق |
| english | English, pronunciation, travel, إنجليزي، نطق، سفر |
| football | football, soccer, match, player, league, كرة، مباراة، لاعب، دوري |
| integrations | plugin, Notion, Airtable, Coda, monday, Canva, بلاجن، تكامل |
| general | anything that does not match a specific area |

## Operating convention

- The user does not need to know internal tool names.
- `/core <request>` means: understand the intent, inspect relevant context, choose the appropriate connected capability, execute what is authorized and available, and report the result with minimal intermediate narration.
- If an external permission or credential is genuinely required, ask only for that missing action.
- Security requests remain subject to `SAFETY.md` and the existing target guard.
