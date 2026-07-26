# Model + effort routing

The canonical owner of which model and reasoning effort each keel surface runs at. Skill and agent
frontmatter that pins a value must **match its row here** — this file is authoritative and ages in one
place (the capability ledger's own anti-staleness point). It is tied to
`decisions/2026-07-25-two-model-routing.md`, `decisions/2026-07-21-model-effort-routing.md`, and
`decisions/2026-07-01-model-capability-ledger.md`.

## The decorrelation principle

**Verify on a different model than you generate on.** With cost no longer the governing constraint, every
surface that *produces* code runs the strong generation model (Opus 5); what stays deliberately *different*
is judgment — the independent `verifier` runs a distinct, at-least-as-capable model (Fable 5) so the check
does not share the builder's blind spots. This is the surviving half of the earlier cost-era asymmetry
principle ("economize on generation, never on judgment", `decisions/2026-07-21-model-effort-routing.md`):
economy is retired, but the capability ledger's point stands — a *more* capable builder's wrong answers get
*more* convincing, and a same-model checker is weakest against exactly the errors the builder is prone to.
Effort follows the failure shape: `low` where a failure is loud and cheap to catch, `xhigh` where it is
quiet and compounding.

## Resolution order

A subagent's model is resolved in this order (first present wins):

**per-invocation dispatch model > skill/agent frontmatter `model:` > `CLAUDE_CODE_SUBAGENT_MODEL` > session model.**

This is why `implement-feature` can raise a `reasoning-heavy` milestone's build to `xhigh` by setting an
explicit `effort` arg on the dispatch call, and why the `punch-list` per-group dispatch can pin
`claude-opus-5` at `low`/`medium`, regardless of the dispatched skill's own frontmatter — the
per-invocation arg sits at the top of the order. (The build *model* no longer varies by grain — every build
runs Opus 5 — so the override that matters at dispatch is now effort, not model.)

## The routing table

| keel surface | Mechanism | Model | Effort |
|---|---|---|---|
| `agents/verifier.md` | agent frontmatter (base) + escalation on the dispatch call | `claude-fable-5` (decorrelated from the Opus-5 builder) | base `high`, **dispatched at ≥ the builder's effort for the milestone** (`reasoning-heavy` → `xhigh`) |
| `implement-milestone` (run directly) | skill frontmatter | `claude-opus-5` | `high` |
| build subagent dispatched by `implement-feature` | orchestration reads milestone `Routing:` tag; sets an explicit **effort arg on the dispatch (Agent/Task) call** — the **model no longer varies by grain** | `claude-opus-5` | `mechanical` → `high`; `reasoning-heavy` → `xhigh` |
| `punch-list` workers (per-**group** dispatched subagents) | model arg on the per-group dispatch call | `claude-opus-5` | `low`/`medium` |
| `debug` | skill frontmatter (effort only) | `inherit` | `high` |
| `implement-feature` | skill frontmatter (effort only) | `inherit` | `high` |
| `auto` | skill frontmatter (effort only) | `inherit` | `high` |
| `land-feature` | skill frontmatter (effort only) | `inherit` | `high` |
| `interview` | skill frontmatter (effort only) | `inherit` | `high` |
| `spec-feature` | skill frontmatter (effort only) | `inherit` | `high` |
| `spec-change` | skill frontmatter (effort only) | `inherit` | `high` |
| `spec-foundation` | skill frontmatter (effort only) | `inherit` | `xhigh` |
| `status` | skill frontmatter (effort only) | `inherit` | `high` |
| `review-feature` | skill frontmatter (effort only) | `inherit` | `high` |
| `verify-milestone` | skill frontmatter (effort only); dispatches the `verifier` subagent under the escalation rule | `inherit` | `high` |
| **Every other skill** (default rule below) | no pinned model | `inherit` | `high` |

## The default rule

**Any skill without an explicit row above runs `inherit`, effort `high`.** The skills covered by this
rule — enumerated here so coverage is auditable, never "covered by omission":
`adopt`, `app-design-directions`, `auto-merge`, `demo`, `gtm`, `harden`, `harvest`, `kickoff`, `logo`,
`marketing-site`, `measure`, `product-video`, `provision`, `run-growth`, `spec-campaign`, `test-health`.

A reader can `ls skills/` and confirm every one of the 29 skills is either in the table above or in this
default list, and the `verifier` agent is in the table — nothing is treated by omission.

## Verifier effort-escalation (a hard rule, not a note)

The `verifier` subagent is dispatched at **effort ≥ the builder's effort for that milestone** — keyed to
the milestone's `Routing:` tag: `reasoning-heavy` → `xhigh`, `mechanical` → `high` — **never below the
build it audits.** `verify-milestone` and `implement-feature` both apply this when they spawn verification.

The reason is `decisions/2026-07-01-model-capability-ledger.md`: independent verification exists to guard
against self-justification, which a *more* capable builder exhibits *more* convincingly. An independent
check weaker than the builder defeats that guard — so pinning the verifier below the builder on the
hardest milestones is forbidden, not merely discouraged.

## Notes

- Effort options are model-dependent (Fable 5 / Opus 5 support `low`→`max`).
- The dispatch mechanism is an **explicit per-invocation arg on the Agent/Task dispatch call** — the
  override at the top of the resolution order, not a reliance on the dispatched skill's own frontmatter.
  `implement-feature` sets an **effort** arg (the build model is Opus 5 either way); `punch-list` sets a
  **model** arg (`claude-opus-5`) plus effort for its per-group workers.
- The platform already routes its built-in `Explore`/search subagents to Haiku; keel benefits from that
  without owning it (out of scope here).
