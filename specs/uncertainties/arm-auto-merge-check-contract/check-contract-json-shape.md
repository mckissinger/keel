# Uncertainty — the check-contract JSON shape and the new PREFLIGHT_SECREVIEW_CHECK env var

**The choice made.** `.claude/keel-auto-merge-checks.json` is:

```json
{
  "required_checks": ["...", "..."],
  "security_review": { "check": "security-review" }
}
```

— a nested `security_review` object carrying the check **name** only. (Earlier drafts also carried
`external` and `pattern`; verification found both weakenable — a committed `external: true` disables the
(b2) scan, and a committed `pattern` is a substring whose too-broad values match every `uses:` line — so
both were removed from the committed schema and stay env-only / keel-default,
`decisions/2026-08-03-arm-auto-merge-check-contract.md`, "the three-round evolution".) And I added a
matching env override `PREFLIGHT_SECREVIEW_CHECK` (there was none before) so the security-review *check
name* has the same env > config > default precedence as `PREFLIGHT_SECREVIEW_PATTERN` /
`PREFLIGHT_SECREVIEW_EXTERNAL`.

**The viable alternatives.** (1) A **flat** shape — `security_review_check` / `security_review_pattern`
/ `security_review_external` as top-level keys — matching the flat `PREFLIGHT_*` env names more
directly. (2) **Not** adding `PREFLIGHT_SECREVIEW_CHECK` at all, leaving the security-review check name
settable only via the committed file (the env layer covers pattern/external but not the name).

**Why it's uncertain.** The spec explicitly left "final key names are the build's to settle," so this
is a delegated-but-consequential pick: the committed file is now a small **contract**, and its shape is
what a consuming project (and any future tooling) writes against. I chose the nested object because it
groups the three security-review knobs and reads well, and added `PREFLIGHT_SECREVIEW_CHECK` for
precedence symmetry (all three security-review knobs overridable the same way). A reviewer could
reasonably prefer the flat shape for env-name parity, or judge the new env var unnecessary scope. Low
blast radius today (no existing consumer to migrate), but worth surfacing because it sets the file
format.
