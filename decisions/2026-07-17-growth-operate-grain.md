# 2026-07-17 — Growth: the operate grain

The strategic decision the `growth` feature plan implements. This entry is the
**why**; the feature spec (`specs/features/growth.md`) and the doctrine reference
(`references/growth-operations.md`) are the **what**. It extends keel past the
build grain: the 2026-07-06 workflow review's finding — keel "covers build
completely and sell not at all" — with `marketing-site` and `product-video` having
since shipped the surface-and-content half, leaves the operating half: marketing
that *runs*.

## Why an operate grain exists

Every prior keel verb is a **build** verb: it ends when a milestone lands and its
pin merges. Marketing operations don't have that shape — a campaign is a
**recurring gated cycle** (readback → prep → approval → push → record) that runs
for weeks over live external channels, where the unit of risk is not a broken
build but an unreviewed message sent under the operator's name to a real inbox or
feed. Forcing that into one-shot build milestones would either fake the recurrence
(a "milestone" per send cycle) or drop the gate (autonomous sending). So the grain
is new: the same doctrine spine — specs as truth, attended gates where judgment
sits, committed artifacts as the record — applied to cycles instead of builds,
with `references/growth-operations.md` as its shared rulebook.

## The architecture: agent brain over rented execution APIs

The 2026-07 research pass (session-recorded) established the choice's evidence
basis: autonomous "AI SDR" products were failing on their own economics — churn
and output quality — while the pattern that held in 2026 is an **agent brain over
rented execution APIs**. Sending platforms own deliverability, scheduling, and
compliance mechanics and (as of 2026-07) ship agent-facing APIs for exactly that;
platform-side slop-suppression and ban enforcement make unreviewed autonomous
posting and sending both ineffective and account-threatening. Hence the suite's
spine: **the agent researches, drafts, and reports; committed scripts push only
human-approved material; vendor platforms execute continuously.** keel does not
build a sending engine, and it does not automate past the approval gate — the two
ends of the spectrum the evidence says fail.

## The hybrid topology

Per-product **`specs/gtm/`** in each product's own repo (positioning is product
truth — `marketing-site` consumes it, and it must live where the product's specs
live), plus **one central growth-ops repo** owning campaigns, queues, dispatch
ledgers, pipeline scripts, and the shared provider credentials' environment
contract (operations are cross-product and credentialed — they must not be
scattered per product). The seam between them is **pinned lineage**: a campaign
spec pins the product-repo paths + commit it derived from, and staleness is
flagged at readback, never silently refreshed
(`references/growth-operations.md` §9).

## The never-delegated line

The grain's queue invariant, held verbatim in
`references/growth-operations.md` §1: **No send, post, or spend ever executes
without either an approval record on its queue or a standing-envelope class
covering it.** This is the growth analog of the build grain's verified-pin gate —
the one line no autonomy mode, campaign spec, or session may widen past. Campaign
specs may narrow the standing-envelope classes, never widen them, without an
attended edit.

## Scope held elsewhere

The v1 scope decisions — **three verbs** (`gtm` / `spec-campaign` / `run-growth`);
channel templates for **outreach + organic social**; `growth-status`, paid-ads
templates, and SMS as recorded deferrals (SMS additionally gated on an attended
compliance decision); `run-growth` carrying `disable-model-invocation` — are held
by `specs/features/growth.md` (interview record, 2026-07-17) and its m3
deferral entries, not restated here.
