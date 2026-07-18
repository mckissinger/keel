# Logo craft — the floor, as rules

The single source of truth for **how a keel logo session constructs, judges, and
ships a mark** — the skill body cites these rules at point of use and never
restates them. Every rule below exists because the 2026-07 research pass found
the same failure fingerprints across agent-generated marks: freehand paths that
fall apart at small sizes, gradient-heavy generic marks, auto-traced diffusion
output with unusable anchor-point bloat, and kits shipped with unlicensed fonts
and no legal posture. Rules, not advice: a session that violates one is
malformed, however good the mark looks in one rendering.

## 1. Parametric construction

**The mark is computed, never drawn freehand.** Every shape derives from a
construction grid: positions and dimensions on grid units, curves from circle
geometry (full circles, arcs, and their intersections — not hand-placed bezier
handles), stroke weights on unit multiples of a single base stroke, flat color
per shape. A mark whose geometry cannot be stated as parameters — "24-unit grid,
mark occupies 20×20, strokes at 2 and 4 units, corner radii at 2" — is freehand
and fails this rule. Parametric construction is what makes the render-and-verify
loop converge: a revision is a parameter change, not a redraw, and optical
corrections (overshoot, stroke tapering at joins) are deliberate, recorded
exceptions to the grid — never its absence.

## 2. Anti-slop bans

Each of these is a ban, not a caution:

- **No gradient-defaulting.** The indigo/purple-gradient fingerprint — a
  blue-to-purple (or teal-to-violet) gradient fill on an abstract shape — is the
  single most recognizable mark of generated slop. Flat color per shape;
  a gradient may appear only as a deliberate, user-directed choice that also
  survives the monochrome gate below.
- **No generic swoosh or abstract-blob marks.** A curved swoosh, an orbiting
  ellipse, an amorphous blob, interlocking abstract ribbons — any mark whose
  shape says nothing about this product fails. The mark's geometry must trace to
  the brief.
- **No default-font wordmarks.** A wordmark set in a stack default or
  ubiquitous system font, unmodified, is not a wordmark — type choice follows
  the font rule (§5), and the letterforms get at least one deliberate
  modification (a cut, a ligature, a terminal) that ties them to the mark.
- **No elements distinguished only by color.** If two elements of the mark read
  as identical once color is removed, the mark fails — it cannot survive the
  monochrome gate, and it excludes color-blind viewers. Distinction comes from
  shape, weight, or spacing first; color amplifies, never carries.

## 3. The three quality gates

Objective, automatable, and non-negotiable — every concept passes all three
before the user ever sees it, and they **ride as `[auto]` done-conditions in the
integration milestone the session authors**, checked against the committed
contact-sheet script (the project's copy of the logo skill's
`templates/render-contact-sheet.mjs`):

1. **Legible at 16px.** On the contact sheet's 16/32/64px favicon strip, the
   icon lockup at 16px still reads as the mark — distinct silhouette, no
   collapsed counters, no strokes merging into mud. Pass bar: a viewer who
   knows the mark identifies it at 16px without the larger sizes beside it.
2. **Survives pure monochrome.** Forced to a single color — every fill and
   stroke the same black — the mark keeps its identity. Pass bar: nothing
   disappears, nothing merges, no element pair becomes indistinguishable.
3. **Survives dark/light reversal.** The reversed colorway on a dark ground and
   the standard colorway on a light ground both hold. Pass bar: no halo, no
   vanishing element, no weight collapse in either polarity.

## 4. Deliverable matrix + naming convention

The kit is a **matrix, not a file**: lockups (**horizontal / stacked / icon**) ×
colorways (**color / mono / reversed**) as SVG masters, named

```
<product>-logo-<lockup>-<colorway>.svg      e.g. ledgerline-logo-icon-mono.svg
```

plus the mechanical derivatives:

- **Favicon/PWA minimal set** — ICO at 32px, SVG favicon, apple-touch 180×180
  (opaque background — no transparency), 192×192 and 512×512 PNG, and a 512×512
  **maskable** variant obeying the central-safe-zone rule (the mark inside the
  central 80% circle, so platform masks never crop it).
- **OG image** — 1200×630.
- **Social avatar** — one square raster of the icon lockup.

Every filename in the kit follows the convention; the manifest inventories all
of them. A kit missing a cell of the matrix records why in the manifest — never
silently.

## 5. The font rule

Wordmark fonts are **OFL-licensed or explicitly license-verified for logo use**
— many commercial font licenses exclude or separately price logo/trademark use,
so "we have a web license" is not verification. In the SVG masters, **text is
converted to outlines** — a master that depends on a font being installed is
not a master. The **font name and license are recorded in the kit manifest**,
so the provenance survives the session that knew it.

## 6. Legal note — verbatim for the manifest

The kit manifest carries this note verbatim:

> **Legal posture (as of 2026):** An AI-generated mark can be registered as a
> trademark (registrability turns on use in commerce and distinctiveness, not
> authorship) but is **not copyrightable** — the Thaler line of cases holds
> that copyright requires human authorship. Before adopting this mark: run a
> trademark clearance search in your jurisdictions and classes, and add human
> modification to the mark so the shipped version carries human authorship.
> This note is a caution recorded by the design session, not legal advice.
