---
name: run-growth
description: Operate ONE gated cycle of an authored campaign in the growth-ops repo — readback of provider outcomes, stop-condition enforcement, prep and drafting onto the queue, the attended approval gate, push of approved material through the committed push script, and a file-per-entry dispatch record. Two run modes — a full attended sitting, or an unattended prep run that stops after the cycle brief and waits for a human. Nothing outbound executes without an approval record or a standing-envelope class covering it.
when_to_use: Human-triggered only — when the user (or a scheduled session invoking it explicitly by name) wants one operating cycle run over campaigns spec-campaign already authored. Runs in the GROWTH-OPS repo, over an authored campaign's committed spec, queue, and scripts. NOT for deciding positioning, audience, or channels — that is gtm, upstream, in the product's own repo; NOT for authoring or changing a campaign — that is spec-campaign, and widening a campaign mid-cycle is exactly what this verb refuses to do. NEVER fires by inference: "keep the campaign moving" in passing does not invoke it; a human (or a schedule a human wrote) names it.
disable-model-invocation: true
---

# Run Growth

You are acting as the operator of one campaign cycle. The deliverable is a
**completed, recorded cycle** — outcomes read back, tripwires enforced, the next
batch drafted onto the queue, approved material (and only approved material)
pushed, and a dispatch record closing the loop. This is the third verb of keel's
**growth** grain; the grain's operating doctrine is
`references/growth-operations.md` (`${CLAUDE_PLUGIN_ROOT}`), cited here and
never restated — every step below runs *under* its queue invariant:

> **No send, post, or spend ever executes without either an approval record on
> its queue or a standing-envelope class covering it.** (doctrine, §1)

Two boundaries, stated once: `gtm` owns the strategy layer in the **product's**
repo and `spec-campaign` owns campaign authoring in the growth-ops repo —
`run-growth` changes neither. It operates what an attended `spec-campaign`
session already authored, over that campaign's committed files and scripts,
and it may **narrow or pause** in-flight work but never widen it — widening is
an attended `spec-campaign` edit, full stop.

## Human-triggered only — why

This verb carries **`disable-model-invocation: true`**, unlike its two
plan-only siblings. It is the grain's execution verb: the one that hands
approved sends, posts, and spend to live provider APIs under the operator's
name. A verb with that blast radius must **never fire because a session
inferred it should** — not from "the campaign looks ready," not from a prompt
that merely resembles operating. It runs only when a human invokes it, or when
a **scheduled prep session a human configured invokes it explicitly by name**.
The same rationale keeps `auto` and `harvest` behind this flag: consequence
outside the repo is a human's call to initiate.

## The cycle — one ordered contract

One cycle is six steps, in order, no skipping and no reordering. Steps 1–2 are
mechanical (the committed scripts do the work); 3 drafts; 4 is the human gate;
5–6 execute and record.

1. **Readback.** Run the campaign's committed readback script — the project's
   copy seeded from m2's **`templates/readback.mjs`** — to pull outcome metrics
   from the provider APIs (the provider is canonical for outcomes — doctrine
   §3), append a new outcome snapshot to the ledger (file-per-entry, never an
   edit to a shared file), and **flag staleness** against the campaign's pinned
   product-repo paths + commit (doctrine §9): a flag for the sitting to judge,
   never a silent refresh.
2. **Stop-condition check.** Any campaign whose committed thresholds (bounce
   ceiling, complaint ceiling, reply floor, budget cap — doctrine §4) are
   breached **is paused immediately by the readback script itself** — m2's
   `readback.mjs` template owns the pause, via the provider API, as the
   doctrine's one always-allowed unattended write (§2) — and the breach is
   flagged into the brief. The skill does not re-implement this; it runs the
   script and honors its verdict.
3. **Prep.** Gather signals (replies, metric movement, list coverage), enrich
   through the campaign's source ladder **with its verification gate** — no
   contact enters a queue unverified — and draft the next batch: new queue
   files plus a **cycle brief** that lays out drafts, flags (staleness,
   stop-condition proximity, drift), and drafted reply responses for review.
   Prep writes drafts and briefs; it approves nothing. When the campaign's
   pinned product repo carries `specs/gtm/metrics.md`, the brief cites the
   latest cohort readout — produced by `measure`'s readout mode, never by
   this verb.
4. **The attended approval gate.** The user reviews the brief and the queues.
   **Approval writes an approval record** (the hash-matched record the push
   script demands); edits and kills need no record — only approval does.
   **Reply handling is always attended**: replies surface in the brief with
   drafted responses, and no response sends without this gate's approval —
   replies are never inside any standing-envelope class (doctrine §5).
5. **Push.** Approved material goes out **only through the campaign's
   committed push script** — the project's copy seeded from m2's
   **`templates/push-approved.mjs`** — which **refuses to run without a
   matching approval record** for the queue's exact current content. That
   refusal is the queue invariant enforced in logic; this skill never pushes
   around it, never inlines a send, never calls a provider API for outbound
   directly.
6. **Dispatch record.** The cycle closes with a **file-per-entry** dispatch
   entry (doctrine §8): what went out, on which channel, in what counts, with
   evidence pointers — approval records, provider message ids, metric
   snapshots. A cycle that sent anything and wrote no record did not complete.

## Two run modes

- **The attended sitting** — all six steps in one session, the user at the
  gate for step 4. This is the normal shape of "run this week's cycle."
- **The unattended prep run** — a scheduled session (which invoked this skill
  explicitly by name) runs **steps 1–3 only**: readback, stop-condition
  enforcement, prep. It stops after the cycle brief, **notifies the user, and
  waits** — steps 4–6 belong to a human sitting. Prep sessions write drafts
  and briefs; they approve nothing (doctrine §5).

**Degrade to paused, never to sent.** An unattended run that hits any gate —
a breached threshold, a staleness flag on in-flight copy, a queue without a
record, a provider error mid-readback — degrades to *paused/waiting for the
sitting*, never to *sent-unreviewed*. The only unattended sends are the
**standing-envelope classes** the doctrine defines (§2, cited not restated):
follow-ups within an already-approved sequence auto-send, pausing is always
allowed, and new threads / new posts / new spend always queue. A campaign spec
may have narrowed those classes; nothing in this verb ever widens them.

**Under an active autonomy mode**, spend remains a **planned stop point**:
pushing anything that commits budget stays attended unless the run's
pre-authorized envelope explicitly covers it — never silent spend, exactly as
the autonomy postures already treat live-key and go-live moments.

## Where this sits

```
gtm             one product's positioning / ICP / channel plan   (product repo)
spec-campaign   one campaign, authored against a pinned gtm      (growth-ops repo)
run-growth      one operating cycle of an approved campaign      ← here (growth-ops repo)
```
