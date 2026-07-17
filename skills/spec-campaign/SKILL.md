---
name: spec-campaign
description: Author ONE campaign in the central growth-ops repo — audience slice, channel, enrichment source ladder, sequence/content copy, cadence, volume/spend envelope, and rate-based stop-conditions — through an attended, interview-first session that sample-validates the source ladder before the spec commits to it, and ends on a plan PR carrying the campaign spec plus the milestone spec(s) that land its pipeline pieces. Nothing is sent; a first-run fork scaffolds the growth-ops repo itself through the kickoff verbs.
when_to_use: When a product whose go-to-market is already decided (specs/gtm/ exists in its repo) needs ONE campaign authored — "set up an outreach campaign," "plan our posting schedule," "turn the channel plan into something that runs." Runs in the GROWTH-OPS repo (scaffolding it on first run) to author one campaign against a pinned product-repo gtm. NOT for deciding positioning, audience, or channels — that is gtm, upstream, in the product's own repo; NOT for operating an authored campaign's cycles (readback → approval → push) — that is run-growth. One campaign is one spec; a second channel for the same product is a second campaign, never a widened one.
---

# Spec Campaign

You are acting as the campaign author for one product's one campaign. The
deliverable is a **plan PR to the growth-ops repo** carrying a campaign spec
(from `templates/campaign-spec.md`) plus the milestone spec(s) that land the
campaign's pipeline pieces — never a send, never a post, never spend beyond the
attended sample pulls below. This is the second verb of keel's **growth** grain;
the grain's operating doctrine is `references/growth-operations.md`
(`${CLAUDE_PLUGIN_ROOT}`), cited here and never restated — the queue invariant,
the standing-envelope defaults, the stop-condition rules, the compliance floor,
and the canonical-state split all live there, and everything this session
authors is authored *under* them.

Two boundaries, stated once: `gtm` owns the strategy layer (positioning, ICP,
channel plan) in the **product's** repo — this verb consumes those artifacts by
**pinned reference** (paths + commit, per the doctrine's lineage rule) and never
re-litigates them; `run-growth` owns the **operating cycle** of a campaign this
verb authored (readback, attended queue approval, provider-API push, dispatch
record) and never fires by inference. `spec-campaign` sits between them: it
turns a decided strategy into one operable, gated campaign spec.

This verb is deliberately **model-invocable** (no `disable-model-invocation`):
the session is attended, its output is plan-only (a campaign spec and milestone
specs on a branch, via a plan PR), and the only spend it can incur — the sample
enrichment pulls that validate a source ladder — is an attended, in-session
step the user watches, so "help me set up a campaign" routes here without a
human-trigger gate. The grain's execution verb (`run-growth`) is the one that
never fires by inference; this one safely can.

## The session at a glance

```
0 FIRST-RUN  → no growth-ops repo? delegate scaffolding to the kickoff verbs
               (skinny growth posture), then continue here
1 GROUND     → pin the product's specs/gtm/ (paths + commit); restate the
               strategy this campaign executes
2 INTERVIEW  → audience slice → channel → source ladder (sample-validated)
               → copy → cadence → envelope → stop-conditions
3 AUTHOR     → campaign spec + pipeline milestone spec(s) → plan PR
```

## Movement 0 — First run: scaffold by delegation

When invoked with no growth-ops repo, do not re-own scaffolding: **delegate to
the kickoff verbs in a skinny growth posture** — the `marketing-site`
greenfield-fork precedent, applied to operations instead of a brand. The
posture **skips** the feature backlog, the data-model depth, and the app-screen
inventory (there is no app), and **keeps**:

- the architecture note (campaign specs, queues, approval records, dispatch
  ledgers, and pipeline scripts as committed files — the doctrine's
  headless-pipeline rule, cited);
- the **environment contract naming every provider key by name** — the sending
  platform's key, the scheduler's key, each enrichment source's key — with
  values never read, never pasted (the provision-miniature path); the contract
  also carries the doctrine's compliance provisioning check (the configured
  sending provider handles opt-outs);
- the process wiring (branch rules, plan-PR gate, CI checks).

The output is a **keel-managed project whose product is the marketing operation
itself**: campaigns are its features, cycles are its operations, and the normal
build/verify verbs run here unchanged. Scaffold once; every later campaign for
any product lands in this same central repo.

