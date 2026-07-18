# Person-level attribution for the measure verb

**Parked 2026-07-17** by the measure feature interview (`specs/features/measure.md`).
Linking an outreach contact's identity to a product account — "did *this* person we
emailed become *this* signup" — is deferred, and **additionally gated on an attended
privacy decision** — a human call, recorded before any join work starts.

**What it would buy.** Contact-level campaign truth: reply-to-activation traces, per-contact
lifecycle views, and source-ladder scoring by who actually converted rather than which
cohort did.

**Why deferred, not built now.** The doctrine's measurement grain-line
(`references/growth-operations.md` §10) already draws the line: **attribution is
cohort-level only** — the readout joins campaigns to product outcomes at campaign/channel
granularity via tagged links, and never links an outreach contact's identity to a product
account. Person-level linkage is a privacy decision, not a data join — consent basis,
jurisdiction rules, and data-retention posture all land on the operator — and building the
join mechanics first would invite running the join before the decision the grain-line
requires exists. **Risk of deferring:** low — cohort granularity already answers the
question campaign iteration needs ("campaign X drove N signups, M activated"); the risk
that matters runs the other way — identity linkage shipped ahead of the privacy gate.

**Reopen condition (trigger).** An operator brings a genuine per-contact need cohort
granularity cannot answer **and** records the attended privacy decision (consent basis,
jurisdictions, retention, the exact identifiers joined) on the record — that recorded
decision is the entry ticket; any join work is authored only after it exists.
