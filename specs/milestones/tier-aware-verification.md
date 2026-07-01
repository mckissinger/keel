# Milestone — Tier-aware, artifact-based verification

**Goal:** the stack profile names each stack's concrete test tiers; `[auto]` means a committed
automated check (any headless tier, including component-render interaction tests); the runtime
walk narrows to divergence/fidelity/exploratory; committed-test coverage hard-gates the pin.
Plus fold-in: spec-time fidelity reference = named workbench components, never spec-time code.

**Change:** `specs/changes/tier-aware-verification.md`. **No-UI** → two-dimension
done-conditions. **Depends on:** none. **Parallelizable:** n/a (single milestone).

## Done-conditions

### Logic / invariants
- [auto] `references/profile-interface.md` gains **Q11 — Test tiers**: concrete runnable
  commands for **unit**, **component-render**, and **end-to-end** tiers, each answerable
  "n/a + why"; all tool mentions hedged ("e.g."), none required by name. Q3 and Q4 ⚠ notes
  cross-reference Q11. A new ⚠ scar generalizes the dogfood evidence (deterministic interaction
  bugs passing pure-logic `[auto]`; the hand-driven walk as a non-repeatable regression harness).
- [auto] `references/milestones-and-verification.md`: **§2/§7** redefine `[auto]` as "a
  committed automated check asserts this" spanning every headless tier (explicitly including
  component-render interaction tests), with the rule that a *deterministic* interaction belongs
  in a committed tier, not `[runtime]`; **§3** narrows the runtime walk to dev+prod surface
  activation, the vision/fidelity diff, the capped live variant, and an exploratory pass, with
  enumerated action→effect assertions moved to committed tests the verifier runs; **§3/§5** add
  the **hard coverage gate** — a `[runtime]` condition without its named committed test (in the
  highest profile-supported tier) forces verdict `blocked`, no pin, unless the profile marks the
  tier "n/a + why".
- [auto] `skills/verify-milestone/SKILL.md` runs the committed suites (all profile tiers) before
  the narrowed walk and enforces the coverage gate; `skills/implement-milestone/SKILL.md` step 4
  has the builder author the committed tests the done-conditions name (tests are part of the
  build); `skills/spec-feature/SKILL.md` tagging guidance routes deterministic interaction
  conditions to committed tiers (`[auto]`) and reserves `[runtime]` for the
  divergence/live/fidelity remainder. Skills reference the rules file; they do not restate it.
- [auto] **Fold-in #3:** `skills/spec-feature/SKILL.md` Movement 2, `skills/spec-change/SKILL.md`
  movement 2, and `references/milestones-and-verification.md` §6 each state: spec-time fidelity
  reference = the named workbench/gallery components (+ optional throwaway divergence sketch); a
  real composed feature story/preview is design-gate infrastructure on `main`, never code in a
  plan-only PR.

### Behavioral completeness
- [auto] No stale contradictions remain: no prose still claims `[auto]` is unit/static-only or
  routes every "a route renders / an action runs" condition to `[runtime]`
  (grep across `skills/` + `references/`); all §-cross-references and Q-numbers resolve
  (Q5–Q10 unrenumbered).
- [auto] `scripts/check-neutral.sh` exits 0 (no framework hardcodes introduced) and
  `scripts/check-verified-pin.test.sh` + `scripts/check-neutral.test.sh` still pass (no script
  was touched).

## verification
verifier subagent against this file (docs greps, cross-reference resolution, consistency
sweep) + `scripts/check-neutral.sh` + both script self-tests. No surface/action change → no
runtime walk; no hard invariant → no `/security-review`.

verified: clean at d0736b5, 2026-07-01, via fresh-context verifier subagent ×2 — first pass verified Q11 + [auto] redefinition + hard coverage gate + narrowed walk + fold-in with 2 stale-phrasing discrepancies; remediation cleared both (+ aligned the verify-milestone no-pin restatement, scope note for workflow strings + gitignore); focused re-verify clean (zero stale hits, check-neutral PASS, 12+9 self-tests, workflow parses, scripts/ untouched vs main). (evidence: verifier reports in PR)
