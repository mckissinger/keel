# Change — two-model-routing: Opus 5 builds, Fable 5 verifies, Sonnet retired

**For:** keel operating on its own dogfood (and any installer) where **cost is not the governing
constraint** and the owner wants the strongest coherent two-model stack. **Enables:** collapsing the
three-tier routing to two models whose split is now justified by **error-decorrelation**, not price —
the builder and the independent verifier run *different* models so the check does not share the
builder's blind spots.

## Why this, why now (the record)

The `model-effort-routing` milestone (#174, `decisions/2026-07-21-model-effort-routing.md`) built a
three-tier policy — Opus 4.8 for judgment, Sonnet for cheap generation — under an explicit **cost**
premise (the asymmetry principle "economize on generation, never on judgment"). Two facts changed that
premise:

1. **Opus 5 shipped 2026-07-24** (`claude-opus-5`): >2× Opus 4.8's coding score, within 0.5% of Fable
   5's peak on CursorBench at max effort — at Opus-4.8 pricing ($5/$25). The strong tier is a same-price,
   strict upgrade.
2. **The owner has removed cost as a constraint** for this tool. With economy off the table, the
   "economize on generation" half of the asymmetry principle loses its reason to exist: there is no
   quality reason to run a weaker model on generation, so Sonnet's only justification is gone.

What does **not** dissolve is the *other* half — judgment. keel's safety rests on an independent
verifier catching the builder's mistakes, and the capability ledger
(`decisions/2026-07-01-model-capability-ledger.md`) is explicit that a *more* capable builder's wrong
answers get *more* convincing. A verifier on the **same** model as the builder is weakest against
exactly the errors the builder is prone to. So the surviving principle is restated from **economy** to
**decorrelation**: verification runs a **different, at-least-as-capable** model than generation.

## The two-model policy

- **Build / execution / orchestration → Opus 5.** Every surface that produces code runs Opus 5
  (`claude-opus-5`), whether pinned (executor skills) or inherited (orchestrators + spec verbs, via the
  session model). Effort still varies by grain.
- **Verification → Fable 5.** The `verifier` agent runs Fable 5 (`claude-fable-5`) — a different,
  strictly-stronger model than the builder, so the independent check is decorrelated from the build it
  audits. The effort-escalation rule is unchanged (dispatch at ≥ the builder's effort).
- **Sonnet is retired** from keel routing entirely.

### Structural consequence: the `Routing:` tag now drives effort only

With no cheaper build tier, the milestone `Routing: mechanical | reasoning-heavy` header **no longer
switches the build model** (it was `reasoning-heavy → Opus`, `mechanical → Sonnet`). It now sets **effort
only**: `reasoning-heavy → xhigh` build + `xhigh` verify; `mechanical → high` build + `high` verify. The
tag still earns its place — it is what escalates effort and the verifier floor — but the model branch in
`implement-feature`'s dispatch disappears.

### Structural consequence: the cheap-model-bounce ledger retires

The rework-tracking rule on both paths (`auto` §5 and `implement-feature`) existed to make a
**cheaper-than-default** build (a `mechanical`-routed Sonnet build) visible when it bounced at
verification. No build path is now cheaper than its default — every build is Opus 5 — so there is no
cheap-bounce to track. The rule is removed on both paths (a plain verification bounce is still recorded
by the existing per-milestone ledger line; only the *model-attribution* clause goes).

## Decisions resolved for the owner (flag at plan-PR review)

- **Concrete model IDs, not aliases, on the two pins.** The verifier and executor frontmatter pin
  `claude-fable-5` / `claude-opus-5` **by full ID**, not the `opus`/`fable` aliases. Rationale: the design
  *requires* builder ≠ verifier; if both were aliases that drift on a future release they could collide on
  one model and silently defeat decorrelation. Concrete IDs make a model bump a **deliberate, reviewed**
  edit — the same alias-drift that documented the strong tier as a stale `claude-opus-4-8` after Opus 5
  shipped is the anti-pattern this avoids. (Reversible if the owner prefers the alias convention.)
- **Debug, orchestrators, spec verbs, and the default-rule skills stay `inherit`.** With the session
  model on Opus 5 they resolve to Opus 5, and the owner keeps the `/model` override rather than hardpinning
  ~25 files. Only the two leaves (verifier, executor surfaces) carry a pin.

## The routing table (canonical copy built into references/model-routing.md)

| keel surface | Model | Effort |
|---|---|---|
| `agents/verifier.md` | `claude-fable-5` | base `high`, **dispatched at ≥ the builder's effort** (`reasoning-heavy` → `xhigh`) |
| `implement-milestone` (run directly) | `claude-opus-5` | `high` |
| build subagent dispatched by `implement-feature` | `claude-opus-5` (model no longer varies by grain) | `reasoning-heavy` → `xhigh`; `mechanical` → `high` |
| `punch-list` workers (per-group dispatch) | `claude-opus-5` | `low`/`medium` |
| `debug` | `inherit` (→ Opus 5) | `high`/`xhigh` |
| Orchestrators + spec verbs (`implement-feature`, `auto`, `land-feature`, `interview`, `spec-foundation`, `spec-feature`, `spec-change`, `status`, `review-feature`, `verify-milestone`) | `inherit` (→ Opus 5) | `high`; `spec-foundation` `xhigh` |
| **Every other skill** (default rule) | `inherit` (→ Opus 5) | `high` |

## Gates untouched (the hard invariant)

Routing selects a model; it moves no gate. The pin gate, merge guard, branch guard, and the never-auto
list stay byte-for-byte unchanged. This is a prose/frontmatter-only change — no `/security-review`.

## Integration seam

The resolution order is unchanged (per-invocation dispatch model > frontmatter > `CLAUDE_CODE_SUBAGENT_MODEL`
> session). What changes is the *values*: `implement-milestone`'s frontmatter default becomes Opus 5, and
`implement-feature`'s dispatch no longer overrides it with a per-grain model — it sets effort per grain and
leaves the model at Opus 5. The reference doc states the policy once; every pinned frontmatter value must
match its reference row (a checked done-condition).
