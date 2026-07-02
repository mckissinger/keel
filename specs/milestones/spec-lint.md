# Milestone — Spec-lint: close the ungated PR class

**Goal:** malformed plans are caught at the plan PR (mechanized structure via
`check-plan.sh`, judgment via a pre-PR adversarial verifier pass) instead of a full
build+verify cycle later.

**Change:** `specs/changes/spec-lint.md`. **No-UI** → two-dimension done-conditions.
**Depends on:** nothing. **Parallelizable:** yes (disjoint from verifier-hygiene; touches
spec-feature/spec-change prose the hooks feature doesn't).

## Done-conditions

### Logic / invariants
- [auto] `scripts/check-plan.sh` exists (house idiom: bash, `set -euo pipefail`, FAIL with
  reason on stderr, exit 0/1) and asserts over each `specs/milestones/*.md`: a verification
  section exists; every done-condition bullet carries exactly one of
  `[auto]`/`[runtime]`/`[attended]`; every `[runtime]` bullet names a committed test
  (path-or-name presence); fidelity-mentioning specs name their reference. Chore batch specs
  (`specs/chores/*.md`) are checked for pin-line shape only.
- [auto] `scripts/check-plan.test.sh` (throwaway fixtures) covers minimum: clean spec passes;
  untagged condition fails; `[runtime]` without a named test fails; missing verification
  section fails; chore spec with valid shape passes; a directory with no specs passes
  (bootstrap-compatible).
- [auto] `check-plan.sh` passes against the full existing corpus on the branch — no
  aspirational rule that fails specs already on `main`; any legacy spec it flags is fixed in
  this same PR (each fix a one-line structural amendment, listed in the PR body).
- [auto] keel's own CI guards job runs `check-plan.sh` + its self-test;
  `skills/spec-foundation/SKILL.md` Repo setup extends the copy-don't-re-author clause to
  include it.

### Behavioral completeness
- [auto] The adversarial plan pass is prescribed once: `references/milestones-and-verification.md`
  states the rule (pre-plan-PR verifier dispatch, the five plan-shaped questions, findings
  fixed in-session before the PR opens); `skills/spec-feature/SKILL.md` Movement 3 and
  `skills/spec-change/SKILL.md` §3 each carry one dispatch line pointing at it (one owner, no
  restatement).
- [auto] The pin gate's plan-only exemption is unchanged in the diff
  (`scripts/check-verified-pin.sh` untouched).
- [auto] `scripts/check-neutral.sh` exits 0; all script self-tests (neutral, verified-pin,
  plan) pass.

## verification
verifier subagent against this file (lint behavior exercised through the committed self-test;
corpus-clean run on the branch; one-owner sweep for the adversarial-pass rule; pin-gate
untouched check) + all script self-tests. No surface/action change → no runtime walk. The
lint is a new gate but adds strictness rather than loosening — no `/security-review`; the
standard adversarial plan pass applies to this spec itself once landed.
