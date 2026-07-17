# Hardening brief — <project>, <date>

<!-- Written in Movement 1, confirmed with the user before the sweep runs. -->

## Launch context

<!-- Which run is this: pre-launch (first audit before real users) or a
     pre-major-release re-run? If a re-run: link the prior report
     (specs/reviews/YYYY-MM-DD-harden.md) — prior accepted risks are re-surfaced
     deliberately, never re-litigated silently. -->

- Run type: pre-launch | pre-release re-run
- Prior report: none | `specs/reviews/....md`
- Target date / forcing event:

## Dimensions in scope

<!-- All on by default for a pre-launch run. Supply chain is a named section of
     the security dimension (it rides the security subagent). A narrowed re-run
     records each exclusion WITH its reason. -->

| Dimension | In scope | Reason if out |
|---|---|---|
| Application security (incl. supply chain, AI surface per Q7) | yes | |
| Reliability + data safety | yes | |
| Operations + launch readiness | yes | |

## Services in play

<!-- From the environment contract in specs/01-architecture.md — names only,
     never values. These scope the service-posture probes. -->

- <service> — <mode: test/live> — <env-var names>

## Profile facts the sweep dispatches through

<!-- Quoted from specs/stack-profile.md so each sweep subagent gets them verbatim:
     the Q1–Q2 surface inventory (what to sweep), Q7 (AI surface: gated in or
     n/a), Q8.1 (browser-facing probes gated in or n/a), Q10 (deployed surface),
     Q9 (migration scheme). -->

## Known accepted risks carried in

<!-- Open specs/deferrals/ entries relevant to launch, listed by slug — audit
     input, re-surfaced at triage. -->
