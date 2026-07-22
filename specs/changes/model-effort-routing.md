# Change — model-effort-routing: route each keel surface to the right model + effort by grain

**For:** keel operating on its own dogfood (and any installer), to stop paying frontier price
on mechanical work while keeping judgment on the strong model. **Enables:** the strong-orchestrator
+ cheap-executor pattern that Anthropic's own first-party benchmarks show reaching **92% of Fable's
SWE-bench Pro score at 63% of cost** (advisor) / **96% of BrowseComp at 46% of cost** (orchestrator)
— realized through keel's existing grain ladder, which already classifies work as mechanical vs
reasoning-heavy at spec time.

## Why this, why now (the record)

keel currently runs **every** surface at one tier — the verifier, punch-list workers, and every
build subagent all inherit the session model. That is the single-tier gap the 2026 field has
converged away from. keel is uniquely positioned to close it because the **grain ladder is already a
work classifier** — the done-condition tags and the fine-vs-coarse stakes rule tell you, at
spec-authoring time, whether a milestone is mechanical or reasoning-heavy. Routing just reads what
`spec-feature`/`spec-change` already wrote down.

The governing principle (the **asymmetry principle**, recorded in the decisions entry this milestone
creates, tied to `decisions/2026-07-01-model-capability-ledger.md`): **economize on generation,
never on judgment.** Everything that *produces* code can run cheap because keel's machinery catches
failures downstream; everything that *is* the machinery — specs, verification, orchestration
decisions — stays strong, because a miss there is the self-justifying failure the capability ledger
says gets *more* convincing with capable models, not less. Effort follows the same line: `low` for
work whose failure is loud and cheap, `xhigh` for work whose failure is quiet and compounding.

## Form (resolved with the owner)

Since keel is currently the owner's own tool (README ships public-install for later), routing is
expressed as a **hybrid**, not blanket frontmatter across ~30 files:

- **Single source of truth:** a new `references/model-routing.md` carries the canonical table + the
  asymmetry principle. It ages in one place — the capability-ledger's own anti-staleness point.
- **Concrete frontmatter only on the leaves** (safe to pin, high value): the verifier agent and the
  executor-grain skills. Model names live here *and* in the reference; the reference is authoritative
  and every pinned value must match it (a checked done-condition).
- **Orchestrators + spec verbs stay `inherit`** so the owner's `/model` choice governs the session —
  they get an `effort:` only, never a pinned model.
- **Escalation is orchestration, not static frontmatter:** `implement-feature` reads each milestone's
  new `Routing:` header tag and dispatches the build subagent on Opus for `reasoning-heavy`, Sonnet
  for `mechanical` (per-invocation model overrides the skill's default per the documented resolution
  hierarchy).

## The routing table (canonical copy built into references/model-routing.md)

| keel surface | Mechanism | Model | Effort |
|---|---|---|---|
| `agents/verifier.md` | agent frontmatter (base) + escalation on the dispatch call | `opus` (`claude-opus-4-8`) | base `high`, **dispatched at ≥ the builder's effort for the milestone** (`reasoning-heavy` → `xhigh`) — the independent check is never weaker than the build it audits |
| `implement-milestone` (run directly) | skill frontmatter | `sonnet` (default) | `high` |
| build subagent dispatched by `implement-feature` | orchestration logic reads milestone `Routing:` tag; sets an explicit **model arg on the dispatch (Agent/Task) call**, which overrides the skill's frontmatter default | `reasoning-heavy` → `opus`; `mechanical` → `sonnet` | `high` (`xhigh` when reasoning-heavy) |
| `punch-list` workers (dispatched per-**group** subagents) | model arg on the per-group dispatch call | `sonnet` | `low`/`medium` |
| `debug` | skill frontmatter | `inherit` (reasoning-heavy → owner keeps a strong session model) | `high`/`xhigh` |
| Orchestrators + spec verbs (`implement-feature`, `auto`, `land-feature`, `interview`, `spec-foundation`, `spec-feature`, `spec-change`, `status`, `review-feature`, `verify-milestone`) | no pinned model | `inherit` | `high`; `spec-foundation` `xhigh` |
| **Every other skill** (`kickoff`, `adopt`, `provision`, `harden`, `harvest`, `demo`, `gtm`, `logo`, `marketing-site`, `measure`, `product-video`, `run-growth`, `spec-campaign`, `test-health`, `app-design-directions`, `auto-merge`) | **default rule** — no pinned model | `inherit` | `high` |

Notes:
- `verify-milestone` dispatches the `verifier` subagent, so it carries the verifier's **effort-escalation
  rule** (dispatch at ≥ the builder's effort); `implement-feature` applies the same escalation when it
  spawns verification. Pinning the verifier *below* the builder on the hardest milestones would violate
  `decisions/2026-07-01-model-capability-ledger.md` (independent verification guards against
  self-justification, which a more capable builder exhibits *more* convincingly) — so the escalation is a
  hard rule, not a note.
- The **default rule** governs every skill not given an explicit row: no pinned model (`inherit`), effort
  `high`. `references/model-routing.md` still enumerates the **complete** skill inventory (all skills + the
  verifier agent) so "covered by rule" is auditable, never "covered by omission."
- The dispatch mechanism is an **explicit model arg on the Agent/Task dispatch call** (the per-invocation
  override, top of the resolution order) — not a reliance on the dispatched skill's own frontmatter. This is
  what makes `implement-feature` able to run a `reasoning-heavy` milestone on Opus even though
  `implement-milestone`'s default frontmatter is Sonnet.
- The platform already routes its built-in `Explore`/search subagents to Haiku — keel benefits from that
  without owning it, out of scope here. Effort options are model-dependent (Fable 5 / Sonnet 5 / Opus 4.8
  support `low`→`max`).

## Rework tracking (so the savings are real, not sideways)

The skeptic critique this milestone answers head-on: a cheap-executor stack can *look* cheaper while
it just moves spend into rework. So a cheap-model verification **bounce** is made visible on **both**
keel paths:

- **Autonomous** (`auto` run): recorded (model + milestone slug) in the run ledger under
  `specs/runs/<run-id>/`, per the ledger contract (`skills/auto/SKILL.md` §5).
- **Attended** (`implement-feature`): surfaced in the orchestrator's own thin per-milestone ledger
  (the slug → branch → PR → verdict → SHA line it already keeps) — the bounce is noted against the
  milestone so it reaches the owner at the merge gate, no new artifact invented.

Either way, a routing choice whose rework cost exceeds its token saving is visible rather than hidden.

## Split out (not this change)

The **decision-surfacing artifact** ("choices I wasn't confident about" at the build→verify handoff)
is a distinct mechanism and lands as its own later `spec-change`.

## Integration seam

`implement-feature`'s dispatch step and `implement-milestone`'s frontmatter must agree on the
resolution order: `implement-feature` sets an **explicit `model` arg on the dispatch (Agent/Task)
call** — the per-invocation override at the top of the order — so a reasoning-heavy milestone runs on
Opus even though `implement-milestone`'s own default frontmatter says Sonnet. The reference doc states
this order once; both skills point to it.
