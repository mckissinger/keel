---
name: logo
description: Design a product's brand mark and ship the versioned LOGO KIT — SVG masters per lockup (horizontal / stacked / icon) × colorway (color / mono / reversed), the favicon/PWA matrix, OG image and social avatar, a usage sheet, and a recorded font + license + trademark note — through an attended session of SVG-direct generation under parametric construction, iterated in a render-and-verify loop with the user art-directing. Ends on a plan PR carrying the kit under design/brand/ plus ONE authored integration milestone (favicon/manifest/OG wiring) built by the normal pipeline.
when_to_use: When the user wants a logo, brand mark, favicon set, or brand identity kit for their product — "design a logo," "we need a brand mark," "make us a favicon." NOT for the marketing page or site — that is marketing-site, which CONSUMES the committed kit rather than authoring the mark; NOT for the app's design system (palette, type, components) — that is app-design-directions, whose committed design.md this verb derives from when it exists; NOT generic image generation — this verb ships a versioned kit under design/brand/ plus an authored integration milestone with automatable quality gates, not a one-off picture.
---

# Logo

You are acting as the brand designer for a product's mark. The deliverable is a
**plan the normal pipeline builds**: the logo kit — SVG masters, the favicon/PWA
matrix, OG image and social avatar, a manifest with usage sheet and legal note —
committed under `design/brand/`, plus **ONE authored integration milestone spec**
(favicon/manifest/OG wiring) built through `implement-milestone` →
`verify-milestone` as usual. Never product code written in this session.

The core technique is **SVG-direct generation under parametric construction**,
iterated through a **render-and-verify loop** — render the SVG, inspect the
raster, revise — with the user art-directing every shortlist. The craft floor
(construction rules, anti-slop bans, quality gates, deliverable matrix, font and
legal rules) lives in `references/logo-craft.md`, cited at each point of use
below and never restated.

This verb is deliberately **model-invocable** (no `disable-model-invocation`):
its output is plan-only in the repo it runs in — specs and design artifacts on a
branch, ending on a plan PR — and the only spend it can incur is the optional,
attended image-model concept stage in Movement 2, which is off by default and
offered, never assumed. So "design us a logo" routes here without a
human-trigger gate.

## The workflow at a glance

```
1 DISCOVER  → which fork (post-app / brand-first), palette + type lineage,
              brand personality → brief, confirmed before anything visual
2 CONCEPTS  → 3–5 parametric concepts via parallel subagents, self-reviewed
              through the render-and-verify loop, user shortlists
              (optional, off-by-default: attended image-model concept round)
3 ITERATE   → attended art direction on the winner — multiple rounds, expected
4 KIT       → deliverable matrix + manifest under design/brand/, ONE authored
              integration milestone with the [auto] quality gates → plan PR
```

## Movement 1 — Discover

**Pick the fork.** Two contexts, one skill — the dual fork mirrors
`marketing-site`'s:

- **Post-app fork (the primary posture).** The app exists and carries a
  committed `specs/design.md`. **Derive the palette and type lineage from it** —
  the mark and the product must read as one brand, so the kit's colorways come
  from the committed tokens and any wordmark's type descends from the committed
  type family's lineage (the font rule in `references/logo-craft.md` still
  governs licensing and outlining).
- **Brand-first / greenfield fork (secondary).** No committed design system yet.
  The session's brand decisions — palette values, type direction, the mark's
  construction language — are **recorded in the kit manifest so a later
  `design.md` inherits them** instead of contradicting them. The logo leads;
  the design system follows.

**Consume positioning when it exists.** When the repo carries `specs/gtm/`
(authored by `gtm`), the committed positioning informs **brand personality** —
audience, category, tone — consumed, never required; with no `specs/gtm/`,
interview the personality directly in the brief.

**Confirm the brief before anything visual.** Product, audience, personality,
fork, palette/type source, and the mark's job (where it must live: favicon,
header, OG card, app icon). A wrong brief poisons every concept downstream —
confirm it with the user first.

## Movement 2 — Concepts

**Fan out 3–5 concepts via parallel subagents.** Each subagent builds one
concept by **parametric construction** — the mark is computed from a
construction grid (circle geometry, strokes on unit multiples, flat color),
never freehand organic paths — under the construction rules and anti-slop bans
of `references/logo-craft.md`, cited to each subagent, never restated.

**Self-review through the render-and-verify loop before showing.** Each concept
is rendered to raster via the contact-sheet script (seed the project's copy from
`templates/render-contact-sheet.mjs`), inspected against the three quality gates
in `references/logo-craft.md` — 16px legibility, monochrome survival, dark/light
reversal — and revised until it survives. Only surviving concepts reach the
user, who **shortlists**; a concept the loop already killed is noise, not a
choice.

**The optional image-model concept round — off-by-default attended spend.**
Offer it; never assume it. When the user takes the offer, it runs through the
committed asset-generation script path whose mechanics live in
`${CLAUDE_PLUGIN_ROOT}/skills/marketing-site/references/asset-pipeline.md`
(cited, not restated): a committed, provider-pluggable project script, the API
key asserted **by name only** via the recorded name-check command, spend
attended while the user judges. Image-model concepts are **direction-pickers
only**: the winner is **rebuilt as clean SVG under parametric construction —
never auto-traced** into the deliverable (auto-tracing produces the anchor-point
bloat the craft reference bans). No image-model provider is ever required.

## Movement 3 — Iterate

Attended art direction on the shortlisted winner: adjust the construction
parameters — grid proportions, stroke weight, counter shapes, colorway — render
through the same render-and-verify loop, judge with the user, repeat. **Set the
expectation up front that real convergence takes multiple rounds** — a mark that
looks done after one pass usually reads as generic after three; the loop is
cheap, so spend rounds until the user calls it, not until the session tires.

## Movement 4 — Kit

**Assemble the deliverable matrix and manifest.** Build the full matrix —
lockups × colorways as SVG masters, the favicon/PWA set, OG image, social
avatar, per the deliverable matrix and naming convention in
`references/logo-craft.md` — and author the manifest from
`templates/brand-kit-manifest.md`: mark rationale, inventory, font + license,
palette lineage, usage sheet, and the legal note the craft reference carries
verbatim. **Commit the kit under `design/brand/`.**

**Author ONE integration milestone spec.** Favicon/manifest/OG wiring into the
app, built by the normal pipeline (`implement-milestone` → `verify-milestone`)
under the shared rules (`${CLAUDE_PLUGIN_ROOT}/references/milestones-and-verification.md`,
cited not restated). Its done-conditions **carry the three quality gates tagged
`[auto]`** — 16px legibility, monochrome survival, dark/light reversal — checked
against the committed contact-sheet script (the project's copy of
`templates/render-contact-sheet.mjs`), so the gates ride as conditions, not
advisory prose.

**The session ends attended, on the plan PR**: `specs/**` + `design/**` only —
the kit under `design/brand/`, the manifest, and the integration milestone spec.
Build and pin run through the normal pipeline.

## Where this sits

```
app-design-directions   the app's design system, once            (product UI)
spec-feature            one feature's screens against it         (product UI)
marketing-site          the public face — page or site           (marketing surface)
logo                    the brand mark + versioned kit both consume   ← here
```
