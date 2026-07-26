# Milestone — two-model-routing: Opus 5 builds, Fable 5 verifies, Sonnet retired

**Goal:** keel's routing collapses from three tiers to two models — every build/execution surface runs
Opus 5, the verifier runs Fable 5 (a decorrelated, stronger independent check), and Sonnet is removed
everywhere. The milestone `Routing:` tag stops switching the build model and drives effort only; the
cheap-model-bounce rework ledger retires. One canonical reference, one new decision entry, gates
untouched.

**Change:** `specs/changes/two-model-routing.md`. **No-UI** → two-dimension done-conditions (logic +
behavioral completeness; no fidelity). **Depends on:** nothing (prose + frontmatter only).
**Parallelizable:** no (single coherent policy touching one reference + several skills). **Routing:**
reasoning-heavy — this edits routing doctrine, the asymmetry principle, and the `Routing:`-tag contract;
by its own principle, machinery-editing work runs on the strong model with a decorrelated verifier.

## Done-conditions

### Logic / invariants

- [auto] `references/model-routing.md` is updated so that: (a) the **asymmetry principle** section is
  restated from cost-economy to **decorrelation** — verification runs a *different, at-least-as-capable*
  model than generation so the independent check does not share the builder's blind spots (the effort
  line — `low` where failure is loud+cheap, `xhigh` where quiet+compounding — is retained); (b) the
  routing table's rows match the change doc's table exactly — verifier `claude-fable-5`; `implement-milestone`
  `claude-opus-5`/`high`; build dispatch `claude-opus-5` with effort `xhigh`(reasoning-heavy)/`high`(mechanical)
  and an explicit statement that **the model no longer varies by grain**; `punch-list` `claude-opus-5`/`low`–`medium`;
  `debug` + all orchestrators/spec-verbs + default-rule skills `inherit`; (c) the **resolution-order** section
  keeps the order statement but its illustrative example no longer tells the now-false Sonnet-override story
  (the build model no longer varies, so the "overrides `implement-milestone`'s Sonnet default" anecdote is
  replaced with a still-true illustration — e.g. `implement-feature` setting a per-invocation **effort** arg,
  or the punch-list per-group dispatch — or dropped); (d) the effort-support note currently reading
  "(Fable 5 / Sonnet 5 / Opus 4.8 support `low`→`max`)" is updated to name the two live models
  ("(Fable 5 / Opus 5 support `low`→`max`)"), dropping Sonnet 5 and Opus 4.8; (e) **strict no-Sonnet:**
  `grep -i sonnet references/model-routing.md` returns **zero** lines — Sonnet's retirement is recorded in the
  decision entry and the change doc, never in the canonical live table. Two-readers bar: a reader finds a row
  for every surface, the decorrelation principle, and the resolution order in the file text alone.
- [auto] `agents/verifier.md` frontmatter `model:` changes from `opus` to `claude-fable-5`; `effort: high`
  (base) unchanged; `tools:`/`disallowedTools:` and the read-only body are untouched (git diff on this file
  touches only the `model:` line).
- [auto] `skills/implement-milestone/SKILL.md` frontmatter `model:` changes from `sonnet` to `claude-opus-5`;
  `effort: high` unchanged; the `allowed-tools:`/`hooks:` block is untouched (git diff touches only the
  `model:` line).
- [auto] `skills/punch-list/SKILL.md` step-4 dispatch prose changes the per-group worker model from
  `sonnet` to `claude-opus-5` (effort `low`/`medium` unchanged), citing `references/model-routing.md`.
