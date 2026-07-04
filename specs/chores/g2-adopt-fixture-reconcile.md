# Chore batch — g2-adopt-fixture-reconcile

Punch-list batch: reconcile the g2 kickoff/adopt/interview boundary fixture so its expected verb matches the intended routing.

## Applied items

- **g2-adopt-expected-interview** — `scripts/skill-eval/fixtures/g2-adopt-existing.json` carries `"expected": "interview"` (reconciled from `"adopt"`) on the `kickoff/adopt/interview` boundary; the "retrofit keel's foundation onto an existing Rails codebase with no keel setup" prompt now expects `interview` to fire rather than `adopt`.

## Combined checks

`bash scripts/check-verified-pin.test.sh` (PASS), `bash scripts/check-neutral.test.sh` (PASS), `bash scripts/check-neutral.sh` (PASS), `bash scripts/session-bootstrap.test.sh` (PASS), `bash scripts/merge-guard.test.sh` (PASS), `bash scripts/guard-branch-rules.test.sh` (PASS), `bash scripts/check-plan.test.sh` (PASS), `bash scripts/check-plan.sh` (PASS), `bash scripts/check-skill-frontmatter.test.sh` (PASS), `bash scripts/check-skill-frontmatter.sh` (PASS), `bash scripts/skill-eval/detect.test.sh` (PASS), `bash scripts/skill-eval/judge.test.sh` (PASS), `bash scripts/skill-eval/index.sh --json` (barrel assembles, 14 fixtures), `claude plugin validate --strict .` (validation passed) — all green on the combined branch.

verified: clean at c225666, 2026-07-03, via punch-list (evidence in PR #71)
