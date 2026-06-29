---
name: review-feature
description: The human aesthetic + completeness gate for a built feature — drive the rendered feature on a preview (or local build), screenshot each surface side-by-side with the feature's own mockups, and present it for the user's judgment, turning gaps into a refinement milestone. Run after a feature's milestones are built, verified, and merged, before the feature counts as done. This is the per-feature checkpoint the autonomous verifier can't make; it sits ABOVE verify-milestone, not instead of it.
---

# Feature Review

Close the loop the autonomous build can't: **does this built feature look and feel like what we designed, and is it actually complete?** `verify-milestone` proves the invariants and logic hold; it cannot judge whether the composition sings or whether the feature feels finished. This skill is that judgment — per feature, with the human, against the feature's own mockups. It is the checkpoint whose absence ships flat design and thin features even when every milestone "passed."

Run it **after** a feature's milestones are built, `/verify-milestone`-clean, and merged (the wave is green on main). The feature is not *done* until this gate passes.

**This gate is for features with a UI.** A no-UI feature (the profile's Q8 — a backend/CLI/library change) has nothing to render-vs-mockup; its completeness is closed by `verify-milestone`, so this gate is skipped.

## Why this exists (and why mechanical checks don't cover it)

The first-run UX walk in `verify-milestone` is autonomous and **mechanical-only** by design — it catches *application failures* (system font where a display face is specified, unstyled native controls, tokens absent, stock charts, layout not matching the direction). It explicitly does **not** judge "does this sing" or "is this the feature I pictured." That judgment is reserved for the human, and the previous workflow front-loaded it onto the kickoff design redline (on generic archetypes) with no per-feature post-build equivalent — so once building started, nothing asked the user to look. This skill is that look, per feature.

## The pass

1. **Render the feature.** Drive each of the feature's surfaces with the **stack profile's activation driver** (Q3 — e.g. a headless browser for a web UI; fresh context = true first-run state for empty/loading paths; programmatic/seeded login for your own auth — an interactive browser only for third-party SSO or the user's live attended skim). Hit every surface the feature owns (the surface→milestone map in `specs/features/<feature>.md`), in each of its enumerated states (empty, loading, error, populated). Capture **console + network** (or the stack's equivalent diagnostics) to catch the error behind a surface that looks fine.
2. **Screenshot each distinct screen/state**, and lay each **side-by-side with that screen's mockup** (`design/mockups/<feature>/<screen>.html`). The mockup is the intent; the screenshot is the reality; the gap is the finding.
3. **Judge with vision + the human.** A vision model looks first (catches "looks wrong" objectively); then present the side-by-side set to the user for the aesthetic + completeness call. Two distinct verdicts:
   - **Completeness** — is every state present and every interaction working? Missing empty states, dead-ended first-run paths, an interaction named in the spec but absent, the wrong/placeholder data — these make a feature feel thin and are objective.
   - **Fidelity-to-intent** — does it read as the feature we mocked? Not pixel parity (the real stack is more polished), but: the structure, hierarchy, density, and signature element of the mockup. Drift toward generic is the thing to catch.
   - **Interaction feel** — does it *move* right? Judge against `${CLAUDE_PLUGIN_ROOT}/references/interaction-craft.md` (easing/duration, press feedback, origin-aware popovers, reduced-motion, nothing animating that shouldn't) and phrase findings as a `| Before | After | Why |` table — the concrete form of "does it sing."
4. **Surface against a deployed artifact too** — run the feature's surfaces on the **deployed verification surface** (Q10 of the stack profile — e.g. a branch preview URL; assert healthy + no console/network errors, passing any required bypass header), the cheap non-vision complement that catches what local can't (env vars, behavior under real infra). The vision judgment stays local; this just confirms the deployed thing works.

## Output — a refinement milestone, not a vibe

Findings are phrased as **checkable remediation conditions with route + screenshot evidence**, exactly like a verifier discrepancy list, so they paste into a `implement-milestone`:
- "the `/contacts` empty state renders the themed `EmptyState` with a create-CTA (currently a bare 'No data' string) — see screenshot vs `design/mockups/contacts/list.html`"
- "the timeline filter-by-event-type control specified in `features/crm.md` is absent on `/contacts/:id`"

These become a **refinement milestone** for the feature (its own branch + PR + `verified:` pin, same gate as any milestone). **The feature is not done until that milestone closes.** Aesthetic notes that are genuinely taste ("nudge this spacing") are the user's call — record them, but distinguish them from objective completeness/fidelity gaps so the latter are never waved through as taste.

**Every finding that reflects a defect *class* graduates into a no-fixture e2e in the stack's test driver** (Q3) (the empty state renders, the create-from-empty action exists and works), so the class is regression-locked in CI where vision review can't go — the same discipline as the verify-milestone walk.

## Relationship to the other gates

- **`verify-milestone`** (per milestone, autonomous) — invariants + logic + mechanical design-application. Runs first, per milestone.
- **`review-feature`** (per feature, human) — completeness + aesthetic fidelity-to-intent. Runs after the feature's milestones are merged. Sits above verify-milestone; never replaces it.
- A feature that is `verify-milestone`-clean but `review-feature`-failed is **not done** — it has an open refinement milestone. Don't mark the feature complete until that's closed and re-reviewed.
