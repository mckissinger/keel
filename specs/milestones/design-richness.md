# Milestone — design-richness

Change context: `specs/changes/design-richness.md`. One milestone; edits skill/reference
prose only (`skills/spec-feature/SKILL.md`, `skills/review-feature/SKILL.md`,
`references/milestones-and-verification.md`, plus the plan-pass count line in
`skills/spec-change/SKILL.md`). No scripts, hooks, gates, or templates move.
Integration seams: the pure-recomposition guard sentence in spec-feature Movement 2
(shipped 1.7.0 — its guarantee must survive with sharpened scope, not weaken); §5's
plan-pass question list is owned by the shared rules and dispatched by one line each in
spec-feature/spec-change (ownership unchanged); review-feature's three-verdict structure
(completeness / fidelity-to-intent / interaction feel) gains a peer, not a rewrite.

## Done-conditions

- [auto] **Content-grain reference trigger.** `skills/spec-feature/SKILL.md` Movement 2
  defines pure recomposition at content grain: a screen is pure recomposition only when
  every **content type** it renders already exists in the workbench gallery, and a
  screen rendering a gallery-absent content type (examples named: an email/message
  view, a timeline, rich text, an activity feed) triggers the reference pull per
  `visual-reference.md`'s mechanics for that content type even when the screen
  archetype is standard. The guard sentence still states that true pure recomposition
  triggers no reference pull — the guarantee survives with its scope sharpened. The
  pull's **lineage (URLs + extraction notes) is recorded in the feature spec** exactly
  as the sketch case records it; the pulls-precede-sketch rule applies only when a
  sketch exists (the content-grain case has none — its pull precedes the *primitive's
  design* instead, and a lineage citation added after the primitive is built is
  banned the same way).
- [auto] **The Movement-1/Movement-2 boundary sentences are updated, not contradicted.**
  The two standing gate sentences — Movement 1's "reference pulls for *looks* stay
  gated at Movement 2's novel-archetype divergence-sketch case, and nowhere else" and
  Movement 2's "in that same novel-archetype case (and only there)" — are rewritten to
  name **both** Movement-2 looks-pull cases (novel screen archetype; gallery-absent
  content type), so no sentence in the file claims the archetype case is the only one.
  Movement 1's flows-not-looks rule is otherwise unchanged.
- [auto] **spec-change carries the same content-grain binary.**
  `skills/spec-change/SKILL.md` Movement 2's novel-archetype / pure-composition ask
  uses the content-grain definition: a change whose surface renders a gallery-absent
  content type is **not** pure composition (the incident shape — an email panel added
  to an existing screen — triggers the pull and the new-primitive rule at this grain
  too), with a pointer to spec-feature's Movement 2 as the owner of the definition.
- [auto] **Content type → workbench primitive.** `skills/spec-feature/SKILL.md`
  Movement 2 states the rule directly: a gallery-absent content type becomes a **new
  themed workbench primitive** added to the gallery in every state (per Q8.3) — never
  improvised inline; the milestone adding the surface owns adding the primitive; and
  the screen's fidelity done-condition names that primitive.
- [auto] **Hierarchy floors in the fidelity dimension.**
  `references/milestones-and-verification.md` §2's fidelity bullet adds two checkable
  type-hierarchy floors — a region rendering 3+ distinct text roles uses ≥2 distinct
  type levels (size or weight), and primary vs secondary actions are visually
  distinct — stated as **mandatory when the design system is type-led/low-color**
  (where type is the only hierarchy carrier); for other systems the sixth plan-pass
  question (below) is the guard, and the floors are not restated as a second rule.
- [auto] **Flatness signals in the vision diff.** The vision/fidelity-diff deviation
  list in `references/milestones-and-verification.md` §3 names three expression-level
  signals alongside the existing application failures: uniform type across a region
  with mixed semantic roles; adjacent equal-weight cards with no focal point; an action
  row of undifferentiated ghost buttons.
- [auto] **The mechanical/aesthetic split descriptions stay true.** The three passages
  characterizing the mechanical check as application-only are updated to match: the §2
  gloss ("*whether the system was applied at all* is mechanical…"), the §3 gloss ("the
  *mechanical* fidelity check (was the system applied)"), and
  `skills/review-feature/SKILL.md`'s "Why this exists" enumeration each state that the
  mechanical side covers **application plus the enumerated expression floors/signals**,
  while "does the composition sing" remains the human's — no passage still describes
  the mechanical check as application-only.
- [auto] **Sixth plan-pass question.** §5's adversarial plan pass enumerates a sixth
  question — does each UI screen's fidelity conditions operationalize the design
  system's stated identity and hierarchy tools (per `specs/design.md`)? — and no stale
  count survives: `grep -rn "five plan-shaped" skills/ references/` returns nothing
  (the spec-feature and spec-change dispatch lines read "six" or drop the number).
- [auto] **Richness verdict in review-feature.** `skills/review-feature/SKILL.md`'s
  judge step names **hierarchy/density/expression** as a per-screen grading the vision
  pass performs *before* presenting to the user, listed as a verdict peer alongside
  completeness and fidelity-to-intent, with the explicit rule that an expression gap
  (the §3 flatness signals) is an objective finding, never waved through as taste.
- [auto] **Repo checks green.** `claude plugin validate --strict .`,
  `scripts/check-neutral.sh`, `scripts/check-plan.sh`,
  `scripts/check-skill-frontmatter.sh`, `scripts/check-skill-anchors.sh`, and every
  `scripts/*.test.sh` pass on the branch.

## verification

verifier subagent against this file's done-conditions (all `[auto]`; prose-only change —
each condition is closable by reading the named files and running the named checks).
