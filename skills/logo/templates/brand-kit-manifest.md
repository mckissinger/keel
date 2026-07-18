# Brand kit — <product>

<!-- Authored by a logo session. Lands as design/brand/MANIFEST.md in the plan
     PR, beside the SVG masters and derivatives it inventories. This file is the
     kit's system of record: what the mark means, what files exist, what font
     and license they embed, where the palette came from, and the legal posture.
     The craft rules it satisfies live in the logo skill's
     references/logo-craft.md — cited, never restated here. -->

## Product + mark rationale

<!-- One paragraph: the product, and why THIS mark — what the geometry traces to
     in the brief. An invented example: *Ledgerline*'s mark is two ledger rules
     converging into a checkmark, on a 24-unit grid, strokes at 2 and 4 units —
     "books that close themselves." Record the construction parameters (grid,
     stroke units, radii) so a later session can recompute the mark, not
     redraw it. -->

## Inventory — lockups × colorways

<!-- One row per SVG master, filenames per the craft reference's naming
     convention: <product>-logo-<lockup>-<colorway>.svg. A missing cell of the
     matrix records WHY in its row — never silently. -->

| Lockup     | Color | Mono | Reversed |
|------------|-------|------|----------|
| Horizontal | `<product>-logo-horizontal-color.svg` | `<product>-logo-horizontal-mono.svg` | `<product>-logo-horizontal-reversed.svg` |
| Stacked    | `<product>-logo-stacked-color.svg` | `<product>-logo-stacked-mono.svg` | `<product>-logo-stacked-reversed.svg` |
| Icon       | `<product>-logo-icon-color.svg` | `<product>-logo-icon-mono.svg` | `<product>-logo-icon-reversed.svg` |

### Derivatives — favicon/PWA set, OG, avatar

<!-- The mechanical derivatives, per the craft reference's minimal set. List
     each file with its size and any rule it obeys (apple-touch opaque; the
     512 maskable's central-safe-zone rule). -->

| File | Size | Note |
|------|------|------|
| `favicon.ico` | 32×32 | |
| `favicon.svg` | scalable | |
| `apple-touch-icon.png` | 180×180 | opaque background |
| `icon-192.png` | 192×192 | |
| `icon-512.png` | 512×512 | |
| `icon-512-maskable.png` | 512×512 | mark inside the central safe zone |
| `og-image.png` | 1200×630 | |
| `avatar.png` | square | social avatar, icon lockup |

## Font + license

<!-- The wordmark's font NAME and LICENSE (OFL, or the verified license naming
     logo use), per the craft reference's font rule. Text in the masters is
     converted to outlines; this section is where the provenance survives. -->

- Font:
- License:
- Outlined in masters: yes

## Palette

<!-- The colorway values. POST-APP fork: record each value's lineage to the
     committed specs/design.md token it derives from — mark and product read as
     one brand. BRAND-FIRST fork: these values are the brand decisions a later
     design.md INHERITS — record them as the future system's source of truth. -->

| Role | Value | Lineage (design.md token, or "brand-first — design.md inherits") |
|------|-------|------------------------------------------------------------------|
| Primary |  |  |
| Ground (light) |  |  |
| Ground (dark) |  |  |

## Usage sheet

<!-- The don'ts are bans for every downstream surface, including marketing-site
     when it consumes this kit. -->

- **Clear space:** <!-- e.g. one grid-unit multiple of the icon's height on all
     sides — state it in the mark's own units. -->
- **Minimum size:** <!-- the smallest rendering allowed per lockup — the icon's
     floor is 16px (it passed the gate there); wordmark lockups need more. -->
- **Don'ts:** <!-- e.g. no recoloring outside the colorways above, no
     stretching, no drop shadows or added gradients, no placing the standard
     colorway on a dark ground (use reversed), no re-typesetting the wordmark. -->

## Legal note

<!-- Carried VERBATIM from the logo skill's references/logo-craft.md §6 — paste
     the blockquote unchanged. -->

> **Legal posture (as of 2026):** An AI-generated mark can be registered as a
> trademark (registrability turns on use in commerce and distinctiveness, not
> authorship) but is **not copyrightable** — the Thaler line of cases holds
> that copyright requires human authorship. Before adopting this mark: run a
> trademark clearance search in your jurisdictions and classes, and add human
> modification to the mark so the shipped version carries human authorship.
> This note is a caution recorded by the design session, not legal advice.
