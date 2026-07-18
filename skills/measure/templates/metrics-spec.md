# Metrics — <product>

<!-- Authored by a measure authoring session. Lands as specs/gtm/metrics.md in
     the plan PR — PRODUCT TRUTH in the product's own repo, pinned (path +
     commit) by growth-ops consumers exactly as positioning is. Scope is the
     GROWTH FUNNEL only: acquisition → signup → activation → retention plus
     guardrails. Per-feature usage/engagement analytics is out of scope. -->

## North-star

<!-- ONE metric the product's growth is judged by, with its exact derivation
     from the canonical events below. A product with two north-stars has none;
     pick the primary and record the runner-up as a guardrail if it matters. -->

## Activation definition

<!-- The observable moment a signup becomes a user who got the value — stated
     as a checkable event condition (which event(s), within what window), not a
     feeling. An invented example: *Ledgerline* counts a signup activated when
     `report_exported` fires within 7 days of `account_created`. Sign-off on
     this definition is FOUNDER-MUST-DO (see the split below): it encodes what
     "got the value" means, and only the founder can make that call. -->

## Funnel stages

<!-- One row per stage, each with its CANONICAL EVENT NAME — the committed name
     the product's instrumentation emits and the readout adapter queries. The
     names here are the contract; instrumentation that emits anything else is
     a build bug, not a definition change. -->

| Stage       | Canonical event | Definition (when it fires) |
|-------------|-----------------|----------------------------|
| Acquisition |                 | <!-- e.g. first attributed visit — tagged-link (UTM/ref) landing --> |
| Signup      |                 | <!-- account creation --> |
| Activation  |                 | <!-- the activation definition's event(s), restated by name only --> |
| Retention   |                 | <!-- the return/continued-use event and its window --> |

## Guardrail thresholds

<!-- Floors and ceilings that flag a stage as broken rather than merely soft —
     e.g. a signup→activation conversion floor, a week-4 retention floor. Each
     threshold is a FLAG for an attended sitting; a readout never acts on a
     breach (measurement writes no provider state — doctrine §10). -->

## Provider / adapter note

<!-- Which analytics provider currently holds the product's outcome events, and
     where the committed readout adapter lives (seeded from the measure skill's
     funnel-readout.mjs template). The provider is an EXAMPLE, never a
     requirement — as of 2026-07, mainstream product-analytics platforms ship
     read-only query APIs with the shape the adapter expects; swapping
     providers means swapping the adapter's fetch functions and env-var names,
     not this spec. Record the env-var NAMES the adapter reads (never values). -->

## Agent-draftable vs founder-must-do

<!-- The split, so no downstream run mistakes a founder's job for an agent's.
     Agent-draftable: drafting stage definitions, proposing event names,
     deriving thresholds from baseline data, authoring the instrumentation
     milestones. Founder-must-do (tag [attended] in any conditions this plan
     authors): SIGN-OFF ON THE ACTIVATION DEFINITION (mandatory — it is the
     value judgment this file exists to record), plus any threshold that
     encodes a business commitment rather than a statistical baseline. -->
