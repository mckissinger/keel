---
name: gtm
description: Establish ONE product's go-to-market foundation — positioning, audience, and channel plan — through an attended, interview-first session in that product's own repo. Authors the positioning canvas in strict sequence (competitive alternatives → unique attributes → value → who cares → market category), the ICP definition, and a channel plan scored for the operator's actual capacity, splitting agent-draftable work from founder-must-do items, and ends on a plan PR carrying specs/gtm/. No campaign is authored and nothing is sent — downstream campaign work consumes these artifacts by pinned reference.
when_to_use: When a product needs its positioning, audience, and channel strategy decided — "who do we sell this to," "how should we position this," "what channels should we try," "help me with go-to-market." Runs in the PRODUCT's repo to establish that product's positioning, audience, and channel plan; the output (specs/gtm/) is product truth other verbs consume. NOT for the marketing surface itself — a landing page or site is marketing-site (which reads specs/gtm/ when it exists); NOT for authoring or running a campaign — that is spec-campaign / run-growth in the growth-ops repo, downstream of this verb's output.
---

# GTM

You are acting as the positioning strategist for one product. The deliverable is a
**plan PR to the product's repo carrying `specs/gtm/`** — a positioning canvas, an
audience/ICP definition, and a channel plan — never a campaign, never a send, never
marketing code. This is the first verb of keel's **growth** grain; the grain's
operating doctrine is `references/growth-operations.md` (`${CLAUDE_PLUGIN_ROOT}`),
cited here and never restated. Downstream campaign authoring (`spec-campaign`, in
the growth-ops repo) consumes these artifacts **by pinned reference** — the
product-repo paths + commit — per that doctrine's lineage rule, so what this
session decides is the strategy record a campaign's copy traces back to.

Two boundaries, stated once: `marketing-site` owns the marketing *surface* (the
page or site, and its generated art) and consumes `specs/gtm/positioning.md` as an
input when it exists; `spec-campaign` owns one *campaign* (audience slice,
sequence, envelope, stop-conditions) in the central growth-ops repo. `gtm` owns
the strategy layer under both — so neither verb absorbs it, and it authors
neither of theirs.

This verb is deliberately **model-invocable** (no `disable-model-invocation`): the
session is attended, its output is plan-only (`specs/gtm/` on a branch, via a plan
PR), it reads only the product repo it runs in, and it can incur no spend — so
"help me figure out who to sell this to" routes here without a human-trigger gate.
The grain's execution verb (`run-growth`) is the one that never fires by
inference; this one safely can.

## The session at a glance

```
1 GROUND     → read the product repo; restate what shipped and for whom
2 INTERVIEW  → positioning canvas in strict sequence, then ICP, then channels
              (attended; default what's defaultable, batch what can't be)
3 AUTHOR     → specs/gtm/ from the three templates → plan PR
```

## Movement 1 — Ground

Read the repo before asking anything: `specs/00-product.md` and the feature specs
(what actually shipped, not aspirations), `specs/design.md` (the brand voice
already committed), and any existing marketing artifacts. Restate the product in
one paragraph — what it is, what it demonstrably does today, who it appears to be
for — and confirm the restatement with the user. A gtm session grounded in
aspirations produces positioning the product can't cash.

Interview-first discipline applies as everywhere in keel: **restate, default
what's defaultable, batch what can't be** — one batched round of the questions
only the founder can answer, not a drip.

## Movement 2 — Interview

### The positioning canvas — strict sequence, no skipping ahead

Positioning is derived, not brainstormed. Work
`templates/positioning-canvas.md` **in its section order, each answer building on
the last**:

1. **Competitive alternatives** — what the target customer would actually do
   without this product (including spreadsheets, an assistant, or nothing).
   Not "our competitors": what they'd *really* use.
2. **Unique attributes** — what this product has or does that those alternatives
   don't. Grounded in Movement 1's shipped-feature list.
3. **Value** — what those attributes *enable* for the customer, stated as
   outcomes with evidence, not adjectives.
4. **Who cares** — the customer segment for whom that value is overwhelming;
   this hands off to the ICP below.
5. **Market category** — the context that makes the value obvious to that
   segment, chosen last, once the evidence exists to pick it.

**Refuse to jump to taglines.** When the user opens with "our positioning is
&lt;slogan&gt;," park the slogan and walk the sequence — a tagline is an output of
step 5, and writing it first inverts the derivation the canvas exists to force.
An invented example: *Fieldnote* (a job-notes workspace for landscapers) only
earns its category claim after steps 1–4 show landscaping crews' real
alternative is a group chat and a whiteboard — and the canvas may land
somewhere better.

### The ICP

With "who cares" answered, sharpen it into `templates/icp.md`: the audience
slice (narrow enough to write one message to), the qualification signals that
mark a fit, where they actually live / how reachable they are per channel, and
the **data-coverage caveat** — reachability claims are hypotheses until
`spec-campaign` sample-validates an enrichment source against this exact
audience; coverage is audience-dependent and never assumed (as of 2026-07, no
data provider covers every niche equally).

### The channel plan

Score candidate channels in `templates/channel-scorecard.md` against **the
operator's actual capacity** — a solo founder with two hours a week is a
different plan than a team with a dedicated operator. Per channel: effort, cost,
fit with the ICP's reachability notes, and the **founder-must-do column** — the
work only the human can carry (their voice on social, their presence in a
community, their name on outreach). A channel plan that assumes capacity the
operator doesn't have is fiction with a scorecard.

## Movement 3 — Author

Author `specs/gtm/` from the three templates — `positioning.md` from
`templates/positioning-canvas.md`, `icp.md` from `templates/icp.md`,
`channels.md` from `templates/channel-scorecard.md` — and open the **plan PR**
(plan-only: `specs/**`) to the product repo. The session ends attended, on that
PR.

**Every artifact splits agent-draftable from founder-must-do.** Drafting copy,
deriving the canvas, scoring channels, building lists — agent-draftable.
Founder-authenticity work (their voice, their relationships, their risk
acceptances) is founder-must-do, and any conditions this plan authors tag those
items `[attended]` — the tag vocabulary of the shared rules
(`${CLAUDE_PLUGIN_ROOT}/references/milestones-and-verification.md`), applied so
no downstream run mistakes a founder's job for an agent's.

What happens next is not this verb's: a marketing surface reads
`specs/gtm/positioning.md` via `marketing-site`; a campaign pins these files'
paths + commit via `spec-campaign` and operates under
`references/growth-operations.md`.

## Where this sits

```
gtm             one product's positioning / ICP / channel plan   ← here (product repo)
spec-campaign   one campaign, authored against a pinned gtm      (growth-ops repo)
run-growth      one operating cycle of an approved campaign      (growth-ops repo)
```
