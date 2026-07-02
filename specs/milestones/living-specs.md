# Milestone — Living specs: post-merge reconciliation + orient-first

**Goal:** specs reconcile to merged reality after a pin lands (code becomes authoritative,
completed milestone specs archive), and every build session orients + runs a green baseline
before writing code.

**Change:** `specs/changes/living-specs.md`. **No-UI** → two-dimension done-conditions.
**Depends on:** nothing. **Parallelizable:** yes (prose; disjoint from platform-posture).

## Done-conditions

### Logic / invariants
- [auto] `skills/land-feature/SKILL.md` gains a final reconciliation step after the post-wave
  consolidated check: one plan-only commit updating `specs/features/<feature>.md` (+ 00-product/
  01-architecture if shapes changed) to merged reality and archiving completed milestone specs
  to `specs/milestones/_landed/`. The step names the gate interaction explicitly (reconciliation
  commit is plan-only → covered by the plan-only exemption; archived path is not an active spec).
- [auto] `references/milestones-and-verification.md` §5 gains the spec-authority rule: after a
  pin merges, the milestone spec is historical and **code is authoritative**; never edit correct
  merged code to match a stale spec; living docs are updated by the later milestone that
  invalidates them. The CLAUDE.md template in `skills/spec-foundation/SKILL.md` Derived-status
  bullet gains the post-merge carve-out (replacing the unqualified "resolve in favor of the spec").
- [auto] `skills/spec-foundation/SKILL.md` Structure block documents `specs/milestones/_landed/`
  (mirroring the `deferrals/_closed.md` archive precedent).
- [auto] `skills/implement-milestone/SKILL.md` gains an "Orient first" step before "Branch
  first": derive state (pins + `gh pr list` + recent `git log`), re-read the milestone spec +
  stack profile from `main`, run the profile's cheapest committed rung once before writing code;
  a pre-existing red is a stop-point / routes to `debug`, never absorbed. The CLAUDE.md template
  carries the same start protocol. Step 6's drift rule is extended to "living docs my change made
  stale," not just "drift I caused."

### Behavioral completeness
- [auto] `scripts/check-plan.sh` still passes the full corpus — confirm the `_landed/` archive
  path is not linted as an active milestone spec (scope the glob if needed; note it in the diff).
- [auto] `scripts/check-verified-pin.sh` is untouched; a plan-only reconciliation commit
  (features + `_landed/` moves) is confirmed exempt by the existing plan-only/bootstrap logic
  (reasoned in the spec; no script change).
- [auto] `scripts/check-neutral.sh` exits 0; all script self-tests pass; one-owner sweep — the
  spec-authority rule stated once in §5, the CLAUDE.md template referencing it.

## verification
verifier subagent against this file (prose greps for each step + the authority carve-out + the
`_landed/` structure note + the extended drift rule; one-owner sweep) + `check-plan.sh` corpus
run + all script self-tests. No surface/action change → no runtime walk; no hard invariant
loosened → no `/security-review` (the plan-only exemption is reasoned, not modified).

verified: clean at 4922029, 2026-07-01, via verifier subagent (evidence in PR #56)
