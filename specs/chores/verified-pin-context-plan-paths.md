# Chore batch — verified-pin-context-plan-paths

Punch-list batch: broaden the verified-pin gate's plan-only exemption to also treat `decisions/**` and `deferrals/**` as plan paths.

## Applied items

- **plan-path-decisions-deferrals** — `scripts/check-verified-pin.sh` `is_plan_path()` now matches `decisions/*` and `deferrals/*` alongside `specs/*` and `design/*`, so a PR touching only those paths is exempt from the pin requirement; the plan-only pass message names all four path families. `scripts/check-verified-pin.test.sh` adds cases 17 (`decisions/**`-only PR is plan-only exempt) and 18 (`deferrals/**`-only PR is plan-only exempt), both off the window-closed base.
  - Done-condition: `bash scripts/check-verified-pin.test.sh` passes with the two new cases (19 passed, 0 failed), and a `decisions/`- or `deferrals/`-only diff is reported plan-only exempt.

## Combined checks

`bash scripts/check-verified-pin.test.sh` (19 passed), `bash scripts/check-neutral.test.sh` (17 passed), `bash scripts/check-neutral.sh` (PASS), `bash scripts/session-bootstrap.test.sh` (30 passed), `bash scripts/merge-guard.test.sh` (81 passed), `bash scripts/guard-branch-rules.test.sh` (30 passed), `bash scripts/attended-marker-parity.test.sh` (8 passed), `bash scripts/check-plan.test.sh` (18 passed), `bash scripts/check-plan.sh` (PASS), `bash scripts/check-skill-frontmatter.test.sh` (12 passed), `bash scripts/check-skill-frontmatter.sh` (PASS) — all green on the combined branch.

verified: clean at d364bb1, 2026-07-05, via punch-list (evidence in PR #79)
