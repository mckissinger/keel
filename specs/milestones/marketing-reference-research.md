# Milestone — marketing-reference-research

Change context: `specs/changes/marketing-reference-research.md`. One milestone,
prose-only; wires reference research into `marketing-site` — one new skill-local
reference (`skills/marketing-site/references/reference-research.md`) and two scoped
hooks in `skills/marketing-site/SKILL.md` (Movement 1 and Movement 2). No gates,
guards, hooks, plugin-root references, or files outside `skills/marketing-site/`
move. Integration seams: mechanics come from
`skills/app-design-directions/references/visual-reference.md` **by citation, never
restated** (that file is not edited); `spec-feature`'s Movement 1 flow pull is the
citation precedent and is untouched; the post-app hook must reinforce, not weaken,
the skill's existing "amplification round, not a from-scratch one" rule. Neutrality
caution for the builder: the design-reference MCP is described generically ("a
connected design-reference MCP whose corpus includes marketing pages"); the known
instance and its capabilities (marketing-pages content type, Sections/Styles
filters, the section-search verb) appear only as hedged, as-of-2026-07 examples,
never as requirements; no dogfood projects or real client brands.

## Done-conditions

- [auto] **The Movement 1 pattern pull lands, structure-only.**
  `skills/marketing-site/SKILL.md`'s Movement 1 (Discover) carries a paragraph
  stating: when a connected design-reference MCP's corpus includes marketing
  pages, a **pattern-level pull runs during Discover** (default-on, not skippable
  by preference) — section-level research into which sections comparable
  products' pages carry, how the category shapes its pricing/proof, where actions
  sit — with findings landing as **structure** in the brief and the
  section-system plan, **never as tokens or visual choices** (looks stay gated at
  Movement 2); the pull and its distillation run per the delegation mechanics of
  `skills/app-design-directions/references/visual-reference.md` (cited, not
  restated); and with no such MCP connected the movement proceeds text-only and
  records that mode. The paragraph names
  `skills/marketing-site/references/reference-research.md` as the owning
  reference.
- [auto] **The Movement 2 greenfield clause lands.** The greenfield-fork bullet in
  Movement 2 states explicitly that the delegated `app-design-directions`
  Phase 1–2 discipline **includes its Phase 0.5 visual-reference pass** (one
  clause; the bullet's scope is otherwise unchanged).
- [auto] **The Movement 2 post-app pull lands, guard-first.** The post-app-fork
  bullet in Movement 2 states: a scoped looks-level pull may inform **only the
  amplification round's variant axes — hero treatment, section spectacle, motion
  posture** — and states **both guard clauses as explicit prohibitions** (wording
  may vary; neither clause may be implied only): the committed design language is
  never re-litigated, and the committed tokens are amplified, never replaced.
  References feed the 2–3 variants and the variants still converge into the
  marketing section system per the skill's existing rules, **with each variant
  spec recording the reference URLs + extraction notes it drew from (lineage)**.
- [auto] **The owning reference exists and carries the marketing delta.**
  `skills/marketing-site/references/reference-research.md` exists and states:
  (a) the movement scoping — pattern pull in Discover (structure), looks pull in
  Explore (fork-scoped as above), and nowhere else; (b) the **marketing
  extraction vocabulary** every kept reference is deconstructed into,
  **movement-scoped**: the Discover pattern pull extracts the structure items
  only — section sequence actually used, CTA count and placement, proof
  placement — while hero treatment type (mapped to
  `references/hero-treatments.md`'s menu) and style stance belong to the
  Movement 2 looks pull alone; (c) that all pipeline mechanics — the source ladder
  with its user-supplied and text-only rungs, generous volume, subagent
  delegation, deconstruction discipline, diversity, licensing,
  inspiration-not-transplant — are owned by
  `skills/app-design-directions/references/visual-reference.md` and are cited,
  never restated; (d) generic detection wording with the known instance's
  marketing-page capabilities hedged as as-of-2026-07 observations; and (e) the
  first-pull probe instruction — confirm the connected MCP's search verbs reach
  the marketing-page corpus, and fall back one ladder rung (recording the mode)
  if they don't; and (f) the **lineage rule** — each pull's reference URLs and
  extraction notes persist in the marketing spec (Discover pull) and the variant
  specs (Explore pull); text and pointers only, never image files.
- [auto] **The ownership seams hold.** `git diff main` touches only
  `skills/marketing-site/SKILL.md` and
  `skills/marketing-site/references/reference-research.md`, plus at most
  plan-path (`specs/**`) hunks — the pin line and plan-pass revisions:
  `skills/app-design-directions/references/visual-reference.md`,
  `skills/app-design-directions/SKILL.md`, and `skills/spec-feature/SKILL.md` are
  byte-identical to `main`.
- [auto] **Repo checks green.** `claude plugin validate --strict .`,
  `scripts/check-neutral.sh`, `scripts/check-plan.sh`,
  `scripts/check-skill-frontmatter.sh`, `scripts/check-skill-anchors.sh`, and
  every `scripts/*.test.sh` pass on the branch.

## verification

verifier subagent against this file's done-conditions (all `[auto]`; the change is
prose in two files, closable by reading the named files and running the named
checks).
