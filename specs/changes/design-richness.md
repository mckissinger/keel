# Change — design-richness

One milestone, prose-only (two skills + one reference). Closes the "flat feature" class
found in the relay review-feature sitting (2026-07-12): a lead-detail screen whose email
panel rendered sender/subject/body as identical `text-sm` passed every mechanical gate
and matched its composition honestly — because the composition, the fidelity conditions,
and the reference rules all operate above the grain where the flatness lived. The six
items were laid out and approved item-by-item in the 2026-07-12 transcript-review
session (Michael: "I approve"); the incident is the relay project's lead-ingestion
review-feature sitting of the same day (session `b4a08064`, the "Alicia Moreno" lead
detail — "The original email is super plain. All the text looks the same.").

## Why (the causal chain, from the incident)

1. The workbench composition named containers and controls ("raw email vs parsed fields
   side by side in `Card`s") — the *content inside* (an email's sender/subject/body
   hierarchy) had no named primitive and no condition, so builder defaults filled it.
2. The design system (type-led, low-color) makes type hierarchy carry everything, but
   no done-condition anywhere asserts hierarchy — "editorial, type-led" was a promise
   no gate operationalized.
3. The looks-pull trigger tests novelty at *screen* grain; the email viewer was novel
   *content* inside a standard screen, so no reference was ever pulled — the
   pure-recomposition guard read the screen as recomposition when its content wasn't.
4. verify-milestone's vision diff checks application (tokens present, components
   themed), not expression — flat-but-token-correct sails through; review-feature's
   vision pass chased named findings and waved overall hierarchy through.

## Decisions taken (the six approved items)

- **Content-grain trigger (item 1).** "Pure recomposition" is *defined*: a screen is
  pure recomposition only when every content type it renders already exists in the
  workbench gallery. A screen rendering a content type the gallery lacks (an email
  view, a timeline, rich text, an activity feed) is novel at content grain — the
  reference pull runs for that content type even when the screen archetype is standard.
  The recomposition guard's guarantee survives with sharpened scope, not weakened: true
  recomposition still triggers no pull.
- **Content type → primitive (item 2).** A gallery-absent content type becomes a new
  themed workbench primitive (added to the gallery in every state, per Q8.3) exactly as
  controls do — never improvised inline; the milestone adding the surface owns adding
  the primitive, and the fidelity condition points at it by name.
- **Hierarchy conditions (item 3).** The fidelity dimension gains checkable
  type-hierarchy floors: a region with 3+ distinct text roles uses ≥2 distinct type
  levels (size or weight); primary and secondary actions are visually distinct. Stated
  as mandatory where the design system is type-led/low-color (hierarchy has no other
  carrier there).
- **Flatness signals in the vision diff (item 4).** The mechanical fidelity check's
  deviation list extends with expression-level signals: uniform type across a region
  with mixed semantic roles; adjacent equal-weight cards with no focal point; an action
  row of undifferentiated ghost buttons.
- **Sixth plan question (item 5).** The adversarial plan pass adds: does each UI
  screen's fidelity conditions operationalize the design system's stated identity and
  hierarchy tools? Every "five plan-shaped questions" count reference updates
  consistently.
- **Richness verdict (item 6).** review-feature's vision-first pass grades each screen
  on hierarchy/density/expression *before* presenting to the user, as a named verdict
  alongside completeness and fidelity-to-intent — never waved through as taste.

## Revisions from the adversarial plan pass

- The trigger extends to `spec-change`'s Movement 2 too (the incident shape — a panel
  added to an existing screen — is sub-feature grain; leaving spec-change's binary
  untouched would preserve the bug at exactly the grain it occurred).
- The two Movement-1/Movement-2 boundary sentences ("and nowhere else" / "(and only
  there)") and the three mechanical-check-is-application-only glosses are owned
  explicitly — the plan must update every sentence it makes false.
- The hierarchy floors bind only where the system is type-led/low-color; elsewhere the
  sixth plan question is the guard (no second rule).

## Milestone

`specs/milestones/design-richness.md` — edits `skills/spec-feature/SKILL.md`,
`skills/spec-change/SKILL.md` (Movement 2 + the count line),
`skills/review-feature/SKILL.md`, and `references/milestones-and-verification.md`.
