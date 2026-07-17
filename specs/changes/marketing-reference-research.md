# Change — marketing-reference-research

One milestone, prose-only (two scoped hooks in `marketing-site`'s skill body + one new
skill-local reference). Approved by Michael 2026-07-16 after an inline research round
(the design-reference MCP's mid-2026 state: an official server on paid plans, OAuth,
inline screen images; and — decisive — a marketing-page corpus added to the known
instance's library in late 2025, with content-type filters for marketing pages, page
patterns like "Landing Page", and Sections/Styles filter taxonomies) and a synthesis
the user signed off on directly.

## Why

`marketing-site` is the one design-track verb with **no reference-research wiring**.
`app-design-directions` owns the full visual-reference pipeline
(`references/visual-reference.md`: source ladder, generous volume, subagent
delegation, mandatory deconstruction, diversity, licensing, inspiration-not-
transplant) and `spec-feature` carries the scoped flow-level pull — but the
marketing verb, whose Explore movement is explicitly about *spectacle*, derives its
variants from prose alone: the text-only ceiling the visual-reference change was
built to break. The gap is not a recorded decision — the marketing-site change
context never weighs it — it simply wasn't wired. Meanwhile the known-instance
corpus now covers exactly this territory: shipped **marketing pages** searchable by
section (hero, features, pricing) and style, mapping almost one-to-one onto the
marketing section system the skill already plans with (hero, feature band, proof
strip, pricing table, footer). The section-search verb the other skills barely use
is the natural marketing verb.

## Decisions taken

- **Reuse the machinery, add only the marketing delta.** All mechanics come from
  `skills/app-design-directions/references/visual-reference.md` **by citation,
  never restated** — the source ladder (connected design-reference MCP →
  user-supplied screenshots → text-only floor), generous volume, subagent
  delegation, the deconstruction discipline, diversity, licensing, and
  inspiration-not-transplant. `spec-feature`'s Movement 1 flow pull is the
  precedent for citing that file cross-skill for mechanics only.
- **Movement 1 (Discover) gains the pattern-level pull** — the marketing analog of
  `spec-feature`'s flow pull, default-on when a design-reference MCP with a
  marketing-page corpus is connected: section-level research into which sections
  comparable products' pages carry, how this category shapes its pricing tables,
  where proof sits. Findings land as **structure** in the brief and the
  section-system plan — never as tokens or visual choices; looks stay gated at
  Movement 2. With no such MCP connected, proceed text-only and record the mode.
- **Movement 2 (Explore) gains the looks pull, fork-scoped.** *Greenfield fork:*
  one clause making explicit that the delegated `app-design-directions` Phase 1–2
  discipline **includes its Phase 0.5 visual-reference pass**. *Post-app fork (the
  subtle case):* the committed design language is never re-litigated — the scoped
  pull informs only the amplification round's variant axes (**hero treatment,
  section spectacle, motion posture**), and the guard is explicit: **the committed
  tokens are amplified, never replaced**. References feed the 2–3 variants; the
  variants still converge into the marketing section system per the skill's
  existing rules.
- **A marketing extraction vocabulary, owned by marketing-site.** The visual-
  reference file's six-item deconstruction is app-UI vocabulary (palette, type
  roles, density, layout, depth, signature devices). Marketing references extract
  into a complementary set: **section sequence actually used; hero treatment type
  (mapped to `references/hero-treatments.md`'s menu); CTA count and placement;
  proof placement; style stance**. This lives in a new skill-local reference —
  `skills/marketing-site/references/reference-research.md` — which also carries
  the movement scoping and the mechanics citations, so `app-design-directions`'
  file is never edited (ownership seam). The vocabulary is **movement-scoped**:
  the Discover pattern pull extracts the structure items only (section sequence,
  CTA count/placement, proof placement); hero treatment type and style stance
  belong to the Movement 2 looks pull alone.
- **Lineage persists in the marketing artifacts.** Each pull's reference URLs and
  extraction notes land in the marketing spec (Discover pull) and the variant
  specs (Explore pull) — the marketing analog of the app pipeline's decision-file
  lineage, satisfying the licensing stance (pointers and text persist, never
  images).
- **Detection stays generic, dependency stays soft.** The wording is "a connected
  design-reference MCP whose corpus includes marketing pages" — the known instance
  is named as an example with its capabilities (marketing-pages content type,
  Sections/Styles filters, the section-search verb) hedged as as-of-2026-07
  observations. The paid MCP is never a hard dependency: the ladder's
  user-supplied-screenshots and text-only rungs apply unchanged.
- **One live probe deferred to runtime.** Whether the connected MCP's search verbs
  reach the marketing-page corpus was not confirmable in the authoring session
  (the server was disconnected); the new reference instructs the first connected
  pull to probe and fall back one rung if the corpus isn't reachable — the skill
  text is mode-disclosing either way, so this affects guidance, not design.

## Seams owned up front

- `app-design-directions` keeps sole ownership of `visual-reference.md` and the
  app-UI pipeline; `marketing-site` owns only its marketing delta (scoping +
  extraction vocabulary) and cites the mechanics. No file outside
  `skills/marketing-site/` changes.
- `spec-feature`'s flow pull is untouched — its scope (product-feature flows) and
  the marketing pull's scope (marketing-page sections) don't overlap.
- The post-app guard sentence is the load-bearing seam with the skill's own
  "amplification, not re-litigation" rule: the pull must strengthen it, not open a
  side door to a redesign.

## Revisions from the adversarial plan pass

Five findings, all folded in before the PR opened:

- **"Verbatim in substance" was self-contradicting.** The post-app guard condition
  now requires both prohibitions as explicit clauses (wording may vary; neither
  may be implied only) instead of an unclosable verbatim-ish phrase.
- **The extraction vocabulary was not movement-scoped.** As drafted, a Discover
  pull extracting style stance would have satisfied the reference-file condition
  while gutting the structure-only rule; the vocabulary condition (and the
  Decision above) now split the items between the two movements.
- **Lineage had nowhere to live.** The cited licensing mechanics record lineage in
  the app pipeline's decision file, which marketing-site lacks; a builder could
  have satisfied every condition with extractions persisting nowhere. A lineage
  clause (and Decision) now lands URLs + extraction notes in the marketing spec
  and variant specs.
- **The diff-seam parenthetical split readers.** "(plus this spec's plan files
  already on `main`)" is now "plus at most plan-path (`specs/**`) hunks — the pin
  line and plan-pass revisions."
- **The approval date was written in UTC**, one day ahead of the user's clock;
  corrected to local.

## Milestone

`specs/milestones/marketing-reference-research.md` — one new skill-local reference
(`skills/marketing-site/references/reference-research.md`) + two scoped hooks in
`skills/marketing-site/SKILL.md` (Movement 1 pattern pull, Movement 2 fork-scoped
looks pull). No gates, guards, hooks, plugin-root references, or other skills move.
