# An SMS channel for the growth grain

**Parked 2026-07-17** by the growth feature interview (`specs/features/growth.md`). No SMS
channel contract or template ships in v1; SMS is deferred, and **additionally gated on an
attended compliance decision** — a human call, recorded before any template work starts.

**What it would buy.** A high-attention channel for audiences email doesn't reach, under the
same authored-campaign / gated-cycle machinery as the v1 channels.

**Why deferred, not built now.** The doctrine's compliance floor
(`references/growth-operations.md` §7) already draws the line: **cold SMS is never used
without an attended decision recorded in the campaign spec** — consent rules for SMS are
stricter than email everywhere that matters, carrier filtering and registration regimes add
per-jurisdiction machinery, and the penalty profile lands on the operator, not the session.
Building the template first would invite using the channel before the human decision the
floor requires exists. **Risk of deferring:** low for the grain (email + social cover v1's
audiences); the risk that matters runs the other way — shipping SMS mechanics ahead of the
compliance gate.

**Reopen condition (trigger).** An operator brings a campaign whose audience genuinely
requires SMS **and** records the attended compliance decision (consent basis, jurisdictions,
provider's registration/opt-out handling) in the campaign spec — that recorded decision is
the entry ticket; the channel contract and template are authored only after it exists.
