# Milestone — Visual-reference pipeline: references before directions, deconstruction before pixels

**Goal:** keel's design lane gains the missing visual-reference layer — a Phase 0.5 REFERENCE
step in `app-design-directions` (generous subagent-delegated pulls, mandatory deconstruction
into token-plan vocabulary, a graceful source ladder), reference lineage recorded in the
decision file and consulted at `review-feature`, a narrow divergence-sketch hook in
`spec-feature`, and an anti-slop staleness mechanism — as skill-prose changes.

**Change:** `specs/changes/visual-reference-pipeline.md`. **No-UI** → two-dimension
done-conditions. **Depends on:** nothing. **Parallelizable:** n/a (single milestone).

## Done-conditions

### Logic / invariants

- [auto] A new `skills/app-design-directions/references/visual-reference.md` exists and
  carries all seven of these elements: (a) a **source ladder** — a connected design-reference
  MCP (Mobbin named as the known instance, with its three search verbs
  screens/flows/sections; detection phrased so any equivalent MCP qualifies) → user-supplied
  screenshots or image batches → the existing text-only derivation — with an instruction to
  tell the user which mode ran; (b) a **generous-volume rule**: multiple queries spanning the
  app's screen archetypes, on the order of 10–20+ diverse screens, plus flow-level pulls
  where a user journey matters — explicitly NOT capped small for context reasons; (c)
  **subagent delegation**: the pull + deconstruction run in a subagent that returns distilled
  extractions plus chosen reference URLs, so the main session does not consume raw screenshot
  volume; (d) a **mandatory deconstruction pass** — each kept reference extracted into the
  direction-spec vocabulary (at minimum: palette, type roles, density, layout architecture,
  depth grammar, candidate signature devices) before any Phase 1 direction is specced, with
  the rationale that raw screenshots without deconstruction produce generic paraphrases; (e)
  a **diversity requirement** — the reference set must span visibly different looks, not one
  style repeated; (f) a **licensing stance** — references are queried at runtime or
  user-supplied, never bundled into the plugin or committed to a project repo as image files;
  (g) an **inspiration-not-transplant rule** — reference-derived directions still pass the
  anti-slop check and the distinctness test.
- [auto] `skills/app-design-directions/SKILL.md` names a Phase 0.5 REFERENCE step in all
  four places: the workflow-at-a-glance diagram, the phase exit-conditions checklist, the
  Phase 1 prose (directions may derive from the deconstructed references alongside the
  domain), and the reference-files table (a `visual-reference.md` row with a read-when). The
  step is positioned between Phase 0 and Phase 1 and is explicitly skippable down the source
  ladder (no hard MCP dependency).
- [auto] `skills/app-design-directions/SKILL.md` Phase 3's decision-file instruction includes
  reference lineage: the chosen direction's reference screens (URLs + extraction notes)
  recorded in `specs/design.md` (else `design/design-decisions.md`), alongside the existing
  spec contents.
- [auto] `skills/spec-feature/SKILL.md` Movement 2 permits a reference pull (per
  `visual-reference.md`'s mechanics) only in the existing bespoke-divergence-sketch case (a
  genuinely novel layout archetype), and states that pure recomposition stays
  reference-free.
- [auto] `skills/review-feature/SKILL.md`'s fidelity-to-intent judgment names the recorded
  reference lineage in the design decision file as consultable context — supplementary like
  the divergence sketch, never the reference itself.
- [auto] `skills/app-design-directions/references/anti-slop.md` gains both staleness
  mechanisms: (a) the fingerprint list is framed as calibrated to current-generation models
  with a dated as-of marker and an expectation of periodic refresh; (b) a cross-direction
  convergence self-check — when drafted directions resemble each other, the resemblance is
  treated as a shared default and at least one of the pair is discarded or reworked — named
  as the durable complement that survives model retraining.
- [auto] **No weakening:** the existing anti-slop fingerprint patterns, the
  diverge-cheap/converge-real doctrine, the workbench-composition fidelity rules, and
  spec-feature's do-not-re-explore rule are unchanged in the diff; every existing phase (0,
  1, 2, 3, 3.5, 4) remains present with its content intact, the only ladder change being the
  insertion of the Phase 0.5 line into the diagram and checklist. The change is pure addition
  plus the named edit points above.

### Behavioral completeness

- [auto] Every skill-file mention of `visual-reference.md` resolves to the new file (grep
  both sides — no dangling pointer), and the SKILL.md frontmatter of all three touched
  skills is unchanged.
- [auto] `scripts/check-neutral.sh` exits 0 (repo-wide run, which covers the touched files);
  `scripts/check-skill-frontmatter.sh` and `scripts/check-skill-anchors.sh` (with their
  self-tests) pass; `scripts/` untouched vs `main`.

## verification

verifier subagent against this file (docs greps: the seven visual-reference.md elements, the
four SKILL.md anchor points, the Phase 3 lineage line, the spec-feature hook + its
recomposition boundary, the review-feature lineage line, both anti-slop mechanisms,
no-weakening sweep, pointer resolution) + `scripts/check-neutral.sh` +
`scripts/check-skill-frontmatter.sh` + `scripts/check-skill-anchors.sh` + their self-tests.
No surface/action change → no runtime walk; no hard invariant → no `/security-review`.
