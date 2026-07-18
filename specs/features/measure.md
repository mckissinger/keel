# Feature — measure: product-side truth for the growth grain

**Goal:** the growth grain gains its fourth verb, `measure` — closing the loop from
campaign dispatch to product truth. Today `run-growth`'s readback ends at provider
outcomes (sends, replies, bounces); nothing answers "did the people a campaign touched
sign up, activate, retain?" One skill, two modes on the `spec-campaign` first-run-fork
precedent: the **authoring mode** (first run, attended, in the product's repo)
interviews the growth funnel — one north-star, one activation definition, named funnel
stages with canonical event names, guardrail thresholds — authors `specs/gtm/metrics.md`
from a template, and routes the instrumentation work into normal product-repo milestones
via the standard pipeline; the **readout mode** (any later run, read-only,
model-invocable) derives funnel numbers through a committed provider-pluggable adapter
script and writes a file-per-entry readout snapshot. Run in the product repo, readout
reports the funnel alone; run in the growth-ops repo, it joins dispatch ledgers against
analytics at **cohort level** (campaign/channel granularity via tagged links — no
identity linkage, ever), so a cycle brief can say "campaign X drove N signups, M
activated." The doctrine gets a measurement section, not a rewrite.

**Why now (evidence):** the growth suite (gtm / spec-campaign / run-growth) shipped
2026-07-17 with readback deliberately scoped to provider outcomes (doctrine §3:
provider APIs are canonical for outcomes). The 2026-07-06 workflow review's sell-gap
analysis is the parent finding; the remaining unclaimed surface after the operate grain
landed is the metrics loop — without product-side truth, the next `spec-campaign`
iteration is authored on sends-and-replies alone, not on whether a channel produced
activated users. `measure` is what makes campaign iteration evidence-driven.

**No-UI feature** → two-dimension done-conditions (logic/invariants + behavioral
completeness); fidelity does not apply; the design track is skipped.

**flow research:** skipped — no user-facing UI flow; the deliverable is skill prose, a
doctrine section, templates, and wiring.

**Interview record (decided 2026-07-17, this session):** **one verb, two modes** — the
readout is a mode of `measure`, not a standalone verb (the `growth-status` deferral's
logic applies: no speculative read verb before operation proves the need; here the
read *is* the feature, so it rides the same skill) and not a `run-growth` step (metrics
must be readable outside a campaign cycle, and `run-growth`'s human-trigger gate must
not apply to a read). **Attribution is cohort-level only**: campaigns tag links
(UTM/ref) and the readout joins at campaign/channel granularity; person-level
attribution (linking an outreach contact's identity to a product account) is a recorded
deferral gated on an attended privacy decision. **Scope is the growth funnel only**:
acquisition → signup → activation → retention plus guardrails; per-feature
usage/engagement analytics is a recorded deferral. `specs/gtm/metrics.md` is **product
truth** in the product's repo, pinned by growth-ops consumers exactly as positioning is
(doctrine §9 lineage, unchanged). The adapter is **provider-pluggable** per the
headless-pipeline rule — analytics vendors appear only as hedged, as-of-2026-07
examples, never requirements. The verb is **model-invocable** (no
`disable-model-invocation`): everything it does is read-only or plan-only — no send, no
post, no spend, and the readout **never writes provider state** (pause remains the
grain's only unattended write; measurement adds none). Readout snapshots are
**file-per-entry** (the dispatch-record discipline, doctrine §8), written in whichever
repo the readout ran in. Doctrine change is an **addendum section** (measurement) to
`references/growth-operations.md`: analytics providers are canonical for product
outcomes (extending §3, with the repo canonical for metric *definitions*), the
cohort-only attribution rule as the measurement grain-line, the read-only rule, and
snapshot/lineage discipline by citation to §8/§9.

## Milestones (file→milestone ownership map; no routes — no UI)

| Unit | Milestone | Owns |
|---|---|---|
| Skill + doctrine | `measure-m1-skill-doctrine` | measurement section appended to `references/growth-operations.md`; new `skills/measure/SKILL.md` + `skills/measure/templates/metrics-spec.md`, `skills/measure/templates/funnel-readout.mjs`; new `decisions/2026-07-17-growth-measurement.md` |
| Wiring | `measure-m2-wiring` | `README.md` (Growth ladder line, Growth skills-list bullet, count 27 → 28); `scripts/session-bootstrap.sh` (both banner copies) + `scripts/session-bootstrap.test.sh` (assertion); one routing sentence each in `skills/run-growth/SKILL.md` and `skills/gtm/SKILL.md`; new `scripts/skill-anchors/measure.txt`; new skill-eval fixtures `scripts/skill-eval/fixtures/g6-*.json`; new `specs/deferrals/measure-person-level-attribution.md`, `specs/deferrals/measure-feature-usage.md` |

**Build order + integration seams:** sequential **m1 → m2**. m2's routing sentences and
anchor cite m1's skill and doctrine sentence (citation, never restatement — the
milestones-and-verification precedent); the anchor file pins m1's cohort-attribution
sentence verbatim, so m1's wording is final before m2 starts. m1 is the sole owner of
the `references/growth-operations.md` edit; all shared-file wiring (README, bootstrap,
the two existing growth skills, anchors, fixtures) is owned by m2 alone, so no two
milestones touch a shared file. The `run-growth` seam is one added sentence — the cycle
brief cites the latest cohort readout when the campaign's pinned product repo carries
`specs/gtm/metrics.md` — and must not change that skill's scope, gates, or
human-trigger posture. The `gtm` seam is one added sentence — the metrics layer is
`measure`'s, downstream — and must not change that skill's scope. Neutrality caution
for the builder: no analytics vendor is named as required anywhere; hedged
as-of-2026-07 examples only; `check-neutral.sh` scans `references/` and `skills/` and
the prose must pass as written.

**Parallelizable:** no (sequential, above).

**External build-order dependency:** m1 amends `references/growth-operations.md` and
m2 edits `skills/run-growth/SKILL.md` / `skills/gtm/SKILL.md` — all of which land on
`main` with release 1.16.0 (the growth wave). The build does not start until that
release has merged to `main`; this plan PR carries specs only and has no such
dependency.

## Lifecycle

- **Interview + synthesis sign-off:** 2026-07-17, this session (attended; recorded in
  the Interview record above; synthesis signed off before authoring).
- **Composition/redline gate:** not applicable — no-UI feature (profile has-UI? = no).
- **Plan PR:** opened at the end of this session (plan-only: `specs/**`); number
  recorded in the PR itself once open.
- **Per-milestone build + pin:** each milestone's `verified:` line lands in its own
  code PR per the shared rules; state derives from
  `specs/milestones/measure-m1-skill-doctrine.md` and
  `specs/milestones/measure-m2-wiring.md`.
- **Post-wave reconciliation:** `land-feature` reconciles `README.md` and this spec
  when the wave lands.
- **review-feature:** not applicable — no-UI feature; the acceptance gate is each
  milestone's verifier pass plus first dogfood (a real `measure` authoring run on a
  product repo, and a readout joined against a real campaign's dispatch ledger in a
  growth-ops repo), whose findings route back as spec-changes.
