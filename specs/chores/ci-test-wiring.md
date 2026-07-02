# Chore batch — ci-test-wiring

Punch-list batch: wire the shipped git-hook self-tests into CI so they run on every push/PR.

## Applied items

- **wire-hook-self-tests** — `.github/workflows/ci.yml` runs the three shipped git-hook self-tests as workflow steps after the neutrality guards: `scripts/session-bootstrap.test.sh`, `scripts/merge-guard.test.sh`, and `scripts/guard-branch-rules.test.sh`.

## Combined checks

`bash scripts/check-verified-pin.test.sh` (17 passed), `bash scripts/check-neutral.test.sh` (17 passed), `bash scripts/check-neutral.sh` (PASS), `bash scripts/session-bootstrap.test.sh` (11 passed), `bash scripts/merge-guard.test.sh` (29 passed), `bash scripts/guard-branch-rules.test.sh` (16 passed), `bash scripts/check-plan.test.sh` (18 passed), `bash scripts/check-plan.sh` (PASS), `claude plugin validate --strict .` (validation passed) — all green on the combined branch.

verified: clean at f7a3b7b, 2026-07-01, via punch-list (evidence in PR #53)
