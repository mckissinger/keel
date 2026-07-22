# Model + effort routing

The canonical owner of which model and reasoning effort each keel surface runs at. Skill and agent
frontmatter that pins a value must **match its row here** — this file is authoritative and ages in one
place (the capability ledger's own anti-staleness point). It is tied to
`decisions/2026-07-21-model-effort-routing.md` and `decisions/2026-07-01-model-capability-ledger.md`.

## The asymmetry principle

**Economize on generation, never on judgment.** Everything that *produces* code can run on a cheaper
tier because keel's machinery catches failures downstream; everything that *is* the machinery — specs,
verification, orchestration decisions — stays on the strong model, because a miss there is the
self-justifying failure the capability ledger says gets *more* convincing with capable models, not less.
Effort follows the same line: `low` where a failure is loud and cheap to catch, `xhigh` where it is quiet
and compounding.

## Resolution order

A subagent's model is resolved in this order (first present wins):

**per-invocation dispatch model > skill/agent frontmatter `model:` > `CLAUDE_CODE_SUBAGENT_MODEL` > session model.**

This is why `implement-feature` can run a `reasoning-heavy` milestone on Opus by setting an explicit
`model` arg on the dispatch call even though `implement-milestone`'s own frontmatter default is Sonnet —
the per-invocation arg sits at the top of the order.

## The routing table

| keel surface | Mechanism | Model | Effort |
|---|---|---|---|
| `agents/verifier.md` | agent frontmatter (base) + escalation on the dispatch call | `opus` (`claude-opus-4-8`) | base `high`, **dispatched at ≥ the builder's effort for the milestone** (`reasoning-heavy` → `xhigh`) |
| `implement-milestone` (run directly) | skill frontmatter | `sonnet` | `high` |
| build subagent dispatched by `implement-feature` | orchestration reads milestone `Routing:` tag; sets an explicit **model arg on the dispatch (Agent/Task) call** (overrides the skill frontmatter default) | `reasoning-heavy` → `opus`; `mechanical` → `sonnet` | `high` (`xhigh` when reasoning-heavy) |
| `punch-list` workers (per-**group** dispatched subagents) | model arg on the per-group dispatch call | `sonnet` | `low`/`medium` |
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

- Effort options are model-dependent (Fable 5 / Sonnet 5 / Opus 4.8 support `low`→`max`).
- The dispatch mechanism for `implement-feature` and `punch-list` is an **explicit model arg on the
  Agent/Task dispatch call** — the per-invocation override at the top of the resolution order — not a
  reliance on the dispatched skill's own frontmatter.
- The platform already routes its built-in `Explore`/search subagents to Haiku; keel benefits from that
  without owning it (out of scope here).
