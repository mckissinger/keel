# Model + effort routing

The canonical owner of which model and reasoning effort each keel surface runs at. Skill and agent
frontmatter that pins a value must **match its row here** — this file is authoritative and ages in one
place (the capability ledger's own anti-staleness point). It is tied to
`decisions/2026-08-03-build-model-opus-5.md`, `decisions/2026-08-01-build-model-opus-4-8.md`, `decisions/2026-07-25-two-model-routing.md`,
`decisions/2026-07-21-model-effort-routing.md`, and `decisions/2026-07-01-model-capability-ledger.md`.

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

**The harness reality check (field-observed, 2026-08-05 harvest F7): not every dispatch mechanism carries
every override.** The Agent/Task dispatch exposes a per-invocation **`model`** arg but **no `effort`
arg** — so a per-dispatch effort override exists only where the mechanism supports it: **Workflow's
`agent()` takes both `model` and `effort`** (this is how the `punch-list` workflow pins
`claude-opus-5` at `low`/`medium` per group), while an Agent-tool dispatch resolves effort from the next
rung down — the dispatched skill/agent frontmatter, then `CLAUDE_CODE_SUBAGENT_MODEL`'s session, then the
session effort. A `reasoning-heavy` build that needs `xhigh` therefore rides an effort-carrying mechanism
(a Workflow dispatch, or a session set to `xhigh`) — never a prescribed dispatch arg the harness doesn't
have. (The build *model* no longer varies by grain — every build runs Opus 5 — so in practice the
frontmatter defaults already carry most rows, and the per-invocation override that matters is Workflow's.)

## The routing table

| keel surface | Mechanism | Model | Effort |
|---|---|---|---|
| `agents/verifier.md` | agent frontmatter | `claude-fable-5` (decorrelated from the Opus-5 builder) | `high` for **every** milestone — capability decorrelation carries the never-weaker invariant (see the invariant section below) |
| `agents/oracle.md` | agent frontmatter | `claude-fable-5` (the decorrelation principle applied mid-run: judgment consults under an active mode run decorrelated from the Opus-5 builder, so an ambiguous default is not resolved by the model most invested in its own path) | `high` |
| `implement-milestone` (run directly) | skill frontmatter | `claude-opus-5` | `high` |
| build subagent dispatched by `implement-feature` | orchestration reads milestone `Routing:` tag; `mechanical` rides `implement-milestone`'s frontmatter (`high`, nothing to set); `reasoning-heavy` → `xhigh` **via an effort-carrying mechanism** (Workflow `agent()` or session effort — the Agent/Task dispatch has no effort arg; see Resolution order) | `claude-opus-5` | `mechanical` → `high`; `reasoning-heavy` → `xhigh` |
| `punch-list` workers (per-**group** dispatched subagents) | model arg on the per-group dispatch call | `claude-opus-5` | `low`/`medium` |
| `arm-auto-merge` | skill frontmatter (effort only) | `inherit` | `high` |
| `debug` | skill frontmatter (effort only) | `inherit` | `high` |
| `prep-auto-merge` | skill frontmatter (effort only) | `inherit` | `high` |
| `implement-feature` | skill frontmatter (effort only) | `inherit` | `high` |
| `auto` | skill frontmatter (effort only) | `inherit` | `high` |
| `land-feature` | skill frontmatter (effort only) | `inherit` | `high` |
| `interview` | skill frontmatter (effort only) | `inherit` | `high` |
| `spec-feature` | skill frontmatter (effort only) | `inherit` | `high` |
| `spec-change` | skill frontmatter (effort only) | `inherit` | `high` |
| `spec-foundation` | skill frontmatter (effort only) | `inherit` | `xhigh` |
| `status` | skill frontmatter (effort only) | `inherit` | `high` |
| `review-feature` | skill frontmatter (effort only) | `inherit` | `high` |
| `verify-milestone` | skill frontmatter (effort only); dispatches the `verifier` subagent under the verifier-strength invariant (flat `high` under the current pair) | `inherit` | `high` |
| **Every other skill** (default rule below) | no pinned model | `inherit` | `high` |

## The default rule

**Any skill without an explicit row above runs `inherit`, effort `high`.** The skills covered by this
rule — enumerated here so coverage is auditable, never "covered by omission":
`adopt`, `app-design-directions`, `auto-merge`, `babysit-prs`, `consult`, `demo`, `gtm`, `harden`,
`harvest`, `kickoff`, `logo`, `marketing-site`, `measure`, `product-video`, `provision`, `run-growth`,
`spec-campaign`, `test-health`.

A reader can `ls skills/` and confirm every one of the 33 skills is either in the table above or in this
default list, and the `verifier` and `oracle` agents are in the table — nothing is treated by omission.
(The `consult` skill pins no `effort:` in its frontmatter, matching every other default-list skill; the
judgment it dispatches runs at the `oracle` agent's own pinned `claude-fable-5`/`high`.)

## The verifier-strength invariant (a hard rule, not a note)

The invariant: **the independent check is never weaker than the build it audits** — measured in
*capability*, not in effort-ladder position. The reason is `decisions/2026-07-01-model-capability-ledger.md`:
independent verification exists to guard against self-justification, which a *more* capable builder
exhibits *more* convincingly; an independent check weaker than the builder defeats that guard.

**Under the current model pair, the invariant resolves to a flat `high`.** With the verifier on Fable 5
and every build on Opus 5, Fable 5 at `high` already exceeds the Opus-5 builder at `xhigh` (Anthropic's
Fable 5 effort guidance, 2026-08: Fable's lower effort tiers "often exceed `xhigh` performance on prior
models") — so the verifier dispatches at `high` for every milestone, `reasoning-heavy` included, cutting
verification wall-clock with no capability loss. The old effort-escalation form of this rule (dispatch
the verifier at effort ≥ the builder's, keyed to the `Routing:` tag) **reactivates automatically whenever
the verifier's model does not strictly exceed the build model** — same-model verification anywhere, or a
future pair where the capability gap closes. The invariant is model-pair-relative; it is never retired.

## Notes

- Effort options are model-dependent (Fable 5 supports `low`→`max`; Opus 5 covers the range keel routes, `low`→`xhigh`).
- Per-invocation overrides ride only mechanisms that carry them (Resolution order, harness reality check):
  the Agent/Task dispatch carries **model only**; Workflow's `agent()` carries **model + effort** —
  `punch-list`'s per-group workers get `claude-opus-5` at `low`/`medium` through the workflow's `agent()`
  args; `implement-feature`'s `reasoning-heavy` → `xhigh` rides a Workflow dispatch or session effort,
  never a nonexistent Agent-tool effort arg.
- The platform already routes its built-in `Explore`/search subagents to Haiku; keel benefits from that
  without owning it (out of scope here).
