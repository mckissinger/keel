# Change — Verifier hygiene: mandate scope, infra classification, condition anti-patterns

**Grain:** one change → one milestone (`spec-change`). **No-UI** (prose changes to the
verifier agent + shared rules). **Stacked on:** nothing (targets `main`).

## Why (the gap)

Three adjacent verification-pipeline gaps, all sourced from Anthropic's published agent
guidance and one measured live:

1. **Over-reporting.** The verifier is prompted to hunt discrepancies ("do not be agreeable")
   with no counterweight; Anthropic's best-practices doc warns verbatim that a reviewer
   prompted to find gaps will report some even in sound work. Every finding blocks a pin and
   spawns a remediation milestone — a preference-shaped finding is expensive. The bounce that
   proved the system works (bootstrap-gate's fail-open, 2026-07-01) is also the calibration
   bar: that finding was empirical, reproduced, and cited — the standard to encode.
2. **Infra noise reads as defects.** The environment-skew rule exists only in
   `workflows/verify-all-milestones.js` — a serial verify session hitting a port conflict or
   OOM records a discrepancy and generates a false remediation build. Anthropic measured
   infra noise swinging agentic results by more than model gaps.
3. **Done-conditions are per-milestone evals with no anti-pattern guidance.** §1 of the
   shared rules has one positive example. The top grader pitfalls (grading implementation
   paths instead of outcomes; over-strict matching where the requirement is approximate;
   wording two readers score differently) are unnamed — and they are exactly what produces
   both false bounces and false pins.

## The mechanic

1. **`agents/verifier.md`** — after the "Do not be agreeable" rule: findings are
   correctness/requirement/spec-conformance gaps only — style preferences, refactor
   suggestions, and "could be more robust" hardening never appear; a checked-clean empty
   report is equally a success, never pad. Before recording any failing check as a
   discrepancy, classify infra-shaped failures (OOM/kill, port conflict, rate limit, service
   never ready) as environment — if still failing after classification, record
   "unverifiable: infrastructure" (no pin, but no false remediation). Read-only stance
   unchanged: classify-and-report, never mutate state to retry. Add 2–3 few-shot calibration
   examples (a real discrepancy with reproduced evidence — the fail-open bounce shape; a
   non-finding style preference; an unverifiable-infrastructure item).
2. **`skills/verify-milestone/SKILL.md`** — the Verdict section echoes the mandate scope and
   the infra classification in one sentence each; the serial path (which stands up its own
   services) may retry after addressing a classified resource issue — the only path that may.
3. **`references/milestones-and-verification.md` §1** — three authoring anti-patterns: grade
   outcomes, never implementation paths (naming the committed test file per §1/§3 is evidence
   location, not a path — no collision); [auto] conditions use tolerance/shape matching where
   the requirement is approximate, never incidental exactness; the wording bar — two
   independent readers reach the same pass/fail verdict from the text alone. Cross-referenced
   from spec-feature Movement 3 and spec-change (one pointer line each, rule owned by §1).

**Not weakened:** the verifier's independence, read-only stance, and evidence rules
unchanged; the finding-hunting posture keeps its teeth — it gains a definition of what counts
as a finding.

## Scope

Three markdown files + two one-line cross-reference pointers. Pure prose;
`check-neutral.sh` green.
