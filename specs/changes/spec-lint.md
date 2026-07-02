# Change — Spec-lint: close the ungated PR class

**Grain:** one change → one milestone (`spec-change`). **No-UI** (a gate script + prose).
**Stacked on:** nothing (targets `main`).

## Why (the gap)

Plan-only PRs are the one PR class the verified-pin gate deliberately exempts — so a
malformed plan (an untagged done-condition, a `[runtime]` condition naming no committed test,
a UI milestone with no fidelity reference, a missing `verification:` line) sails through CI
and is discovered a full build+verify cycle later, when verify-milestone bounces the
milestone. The route→milestone map is called "auditable" (§6) but nothing audits it.
Anthropic's harness guidance has the evaluator negotiate the done-contract *before* the
generator builds; spec-kit's analyze step and superpowers v5 converged on the same shape
independently. keel already owns both halves of the fix: a bash-gate idiom
(check-neutral/check-verified-pin) for the mechanizable part, and the read-only verifier for
the judgment part.

## The mechanic

1. **`scripts/check-plan.sh`** (+ `check-plan.test.sh`, house idiom: throwaway fixtures,
   assert exit codes) — structural lint over `specs/milestones/*.md` (and
   `specs/chores/*.md` batch specs, pin-line rules only). Asserts per milestone spec: a
   `## verification` (or `verification:`) section exists; every done-condition line carries
   exactly one `[auto]`/`[runtime]`/`[attended]` tag; every `[runtime]` condition names a
   committed test (a path or test name — presence, not semantics); a spec whose conditions
   mention fidelity names its reference. Warnings vs failures split conservatively:
   structure is a failure, judgment calls are not mechanized. Wired into keel's own CI
   guards job; added to `spec-foundation`'s Repo setup CI prescription (copy, don't
   re-author — same clause as the pin gate).
2. **The adversarial plan pass** — `spec-feature` Movement 3 (before "Open the plan PR") and
   `spec-change` §3 (before the plan PR) dispatch the existing read-only verifier with
   plan-shaped questions: does every surface/route in the spec have an owning milestone; does
   every interview decision trace to a done-condition; are all applicable dimensions present
   per UI milestone; are integration seams named; and — the two-readers bar — flag any
   condition the verifier could not close as written. Findings are fixed in-session before
   the PR opens. The rule is stated once in `references/milestones-and-verification.md`
   (§ nearest the plan-PR/pin-gate rules); the two skills carry one dispatch line each.

**Not weakened:** the plan-only exemption in the pin gate is untouched — plan PRs still need
no pin; they now need well-formed plans.

## Scope

Two new scripts (lint + self-test), one CI step in keel's guards job, prose additions to two
skills + one reference + spec-foundation's Repo setup line. `check-plan.sh` must pass against
all existing specs on `main` at land time (fix any legacy spec it flags in the same PR, or
scope the lint to structural rules the corpus already satisfies — no aspirational rules that
fail the existing corpus).
