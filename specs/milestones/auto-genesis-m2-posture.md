# Milestone — auto-genesis-m2-posture: the genesis posture in keel:auto

**Goal:** `keel:auto genesis "<idea>"` exists as the skill's third posture: Phase 1's research +
approval-gate contract, the Phase 2 orchestration over existing verbs, and the ledger/debrief
deltas — all as prose in `skills/auto/SKILL.md`, re-implementing nothing the other verbs own.

**Feature:** `specs/features/auto-genesis.md`. **No-UI** → two-dimension done-conditions.
**Depends on:** `auto-genesis-m1-doctrine` (cites its decisions entry + template contract by
name) **and the landed `auto-hardening` feature** (reuses its `scripts/check-skill-anchors.sh`
prose-anchor lint via a new per-feature anchor file). **Parallelizable:** no.

## Done-conditions

### Logic / invariants
- [auto] `skills/auto/SKILL.md` documents the genesis posture alongside the existing two:
  invocation `keel:auto genesis "<idea>"`, human-triggered only, `disable-model-invocation:
  true` retained, frontmatter `description`/`when_to_use` updated to name three postures —
  conforming to `scripts/check-skill-frontmatter.sh`.
- [auto] **Phase 1 contract** (attended, before any mode file): a research fan-out producing
  ONE approval artifact with three named parts — (1) a **validation assessment** (prior art,
  demand/feasibility, an explicit "should this exist" recommendation the user can reject);
  (2) a **product skeleton** (feature backlog, spine journey, high-level data shapes, and a
  service inventory drawn from the sandbox key set by name); (3) **2–3 throwaway
  design-direction boards** (cheap, disposable — direction-picking only, per the
  diverge-cheap/converge-real rule; the real workbench is still built later by
  `app-design-directions` with the approved board as its ledgered input). The gate's three
  outcomes are stated: approve (naming a direction) / revise (iterate Phase 1) / reject (end,
  nothing created).
- [auto] **Phase 2 orchestration** (unattended, after approval): the section sequences —
  bootstrap the repo per `references/template-contract.md` under the envelope
  `decisions/2026-07-genesis-envelope.md` grants (generate-from-scratch v1; keys wired by
  **name only** from `~/.config/keel/sandbox.env`; tier-2 prune rule applied); run
  `scripts/check-auto-preflight.sh` — **a red preflight is a stop-point ending the run
  attended, never routed around**; on green, write the mode file with `level: "genesis"` per
  the mode-file contract in `scripts/merge-guard.sh`'s header + the 24h TTL the landed
  `auto-hardening` feature enforces; then drive the **existing verbs by reference** —
  `spec-foundation` (its new under-a-mode carve-out — see the next condition — seeded by the
  approved skeleton), `app-design-directions` (its existing ledgered-pick carve-out, seeded by
  the approved board), then the `auto:run` loop (`spec-feature` → `implement-feature` → the
  `--auto` land path) — re-deriving none of their rules; end at preview deploy + the debrief.
  The never-auto list is referenced (never restated) and genesis is stated to end at preview,
  never live.
- [auto] `skills/spec-foundation/SKILL.md` gains an **"Under an active autonomy mode"** section
  (the carve-out `interview`, `spec-feature`, `app-design-directions`, and `provision` already
  carry, and which `spec-foundation` alone lacks): under an active mode its attended
  interview/confirm gates become ledgered defaults seeded by the approved skeleton, the
  synthesis + the artifact each gate would have shown are written to the run ledger, and the
  build proceeds; every structural rule (repo setup, the CI-gate wiring, the pin gate) is
  unchanged. This is the only skill *behavior* change m2 makes, and it is additive prose (a new
  section), not an edit to any existing gate.
- [auto] **Ledger + debrief deltas**: Phase 1's approval artifact is committed as the new
  repo's first run-ledger entries (the run ledger contract otherwise unchanged, by reference);
  the debrief mandate section names genesis's addition — the validation assessment is
  revisited against the built reality at the debrief sitting.
- [auto] The skill's Boundaries section states: the agent never invokes genesis to escalate
  (human invocation is the authorization); the approval gate is attended under every
  circumstance (it is the mode's entry, not a ledgerable default); no session reads or prints
  sandbox key values; a rejected assessment creates nothing.
- [auto] `scripts/check-neutral.sh` + `scripts/check-skill-frontmatter.sh` pass on the changed
  skill files; **no guard, hook, or preflight script changes** in this milestone (guard
  recognition of `level: "genesis"` is m3 — until m3 lands, a genesis mode file is simply
  invalid to the guards, which fails closed).

### Behavioral completeness
- [auto] A new `scripts/skill-anchors/auto-genesis.txt` (its own file — the §4 file-per-feature
  rule, no edit to `auto-hardening.txt`) pins each load-bearing sentence via the
  `scripts/check-skill-anchors.sh` lint the `auto-hardening` feature shipped: the three Phase 1
  artifact parts by name; the three gate outcomes; the red-preflight stop-point sentence;
  `level: "genesis"`; the names-only-keys sentence; the preview-never-live sentence; and the
  `spec-foundation` under-a-mode section heading. `check-skill-anchors.sh` passes with the file
  present.
- [auto] `claude plugin validate --strict .` passes; every pre-existing self-test suite still
  passes.
- [attended] At the first genesis dogfood run, the user confirms Phase 1 ended at a single
  approval decision carrying all three artifact parts, and that rejection would have created
  nothing (the committed text anchors are the machine-checkable ground truth; this bullet is
  the human's end-to-end confirmation).

## verification
verifier subagent against this file — every enumerated contract element present in the skill
text (the anchors), orchestration strictly by-reference (no re-derived land choreography, no
restated never-auto list), the fail-closed posture at every seam (red preflight stops; invalid
mode file gates), and frontmatter conformance. Prose-only milestone (guards untouched) → no
`/security-review` here; m3 carries it where the decision surface changes.

verified: clean at e8acb64, 2026-07-05, via a fresh-context verifier subagent against this file — every enumerated contract element present in the skill text: the genesis posture (frontmatter names three postures, disable-model-invocation retained; Phase 1's one approval artifact with the three named parts + the three gate outcomes; Phase 2's bootstrap-under-envelope, keys-by-name-only, the red-preflight stop-point, mode file `level: "genesis"` per the merge-guard header + 24h TTL, the existing verbs driven by reference, preview + debrief; ledger + debrief deltas; the four Boundaries invariants), and spec-foundation's additive "Under an active autonomy mode" section (4 insertions / 0 deletions, no existing gate edited). Orchestration strictly by-reference: grep for the never-auto list's contents (go-live / live-key / spend) in skills/auto/SKILL.md returns nothing (referenced via §(d), never restated); the land path is cited as "the --auto land path (step 4 above)", not re-choreographed. Fail-closed confirmed at every seam (red preflight stops; a genesis mode file is invalid to the guards until m3, i.e. fails closed). git diff --stat main = exactly the three permitted files; scripts/skill-anchors/auto-hardening.txt untouched. Gates green: check-skill-anchors (14 anchors, the 9 new present), check-skill-frontmatter (17 files), check-neutral, check-plan, `claude plugin validate --strict`, all 10 self-test suites. Prose-only — no /security-review (that gate is m3). **Open [attended] condition, recorded not silently deferred:** the first-genesis-dogfood-run end-to-end confirmation is not closeable until a real genesis run exists; the committed text anchors are its machine-checkable ground truth and all pass, and the human confirmation is carried forward to that first dogfood run. (evidence: verifier report in PR)
