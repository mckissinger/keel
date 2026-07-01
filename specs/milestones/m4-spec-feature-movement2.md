# M4 — spec-feature / spec-change: design in the real workbench

**Feature:** design-track-neutral. **Depends on:** M1 (workbench verb) + M2 (neutral fidelity). **Parallelizable:** no — after M2.
**Files owned:** `skills/spec-feature/SKILL.md`, `skills/spec-change/SKILL.md`.

## Goal

Rework per-feature design (Movement 2) so a feature's screens are composed from **real workbench components** (a feature story/preview) — the fidelity reference — with **states + motion first-class**, instead of a throwaway HTML mockup that a later build re-implements. Keep the three-movements structure and the plan-PR handoff.

## Done-conditions

1. **[auto] Movement 2 composes on the workbench.** `spec-feature/SKILL.md` Movement 2 composes the feature's screens from the **real workbench components** (per the M1 workbench verb) into a feature story/preview, which is the fidelity reference. A bespoke throwaway mockup is **optional and only for a genuinely novel layout archetype** at divergence — never the re-implemented spec. The "compose from the locked system, don't re-explore" rule and the "do not run app-design-directions per feature" rule are retained.
2. **[auto] Fidelity points at the real composition.** Movement 3's fidelity done-conditions point at the **real workbench composition + enumerated states + tokenized motion/interaction** (per M2's neutral fidelity), not a static HTML file. Motion/interaction-state are specced as tokens, not left to builder defaults.
3. **[auto] spec-change parity.** `spec-change/SKILL.md` Movement 2 (mockups optional-and-asked) is kept in parity: the fidelity reference is the workbench composition or named gallery components — never nothing, never a re-implemented static mockup.
4. **[auto] No-UI path + neutrality intact.** The "skip Movement 2 for a no-UI feature" carve-out still reads correctly against the M1 has-UI? verb; `bash scripts/check-neutral.sh` passes.
5. **[completeness] Structure + handoff intact.** The three-movements flow, the confirm-before-author gate, the route→milestone ownership rule, and the plan-PR / fresh-build handoff are unchanged except for the medium.

## Verification

`verification: verifier subagent against this milestone's done-conditions, + bash scripts/check-neutral.sh`.

verified: clean at 93209cd, 2026-06-30, via verifier subagent against done-conditions + bash scripts/check-neutral.sh (all five DCs PASS; plan-only handoff ruled coherent; evidence in PR)
