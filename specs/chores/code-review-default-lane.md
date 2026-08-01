# Chore batch — code-review-default-lane

Single-item chore: the pre-pin review-type picker for algorithmic/logic-heavy milestones names the standard local `/code-review`, not the cloud `/code-review ultra` escalation. The owner's call (2026-08-01): the default correctness-class review lane is the normal local review; the ultra escalation stays available but is no longer the prescribed default. The `/security-review` half of the picker is untouched.

## Applied items

- **review-picker-default** — `references/milestones-and-verification.md` §3: the hard-invariant review-type picker's correctness-class lane changed from `/code-review ultra` to `/code-review`.
  - Done-condition: the review-type picker sentence in §3 names `/code-review` (bare, no `ultra`) for the algorithmic/logic-heavy class, and no operative directive anywhere in `references/` or `skills/` prescribes `/code-review ultra`. (The historical ultrareview anecdote in `skills/spec-foundation/SKILL.md` is a record of a past finding, not a directive, and stays.)

## Combined checks

`bash scripts/check-verified-pin.test.sh` (36 passed), `bash scripts/check-neutral.test.sh` (17 passed), `bash scripts/check-plan.test.sh` (21 passed), `bash scripts/check-neutral.sh` (PASS), `bash scripts/check-plan.sh` (PASS), `bash scripts/check-skill-frontmatter.sh` (PASS), `bash scripts/check-skill-anchors.sh` (PASS) — all green on the branch.

verified: clean at 022ce4f, 2026-08-01, via fresh-session verifier (all three done-condition points confirmed with file:line evidence)
