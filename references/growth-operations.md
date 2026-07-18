# Growth operations — the operate-grain rules (shared)

The single source of truth for **how keel's growth verbs operate** — the doctrine the
four growth skills (`gtm`, `spec-campaign`, `run-growth`, `measure`) cite and never restate,
exactly as `spec-feature` and `spec-change` cite `milestones-and-verification.md`.
Build verbs end when a milestone lands; growth is an **operate grain**: recurring,
gated cycles over live external channels, where the failure mode is not a broken
build but an unreviewed message sent under the operator's name. Every rule below
exists because the 2026-07 research pass found autonomous send-everything products
failing on their own economics while the working pattern — an agent brain over
rented execution APIs, with a human approval gate on everything outbound — held.
Vendors appear below only as hedged examples (as of 2026-07); no provider is ever
required.

## 1. The queue invariant

**No send, post, or spend ever executes without either an approval record on its
queue or a standing-envelope class covering it.**

That sentence is the grain's never-delegated line. It is a rule, not a default: no
campaign spec, autonomy mode, or session may widen past it. The push scripts enforce
it mechanically — an outbound item either carries an approval record written by an
attended sitting, or falls inside a standing-envelope class (§2) the attended spec
already authorized. Anything else does not go out, regardless of how confident the
drafting session was.

## 2. Standing-envelope defaults

The standing envelope is the set of action classes approved material may execute
**unattended**. Its defaults, as rules:

- **Follow-ups within an approved sequence may auto-send.** The attended approval of
  a sequence covers its scheduled follow-up steps; each step does not re-queue.
- **Pausing is always allowed unattended.** Any session, scheduled or attended, may
  pause a campaign at any time. Pause is the one write that never needs approval.
- **New threads, new posts, and new spend always queue.** First-touch messages,
  fresh social posts, and any budget commitment wait for an approval record — no
  exceptions by default.

A campaign spec may **narrow** these classes (e.g. queue even follow-ups for a
sensitive audience) but may never **widen** them without an attended edit to the
spec. Widening-by-drafting-session is the exact failure the invariant exists to
block.

## 3. The canonical-state split

Two systems of record, split by kind — never one overwriting the other:

- **The repo is canonical for intent**: copy, sequences, audience definitions,
  envelopes, stop-conditions. What *should* go out lives in committed files.
- **Provider APIs are canonical for outcomes**: what actually sent, who replied,
  what bounced, what a post's metrics did. The sending platform owns delivery truth.

**Reconciliation flags drift; it never silently overwrites either side.** When
readback finds the provider's state diverging from the repo's intent (a sequence
edited in a dashboard, a contact list changed out-of-band), the cycle brief surfaces
the drift for the attended sitting to resolve. A script that "fixes" drift in either
direction unattended is rewriting a system of record it does not own.

## 4. Rate-based stop-conditions

Every campaign spec **carries threshold conditions** — at minimum a bounce-rate
ceiling, a complaint-rate ceiling, a reply-rate floor, and a budget cap — and a
breach of any threshold **pauses the campaign via the provider API**. Pause is the
one write always allowed unattended (§2), which is the point: under any failure —
a bad list, a burned domain, a runaway spend — the system degrades to *paused*,
never to *sent-unreviewed*. Stop-conditions are not advisory monitoring; they are
the committed tripwires that make unattended execution of approved material safe.

## 5. The three-layer autopilot model

Continuous operation without continuous attention, split by who is competent to
hold each layer:

1. **Provider platforms execute approved material continuously** — scheduling,
   deliverability, throttling, unsubscribe mechanics. That is what they are rented
   for (as of 2026-07, sending platforms ship agent-facing APIs for exactly this).
2. **Scheduled prep sessions read back and draft** — pull outcome metrics, flag
   drift and stop-condition proximity, draft the next batch onto the queue. Prep
   sessions write drafts and briefs; they approve nothing.
3. **The attended sitting approves** — reviews the queue, edits or rejects drafts,
   writes the approval records the push scripts require.

**Reply handling is always attended.** A reply is a human entering the
conversation; drafting a suggested response is prep-layer work, but nothing sends
to a replier without the sitting's approval — replies are never inside any
standing-envelope class.

## 6. The headless-pipeline rule

