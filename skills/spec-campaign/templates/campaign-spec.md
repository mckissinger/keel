# Campaign — <campaign-slug>

<!-- TEMPLATE — one campaign is one spec. A second channel or a second audience
     slice for the same product is a SECOND campaign spec, never a widened one.
     The operating rules this spec runs under are references/growth-operations.md
     (the keel plugin root) — cited throughout, never restated here. -->

## Product + pinned references

- **Product:** <name — e.g. the invented *Fieldnote*> · repo: <product-repo>
- **Pinned product-repo references** (the lineage this campaign's copy and
  positioning derive from — staleness is flagged at readback against this
  commit, never silently refreshed; doctrine §9):
  - `specs/gtm/positioning.md` at commit `<short-sha>`
  - `specs/gtm/icp.md` at commit `<short-sha>`
  - `specs/gtm/channels.md` at commit `<short-sha>`
  - <other pinned paths — e.g. `specs/design.md` for voice> at `<short-sha>`

## Audience slice

<The segment of the pinned ICP this one campaign addresses — narrow enough to
write one message to. Size estimate and how it was derived.>

## Channel

<outreach | organic social> — provider: <the provider satisfying the channel
contract — see the skill's `references/channel-contracts.md`; providers are
swappable adapters, never a requirement>. Platforms (social only): <named
platforms>.

## Source ladder + sample-pull results

Ladder (ordered rungs, per the skill's `references/source-ladders.md`):

1. <rung — e.g. a licensed contact database, named>
2. <rung — e.g. a state license board>
3. <rung>

Verification gate: <the verifier step every found address passes before it may
enter a queue — mandatory>.

**Sample-pull results** (measured in the authoring session — coverage is
measured, never assumed):

| Rung | Sample size | Resolved | Verified |
|---|---|---|---|
| <rung 1> | <n> | <n (%)> | <n (%)> |
| <rung 2> | <n> | <n (%)> | <n (%)> |

## Sequence / content copy

<The committed copy — sequence steps for outreach (subject + body per step),
or the post series for social. Derived from the pinned positioning, in the
product's committed voice. Founder-must-do items tagged [attended].>

## Cadence

<Steps and intervals (outreach: e.g. step 2 at +3 days, reply-stop always on)
or posting rhythm (social: e.g. 3 posts/week, per-platform timing).>

## Volume / spend envelope

- Per-day cap: <n sends/posts per day>
- Total volume: <campaign total>
- Budget cap: <currency amount — enrichment + provider costs>

## Standing-envelope classes (narrow-only)

The doctrine's defaults (§2) apply unless narrowed below — this spec may
**narrow** these classes, never widen them; widening requires an attended edit
to this file:

- Follow-ups within the approved sequence: <auto-send (default) | narrowed:
  queue for approval, with reason>
- Pause: always allowed unattended (never narrowable — doctrine).
- New threads / new posts / new spend: always queue (never widenable).

## Stop-conditions

Breach of any threshold **pauses the campaign via the provider API** (the one
always-allowed unattended write — doctrine §4):

- Bounce-rate ceiling: <e.g. 3%> (mandatory)
- Complaint-rate ceiling: <e.g. 0.1%> (mandatory)
- Reply-rate floor: <e.g. below 1% after n sends>
- Budget cap: <amount>
- <campaign-specific additions>

## Compliance

Per the doctrine's compliance floor (§7):

- Unsubscribe/opt-out: delegated to the sending provider; asserted by the
  growth-ops environment contract's provisioning check.
- Bounce + complaint thresholds: present above (a spec without them is
  malformed).
- Cold SMS: <not used | used — attended decision recorded here, by whom, when>.
- ToS-risk / gray-zone rungs and channels: <none | named, each with the
  operator's recorded attended risk acceptance>.

## Queue / approval / dispatch paths

Where this campaign's operational files live (all committed; the repo is
canonical for intent, provider APIs for outcomes — doctrine §3):

- Queue files: `campaigns/<campaign-slug>/queue/`
- Approval records: `campaigns/<campaign-slug>/approvals/` (one record per
  approved queue batch — what `push-approved.mjs` requires before it will run)
- Dispatch ledger: `campaigns/<campaign-slug>/dispatch/` (file-per-cycle,
  never a shared growing file — doctrine §8)
- Outcome snapshots: `campaigns/<campaign-slug>/outcomes/` (written by
  `readback.mjs`; never mutates the files above)
