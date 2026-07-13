# Change — design-directions-content-grain

One milestone, prose-only (one skill + two templates + one skill-local reference).
Extends `skills/app-design-directions` with the design-richness class of improvements —
the five items reviewed and approved item-by-item by Michael 2026-07-13, in direct
response to the review of that skill. `design-richness` (PR #106) closed the flat-feature
class *downstream*: spec-feature/spec-change gained the content-grain trigger and the
reactive new-primitive rule, the shared rules gained hierarchy floors and flatness
signals, review-feature gained the expression verdict. This change closes the same class
*at the source* — the skill that builds the workbench gallery whose content-type absence
caused the relay incident (session `b4a08064`, the "Alicia Moreno" email panel rendering
sender/subject/body as identical body text).

## Why (the source-side causal chain)

1. Phase 0 discovery inventories screens and data shapes but never **content types**
   (an email/message view, rich text, a timeline, an activity feed) — so the gallery is
   planned blind to them.
2. Phase 4 builds the workbench as controls + icons + motion + charts — content types
   are absent from the build list, so the gallery ships without them and every one
   becomes a reactive per-feature primitive addition (or, pre-#106, a flat inline
   improvisation).
3. The Phase 2/3.5 self-reviews and the Phase 4 fidelity check test application
   (contrast, alignment, tokens, signature element) — a flat-but-token-correct mockup
   or workbench sails through here exactly as it did in verify-milestone before
   design-richness item 4.
4. Nothing records **which carrier the chosen system uses to express hierarchy** — the
   downstream conditional floors ("mandatory where type-led/low-color"), the sixth
   plan question, and review-feature's expression verdict all bind on the system's
   identity, but must infer it from tokens instead of reading a declared line.
5. The Phase 0.5 reference pull and the Phase 3.5 spread are screen-structural; content
   novelty is orthogonal to screen archetype (the incident's lesson), so a distinctive
   content type gets no reference and no spread representative.

## Decisions taken (the five approved items)

- **Content-type inventory in Phase 0 (item 1).** Discovery enumerates the app's
  content types as a recorded finding, distinct from the screen inventory and the data
  shapes; the brief template carries the slot; the load-bearing mockup screen
  preferably carries a distinctive content type.
- **Content-type primitives in the Phase 4 workbench (item 2).** The inventoried
  content types become themed gallery primitives (every state, per Q8.3) at
  convergence, alongside controls/icons/motion/charts — the proactive half of
  design-richness item 2. The seam with spec-feature is compositional, not
  contradictory: the kickoff seeds the gallery with *discovered* content types; a
  content type a later feature introduces still becomes a primitive via that feature's
  milestone, per spec-feature Movement 2, which stays the definition's owner.
- **Flatness signals in the self-reviews (item 3).** Phase 2's self-review, Phase 3.5's
  screenshot-review, and Phase 4's directional-fidelity check cite the three
  expression-level flatness signals owned by the shared rules
  (`references/milestones-and-verification.md` §3, plugin root) — cited with
  attribution, never re-owned.
- **Hierarchy carriers declared (item 4).** The direction-spec template, Phase 1's
  spec bullet list, and Phase 3's decision-file write each carry **how this system
  expresses hierarchy** (type scale/weight, color, depth, spacing), so the downstream
  gates read the carrier from `design.md` instead of inferring it.
- **Content-type coverage in the pull and the spread (item 5).** The Phase 0.5
  generous pull spans the app's distinctive content types, not only its screen
  archetypes (`references/visual-reference.md` owns the pull mechanics); Phase 3.5's
  archetype representatives are picked to also exercise the content-type inventory —
  the ~5 cap unchanged, content types choosing *which* representatives, never adding
  archetypes.

## Seams owned up front

- Phase 3.5's mandatory conversational-archetype bullet already treats chat/feed/live-log
  as a special surface; after item 5 it must not read as the phase's *only*
  content-grain rule — the general representative-picking rule sits alongside it.
- The design-brief template slot lands under "Data & vocabulary" (adjacent to domain
  artifacts), not as a new top-level section — the brief stays one page.
- Phase 4's build sentence ("the whole material palette, as real components") is one of
  the sentences item 2 makes partially false; it is updated in place, not left to imply
  controls-and-materials only.

## Revisions from the adversarial plan pass

- The altitude paragraph's **complete material palette** definition ("tokens + icons +
  motion + charts + primitives") is the second sentence item 2 makes stale — named
  explicitly in the done-condition, since the original sweep clause could never trip it.
- Condition 4's binding clause sharpened to the two-readers bar: the decision-file
  write must carry the binding *sentence* (downstream gates read the carrier from the
  recorded line); naming the individual gates is explicitly optional.
- Condition 5's conversational-bullet clause replaced the judgment predicate ("reads as
  an instance") with the falsifiable form from the design-richness precedent: the
  bullet's own text is rewritten to reference the general rule, so no sentence presents
  the conversational case as the phase's only content-grain rule.

## Milestone

`specs/milestones/design-directions-content-grain.md` — edits
`skills/app-design-directions/SKILL.md`,
`skills/app-design-directions/templates/direction-spec.md`,
`skills/app-design-directions/templates/design-brief.md`, and
`skills/app-design-directions/references/visual-reference.md`. No scripts, hooks,
gates, or plugin-root references move.
