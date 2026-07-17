# Channel contracts — what a provider layer must own, per v1 channel

keel's growth grain rents execution: provider platforms own delivery mechanics
continuously while committed scripts push only approved material (the doctrine's
three-layer model — `references/growth-operations.md` §5, `${CLAUDE_PLUGIN_ROOT}`,
cited). This file states the **contracts** — what the provider layer for each v1
channel must do — never a required vendor. Every tool named below is a hedged,
as-of-2026-07 example; a campaign spec names whichever provider satisfies the
contract, and swapping providers means swapping a script adapter, not rewriting
the campaign.

## The sending contract (outreach)

The outreach provider layer must own, end to end:

- **Mailbox rotation and per-mailbox caps** — sends distributed across a pool
  of mailboxes, each held under a daily cap, so no single mailbox's volume
  profile looks like a blast.
- **Warmup** — new mailboxes and domains ramped gradually to sendable volume
  before campaign traffic touches them.
- **Throttling** — human-plausible send pacing inside each mailbox's cap,
  never burst delivery of a day's queue.
- **Sequence execution with reply-stop** — multi-step follow-ups executed on
  schedule, and a reply anywhere in a thread halting that prospect's remaining
  steps automatically. (Replies themselves are always handled attended — the
  doctrine's rule; the provider's job is only to *stop sending* on reply.)
- **Unsubscribe handling** — provider-side opt-out mechanics, whose presence
  is a provisioning check per the doctrine's compliance floor (§7, cited).
  Hand-rolled unsubscribe is how compliance gaps ship.
- **Reply/bounce/complaint readback by API** — outcome data (delivery, opens
  where measurable, replies, bounces, spam complaints) queryable by script, so
  readback and stop-condition evaluation run headlessly.

As of 2026-07, agent-facing sending platforms (e.g. Instantly, Smartlead, or an
equivalent) ship this contract as their core product; any provider that
satisfies every clause qualifies.

### The deliverability floor (outreach)

Non-negotiable substrate under any sending provider:

- **Secondary domains, never the product's primary.** Outreach sends from
  lookalike/secondary domains so a burned domain is a replaceable asset, not
  the product's own email reputation.
- **Authenticated DNS** — sender-authentication records (SPF, DKIM, DMARC as
  of 2026-07) configured and verified per sending domain before any send.
- **Warmup lead time is a provisioning long pole** — domains and mailboxes
  need weeks, not hours, from purchase to sendable; the campaign's provisioning
  step names this lead time explicitly so the schedule absorbs it.
- **Verified-only recipients** — the source ladder's mandatory verification
  gate (see `source-ladders.md`) means nothing unverified is ever queued.

## The scheduling contract (organic social)

The social provider layer must own:

- **Queued publishing by API across the named platforms** — the campaign spec
  names its platforms; the provider accepts a queue of posts by API and
  publishes them at their scheduled times, per platform, without a human in a
  dashboard at post time.
- **Post-status readback** — published/failed status and available per-post
  metrics queryable by API, so the cycle brief and stop-condition evaluation
  run headlessly.

As of 2026-07, scheduling platforms with publish APIs (e.g. Buffer, or a
platform's own native scheduling API where one exists) cover this contract;
platform ToS constraints on automated posting are handled per the source
ladders' ToS rule and the doctrine's compliance floor — a ToS-risk channel is
an attended risk acceptance named in the campaign spec, or it stays out.
