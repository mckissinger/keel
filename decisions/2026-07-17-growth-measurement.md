# 2026-07-17 — Growth: measurement closes the loop

The strategic decision the `measure` feature plan implements. This entry is the
**why**; the feature spec (`specs/features/measure.md`) and the doctrine's
measurement section (`references/growth-operations.md` §10) are the **what**.

## Why measurement extends the operate grain

The grain's canonical-state split made provider APIs canonical for **delivery**
outcomes — sends, replies, bounces. But provider outcomes are not **product**
truth: nothing in a readback answers whether the people a campaign touched
signed up, activated, or retained. Without that answer, campaign iteration runs
open-loop — the next `spec-campaign` session is authored on sends-and-replies
alone, not on whether a channel produced activated users. Measurement is the
grain's closing arc: analytics providers become canonical for product outcomes
(extending the §3 split), the repo stays canonical for metric *definitions*
(`specs/gtm/metrics.md` as product truth), and the cycle brief can finally say
"campaign X drove N signups, M activated."

## Why one verb with two modes

Not a standalone readout verb: the `growth-status` deferral's logic applies —
no speculative read surface before operation proves the need — and here the
read *is* the feature, so it rides the same skill rather than justifying a
second one. Not a `run-growth` step either, for two reasons that both bind:
metrics must be readable **outside** a campaign cycle (a founder asking "what's
our activation rate" should not have to run an operating cycle to learn it),
and `run-growth`'s human-trigger gate exists for consequence outside the repo —
a gate that must **not** apply to a read. So `measure` is one model-invocable
verb whose first-run fork (the `spec-campaign` precedent) picks the mode:
authoring when `specs/gtm/metrics.md` is absent, readout when it exists.

## The cohort-only attribution rule

The measurement analog of the queue invariant: as §1 is the line no autonomy
mode may widen past on the send side, the doctrine's cohort-attribution rule
(§10, held verbatim there) is the line on the read side — attribution joins
campaigns to product outcomes at campaign/channel granularity via tagged
links, and never links an outreach contact's identity to a product account.
Person-level linkage is a privacy decision requiring an attended sitting on
the record, not a data join a readout script performs because both datasets
happen to be reachable.

## Scope held elsewhere

The v1 scope decisions — **funnel only** (acquisition → signup → activation →
retention plus guardrails); person-level attribution and per-feature
usage/engagement analytics as recorded deferrals — are held by
`specs/features/measure.md` (interview record, 2026-07-17) and its m2 deferral
entries, not restated here.
