# Change — Visual-reference pipeline: references before directions, deconstruction before pixels

**Grain:** one change → one milestone (`spec-change`). **No-UI** (docs change to keel's design
skills). **Stacked on:** nothing (targets `main`).

## Why (the gap)

A deep-research pass (2026-07-06, 22 sources, 23 adversarially-confirmed claims) mapped the
craft ingredients of handcrafted-looking generated UI against keel's design lane. Keel already
carries five of the six verified layers — an anti-default core (`anti-slop.md`, broader than
Anthropic's official skill), quantified craft doctrine, a pre-code token-plan pass with
genericness gates, token-centralized styling, and screenshot-iterate loops. The sixth layer is
absent everywhere in keel, and it is the one every leading public skill also lacks: a
**visual-reference pipeline**. Phase 1 directions are derived entirely from prose — brief,
domain artifacts, and the model's imagination — which is the text-only ceiling. Practitioner
evidence (and the user's own experiment: a batch of diverse Dribbble mockups sharply improved
output) says visual reference supplies the out-of-distribution specificity prose cannot.
Infrastructure now exists: Mobbin ships an MCP server (600k+ shipped-product screens,
`search_screens`/`search_flows`/`search_sections`), verified working in this repo's sessions.

Two subtleties from the research shape the design:

- **Raw screenshots without a deconstruction step produce generic paraphrases.** The
  reference must be extracted into token-plan vocabulary (palette, type roles, density,
  layout architecture, depth grammar, candidate signature devices) before any direction is
  specced — the extraction, not the image, is what the direction consumes.
- **Named default-cluster blocklists decay as models retrain.** `anti-slop.md`'s pattern
  list is calibrated to current-generation models; banning today's clusters shifts
  convergence to the next nameable one. The durable complement is self-diagnosis: directions
  checked against *each other*, resemblance treated as a shared default.

## The decisions (from the attended mini-interview, 2026-07-06)

- **Volume is generous, context cost is delegated.** Per the user's explicit edit: no
  small-limit rule. The pull is wide — multiple queries across the app's screen archetypes,
  on the order of 10–20+ diverse screens, plus flow pulls where a journey matters — and runs
  in a **subagent** that returns distilled deconstructions plus the chosen reference URLs, so
  the attended session never consumes the raw screenshot volume.
- **Fallback ladder, never a hard dependency.** Connected design-reference MCP (Mobbin named
  as the known instance; detection written generically) → user-supplied screenshots/batches →
  the existing text-only derivation. The skill states which mode it ran in. Keel is a plugin
  others install; a paid MCP can never be required.
- **Licensing stance:** references are queried at runtime or supplied by the user — never
  bundled into the plugin or committed to a project repo as image files.
- **Reference lineage is recorded** in the Phase 3 decision file (`specs/design.md`) — the
  winning direction cites its reference screens (URLs + extraction notes) so later sessions
  and `review-feature` know what the direction converged toward.
- **Per-feature scope stays narrow:** `spec-feature` Movement 2 may pull references only in
  the case that already permits a bespoke divergence sketch (a genuinely novel layout
  archetype); pure recomposition stays reference-free. Re-exploring the locked direction per
  feature remains the bug it always was.
- **`review-feature` consults the lineage** (one line): the fidelity-to-intent judgment may
  read `design.md`'s recorded references as context for what the composition intended —
  supplementary, like the divergence sketch, never the reference itself.
- **References inspire, the gates still gate.** A reference-derived direction still passes
  the anti-slop check and the distinctness test; a reference is raw material for a choice,
  not a license to transplant a look wholesale.

## What changes (five items, one milestone)

1. `skills/app-design-directions/references/visual-reference.md` (new) + a named
   **Phase 0.5 — REFERENCE** step in the SKILL's workflow, exit conditions, Phase 1, and
   reference-file table.
2. Phase 3 records reference lineage in the decision file.
3. `skills/spec-feature/SKILL.md` Movement 2: the divergence-sketch case may pull references.
4. `skills/review-feature/SKILL.md`: the fidelity-to-intent judgment may consult the recorded
   reference lineage.
5. `skills/app-design-directions/references/anti-slop.md`: dated current-clusters framing +
   the cross-direction convergence self-check.

Milestone: `specs/milestones/visual-reference-pipeline.md`.
