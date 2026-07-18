# Brand collateral beyond the mark

**Parked 2026-07-18** by the logo feature spec (`specs/features/logo.md`), at the point
the verb's scope settled on the mark and its kit alone. Brand collateral beyond the
logo kit — pitch decks, business cards, social banners, event assets, a hosted brand
guidelines site — is deferred.

**What it would buy.** A full brand-asset surface: every place the mark appears outside
the product and its marketing site would draw from committed, on-brand templates instead
of ad-hoc recreations, and a guidelines site would give external parties (press,
partners, print shops) a canonical reference without repo access.

**Why deferred, not built now.** `logo` owns the mark and its versioned kit —
SVG masters, the favicon/PWA matrix, OG image and avatar, the usage sheet — because
that is the surface the product and `marketing-site` consume directly; collateral is a
different deliverable class with different consumers (sales, events, press, print) and
mostly non-SVG, layout-heavy formats the render-and-verify loop isn't tuned for.
Folding it in would balloon the deliverable matrix and the quality gates before the kit
itself is proven in downstream use. **Risk of deferring:** low — the usage sheet
already states the rules (clear space, minimum sizes, colorway selection), so anyone
producing collateral by hand has the constraints in writing; the worst case is a deck
or card that drifts from the sheet and gets corrected against it.

**Reopen condition (trigger).** Real demand proves the need: collateral requests recur
against the kit's limits — a deck, card, or banner is hand-built from the masters more
than once, or an external party needs guidelines without repo access — at which point
brand collateral is specced as its own feature (its own deliverable matrix and
templates, consuming the committed kit under `design/brand/`), not widened into this
verb's kit scope.
