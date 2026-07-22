# 2026-07-21 — Model + effort routing by grain

keel stops running every surface at one tier. Each surface is now routed to a model and reasoning
effort by its grain, with the canonical policy in `references/model-routing.md`.

## The decision

Route by the **asymmetry principle**: **economize on generation, never on judgment.** Everything that
*produces* code (the executor-grain skills, punch-list workers, the build subagent for a `mechanical`
milestone) can run on a cheaper tier because keel's machinery catches failures downstream. Everything
that *is* the machinery — the verifier, specs, orchestration decisions, a `reasoning-heavy` build — stays
on the strong model. Effort follows the same line: `low` where a failure is loud and cheap to catch,
`xhigh` where it is quiet and compounding.

Concretely: the `verifier` agent pins `opus`/`high` and is **dispatched at ≥ the builder's effort**;
`implement-milestone` runs `sonnet`/`high`; `implement-feature` dispatches each build subagent by the
milestone's `Routing:` tag (`reasoning-heavy` → Opus/`xhigh`, `mechanical` → Sonnet/`high`); punch-list
workers run `sonnet` at `low`/`medium`; orchestrators and spec verbs stay `inherit` (effort only) so the
owner's `/model` choice governs those sessions; every other skill inherits by the default rule. The full
table, the resolution order, and the complete surface inventory are in `references/model-routing.md`.

Cheap-model **rework is made visible on both paths** — a bounce of a cheaper-than-default build is
recorded in the run ledger (`auto` §5) or noted on the orchestrator's per-milestone ledger line
(`implement-feature`) — so a routing choice whose rework cost exceeds its token saving surfaces rather
than hiding as sideways spend.

## Relationship to the capability ledger (amended by reference, not edited)

This decision **amends `decisions/2026-07-01-model-capability-ledger.md` by reference** — it does not edit
that file. Model routing is a capability-**tracking** mechanism (which tier fits which grain), **not** a
compensates-for-weakness crutch. It is therefore **permanent audit machinery**, not a pruning candidate:
it does not exist because a model forgets or drifts; it exists because different grains have different
failure economics, which remains true against a hypothetically perfect-but-expensive builder.

The verifier effort-escalation rule descends directly from that ledger: independent verification guards
against self-justification, which a *more* capable builder exhibits *more* convincingly — so an
independent check weaker than the builder defeats the guard, and pinning the verifier below the builder on
the hardest milestones is forbidden, not merely discouraged.