## Movement 1 — Ground

Read before asking: the product repo's pinned `specs/gtm/` (positioning, ICP,
channel plan), its `specs/design.md` voice, and its shipped feature list.
**Record the product-repo paths + commit the campaign derives from** — the
pin is the lineage record the doctrine's cross-repo rule requires, and it is
what readback later measures staleness against. Restate in one paragraph which
channel-plan row this campaign executes and for which ICP slice, and confirm it
with the user. A campaign grounded in an unpinned or stale gtm is copy with no
provenance.

Interview-first discipline applies as everywhere in keel: **restate, default
what's defaultable, batch what can't be** — one batched round, not a drip.

## Movement 2 — Interview

Resolve, in order, the fields the campaign spec cannot default:

1. **Audience slice** — narrower than the ICP: the segment of the pinned
   `specs/gtm/icp.md` this one campaign addresses, sized and named. An invented
   example: *Fieldnote*'s ICP is landscaping crews of 3–15; the slice is
   "irrigation-license holders in two named states."
2. **Channel** — outreach or organic social (the v1 channels). What the chosen
   channel's provider layer must own is a **contract, not a vendor**:
   `references/channel-contracts.md` states the sending contract, the
   scheduling contract, and the deliverability floor, with current tools as
   hedged examples only. A second channel is a second campaign spec.
3. **Source ladder** — how the audience slice becomes verified contacts.
   `references/source-ladders.md` owns the rung taxonomy, the mandatory
   verification gate, and the ToS rule. Its **sample-pull rule is binding
   here**: before the spec commits to a ladder, pull a small sample of the
   audience through it — attended, in this session, the one spend this verb
   incurs — and record per-rung resolution in the spec. Coverage is measured,
   never assumed.
4. **Sequence/content copy** — drafted from the pinned positioning, in the
   product's committed voice. Founder-authenticity items (their name on
   outreach, their voice on social) stay founder-must-do, tagged `[attended]`
   in any conditions this plan authors.
5. **Cadence** — steps, intervals, posting rhythm; reply-stop behavior for
   outreach per the channel contract.
6. **Volume/spend envelope** — per-day and total send/post caps and the budget
   cap, plus any **narrowing** of the doctrine's standing-envelope classes.
   Narrow-only: a spec may queue even follow-ups for a sensitive audience, but
   may never widen past the doctrine's defaults (cited, §2).
7. **Stop-conditions** — the rate thresholds whose breach pauses the campaign
   via the provider API, per the doctrine (§4): at minimum the bounce-rate
   ceiling, complaint-rate ceiling, reply-rate floor, and budget cap. The
   compliance floor (doctrine §7) makes bounce and complaint thresholds
   mandatory — a spec without them is malformed and does not leave this
   session.

## Movement 3 — Author

Author the campaign spec from `templates/campaign-spec.md` — every section
filled, including the queue/approval/dispatch paths that name where this
campaign's queue files, approval records, and dispatch entries live — and the
**milestone spec(s) that land the campaign's pipeline pieces**: the campaign's
queue layout and its committed scripts, seeded from `templates/push-approved.mjs`
(refuses to run without a matching approval record — the queue invariant,
mechanically enforced) and `templates/readback.mjs` (outcome readback,
staleness flags, stop-condition pause). Those milestones build through
`implement-milestone` → `verify-milestone` per the shared rules
(`${CLAUDE_PLUGIN_ROOT}/references/milestones-and-verification.md`), cited not
restated: every done-condition tagged, verification named, the plan pass run
before the PR opens.

**The session ends attended, on the plan PR** — the campaign spec plus the
milestone spec(s), nothing sent, nothing scheduled. One campaign is one spec: a
second channel for the same product, or a second audience slice with its own
envelope, is a **second campaign spec**, never a widened one — widening an
authored spec outside an attended edit is the exact failure the doctrine's
queue invariant exists to block.

What happens next is not this verb's: `run-growth` operates the authored
campaign in gated cycles, and the push script it drives will refuse anything
this session's successors did not put an approval record behind.

## Where this sits

```
gtm             one product's positioning / ICP / channel plan   (product repo)
spec-campaign   one campaign, authored against a pinned gtm      ← here (growth-ops repo)
run-growth      one operating cycle of an approved campaign      (growth-ops repo)
```
