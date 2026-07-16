# Conversion craft — the floor under the spectacle

The marketing surface's job is a conversion, and the craft below is what the ecosystem's
landing-page practice agrees on. **This floor flows into the authored milestones as
done-conditions, never advisory prose** — the skill's Movement 4 owns that rule; this
file owns the content.

## The section ladder

The canonical order, **pruned to the page's goal — the full ladder is not mandatory**:

```
hero → social proof strip → problem → solution / benefits → how it works
     → features → testimonials → pricing → FAQ → final CTA
```

Prune by goal: a waitlist page might be hero → problem → solution → final CTA; a
self-serve SaaS page usually earns pricing and FAQ; an enterprise page trades pricing
for a demo CTA and heavier proof. Every kept section has one job — if two adjacent
sections do the same job, cut one. The ladder orders sections; the marketing section
system (the skill's Movement 1) styles them.

## Awareness stage → copy framework

The brief's awareness stage picks the framework; don't mix them on one page:

| Audience arrives…                        | Framework | Shape |
|------------------------------------------|-----------|-------|
| **problem-aware** (feels the pain, doesn't know solutions) | **PAS**  | Problem → Agitate → Solve |
| **unaware** (doesn't yet feel the pain)   | **AIDA**  | Attention → Interest → Desire → Action |
| **solution-aware** (knows the category, comparing options) | **BAB**  | Before → After → Bridge |

Copy comes from the product's real vocabulary — the post-app fork's shipped feature
list, the greenfield fork's brand interview — never generic SaaS filler ("supercharge
your workflow" is the copy equivalent of AI-slop purple gradients).

## One primary CTA

One page, one primary call to action, repeated (hero + final, optionally mid-page) but
never competing — a secondary action, if it exists at all, is visually subordinate
(link-weight, not button-weight). Navigation on a landing page is minimal to absent;
every exit link is a leak.

## Performance budgets (Core Web Vitals)

These are conversion mechanics, not engineering vanity — encode them as `[auto]`/
`[runtime]` conditions on the authored milestones:

- **LCP < 2.5s** on a mid-range mobile profile — the hero (largest element) loads first;
  hero imagery is sized, modern-format, and preloaded.
- **CLS < 0.1** — every image and embed has explicit dimensions; fonts load without
  layout-shifting swaps.
- **~1MB total page weight** as the working budget — generated art is compressed at
  build time (the build milestone owns optimization); WebGL/video treatments must fit
  inside this budget or lazy-load behind a static poster.

## Meta + reduced motion

- **`og:image` + meta**: the page ships a generated/staged `og:image`, a real
  `<title>`/description, and correct social-card tags — the share card is part of the
  marketing surface, not an afterthought.
- **Reduced-motion pass**: every motion treatment (CSS, WebGL, video) respects
  `prefers-reduced-motion` with a designed static state — this is a named done-condition
  on any milestone that ships motion, and `references/hero-treatments.md` carries the
  per-treatment guardrails.
