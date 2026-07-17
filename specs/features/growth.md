# Feature — growth: the operate grain (gtm · spec-campaign · run-growth)

**Goal:** keel gains its first **operate-grain** capability — marketing that runs as
gated recurring cycles rather than one-shot builds. Three new verbs: `gtm` (per-product
positioning/ICP/channel interview, landing `specs/gtm/` in the product's own repo via a
plan PR), `spec-campaign` (authors one campaign — audience slice, enrichment source
ladder, sequence/content copy, cadence, volume/spend envelope, rate-based
stop-conditions — in a central growth-ops repo, plan-PR gated, with a first-run fork
that scaffolds that repo through the kickoff verbs in a skinny growth posture), and
`run-growth` (human-triggered only: one operating cycle of metrics readback → prep →
attended queue approval → provider-API push → committed dispatch record). A shared
plugin-root reference (`references/growth-operations.md`) owns the operate-grain
doctrine; provider-pluggable templates cover the outreach and organic-social channels
with every vendor hedged as an example, never a requirement.

**Why now (evidence):** the 2026-07-06 workflow review found keel "covers build
completely and sell not at all" and roadmapped the gtm layer; `marketing-site` and
`product-video` have since shipped the surface-and-content half. The 2026-07 research
pass (session-recorded) established the architecture this feature encodes: autonomous
"AI SDR" products are failing on their own economics (churn, quality) while the working
2026 pattern is an agent brain over rented execution APIs — sending platforms own
deliverability/scheduling/compliance and now ship agent-facing APIs; platform-side
slop-suppression and ban enforcement make unreviewed autonomous posting/sending both
ineffective and risky. Hence the suite's spine: the agent researches, drafts, and
reports; committed scripts push only human-approved material; vendor platforms execute
continuously. The operate grain is what makes this loop safe under keel's doctrine
instead of ad-hoc.

**No-UI feature** → two-dimension done-conditions (logic/invariants + behavioral
completeness); fidelity does not apply; the design track is skipped.

**flow research:** skipped — no user-facing UI flow; the deliverable is skill prose,
references, and templates.

**Interview record (decided 2026-07-17, this session):** v1 ships **three verbs** —
`growth-status` is a recorded deferral (its derivation folds into `run-growth`'s cycle
brief until real operation proves the need). Channel templates: **outreach + organic
social**; paid-ads templates and any SMS channel are recorded deferrals (SMS
additionally gated on an attended compliance decision). `run-growth` carries
`disable-model-invocation` — the verb that executes sends/posts after approval never
fires by inference; scheduled prep sessions invoke it explicitly. Naming: the grain is
**Growth**; verbs `gtm` / `spec-campaign` / `run-growth`. Topology is hybrid:
per-product `specs/gtm/` (positioning is product truth, consumed by `marketing-site`)
plus one central growth-ops repo owning campaigns, queues, dispatch ledgers, pipeline
scripts, and the shared provider credentials' environment contract; campaign specs pin
the product-repo paths + commit they derived from, and staleness is flagged at
readback, never silently refreshed. Standing-envelope defaults: follow-ups within an
approved sequence may auto-send; pausing is always allowed unattended; new
threads/posts/spend always queue — campaign specs may narrow these classes, never
widen them, without an attended edit. A compliance floor lives in the doctrine
reference (provider-side unsubscribe handling, bounce/complaint thresholds as
mandatory stop-conditions, no cold SMS without an attended recorded decision,
ToS-risk channels as attended risk acceptances in the campaign spec). The pipeline is
**headless**: all operational logic lives in committed, provider-pluggable scripts and
spec/queue/ledger files; the skills orchestrate over them, so a future operating UI is
a front end over existing artifacts, not a rewrite. Source ladders are per-campaign:
the enrichment ladder (licensed databases, public records, maps/places APIs, website
extraction, waterfall email-finding with a mandatory verification gate) is named and
sample-validated in `spec-campaign` before any spec commits to it — data-provider
coverage is audience-dependent and never assumed.

## Milestones (file→milestone ownership map; no routes — no UI)

| Unit | Milestone | Owns |
|---|---|---|
| Doctrine + gtm | `growth-m1-doctrine-gtm` | new `references/growth-operations.md`; new `skills/gtm/SKILL.md` + `skills/gtm/templates/positioning-canvas.md`, `skills/gtm/templates/icp.md`, `skills/gtm/templates/channel-scorecard.md`; new `decisions/2026-07-17-growth-operate-grain.md` |
| Campaign authoring | `growth-m2-spec-campaign` | new `skills/spec-campaign/SKILL.md` + `skills/spec-campaign/references/source-ladders.md`, `skills/spec-campaign/references/channel-contracts.md`, `skills/spec-campaign/templates/campaign-spec.md`, `skills/spec-campaign/templates/push-approved.mjs`, `skills/spec-campaign/templates/readback.mjs` |
| Cycle verb + wiring | `growth-m3-run-growth-wiring` | new `skills/run-growth/SKILL.md`; `README.md` (ladder line, skills-list bullet, count); `scripts/session-bootstrap.sh` (both banner copies) + `scripts/session-bootstrap.test.sh` (assertion); one routing sentence in `skills/marketing-site/SKILL.md`; new `scripts/skill-anchors/growth.txt`; new skill-eval fixtures `scripts/skill-eval/fixtures/g5-*.json`; new `specs/deferrals/growth-status.md`, `specs/deferrals/growth-ads-templates.md`, `specs/deferrals/growth-sms.md` |

**Build order + integration seams:** sequential **m1 → m2 → m3**. m2's skill cites the
doctrine reference m1 creates (citation, never restatement — the
milestones-and-verification precedent); m3's `run-growth` cites both the doctrine and
m2's templates (the push script's approval-record gate is stated once, in the doctrine,
and named by both m2's script template and m3's cycle contract). All README /
session-bootstrap / routing-pointer / anchor / fixture edits are owned by m3 alone, so
no two milestones touch a shared file (the review-hardening same-file precedent);
between m1 and m3 the README count line is intentionally untouched and m3's
done-condition asserts the final state. Deferral and decision entries are file-per-entry
(shared-rules §4). The `marketing-site` routing seam is one added sentence — Discover
consumes `specs/gtm/positioning.md` when it exists — and must not change that skill's
scope.

**Parallelizable:** no (sequential, above).

## Lifecycle

- **Interview + synthesis sign-off:** 2026-07-17, this session (attended; recorded in
  the Interview record above).
- **Composition/redline gate:** not applicable — no-UI feature (profile has-UI? = no).
- **Plan PR:** opened at the end of this session (plan-only: `specs/**`); number
  recorded in the PR itself once open.
- **Per-milestone build + pin:** each milestone's `verified:` line lands in its own
  code PR per the shared rules; state derives from
  `specs/milestones/growth-m1-doctrine-gtm.md`, `…-m2-spec-campaign.md`,
  `…-m3-run-growth-wiring.md`.
- **Post-wave reconciliation:** `land-feature` reconciles `README.md` and this spec
  when the wave lands.
- **review-feature:** not applicable — no-UI feature; the acceptance gate is each
  milestone's verifier pass plus first dogfood (a real `gtm` run on a product repo and
  a real `spec-campaign`/`run-growth` cycle in a growth-ops repo), whose findings route
  back as spec-changes.
