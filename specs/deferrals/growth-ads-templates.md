# Paid-ads channel templates for the growth grain

**Parked 2026-07-17** by the growth feature interview (`specs/features/growth.md`). The v1
channel templates cover **outreach and organic social**; paid-ads channel contracts and
pipeline templates (campaign structure, budget pacing, creative rotation) are deferred.

**What it would buy.** A third channel class under the same doctrine: ads campaigns authored
by `spec-campaign` and operated by `run-growth`, with spend gated by the same queue
invariant and budget-cap stop-conditions that already govern outreach.

**Why deferred, not built now.** The **platform-API asymmetry** (as of 2026-07): the major
ad platforms expose mature, first-party campaign-management APIs, but their review systems,
billing coupling, and per-platform campaign object models differ enough that a
provider-pluggable template — the shape the grain's headless-pipeline rule requires — would
either flatten to uselessness or hardcode one platform, which the neutrality bar forbids.
Outreach and organic social converged on a common adapter shape; ads have not yet.
**Risk of deferring:** ads spend is exactly the class the queue invariant most protects —
until templates exist, any ads work is manual and outside the grain's gates, so operators
must not improvise an unattended ads pipeline in the meantime.

**Reopen condition (trigger).** A real campaign needs paid ads AND the operator accepts the
per-platform adapter cost in an attended `spec-campaign` session — at which point the
channel contract is authored against the doctrine (budget cap as a mandatory stop-condition,
spend always queued) with the then-current platform APIs surveyed fresh, not from this
entry's 2026-07 snapshot.
