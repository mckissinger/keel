# Chore batch — ci-test-wiring

Punch-list batch: wire the shipped hook-guard self-tests into keel's own CI.

## Applied items

- **wire-hook-self-tests** — CI runs the session/merge/branch hook guard self-tests (`scripts/session-bootstrap.test.sh`, `scripts/merge-guard.test.sh`, `scripts/guard-branch-rules.test.sh`) as workflow steps between the neutrality guard and the plan lint.

## Combined checks

`bash scripts/check-verified-pin.test.sh` (17 passed), `bash scripts/check-neutral.test.sh` (17 passed), `bash scripts/check-neutral.sh` (PASS), `bash scripts/session-bootstrap.test.sh` (11 passed), `bash scripts/merge-guard.test.sh` (29 passed), `bash scripts/guard-branch-rules.test.sh` (16 passed), `bash scripts/check-plan.test.sh` (18 passed), `bash scripts/check-plan.sh` (PASS), `claude plugin validate --strict .` (validation passed) — all green on the combined branch.

verified: clean at 396f81f, 2026-07-01, via punch-list (evidence in PR #52)
