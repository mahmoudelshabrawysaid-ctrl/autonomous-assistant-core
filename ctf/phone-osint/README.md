# Phone OSINT CTF — Synthetic Target

**Scope:** local-only. All data is fictional.

Target phone: `+201001234567`

## Objectives

1. Normalize the number and identify country/country code.
2. Separate harmless public metadata from identity/private-data collection.
3. Review the synthetic account/recovery fixture.
4. Identify simulated SIM-swap, SMS-OTP, rate-limit, and phone-only recovery risks.
5. Produce an Evidence + Risk + Remediation report with Report Engine.

## Intended lessons

- Phone numbers are identifiers, not authorization factors.
- SMS OTP can be weaker than phishing-resistant MFA.
- Recovery flows need rate limiting and independent recovery factors.
- OSINT collection should minimize personal-data exposure.

Do not use this fixture to contact or test real services.