- [auto] `skills/implement-feature/SKILL.md` build-dispatch prose (step 1) is rewritten so the build
  subagent is dispatched on **`claude-opus-5` regardless of grain**, with the milestone's `Routing:` tag
  setting **effort only** (`reasoning-heavy` → `xhigh`, `mechanical` → `high`) — the per-grain **model**
  branch (`reasoning-heavy → Opus`, `mechanical → Sonnet`) and the "overrides implement-milestone's Sonnet
  default" clause are gone. The verify-dispatch prose (step 2) keeps the effort-escalation rule verbatim and
  must not imply an Opus verifier base — it names no base model today, and none is added (the verifier's
  base-model change lives in `agents/verifier.md` and `skills/verify-milestone/SKILL.md` step 2, not here).
- [auto] `skills/verify-milestone/SKILL.md` step-2 verifier-dispatch prose updates the agent's stated base
  model/effort from `opus`/`high` to `fable`/`high`; the escalation rule (dispatch at ≥ builder's effort,
  keyed to `Routing:`) is unchanged.
- [auto] `references/milestones-and-verification.md` §4 `Routing:`-tag paragraph is updated: the tag sets
  **effort** (and the verifier escalation floor), **not the build model** — the "choose the build subagent's
  model — `reasoning-heavy → Opus`, `mechanical → Sonnet`" clause is replaced with the effort-only reading
  (build is always Opus 5). The `default mechanical when omitted` behavior is unchanged.
- [auto] **Cheap-bounce ledger retired on both paths:** the model-attribution clause is removed from
  `skills/auto/SKILL.md` §5 (the "cheaper-than-its-default … Sonnet build … bounces" rule) and from
  `skills/implement-feature/SKILL.md`'s rework-visibility line. A plain verification bounce is still noted by
  the existing per-milestone ledger line / run-ledger; only the cheaper-than-default *model* clause goes.
  Verifiable: `grep -i "cheaper-than\|cheaper than\|Sonnet build" skills/auto/SKILL.md skills/implement-feature/SKILL.md`
  returns nothing.
- [auto] New append-only `decisions/2026-07-25-two-model-routing.md` records the two-model policy, the
  economy→decorrelation restatement, the concrete-ID pinning decision, and the `Routing:`-tag/ledger
  consequences. It amends `decisions/2026-07-21-model-effort-routing.md` and
  `decisions/2026-07-01-model-capability-ledger.md` **by reference** (it does **not** edit either in place —
  their git diff is empty).
- [auto] **Gates untouched (hard invariant):** git diff shows **no** edits to `scripts/check-verified-pin.sh`,
  `scripts/merge-guard.sh`, `scripts/guard-branch-rules.sh`, or the never-auto list in
  `decisions/2026-07-autonomy-modes.md`. Routing selects a model only; no gate, guard matrix, or
  merge-authority rule moves.
- [auto] **Frontmatter accepted, no regression:** `scripts/check-skill-frontmatter.sh` passes on every edited
  skill and `claude plugin validate --strict .` passes. **Note for the verifier:** neither check inspects
  `model:`/`effort:` field *values*, so these prove "no-regression," **not** that the runtime honors the new
  IDs — that is the `[attended]` dogfood below, not foldable into an `[auto]` pass.
- [auto] `scripts/check-skill-anchors.sh` and `scripts/check-neutral.sh` pass on all edited files.

### Behavioral completeness

- [auto] **Complete inventory, no omissions:** `references/model-routing.md` still enumerates **every** skill
  in `skills/` plus the `verifier` agent, each with an explicit treatment (pinned or `inherit` by row or the
  stated default rule). A verifier can `ls skills/` and find a treatment for every entry; nothing by omission.
- [auto] **Table ↔ frontmatter consistency:** every pinned model/effort value in an edited skill or the
  verifier agent equals its row in `references/model-routing.md` — specifically verifier=`claude-fable-5`,
  `implement-milestone`=`claude-opus-5`, punch-list dispatch=`claude-opus-5`. No drift between doc and
  frontmatter.
