# Milestone — model-effort-routing: route each keel surface to model + effort by grain

**Goal:** keel stops running every surface at one tier. The verifier, executor-grain skills, and
punch-list workers get concrete model/effort assignments; orchestrators and spec verbs stay
`inherit`; `implement-feature` dispatches each build subagent by the milestone's grain — all recorded
in one canonical reference, tied to the capability ledger, with cheap-model rework made visible.

**Change:** `specs/changes/model-effort-routing.md`. **No-UI** → two-dimension done-conditions.
**Depends on:** nothing (frontmatter + prose only). **Parallelizable:** no (single coherent policy
touching one reference + several skills' frontmatter). **Routing:** reasoning-heavy — this milestone
edits verification doctrine (`references/milestones-and-verification.md` §4), a resolution-order
contract, and the ledger; by its own asymmetry principle, machinery-editing work stays on the strong
model.

## The routing policy (canonical owner is `references/model-routing.md`)

The full table + rationale live in `specs/changes/model-effort-routing.md` and are built verbatim
into `references/model-routing.md`. Resolution order (stated once in the reference, both skills point
to it): **per-invocation dispatch model > skill/agent frontmatter model > `CLAUDE_CODE_SUBAGENT_MODEL`
> session model.** Assignments in brief: verifier → `opus`, base `high` but **dispatched at ≥ the builder's effort**
(`reasoning-heavy` → `xhigh`); `implement-milestone` →
`sonnet`/`high`; `implement-feature` build dispatch → `opus` when the milestone is `reasoning-heavy`,
`sonnet` when `mechanical`; punch-list workers → `sonnet`/`low`–`medium`; `debug` → `inherit`/`high`;
orchestrators + spec verbs → `inherit` (effort only; `spec-foundation` `xhigh`).

## Done-conditions

### Logic / invariants
- [auto] `references/model-routing.md` exists and carries: (a) a routing row for **every** surface named
  in `specs/changes/model-effort-routing.md`'s table (each with its model + effort), (b) the asymmetry
  principle ("economize on generation, never on judgment") stated explicitly, and (c) the resolution-order
  line above. Two-readers bar: a reader can find a row for each named surface and the resolution order in
  the file text alone.
- [auto] `agents/verifier.md` frontmatter adds `model: opus` and base `effort: high`, matching its
  `references/model-routing.md` row; the existing `tools:`/`disallowedTools:` and the read-only body are
  unchanged (git diff touches only the frontmatter model/effort lines).
- [auto] **Verifier effort-escalation (doctrine, not a note):** `references/model-routing.md` states, and
  `skills/verify-milestone/SKILL.md` + `skills/implement-feature/SKILL.md`'s verification-dispatch prose
  implement, that the `verifier` subagent is dispatched at **effort ≥ the builder's effort for that
  milestone** — `reasoning-heavy` → `xhigh`, `mechanical` → `high` — never below the build it audits. The
  reference cites `decisions/2026-07-01-model-capability-ledger.md` as the reason (an independent check
  weaker than the builder defeats the self-justification guard). Verifiable: the escalation rule appears in
  the reference and in both dispatch skills' prose, keyed to the milestone's `Routing:` tag.
- [auto] `skills/implement-milestone/SKILL.md` frontmatter adds `model: sonnet` and `effort: high`,
  matching its reference row.
- [auto] `skills/debug/SKILL.md` frontmatter adds `effort: high` (or `xhigh`) and carries **no** `model:`
  field (stays `inherit`), matching its reference row.
- [auto] `skills/implement-feature/SKILL.md`'s dispatch step instructs, in prose: dispatch each build
  subagent by setting an **explicit `model` arg on the dispatch (Agent/Task) call** — chosen by that
  milestone's `Routing:` tag, `reasoning-heavy` → Opus (`xhigh`), `mechanical` → Sonnet (`high`) — and
  states that this per-invocation arg overrides `implement-milestone`'s own Sonnet frontmatter default per
  the resolution order, citing `references/model-routing.md`. (The mechanism is the dispatch-call arg, not
  a reliance on the dispatched skill's frontmatter — that is what lets a `reasoning-heavy` milestone run on
  Opus.)
- [auto] `skills/punch-list/SKILL.md` specifies that its per-**group** worker subagents are dispatched with
  a `model: sonnet` arg at `low`/`medium` effort, per the reference. (Dispatch lives in `SKILL.md`; there
  is no separate workflow file.)
- [auto] The orchestrator + spec-verb skills named in the reference table
  (`implement-feature`, `auto`, `land-feature`, `interview`, `spec-foundation`, `spec-feature`,
  `spec-change`, `status`, `review-feature`, `verify-milestone`) carry an `effort:` per the table
  (`spec-foundation` `xhigh`, the rest `high`) and **no** pinned `model:` field.
- [auto] `references/milestones-and-verification.md` §4 documents a `Routing: mechanical | reasoning-heavy`
  milestone-header field (default `mechanical` when omitted) and states that `implement-feature` reads it
  to choose the build subagent's model. This milestone spec's own header is the first conforming instance
  (it carries a `Routing:` line — here `reasoning-heavy`, per the header's justification).
- [auto] New append-only `decisions/2026-07-21-model-effort-routing.md` records the routes-by-grain
  decision and the asymmetry principle, amending `decisions/2026-07-01-model-capability-ledger.md`
  **by reference** (it does **not** edit that file in place): model routing is a capability-*tracking*
  mechanism (which tier fits which grain), not a compensates-for-weakness crutch, so it is not on the
  prune list.
- [auto] Rework-tracking on **both** paths (a cheap-model bounce must be visible whether or not an autonomy
  mode is active): (a) `skills/auto/SKILL.md`'s ledger contract (§5) gains a rule that when a milestone
  built on a **cheaper-than-its-default** model bounces at verification, that bounce is recorded (model +
  milestone slug) in the run ledger under `specs/runs/<run-id>/`; (b) `skills/implement-feature/SKILL.md`
  states that in the attended path the same bounce is noted against the milestone in the orchestrator's thin
  per-milestone ledger (the existing slug → branch → PR → verdict → SHA line) so it reaches the owner at the
  merge gate. Verifiable: both skills carry the rule, keyed to a cheaper-than-default build.
- [auto] **Gates untouched (the hard invariant of this change):** git diff shows **no** edits to
  `scripts/check-verified-pin.sh`, `scripts/merge-guard.sh`, `scripts/guard-branch-rules.sh`, or the
  never-auto list in `decisions/2026-07-autonomy-modes.md`. Routing changes model selection only; no gate,
  guard decision matrix, or merge-authority rule moves.
- [auto] **Frontmatter is accepted, no regression:** `scripts/check-skill-frontmatter.sh` passes on every
  edited skill. (It is presence-only with no field allowlist — confirmed — so the new fields need no script
  change; this condition asserts it still passes, not that it validates the fields.) `claude plugin validate
  --strict .` passes. **Note for the verifier:** neither check inspects `model:`/`effort:` field *names* or
  *values* — the validator is blind to skill/agent frontmatter fields. So these two checks prove
  "no-regression," **not** "the runtime honors the fields." Whether Claude Code actually applies the routing
  at dispatch time is closed only by the `[attended]` dogfood below — do not fold it into an `[auto]` pass.
- [auto] `scripts/check-skill-anchors.sh` and `scripts/check-neutral.sh` pass on all edited files.

### Behavioral completeness
- [auto] **Complete inventory, no omissions:** `references/model-routing.md` enumerates **every** skill in
  `skills/` (the full set, not a sample) plus the `verifier` agent, each with an explicit treatment — a
  pinned model/effort, or `inherit` (whether by an explicit row or the stated default rule). A verifier can
  `ls skills/`, and every entry has a treatment in the reference; nothing is covered by omission. The
  default rule ("any skill without an explicit row → `inherit`, effort `high`") is stated in the reference.
- [auto] **Table ↔ frontmatter consistency:** every pinned model/effort value in an edited skill or the
  verifier agent equals its row in `references/model-routing.md` (no drift between the doc and the
  frontmatter).
- [auto] **Inherit-preservation regression:** the orchestrator + spec-verb skills named above carry no
  pinned `model:` field, so the owner's `/model` choice still governs those sessions — asserted across the
  full named set, not a sample.
- [auto] All pre-existing self-tests still pass with no regression from the frontmatter/prose edits:
  `check-verified-pin`, `check-plan`, `check-skill-frontmatter`, `check-skill-anchors`, `check-neutral`,
  `merge-guard`, `guard-branch-rules`, `session-bootstrap`.
- [attended] **Dogfood (unobservable by CI):** in a live session, a routed verb runs on its assigned
  model — dispatching the `verifier` subagent shows Opus, and a `mechanical`-tagged milestone dispatched via
  `implement-feature` runs its build subagent on Sonnet — confirmed via the session/subagent model
  indicator or `/cost`. A tool result cannot prove which model a subagent used; this is the owner's
  end-to-end confirmation. Its machine-checkable half (frontmatter values valid and matching the reference)
  is fully covered by the `[auto]` conditions above.

## verification
verifier subagent against this file — every `[auto]` condition checked against source with `file:line`
evidence (frontmatter model/effort values, reference-table rows, the gates-untouched git-diff assertion,
table↔frontmatter consistency, inherit-preservation across the named set); the self-tests trusted from the
committed suites (run, not re-derived). **No `/security-review`** — this milestone touches no hard invariant
(the "gates untouched" condition is itself the proof: the pin gate, merge guard, branch guard, and never-auto
list are unchanged; routing selects a model, it does not move a merge/auth/data decision). The `[attended]`
dogfood is the owner's live confirmation of subagent model selection, which no CI check can observe.
