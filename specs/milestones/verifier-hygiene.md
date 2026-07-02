# Milestone — Verifier hygiene: mandate scope, infra classification, condition anti-patterns

**Goal:** the verifier reports spec-conformance gaps only (checked-clean is success),
classifies infra failures before any verdict, and the shared rules name the done-condition
authoring anti-patterns that cause false bounces and false pins.

**Change:** `specs/changes/verifier-hygiene.md`. **No-UI** → two-dimension done-conditions.
**Depends on:** nothing. **Parallelizable:** yes (disjoint from spec-lint and the hooks
feature).

## Done-conditions

### Logic / invariants
- [auto] `agents/verifier.md` gains, adjacent to the "Do not be agreeable" rule: (a) the
  mandate scope — findings are correctness/requirement/spec-conformance gaps only; style
  preferences, refactor suggestions, and speculative hardening never appear; (b) the
  counterweight — a checked-clean empty report is equally a success; never pad; (c) the infra
  rule — classify infra-shaped failures (OOM/kill, port conflict, rate limit, service never
  ready) as environment before recording a discrepancy; still-failing after classification →
  "unverifiable: infrastructure" (no pin, no remediation milestone); the read-only
  classify-and-report stance is restated (no mutate-to-retry).
- [auto] `agents/verifier.md` gains 2–3 few-shot calibration examples: a real
  discrepancy (empirical, reproduced, cited — the fail-open-bounce shape), a non-finding
  (style preference), an unverifiable-infrastructure item.
- [auto] `skills/verify-milestone/SKILL.md` Verdict section: one sentence each for mandate
  scope and infra classification; the serial-path-may-retry-after-resource-fix carve-out
  appears there and nowhere else.
- [auto] `references/milestones-and-verification.md` §1 gains exactly three anti-patterns:
  outcomes-not-paths (with the named-test-file no-collision note), tolerance-over-exactness
  for approximate requirements, and the two-readers wording bar. `skills/spec-feature/SKILL.md`
  Movement 3 and `skills/spec-change/SKILL.md` each gain one pointer line to §1's
  anti-patterns — no restatement (one owner).

### Behavioral completeness
- [auto] No weakening: "Do not be agreeable", the evidence rules, read-only stance, and the
  existing §1 example are unchanged in the diff.
- [auto] `scripts/check-neutral.sh` exits 0 (verifier.md and the §1 spine edit are
  platform-neutral); both script self-tests pass; `scripts/` untouched vs `main`.

## verification
verifier subagent against this file (docs greps for each clause, one-owner sweep for the
carve-out and anti-patterns, no-weakening diff review) + neutral checks. No surface/action
change → no runtime walk; no hard invariant → no `/security-review`.

verified: clean at 7052b8a, 2026-07-01, via fresh-context verifier subagent — all 6 conditions pass: three ground rules adjacent to "Do not be agreeable" (mandate scope, checked-clean/never-pad, infra classification with "unverifiable: infrastructure"/no-pin-no-remediation and no-mutate-to-retry restated) at verifier.md:14–16, exactly 3 calibration examples of the required shapes (:39–41), Verdict mandate+infra sentences with the serial-path retry carve-out appearing there and nowhere else per corpus grep (verify-milestone SKILL.md:42), exactly three §1 anti-patterns incl. the named-test no-collision note with one pointer line each in spec-feature Movement 3 (:53) and spec-change (:33) and no restatement, pure-insertion diff (21+/0−) leaving "Do not be agreeable"/evidence rules/read-only stance/§1 example byte-unchanged, check-neutral PASS + 12/12 + 17/17 self-tests with scripts/ untouched; all three disclosed interpretations acceptable (genericized war story keeps the empirical/reproduced/cited shape, "(no pin, no remediation milestone)" verbatim, combined mandate+counterweight sentence still gives one sentence each to scope and infra) (evidence: verifier report in PR)
