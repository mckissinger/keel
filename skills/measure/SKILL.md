---
name: measure
description: Close the loop from campaign dispatch to product truth — the growth grain's metrics verb, one skill with two modes. The AUTHORING mode (first run, attended, in the product's repo) interviews the growth funnel — one north-star, one activation definition, funnel stages with canonical event names, guardrail thresholds — authors specs/gtm/metrics.md from a template, and ends on a plan PR with instrumentation routed to the normal build pipeline. The READOUT mode (any later run) is read-only — derives funnel numbers through the committed provider-pluggable adapter and writes a file-per-entry readout snapshot; in a growth-ops repo it joins dispatch ledgers against analytics at cohort level via tagged links. Nothing sends, posts, or spends; the readout never writes provider state.
when_to_use: When someone asks whether the growth funnel is working — "did that campaign drive signups," "what's our activation rate," "define our metrics," "how many of the people we reached actually activated." Runs in the PRODUCT repo (funnel only) or the GROWTH-OPS repo (funnel joined against dispatch ledgers at cohort level). NOT for deciding positioning, audience, or channels — that is gtm, strategy not metrics; NOT for operating a campaign cycle — that is run-growth, which sends and is human-trigger gated, while measure never sends and is not; NOT for general product analytics — per-feature usage and engagement instrumentation is out of scope, this verb owns the growth funnel (acquisition → signup → activation → retention) only.
---

# Measure

You are acting as the measurement analyst for the growth grain. The deliverable
is either a **committed metrics definition** (`specs/gtm/metrics.md`, via a plan
PR — the authoring mode) or a **file-per-entry readout snapshot** (the readout
mode) — never a send, never a post, never a spend, never a write to any
provider. This is the fourth verb of keel's **growth** grain; the grain's
operating doctrine is `references/growth-operations.md`
(`${CLAUDE_PLUGIN_ROOT}`), cited here and never restated — this verb runs under
its measurement rules (§10): analytics providers are canonical for product
outcomes while the repo is canonical for metric definitions, attribution is
cohort-level only, and measurement reads provider APIs and never writes
provider state.

This verb is deliberately **model-invocable** (no `disable-model-invocation`):
every mode is read-only or plan-only. The authoring mode writes specs on a
branch and ends on a plan PR; the readout mode reads provider APIs and writes
one new snapshot file in the repo it runs in. No send, no post, no spend — and
the readout never writes provider state (pause remains the grain's only
unattended write, §2/§4, and measurement adds none). So "did that campaign
actually work?" routes here without a human-trigger gate; `run-growth` is the
grain's execution verb, and this one is its opposite pole.

## The first-run fork

Like `spec-campaign`'s first-run precedent, the mode is decided by one check:
does the product repo carry a committed `specs/gtm/metrics.md`?

- **Absent → authoring mode.** The funnel has no agreed definitions yet;
  interview them into existence first. A readout against undefined metrics is
  a number nobody agreed to.
- **Present → readout mode.** Definitions exist; derive the numbers, read-only.

## Authoring mode — define the funnel (attended, product repo)

Interview-first discipline as everywhere in keel: **restate, default what's
defaultable, batch what can't be** — one batched round of the questions only
the founder can answer. The session resolves, in one sitting:

- **One north-star** — the single metric the product's growth is judged by.
- **One activation definition** — the observable moment a signup becomes a
  user who got the value. This is the interview's hard question; it cannot be
  defaulted, and its sign-off is founder-must-do.
- **Funnel stages** — acquisition → signup → activation → retention, each with
  its **canonical event name** (the committed name the instrumentation and the
  adapter both use; a funnel whose stages are named differently in code and in
  the readout is two funnels).
- **Guardrail thresholds** — the floors and ceilings that flag a stage as
  broken rather than merely soft.

Author `specs/gtm/metrics.md` from **`templates/metrics-spec.md`** and end on a
**plan PR** to the product repo (plan-only: `specs/**`). Instrumentation — the
event-emitting code the definitions imply — is **routed to the normal build
pipeline**: the plan PR names the work, and `spec-change` / `spec-feature`
milestones in the product repo build it. This skill never builds
instrumentation inline; defining a metric and shipping its telemetry are
different grains.

## Readout mode — derive the numbers (read-only, either repo)

Any run where the metrics spec exists. The readout derives funnel numbers
**through the campaign's or product's committed adapter script** — the
project's copy seeded from **`templates/funnel-readout.mjs`** — which reads the
pinned metrics spec, queries the analytics provider's API read-only, and emits
a **file-per-entry readout snapshot** (one new file per readout, §8's collision
discipline; never an edit to a shared growing file) with metric values and
evidence pointers, written in the repo the readout ran in. The skill runs the
adapter and interprets its snapshot; it never inlines provider queries and
never re-derives numbers around the committed script (the headless-pipeline
rule, §6).

**The repo split decides what a readout can say:**

- **Product repo → funnel only.** North-star, stage counts, conversion rates,
  guardrail status. No campaign attribution — the product repo has no dispatch
  ledgers to join.
- **Growth-ops repo → funnel joined against dispatch ledgers at cohort
  level.** Campaign tags on links (UTM/ref) join dispatch records to funnel
  outcomes at campaign/channel granularity, so a cycle brief can say "campaign
  X drove N signups, M activated." The join runs under the doctrine's
  cohort-attribution rule (§10, cited not restated): cohorts, never an
  outreach contact's identity linked to a product account.

Consumers pin `specs/gtm/metrics.md`'s path + commit; the adapter flags
staleness when the definitions moved past the pin — a flag for a human, never
a silent refresh (§9).

## Where this sits

```
gtm             one product's positioning / ICP / channel plan   (product repo)
spec-campaign   one campaign, authored against a pinned gtm      (growth-ops repo)
run-growth      one operating cycle of an approved campaign      (growth-ops repo)
measure         funnel definitions + cohort-level readouts       ← here (either repo)
```
