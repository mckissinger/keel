# Chore batch — gate-doctrine-quickfixes

Punch-list batch: six small doctrine/hygiene fixes across the gate-and-merge skill corpus — review-before-pin scope, merge-authority settings scope, auto-merge marker expiry handling, env-recipe recording, a test-script mode bit, and a stale cross-reference.

## Applied items

- **review-then-pin** — `skills/verify-milestone/SKILL.md`: the invariant-milestone "no pin without a clean adversarial-review record" paragraph now states explicitly that the implement → review → verify+pin ordering covers *every* intended review pass (quality `/code-review` included), not just the security gate, so no review's fixes ever invalidate a fresh pin.
  - Done-condition: the verify-milestone skill's pin-precondition paragraph names the quality `/code-review` pass as running before the pin alongside `/security-review`.
- **merge-authority-scope** — `skills/spec-foundation/SKILL.md`: the merge-authority bullet in the generated project CLAUDE.md guidance now states that merge-authority/permission changes are expressed only in PROJECT-level settings (committed `.claude/settings.json` + hooks), never user-global, and that "merge as I go" routes to `keel:auto-merge` or an active auto posture, never a global settings edit.
  - Done-condition: the spec-foundation merge bullet forbids user-global merge-permission edits and names the attended auto-merge toggle as the correct route.
- **marker-expiry** — `skills/auto-merge/SKILL.md`: turning attended auto-merge on now requires announcing the marker's concrete expiry clock time, and a new "Expiry vs. pending merges" section requires either queueing the server-side `--auto` handoff or prompting a re-arm while the marker is still valid — letting it lapse over pending PRs is named a failure mode.
  - Done-condition: the auto-merge skill's `on` steps announce a concrete expiry time and the skill documents the two valid pre-expiry actions for in-flight PRs.
- **env-recipe** — `skills/provision/SKILL.md`: step 3 now requires recording the one-command recipe that re-derives the local env file (e.g. `vercel env pull .env.local`) in the environment contract, so any fresh checkout/worktree/session regenerates it mechanically.
  - Done-condition: provision step 3 instructs committing the env-file re-derivation command to the environment contract.
- **anchors-test-mode** — `scripts/check-skill-anchors.test.sh`: file mode corrected from 644 to 755 to match the repo's other executable test scripts.
  - Done-condition: `git ls-files -s scripts/check-skill-anchors.test.sh` shows mode 100755 and the self-test still passes.
- **stale-xref** — `references/milestones-and-verification.md`: the mechanical-vs-aesthetic split paragraph's section cross-reference updated from the stale §"verification splits in two" to the current §"Verification splits three ways".
  - Done-condition: the reference file's cross-reference names the section heading that actually exists in the document.

## Combined checks

`bash scripts/check-verified-pin.test.sh` (36 passed), `bash scripts/check-neutral.test.sh` (17 passed), `bash scripts/check-neutral.sh` (PASS), `bash scripts/session-bootstrap.test.sh` (36 passed), `bash scripts/merge-guard.test.sh` (102 passed), `bash scripts/guard-branch-rules.test.sh` (55 passed), `bash scripts/attended-marker-parity.test.sh` (12 passed), `bash scripts/check-auto-preflight.test.sh` (20 passed), `bash scripts/check-plan.test.sh` (21 passed), `bash scripts/check-plan.sh` (PASS), `bash scripts/check-skill-frontmatter.test.sh` (12 passed), `bash scripts/check-skill-frontmatter.sh` (PASS), `bash scripts/check-skill-anchors.test.sh` (14 passed), `bash scripts/check-skill-anchors.sh` (PASS), `claude plugin validate --strict .` (Validation passed) — all green on the combined branch.

verified: clean at d652596, 2026-07-12, via punch-list (evidence in PR #107)