- [auto] **Inherit-preservation regression:** the orchestrator + spec-verb skills named in the reference
  (`implement-feature`, `auto`, `land-feature`, `interview`, `spec-foundation`, `spec-feature`, `spec-change`,
  `status`, `review-feature`, `verify-milestone`) and `debug` carry **no** pinned `model:` field, so the
  owner's `/model` choice still governs those sessions — asserted across the full named set, not a sample.
- [auto] **No stray Sonnet in the live routing surfaces (strict zero):** `grep -ri "sonnet"
  references/model-routing.md references/milestones-and-verification.md agents/verifier.md
  skills/implement-milestone/SKILL.md skills/implement-feature/SKILL.md skills/verify-milestone/SKILL.md
  skills/punch-list/SKILL.md skills/auto/SKILL.md` returns **zero** lines. The retirement narrative lives in
  `decisions/2026-07-25-two-model-routing.md` and `specs/changes/two-model-routing.md` (neither in this grep
  set), so no live surface needs a retirement mention — any Sonnet hit in the set is a missed edit. (Historical
  records — `decisions/2026-07-21-model-effort-routing.md`, `specs/chores/release-1-20-0.md`, the shipped
  `model-effort-routing` specs, `specs/reviews/**` — are **out of scope**: keel does not rewrite append-only
  decisions or shipped spec history.)
- [auto] All pre-existing self-tests still pass with no regression: `check-verified-pin`, `check-plan`,
  `check-skill-frontmatter`, `check-skill-anchors`, `check-neutral`, `merge-guard`, `guard-branch-rules`,
  `session-bootstrap`.
- [attended] **Dogfood (unobservable by CI):** in a live session, dispatching the `verifier` subagent shows
  **Fable 5**, and a build subagent dispatched via `implement-feature` (either grain) shows **Opus 5** —
  confirmed via the session/subagent model indicator or `/cost`. A tool result cannot prove which model a
  subagent used; this is the owner's end-to-end confirmation. Its machine-checkable half (frontmatter values
  valid and matching the reference) is covered by the `[auto]` conditions above.

## verification

verifier subagent against this file — every `[auto]` condition checked against source with `file:line`
evidence (frontmatter `model:` values, reference-table rows, the no-Sonnet greps, the gates-untouched
git-diff assertion, table↔frontmatter consistency, inherit-preservation across the named set,
decision-entry-amends-by-reference); the self-tests run, not re-derived. **Dispatch the verifier at `xhigh`**
(this milestone is `reasoning-heavy`, so the escalation floor is `xhigh`) — and per this very change the
verifier runs **Fable 5**, decorrelated from an Opus-5 build. **No `/security-review`** — the milestone
touches no hard invariant; the "gates untouched" condition is the proof (pin gate, merge guard, branch guard,
never-auto list all unchanged). The `[attended]` dogfood is the owner's live confirmation that the runtime
honors the new frontmatter at dispatch, which no CI check can observe.

verified: clean at 43ffa6f, 2026-07-25, via fresh-context verifier subagent (keel:verifier, dispatched at
`xhigh` per this milestone's own reasoning-heavy escalation rule) against this spec's done-conditions — all
17 `[auto]` conditions evidenced with `file:line` (frontmatter model values, the reference table rows, the
decorrelation-principle restatement, the strict no-Sonnet greps returning zero across all 8 live surfaces,
the cheap-bounce-ledger removal, the decision-entry amends-by-reference with both prior decisions' diffs
empty, gates-untouched git-diff, table↔frontmatter consistency, inherit-preservation across the named set,
the complete 29-skill + verifier inventory). 8 self-test suites + `check-skill-frontmatter` + `check-neutral`
+ `check-skill-anchors` + `claude plugin validate --strict` all green. Prose/frontmatter-only — no
`/security-review` (gates-untouched is the proof). The `[attended]` dogfood — that the runtime actually
dispatches Fable 5 for the verifier and Opus 5 for builds — is explicitly **not** covered by this pin and
remains the owner's live confirmation via `/cost` or the model indicator. (evidence: verifier report in PR)
