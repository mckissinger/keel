# Visual Reference: references before directions, deconstruction before pixels

## Why this file exists

Phase 1 directions derived from prose alone — the brief, the domain artifacts, the model's
imagination — hit a text-only ceiling: the output converges on what the model would draw for
*any* app in the category. Visual reference supplies the out-of-distribution specificity prose
cannot. But the reference is raw material, not the deliverable: **raw screenshots without a
deconstruction step produce generic paraphrases** — the model describes what it saw in its own
default vocabulary and the specificity evaporates. The pipeline below is therefore two moves,
never one: pull a generous, diverse reference set, then extract each kept reference into the
direction-spec vocabulary *before* any Phase 1 direction is specced. The extraction, not the
image, is what the direction consumes.

## The source ladder

Run down this ladder and use the highest rung available. **Tell the user which mode ran** — the
reference mode shapes how much weight the directions' specificity can bear, and the user should
know whether the directions were fed by shipped-product screens, their own images, or prose
alone.

1. **A connected design-reference MCP.** Mobbin is the known instance — a library of shipped
   product screens exposed through three search verbs: screens (`search_screens`), flows
   (`search_flows`), and sections (`search_sections`). Detection is generic, not Mobbin-specific:
   any connected MCP whose tools search a corpus of product-design screenshots by query
   qualifies as this rung. If such a server is connected, use it.
2. **User-supplied screenshots or image batches.** No design-reference MCP connected, but the
   user has (or can gather) reference images — a Dribbble batch, competitor screenshots, apps
   they admire. Ask for them at Phase 0.5 and run the same deconstruction pass over what they
   provide.
3. **Text-only derivation.** Neither of the above. Fall back to the existing prose pipeline —
   the discovery brief, the domain's own artifacts, `direction-recipes.md` — exactly as before.
   This rung is the floor, not a failure; the skill must work with no MCP and no images, because
   keel is a plugin others install and a paid service can never be a hard dependency.

## The generous-volume rule

When a reference source is available, pull **wide**: multiple queries spanning the app's screen
archetypes (from the Phase 0 screen inventory — the dense table, the detail view, the dashboard,
the form, whatever this app actually has), on the order of **10–20+ diverse screens**, plus
flow-level pulls where a user journey matters (onboarding, a create flow, a checkout). Do
**not** cap the pull small to save context — context cost is handled by delegation (below), not
by starving the reference set. A thin reference set reproduces the text-only ceiling with extra
steps.

## Subagent delegation

The pull **and** the deconstruction run in a **subagent**, which returns only the distilled
extractions plus the chosen reference URLs. The main (attended) session never consumes the raw
screenshot volume — that is what makes the generous-volume rule affordable. The subagent's
contract: query the source across the archetypes, keep the strongest and most diverse
references, deconstruct each kept reference (next section), and hand back the extractions +
URLs as compact text.

## The mandatory deconstruction pass

Every kept reference is extracted into the direction-spec vocabulary **before any Phase 1
direction is specced**. At minimum, per reference:

- **Palette** — the actual working colors and their jobs (surface, ink, accent, semantic).
- **Type roles** — display/UI/data faces, how hierarchy is carried.
- **Density** — rows-per-viewport, padding scale, how much air.
- **Layout architecture** — nav pattern, screen composition, how the page is regioned.
- **Depth grammar** — borders vs. shadows vs. flat, and the consistency of the recipe.
- **Candidate signature devices** — the one or two ownable moves this reference makes that
  could seed a direction's signature element.

This pass is not optional when references exist. A direction may then cite the extractions it
draws from; it never cites a raw image as its spec.

## The diversity requirement

The kept reference set must span **visibly different looks** — different density stances,
different depth grammars, different type systems — not one style pulled ten times. A
same-looking reference set collapses Phase 1 back to a single direction wearing five names. If
the pull came back homogeneous, query again along different axes before deconstructing.

## Licensing stance

References are **queried at runtime or supplied by the user — never bundled**. No reference
image is committed into the keel plugin, and none is committed into a project repo as an image
file. What persists is text: the extractions and the reference URLs (recorded as lineage in the
Phase 3 decision file). The reference corpus belongs to its source; keel stores pointers and
deconstructions, not copies.

## Inspiration, not transplant

A reference-derived direction is still a **direction** — it must pass the anti-slop check
(`anti-slop.md`) and the distinctness test exactly like a prose-derived one. A reference is raw
material for a choice specific to *this* app, not a license to transplant a look wholesale;
"make it look like this screenshot" is a user brief to execute, but absent that brief, a
direction that merely re-skins one reference has skipped the derivation step the engagement is
paid for.
