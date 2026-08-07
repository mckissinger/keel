# Milestone — judgment-oracle: the Fable-5 consult path for judgment questions under a mode

**Goal:** under an active autonomy mode, a would-be *judgment* ask can be consulted against a
dedicated read-only `oracle` agent on `claude-fable-5` before its default is ledgered; every
*authorization* ask remains the stop-point it is today. The consult is an input to a ledgered
default, never a new authority.

**Change:** `specs/changes/judgment-oracle.md`. **No-UI** → two-dimension done-conditions.
**Depends on:** nothing. **Parallelizable:** no (coupled edits to two skills + one reference + one
new agent). **Routing:** reasoning-heavy — edits autonomy doctrine.

## Done-conditions

### Logic / invariants

- [auto] `agents/oracle.md` exists with frontmatter mirroring the verifier's read-only posture:
  `name: oracle`, a non-empty `description:`, `tools: Read, Grep, Glob, Bash`,
  `disallowedTools: Edit, Write, NotebookEdit`, `model: claude-fable-5`, `effort: high`. Its body states it is read-only (observation-only Bash,
  no state mutation), answers **exactly one question per dispatch**, and may read the repo to
  ground its answer.
- [auto] `agents/oracle.md`'s body defines the report shape: a **recommendation**, the
  **rationale**, and a **disposition** that is exactly one of `answered`, `uncertain`, or
  `reframed-as-authorization` — and instructs the oracle to return `reframed-as-authorization`
  (with the reframing stated) whenever the dispatched question is authorization-shaped ("may I":
  merge authority, scope widening, gate deferral, or anything the never-auto list names — cited by
  reference, not restated), rather than answering it. Two-readers bar: the three disposition values and the refusal rule are present in the text.
- [auto] `skills/auto/SKILL.md` carries a **consult contract** section stating all of: (1) consults
  exist **only under an active mode** (a valid mode file per its existing contract); (2) the
  consultable class is **judgment questions only** — the spec underdetermines a choice among viable
  alternatives — and **authorization-shaped asks are never consultable**: merge authority outside
  the sanctioned `--auto` path, scope widening, gate deferrals, and anything the never-auto list
  names (cited as `decisions/2026-07-genesis-envelope.md` §(c) **by reference — the list is not
  restated**); (3) a consult dispatches `agents/oracle.md` with a distilled brief — the question,
  the viable options considered, and the relevant paths — **from the orchestrating session only**;
  build subagents never dispatch the oracle (they surface the question at the build→orchestrator
  handoff; the orchestrator consults and re-dispatches with the answer); (4) disposition handling,
  stated decidably: `answered` → the run proceeds on the recommendation as a ledgered default (the
  only disposition on which the run proceeds); `reframed-as-authorization` → the item was always a
  stop-point, halt per step 7; `uncertain` → the run halts attended (the consult confirms the
  ambiguity is beyond unattended resolution — the run does **not** fall back to the shaky default);
  and the contract carries this sentence **verbatim**: "A consult never converts a stop-point into
  forward motion; `answered` is the only disposition on which the run proceeds."
- [auto] `skills/implement-feature/SKILL.md`'s stop-points / notify-and-continue taxonomy is
  reconciled with the consult contract so that, reading the skill's letter alone, a run under an
  active mode: (a) routes a mid-build **judgment** question to the consult contract in
  `skills/auto/SKILL.md` (cited by reference, never restated — the ledger-contract citation
  pattern), and (b) classifies the contract's two attended halts — an `uncertain` disposition and
  the cap-exceeded would-be consult — as **stop-points, not notify-and-continue** (the taxonomy's
  "exactly the un-pre-authorizable set" enumeration must not contradict this: a compliant reading
  cannot resolve an `uncertain` consult to a silent default). The edit is confined to the
  stop-point/consult seam; attended-run semantics and the rest of `implement-feature` are
  unchanged.
- [auto] The consult contract states the **cap**: at most **5 consults per feature**; the would-be
  6th consult is itself a stop-point that halts the run attended, with the stated rationale that
  the volume signals a spec too ambiguous to run unattended. (5 is the requirement, not an
  approximation — the user set it.)
- [auto] The consult contract extends the **ledger contract** (step 5) without altering its
  existing semantics: every consult writes a file-per-entry record under `specs/runs/<run-id>/`
  carrying the **feature slug the consult belongs to** (so the per-feature cap count is derivable
  from the records alone, including under `auto:run`'s multi-feature ledger), the question, the
  distilled brief, the oracle's recommendation + rationale, the disposition, and what the run did
  with it (adopted / halted), committed with the work it explains; consult entries are adjudicated at the debrief (step 6) alongside the other ledger
  entries. The existing step-5 and step-6 prose is extended, not weakened: silent deferral stays
  banned, and no existing ledger or debrief sentence is deleted.
- [auto] **No-gate-change invariant:** `git diff` for this milestone shows no edits to
  `scripts/merge-guard.sh`, `scripts/check-auto-preflight.sh`, `scripts/guard-branch-rules.sh`,
  `scripts/check-verified-pin.sh`, `decisions/2026-07-genesis-envelope.md`, or
  `agents/verifier.md` — the consult path adds no authority and touches no guard, gate, or
  never-auto list.
- [auto] `references/model-routing.md`'s routing table carries a row for `agents/oracle.md` —
  mechanism agent frontmatter, model `claude-fable-5`, effort `high` — with a rationale tying it to
  the decorrelation principle (mid-run judgment decorrelated from the Opus-5 builder), and the
  reference's coverage-audit sentence names the oracle alongside the verifier so the agent set is
  auditable, not covered by omission. The frontmatter in `agents/oracle.md` matches its row (the
  reference's own must-match rule).

### Behavioral completeness

- [auto] The consult contract carries **at least one worked example of each side of the line** —
  a concrete consultable judgment question (e.g. two viable schema shapes for an underdetermined
  spec sentence) and a concrete never-consultable authorization question (e.g. "may I widen scope
  to include the adjacent route") — so an orchestrating session has a calibration anchor, not only
  the abstract test. Verifiable: both worked examples are present in the prose.
- [auto] `scripts/skill-anchors/judgment-oracle.txt` exists (file-per-feature — no existing anchor
  file edited) and pins, verbatim in their named files, at least: the authorization-never-
  consultable boundary sentence, the 5-per-feature cap sentence, and the exact invariant sentence
  fixed above ("A consult never converts a stop-point into forward motion; `answered` is the only
  disposition on which the run proceeds."); `scripts/check-skill-anchors.sh` passes.
- [auto] All pre-existing self-tests pass with no regression (`check-verified-pin`, `check-plan`,
  `check-skill-frontmatter`, `check-skill-anchors`, `check-neutral`); `claude plugin validate
  --strict .` passes.

## Verification

`verification: verifier subagent against this file's done-conditions (read the edited prose and the
new agent file; run the self-test suite and the anchors lint; run the no-gate-change diff check
against the milestone branch's merge base).`
