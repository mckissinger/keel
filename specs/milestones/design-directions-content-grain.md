# Milestone — design-directions-content-grain

Change context: `specs/changes/design-directions-content-grain.md`. One milestone;
edits skill/template prose only (`skills/app-design-directions/SKILL.md`,
`skills/app-design-directions/templates/direction-spec.md`,
`skills/app-design-directions/templates/design-brief.md`,
`skills/app-design-directions/references/visual-reference.md`). No scripts, hooks,
gates, or plugin-root references move. Integration seams: `skills/spec-feature/SKILL.md`
Movement 2 owns the content-grain definition and the reactive new-primitive rule — this
skill cites that owner and must not re-own or contradict it (the kickoff seeds the
gallery with *discovered* content types; a content type a later feature introduces is
still added by that feature's milestone, feature-side); the three flatness signals are
owned by `references/milestones-and-verification.md` §3 at the plugin root — this skill
cites them with attribution, as `skills/review-feature/SKILL.md` already does; the
direction-spec template's structure is consumed by Phase 1's spec bullet list and
Phase 3's decision-file enumeration, so all three name the new line consistently; the
downstream gates that bind on the system's identity (the sixth plan-pass question, §2's
conditional type-hierarchy floors, review-feature's expression verdict) read
`specs/design.md` and need no edits — the declared carrier line is what they bind
against.

## Done-conditions

- [auto] **Content-type inventory in Phase 0.** `skills/app-design-directions/SKILL.md`
  Phase 0's discovery enumerates the app's **content types** — with examples named (an
  email/message view, rich text, a timeline, an activity feed, a chat transcript) — as
  a recorded finding distinct from the screen inventory and the data shapes, and states
  that the load-bearing mockup screen preferably carries a distinctive content type
  when the app has one. `templates/design-brief.md` carries a matching content-types
  slot under "Data & vocabulary" so the inventory lands in the brief.
- [auto] **Content-type primitives in the Phase 4 workbench.** Phase 4's workbench
  build names the Phase 0 content-type inventory as part of what gets built: each
  discovered content type becomes a **themed workbench primitive** in the gallery, in
  every state (per Q8.3), alongside the themed controls, icon package, motion library,
  and chart library — so `spec-feature`'s content-grain trigger finds the primitive
  *present* instead of firing a reactive per-feature build. The seam is stated: this
  seeds the gallery proactively; a gallery-absent content type a later feature
  introduces is still added by that feature's milestone per `spec-feature` Movement 2,
  which remains the definition's owner (cited, not restated). Two named sentences are
  updated in place: Phase 4 step 2's build sentence ("the whole material palette, as
  real components") and the altitude paragraph's definition of a **complete material
  palette** ("tokens + icons + motion + charts + primitives" — its enumeration gains
  the content-type primitives), so neither still defines completeness as
  controls-and-materials only.
- [auto] **Flatness signals in the self-reviews and the Phase 4 check.** Phase 2's
  self-review rule, Phase 3.5's screenshot-review step, and Phase 4's
  directional-fidelity verification each cite the three expression-level flatness
  signals (uniform type across a region with mixed semantic roles; adjacent
  equal-weight cards with no focal point; an action row of undifferentiated ghost
  buttons) with ownership attributed to the shared rules
  (`references/milestones-and-verification.md` §3, plugin root) — a flat-but-
  token-correct mockup or workbench is a named self-review finding at this gate, not
  something only downstream verification can catch.
- [auto] **Hierarchy carriers declared.** `templates/direction-spec.md` carries a
  **hierarchy-carriers** line (how this direction expresses hierarchy — e.g. type
  scale/weight, color, depth, spacing); Phase 1's direction-spec bullet list names it
  as part of a direction's spec; Phase 3's decision-file write includes it in the
  recorded chosen-direction spec (`specs/design.md` / `design/design-decisions.md`)
  **with a sentence stating that downstream gates read the hierarchy carrier from this
  recorded line rather than inferring it from the tokens** — the binding statement is
  required; naming the specific gates (the sixth plan-pass question, the
  type-led/low-color conditional floors, review-feature's expression verdict) is
  optional.
- [auto] **Content-type coverage in the pull and the spread.**
  `references/visual-reference.md`'s generous-volume rule extends the pull span to the
  app's distinctive content types, not only its screen archetypes (and the subagent
  contract's query instruction matches); `SKILL.md` Phase 0.5's pull description
  agrees. Phase 3.5 step 1 states that the archetype representatives are picked to
  also exercise the Phase 0 content-type inventory — the ~5 cap unchanged, content
  types choosing *which* representative screens, never adding archetypes — and the
  existing mandatory conversational-archetype bullet's own text is rewritten to
  reference that general rule (its case as one instance of content-type coverage), so
  no sentence in the phase presents the conversational case as the only content-grain
  rule.
- [auto] **Repo checks green.** `claude plugin validate --strict .`,
  `bash scripts/check-neutral.sh`, `bash scripts/check-plan.sh`,
  `bash scripts/check-skill-frontmatter.sh`, `bash scripts/check-skill-anchors.sh`,
  and every `scripts/*.test.sh` pass on the branch.

## verification

verifier subagent against this file's done-conditions (all `[auto]`; prose-only change —
each condition is closable by reading the named files and running the named checks).
verified: clean at a7e6143, 2026-07-13, via fresh-context keel:verifier subagent against this spec's done-conditions — all 6 prose conditions evidenced per-file/line, diff scope exactly the four named files, Phase 0 renumbering collateral-checked repo-wide (zero numeric references), 5 repo checks + 11 script self-tests green (348 tests) (evidence in PR #127)
