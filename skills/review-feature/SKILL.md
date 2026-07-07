---
name: review-feature
description: The human aesthetic + completeness gate for a built feature — drive the rendered feature on a preview (or local build), screenshot each surface and diff it against the feature's workbench composition, and present it for the user's judgment, turning gaps into a refinement milestone.
when_to_use: After a feature's milestones are built, verified, and merged, before the feature counts as done. This is the per-feature checkpoint the autonomous verifier can't make; it sits ABOVE verify-milestone, not instead of it.
---

# Feature Review

Close the loop the autonomous build can't: **does this built feature look and feel like what we designed, and is it actually complete?** `verify-milestone` proves the invariants and logic hold; it cannot judge whether the composition sings or whether the feature feels finished. This skill is that judgment — per feature, with the human, against the feature's **workbench composition** (the named components from the feature spec's Movement-2 record). It is the checkpoint whose absence ships flat design and thin features even when every milestone "passed."

Run it **after** a feature's milestones are built, `/verify-milestone`-clean, and merged (the wave is green on main). The feature is not *done* until this gate passes.

**This gate is for features with a UI.** A no-UI feature (the profile's Q8 — a backend/CLI/library change) has nothing to render against a composition; its completeness is closed by `verify-milestone`, so this gate is skipped.

## Why this exists (and why mechanical checks don't cover it)

The first-run UX walk in `verify-milestone` is autonomous and **mechanical-only** by design — it catches *application failures* (system font where a display face is specified, unstyled native controls, tokens absent, stock charts, layout not matching the direction). It explicitly does **not** judge "does this sing" or "is this the feature I pictured." That judgment is reserved for the human, and the previous workflow front-loaded it onto the kickoff design redline (on generic archetypes) with no per-feature post-build equivalent — so once building started, nothing asked the user to look. This skill is that look, per feature.

## The pass

1. **Render the feature.** Drive each of the feature's surfaces with the **stack profile's activation driver** (Q3 — e.g. a headless browser for a web UI; fresh context = true first-run state for empty/loading paths; programmatic/seeded login for your own auth — an interactive browser only for third-party SSO or the user's live attended skim). Hit every surface the feature owns (the surface→milestone map in `specs/features/<feature>.md`), in each of its enumerated states (empty, loading, error, populated). Capture **console + network** (or the stack's equivalent diagnostics) to catch the error behind a surface that looks fine.
2. **Screenshot each distinct screen/state**, and diff each against **the feature's workbench composition** — the named workbench/gallery components the feature spec's Movement-2 record composes into this screen (§6 of the rules). The composition is the intent; the screenshot is the reality; the gap is the finding. When a divergence sketch exists for a screen (`design/mockups/<feature>/<screen>.html` — the optional throwaway that picked a novel archetype's direction), consult it too, as the supplementary record of what the composition was converging toward — never as a required input, and never as the reference itself.
3. **Judge with vision + the human.** A vision model looks first (catches "looks wrong" objectively); then present the side-by-side set to the user for the aesthetic + completeness call. Two distinct verdicts:
   - **Completeness** — is every state present and every interaction working? Missing empty states, dead-ended first-run paths, an interaction named in the spec but absent, the wrong/placeholder data — these make a feature feel thin and are objective.
   - **Fidelity-to-intent** — does it read as the feature we composed? Not pixel parity, but: the structure, hierarchy, density, and signature element of the workbench composition. Drift toward generic is the thing to catch. The **reference lineage recorded in the design decision file** (the chosen direction's reference screens — URLs + extraction notes) is consultable context for what the composition was converging toward — supplementary, like the divergence sketch, never the reference itself.
   - **Interaction feel** — does it *move* right? Judge against `${CLAUDE_PLUGIN_ROOT}/references/interaction-craft.md` (easing/duration, press feedback, origin-aware popovers, reduced-motion, nothing animating that shouldn't) and phrase findings as a `| Before | After | Why |` table — the concrete form of "does it sing." Two techniques deepen this judgment: check **entrance choreography** (multi-element entrances sequence by importance, not document position), and run the **frame-by-frame scrub** — when the profile's screenshot/review driver (Q8.4) declares a recording capability, record the feature's key transitions and step through them frame by frame (or at 2–5× slowdown); the timing flaws invisible at full speed (overlapping crossfade states, snapping easing, transform-origin drift) show up scrubbed. No recording capability → fall back to the slowed live replay in `${CLAUDE_PLUGIN_ROOT}/references/motion-cookbook.md`'s debugging guidance. Scrub findings land in the same `| Before | After | Why |` table.
4. **Surface against a deployed artifact too** — run the feature's surfaces on the **deployed verification surface** (Q10 of the stack profile — e.g. a branch preview URL; assert healthy + no console/network errors, passing any required bypass header), the cheap non-vision complement that catches what local can't (env vars, behavior under real infra). The vision judgment stays local; this just confirms the deployed thing works.

## Output — a refinement milestone, not a vibe

Findings are phrased as **checkable remediation conditions with route + screenshot evidence**, exactly like a verifier discrepancy list, so they paste into a `implement-milestone`:
- "the `/contacts` empty state renders the themed `EmptyState` with a create-CTA (currently a bare 'No data' string) — see screenshot vs the feature spec's composed list screen (`EmptyState` + `PageHeader` per its Movement-2 record)"
- "the timeline filter-by-event-type control specified in `features/crm.md` is absent on `/contacts/:id`"

These become a **refinement milestone** for the feature (its own branch + PR + `verified:` pin, same gate as any milestone). **The feature is not done until that milestone closes.** Aesthetic notes that are genuinely taste ("nudge this spacing") are the user's call — record them, but distinguish them from objective completeness/fidelity gaps so the latter are never waved through as taste.

**Every finding that reflects a defect *class* graduates into a no-fixture e2e in the stack's test driver** (Q3) (the empty state renders, the create-from-empty action exists and works), so the class is regression-locked in CI where vision review can't go — the same discipline as the verify-milestone walk.

## Relationship to the other gates

- **`verify-milestone`** (per milestone, autonomous) — invariants + logic + mechanical design-application. Runs first, per milestone.
- **`review-feature`** (per feature, human) — completeness + aesthetic fidelity-to-intent. Runs after the feature's milestones are merged. Sits above verify-milestone; never replaces it.
- A feature that is `verify-milestone`-clean but `review-feature`-failed is **not done** — it has an open refinement milestone. Don't mark the feature complete until that's closed and re-reviewed.

## Under an active autonomy mode

Under an active `keel:auto` mode (per `decisions/2026-07-autonomy-modes.md`), this gate is **scheduled, not skipped**: `keel:auto`'s debrief mandate batches it per feature — `auto:feature` at feature end, `auto:run` at run end, one sitting per feature in scope — and the sitting also adjudicates the run's ledger entries. Until it happens, a landed feature is *built-verified-merged*, never *feature-done*. The gate's content above is unchanged.