All operational logic lives in **committed, provider-pluggable scripts** and
spec/queue/ledger **files**; the skills orchestrate over them. A skill never embeds
the push logic, and no operation depends on a session's memory: everything a cycle
needs — the campaign spec, the queue, the approval records, the dispatch ledger —
is a file another session (or a future operating UI) can read cold. Swapping a
provider means swapping a script adapter, not rewriting the grain; a front end
later is a view over existing artifacts, not a rewrite.

## 7. The compliance floor

Rules, not recommendations — a campaign spec that omits them is malformed:

- **Unsubscribe/opt-out handling is delegated to the sending provider**, and its
  presence is a **provisioning check**: the growth-ops repo's environment contract
  asserts the configured provider handles opt-outs before any campaign runs.
  Hand-rolled unsubscribe mechanics are how compliance gaps ship.
- **Bounce and complaint thresholds are mandatory stop-conditions in every outreach
  campaign spec** — not optional, not "added when volume grows." A spec without
  them does not pass campaign authoring.
- **Cold SMS is never used without an attended decision recorded in the campaign
  spec.** Consent rules for SMS are stricter than email everywhere that matters;
  the recorded decision is the evidence the operator made the call, not a session.
- **A channel whose automation carries platform-ToS risk is named in the campaign
  spec as an attended risk acceptance before it is used.** (As of 2026-07, most
  social platforms' terms restrict automated posting/outreach in ways their APIs
  don't mechanically enforce.) The operator accepts the risk on the record, or the
  channel stays out of the campaign.

## 8. The dispatch record

**Each operating cycle ends with a file-per-entry dispatch record**: one new file
per cycle stating what went out, on which channel, in what counts, with evidence
pointers (queue approval records, provider message ids, metric snapshots). Never an
edit to a shared growing file — the shared rules' collision discipline
(`milestones-and-verification.md` §4) applies unchanged: parallel or interleaved
cycles must never merge-tangle a ledger. The dispatch ledger is the grain's audit
trail; a cycle that sent anything and wrote no record did not complete.

## 9. Cross-repo lineage

Campaign copy and positioning derive from a product's repo (`specs/gtm/`,
`specs/design.md`, the shipped feature list), but campaigns live in the growth-ops
repo. So **each campaign spec pins the product-repo paths + commit** its copy and
positioning derived from. At readback, **staleness is surfaced as a flag** — the
product repo moved past the pinned commit — for the attended sitting to judge;
it is **never a silent refresh**. Positioning drift is a strategy question, not a
sync job: an invented example — *Ledgerline* repositions from bookkeepers to
fractional CFOs — should pause a mid-flight sequence for a human, not have its
in-flight copy quietly rewritten under the pinned approval.

## 10. Measurement

Measurement closes the loop from dispatch to product truth — did the people a
campaign touched sign up, activate, retain? Its rules extend the grain without
widening it:

- **Analytics providers are canonical for *product* outcomes** — signups,
  activation events, retention — exactly as sending platforms are canonical for
  delivery outcomes (§3). **The repo is canonical for metric *definitions***:
  the north-star, the activation definition, the funnel stages, and the
  canonical event names live in the product repo's committed
  `specs/gtm/metrics.md`. A readout that computes a metric any way the
  committed definition doesn't state is reporting a number nobody agreed to.
- **Attribution is cohort-level only: the readout joins campaigns to product outcomes at campaign/channel granularity via tagged links, and never links an outreach contact's identity to a product account.**
  This is the measurement analog of the queue invariant (§1) — the
  grain-line no readout script,
  campaign spec, or session may widen past. Person-level linkage is a privacy
  decision, not a data join; it happens, if ever, only through an attended
  decision on the record.
- **Measurement reads provider APIs and never writes provider state.** Pause
  (§2, §4) remains the grain's only unattended write, and measurement adds
  none. A readout script containing any provider write call is malformed —
  read-only by construction, not by convention.
- **Readout snapshots are file-per-entry** — one new file per readout, never an
  edit to a shared growing file; §8's collision discipline applies unchanged.
  And consumers of `specs/gtm/metrics.md` **pin its path + commit** exactly as
  campaign specs pin positioning: staleness is surfaced as a flag for the
  attended sitting, never silently refreshed (§9). A funnel number whose
  definition moved under it is a flag, not a fact.
