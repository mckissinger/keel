# 2026-07-25 — Two-model routing: Opus 5 builds, Fable 5 verifies, Sonnet retired

keel's routing collapses from three tiers to **two models**. Every build/execution surface runs Opus 5;
the `verifier` runs Fable 5; Sonnet is retired. The canonical policy stays in `references/model-routing.md`.

## Why the earlier policy changed

The `2026-07-21` routing decision split work under an explicit **cost** premise — the asymmetry principle
"economize on generation, never on judgment." Two facts removed that premise:

1. **Opus 5 shipped 2026-07-24** (`claude-opus-5`): >2× Opus 4.8's coding score, within 0.5% of Fable 5's
   peak on CursorBench at max effort — at Opus-4.8 pricing ($5/$25). The strong tier is a same-price,
   strict upgrade.
2. **The owner removed cost as a governing constraint** for this tool. With economy off the table, there
   is no quality reason to run a weaker model on generation, so Sonnet's only justification is gone.

## The decision

Route by the **decorrelation principle** — the surviving half of the asymmetry principle: **verify on a
different model than you generate on.** Generation runs the strong model everywhere (Opus 5); judgment
runs a *distinct, at-least-as-capable* model (Fable 5) so the independent check does not share the
builder's blind spots. Effort still follows the failure shape: `low` where a failure is loud and cheap to
catch, `xhigh` where it is quiet and compounding.

Concretely: the `verifier` agent pins `claude-fable-5`/`high` and is **dispatched at ≥ the builder's
effort**; `implement-milestone` runs `claude-opus-5`/`high`; `implement-feature` dispatches every build
subagent on `claude-opus-5` and routes only its **effort** by the milestone's `Routing:` tag
(`reasoning-heavy` → `xhigh`, `mechanical` → `high`); punch-list workers run `claude-opus-5` at
`low`/`medium`; orchestrators and spec verbs stay `inherit` (effort only) so the owner's `/model` choice
governs those sessions; every other skill inherits by the default rule. The full table, the resolution
order, and the complete surface inventory are in `references/model-routing.md`.

Two structural consequences:

- **The `Routing:` tag drives effort only, not model.** With no cheaper build tier, the tag no longer
  switches the build model — it sets build effort and the verifier's escalation floor.
- **The cheap-model-bounce rework ledger retires** (`auto` §5 and `implement-feature`). No build path is
  cheaper than its default, so there is no cheap-bounce to attribute; a plain verification bounce is still
  carried by the existing per-milestone ledger line.

## Concrete model IDs, not aliases

The two pins name **full model IDs** (`claude-fable-5`, `claude-opus-5`), not the `opus`/`fable` aliases.
The design *requires* builder ≠ verifier; aliases that drift on a future release could collide on one
model and silently defeat decorrelation. Concrete IDs make every model bump a deliberate, reviewed edit —
the same alias drift that left the strong tier documented as a stale `claude-opus-4-8` after Opus 5 shipped
is the anti-pattern this avoids. The cost is a hand-bump per release, accepted deliberately.

## Relationship to the prior routing + capability-ledger decisions (amended by reference, not edited)

This decision **amends `decisions/2026-07-21-model-effort-routing.md` and
`decisions/2026-07-01-model-capability-ledger.md` by reference** — it edits neither file. The economy half
of the 2026-07-21 asymmetry principle is retired (cost is no longer the constraint); the capability
ledger's judgment half is *strengthened*, not weakened: it is why verification moves onto a different,
stronger model rather than sharing the builder's. Routing remains capability-**tracking** machinery (which
model fits which role), not a compensates-for-weakness crutch — so it stays permanent audit machinery, not
a pruning candidate.
