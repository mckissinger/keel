# Feature — review-hardening: close the gaps the 2026-07-05 full review confirmed

**Goal:** the enforcement layer's confirmed defects are fixed and its claims are stated
honestly, so the gate actually fails closed everywhere its header says it does, keel runs
its own gate on its own PRs, and the skill pipeline stops contradicting itself: the pin
gate's no-merge-base fail-open is closed; runtime-affecting spec files no longer ride the
plan-only exemption; the branch guard degrades closed like the merge guard; the accepted
classifier bypasses are asserted, not assumed; the "verified == merged" claim is scoped to
what the mechanism proves; the mockup→workbench refactor is finished in the three stale
files; provision seeds the inventory the preflight requires; and the small-fix lanes get a
routing rule.

**Why now (evidence):** the 2026-07-05 three-track review (skills / enforcement / doctrine)
confirmed each gap first-hand. The load-bearing one was **reproduced live**: with no merge
base between `BASE_REF` and `HEAD_REF` (orphan history; the realistic trigger is a shallow
CI clone — `actions/checkout` without `fetch-depth: 0`), `git diff BASE...HEAD` fails with
empty output inside the process substitution at `check-verified-pin.sh:44-45`, the failure
never propagates past `set -euo pipefail`, and a code PR carrying an **unpinned** milestone
spec passes with "no changes — pass", exit 0 — the exact fail-open class the script's own
step 0 exists to close, surviving one step past its fix. The same review confirmed: the
gate mechanically proves *drift-freedom*, not that verification happened (a self-written
`verified: clean at <HEAD>` passes unconditionally); the "verified == merged" claim
degrades under squash/rebase merges or a moved base (the gate runs pre-merge on the PR
head, never the merged commit); keel's own CI runs the gate's self-test but never the gate
against keel's PRs; `spec-feature`/`spec-change` were rewritten to workbench-as-reference
while `review-feature`, `implement-milestone` (preconditions), and
`skills/spec-feature/references/no-foundation.md` still demand `design/mockups/` as
mandatory; `skills/provision/SKILL.md` asserts `specs/run-command-inventory.txt` is "seeded
alongside the step-4 allowlist" but step 4 never seeds it (the preflight fails closed
without it); and a one-line fix has three plausible lanes (`debug` trivial-fix,
`punch-list`, `spec-change`) with no rule to pick.

**No-UI feature** → two-dimension done-conditions (logic/invariants + behavioral
completeness); fidelity does not apply. **Interview record:** decided 2026-07-05 —
merge-mode gap resolved by **prose + protection** (state the guarantee honestly;
`spec-foundation`/`adopt` require **require-branches-up-to-date** branch protection — the
load-bearing setting: a moved base then forces the branch to absorb it, real code enters
the drift set, and the pin gate itself demands re-verification of the combined state; a
post-merge mechanical re-check on main is a recorded **deferral**, not built). *Authoring
refinement over the sign-off sketch:* "merge-commit-only" was dropped — `spec-foundation`
already prescribes squash-merge for independent milestones (merge commits for stacked),
and with up-to-date enforced, squash preserves content equality; its only cost is pin-SHA
ancestry on main (traceable via the PR + spec record), which the honest prose states
rather than reversing the squash doctrine; pin-honesty gap resolved by
**prose only** (the gate is reframed as the drift half of a two-part control — the
fresh-session `verify-milestone` process is the verification, the gate is the drift
detector — per the model-capability ledger's process-is-the-verification stance; no
mechanical pin-binding change); scope includes the small-fix routing rule and the
plan-exemption carve-out; the reference-dedup/compression pass and all doc-only nits
(README counts/modes/hooks sentence, banner genesis line, M1/M2 prose leakage) are **out**
— the nits route to a separate punch-list after this plan lands.

## Milestones (file→milestone ownership map; no routes — no UI)

| Unit | Milestone | Owns |
|---|---|---|
| Gate + guard mechanics | `review-hardening-m1-gate` | `scripts/check-verified-pin.sh` (logic), `scripts/check-verified-pin.test.sh`, `scripts/guard-branch-rules.sh` (logic — the reader-less raw-scan fallback), `scripts/guard-branch-rules.test.sh`, `scripts/merge-guard.test.sh` (accepted-bypass assertions only — `merge-guard.sh` itself byte-identical; **all header prose is m2's**) |
| CI + doctrine honesty | `review-hardening-m2-ci-doctrine` | `.github/workflows/ci.yml`, **all header comment blocks this feature touches** — `scripts/check-verified-pin.sh`, `scripts/merge-guard.sh` (accepted-limits paragraph), `scripts/guard-branch-rules.sh` (limits + degrade direction) — plus their header-doc tripwire greps, the "verified code == merged code" banner line in `scripts/session-bootstrap.sh` + its test, `skills/spec-foundation/SKILL.md` + `skills/adopt/SKILL.md` (branch-protection requirement), new `decisions/2026-07-05-pin-gate-honesty.md`, new `specs/deferrals/post-merge-drift-check.md` |
| Skill-prose contradictions + routing | `review-hardening-m3-skills` | `skills/review-feature/SKILL.md`, `skills/implement-milestone/SKILL.md`, `skills/spec-feature/references/no-foundation.md`, `skills/provision/SKILL.md`, `skills/debug/SKILL.md`, `skills/punch-list/SKILL.md`, `skills/adopt/SKILL.md` (cut-line sentence), `scripts/check-skill-anchors.sh` + `scripts/check-skill-anchors.test.sh` (negative-anchor support), `scripts/skill-anchors/review-hardening.txt` (new, file-per-feature) |

**Build order + integration seams:** sequential **m1 → m2 → m3**. m2's CI job and honesty
prose describe m1's fixed semantics, so m2 follows m1; m2 and m3 both edit
`skills/adopt/SKILL.md` (m2: branch-protection requirement in repo setup; m3: the
adopt-vs-no-foundation cut line) — different sections, but sequential to avoid a same-file
rebase (the auto-hardening precedent). The logic-vs-header split on
`scripts/check-verified-pin.sh` and `scripts/guard-branch-rules.sh` is a named seam: m1
owns logic, m2 owns every header comment block **and** the tripwire greps that pin header
text (the tripwires land with the prose they pin, so m1's merge-guard byte-identity claim
and m2's header rewrite can never collide). m1 and m2 both extend
`scripts/merge-guard.test.sh` (m1: bypass assertions; m2: header tripwires) — sequential
ordering makes that safe.

**Parallelizable:** no (sequential, above).
