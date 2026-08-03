# Uncertainty — is an edited config-block default an "operator override" (trusted) or held to never-weakens?

**The choice made.** The never-weakens rule (the effective required set MUST include the
security-review check) is applied to the **committed-config / keel-default path only**. An OPERATOR
OVERRIDE — `PREFLIGHT_REQUIRED_CHECKS` set in the environment, **or a project copy that edited the
script's config-block default** — is trusted and may omit security-review, exactly as before this
change (`scripts/check-branch-protection.sh`, the `if [ "$override_checks" -eq 0 ]` guard around the
never-weakens GAP).

**The viable alternative.** Hold an **edited config-block default** to never-weakens too (only a bare
env var would be the trusted one-off), on the grounds that editing a committed script is itself a
committed change to the trust base and arguably deserves the same "can't silently drop the review"
protection as the committed data file.

**Why it's uncertain.** The spec did not dictate which side of the operator/data line the config-block
edit falls on. I put it on the trusted (operator) side to preserve the existing behavior encoded by
`check-branch-protection.test.sh` case 10 (an explicit required set without security-review passes) and
`check-auto-preflight.test.sh` test 21 (a config-block edit propagates) — keel's established model
trusts an operator stating the set explicitly. But a reasonable reviewer focused on the standing,
unattended nature of the committed marker could argue the config-block edit is "committed enough" to
warrant never-weakens, and would move that one comparison. The consequence is real but narrow: it only
governs whether a project that edits the *script* (not the data file) can arm with a required set that
names no security-review check.
