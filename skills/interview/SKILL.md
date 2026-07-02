---
name: interview
description: >-
  Clarify a large or ambiguous request before building. Restates the goal,
  surfaces the decisions the request leaves open, and asks only the questions
  that can't be defaulted — in one batched round. For a brand-new project this
  is the app-skeleton kickoff gate: it resolves the goal, users, scope,
  FEATURE BACKLOG, services, and design direction at breadth (not per-feature
  depth), then hands off to spec-foundation.
when_to_use: >-
  When a request is large or ambiguous enough that wrong assumptions would
  waste significant build time, or at a brand-new project's kickoff as the
  app-skeleton gate. The deep per-feature interview lives in spec-feature,
  not here. Do not use for small fixes or well-specified tasks.
---

# Interview

Clarify what the user actually wants before significant build work begins. The cost of this skill is one round of questions; only invoke it when the cost of a wrong assumption is higher than that.

## When this applies

- The request is large or ambiguous enough that a wrong assumption would waste significant build time.
- Do **not** use for small fixes, well-specified tasks, or anything where exploring the codebase answers the question faster than asking.

## Behavior

1. **Restate the goal in one sentence.** Confirm who the output is for and what it enables. If you can't write that sentence, that's the first question.
2. **Surface the open decisions.** List the decisions the request leaves open. For each, decide: can I reasonably default this?
   - If yes: state the default you'll use. Don't ask.
   - If no: ask. These are decisions where the options diverge meaningfully and nothing in the request, codebase, or prior context picks one.
   - **If the project or feature includes a user interface**, the open decisions must include design direction: purpose, audience, and aesthetic tone (e.g. dense professional dashboard vs. clean minimal, editorial vs. utilitarian), plus any reference points ("feels like X, not Y"). Same rules as the other questions — ask only what can't be reasonably defaulted, state defaults for the rest.
   - **If the project or feature touches external services** (database, payments, auth, AI APIs, email, etc.), the open decisions must include the service inventory: which services, and any where the user might prefer an alternative to the default. Same rules — default what's defaultable (e.g. Supabase for the database, test mode for everything), ask the rest. The inventory feeds the spec's environment contract.
   - **If the project is greenfield** (no existing spec), surface the **feature backlog, the spine journey, and the core data shapes** (entities + key fields) at **breadth, not depth**. You need the *shape of the app* — every feature as a one-paragraph capability, the one end-to-end journey through it, and the high-level entities — because these are what `spec-foundation` and the design-system gate consume: the design gate needs the app's archetypes to mock, and the foundation needs the data model + the backlog to draw features from. Do **not** drain every screen/state/interaction of every feature here — that per-feature depth is `spec-feature`'s job, done one feature at a time so each is informed by what's already built. Resolving the *skeleton* here is what lets the foundation and design gate run without re-deriving it.
3. **Batch questions into one round.** Ask everything at once rather than dribbling questions across turns. Use AskUserQuestion where it fits; include your recommended answer for each question.
4. If a question can be answered by exploring the codebase or existing artifacts, explore instead of asking.

After the round, **synthesize the resolved understanding — the goal, the decisions made, the defaults you're taking, and (for anything with a stack) the proposed stack — and get the user's explicit confirmation before authoring anything** (docs, mockups, milestones). Do **not** auto-advance from interview to authoring; the synthesis-and-confirm is a hard gate. Once confirmed, don't re-open settled decisions.

## Under an active autonomy mode

Under `keel:auto run` (per `decisions/2026-07-autonomy-modes.md`), the question round and the synthesis-and-confirm gate become **ledgered defaults**: default every open decision from the recorded context, write the synthesis to the run ledger per `keel:auto`'s ledger contract, and proceed; the user adjudicates at the debrief. Outside a mode, the attended gates above hold exactly.

## Greenfield kickoff: you are the app-skeleton gate

For a brand-new project (greenfield, no existing spec), one round is usually not enough, and the interview is **the first attended kickoff gate.** Continue until the app-level open decisions — goal, users, scope, **feature backlog, spine journey, high-level data shapes**, external services, and **design direction** — are resolved enough to write the foundation. Stay at *breadth*: the whole app's shape, not the inside of any one feature.

Then — **after presenting the app-skeleton synthesis (including the proposed stack) and getting the user's sign-off** — **hand off to `spec-foundation`** rather than starting to build directly, and name the sequence so the handoff is explicit: `spec-foundation` writes the product skeleton (a feature backlog) + architecture, **pauses for the design-system gate** (`app-design-directions`, which builds the reviewable component gallery + `specs/design.md`), then `provision` runs — and the kickoff **ends there, with no milestone list.** Per-feature depth (every screen/state/interaction) and the milestones come later, one feature at a time, in `spec-feature`. Do **not** author milestones, design, or per-feature detail here — resolve the skeleton the next gates consume and pass it on. (The whole kickoff sequence can be run by the `kickoff` skill.)
