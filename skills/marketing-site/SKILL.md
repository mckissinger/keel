---
name: marketing-site
description: Produce the marketing surface for a product — ONE landing page or a FULL marketing website — usually after the app is built. Reads the specs and the committed design system, screenshots the shipped product, explores 2–3 amplification variants (hero treatment is the main axis), generates hero/marketing assets through a committed script while the user watches, then authors the milestone specs that build the surface through the normal pipeline. A greenfield fork covers a marketing site with no app behind it.
when_to_use: When the user wants a landing page, marketing site, promo page, or public website for their product — "build me a landing page," "we need a marketing site," "make the homepage." Covers BOTH grains — a single landing page and a full multi-page marketing site — the grain is decided in Discover, not by picking a different verb. Primary posture is post-app (the common case — the shipped app and its design system are the raw material); greenfield with no codebase is the secondary fork. NOT for product UI — the app's design system is app-design-directions, and per-feature app screens are spec-feature.
---

# Marketing Site

You are acting as the design-and-conversion lead for a product's public face. The deliverable is a **plan the normal pipeline builds**: a chosen visual direction (with the user's sign-off), the generated assets that direction needs, and authored milestone specs — never product code written in this session.

This is the sibling of `app-design-directions`, on the other side of its scoping line: that skill owns **product UI** (screens users work inside, where clarity and density beat spectacle); this one owns the **marketing surface**, where spectacle is the job — but spectacle with a conversion floor under it, not decoration. The marketing surface is **web regardless of the app's platform**: a mobile app still gets a web marketing site; when no web app exists to host it, the standalone scaffold below is the vehicle.

Two boundaries, stated once: `spec-feature` owns per-feature screen design against the app workbench; `marketing-site` owns the marketing surface end-to-end — its **marketing section system** (below) is the workbench-equivalent that its authored milestones' fidelity conditions name — so neither verb absorbs the other. And this verb is deliberately **model-invocable** (no `disable-model-invocation`): it reads only the project it runs in, and the only spend it can incur — asset generation — is an attended, in-session step, so "build me a landing page" routes here without a human-trigger gate.

## The workflow at a glance

```
1 DISCOVER  → which fork (post-app / greenfield), which grain (page / site),
              audience + awareness stage + conversion goal → marketing brief, confirmed
2 EXPLORE   → 2–3 throwaway variants (hero treatment is the main axis),
              screenshot self-review, user picks
3 ASSETS    → generate + judge hero/marketing art live (attended spend),
              chosen assets become design artifacts
4 AUTHOR    → marketing spec + milestone spec(s) per the shared rules → plan PR
              → build via implement-milestone → verify-milestone; review-feature judges
```

The governing principle is `app-design-directions`' own: **diverge cheap, converge real.** Variants are throwaway; the built surface converges on real components against the marketing section system, and *that* is the fidelity reference — never a re-implemented mockup.

## Movement 1 — Discover

**Pick the fork.** Two contexts, one skill:

- **Post-app fork (the primary posture).** The app exists and was built through keel. Read `specs/` — the product skeleton, the shipped feature list, `specs/design.md` — and **screenshot the running app** (boot it per the stack profile; capture the 2–3 load-bearing screens). The shipped product is the raw material: feature copy comes from what actually shipped, not aspirations, and **staged real product shots** join the hero-treatment menu as its strongest option for a working product. The marketing section system **derives from the app workbench's tokens** — same palette, same type family lineage, amplified scale — so product and marketing read as one brand. Placement defaults to a **`(marketing)` route group inside the same app** (shared tokens, one deploy); a standalone site only if the user asks or no web app exists.
- **Greenfield fork (secondary).** No codebase. Do not re-own scaffolding: **delegate to the kickoff verbs in a marketing-scoped posture** — a **compressed brand interview stands in for the product interview** (what the product is, who it's for, taste references, brand constraints), and `spec-foundation` runs skinny: the posture **skips** the feature backlog, the data-model depth, and the app screen inventory (there is no app), keeping the architecture note, the environment contract, and the process wiring. The output is a **keel-managed project** — minimal web stack, lightweight `specs/` — whose `design.md` records the brand decisions, so the normal build/verify verbs run here and a future app **inherits the brand** instead of contradicting it.

**Decide the grain.** One landing page, or a full marketing site (home / pricing / about / contact / legal / …)? Ask; don't assume. Either way the plan establishes a **marketing section system** first — tokens, an amplified type scale, and named section primitives (hero, feature band, proof strip, pricing table, FAQ, footer) — **recorded in the marketing spec the plan PR carries**. Both grains compose pages from it, which is why "upgrade the landing page to a full site" later is composition, never a redesign.

**Interview the conversion delta, not the whole product.** What's the page's one job (signups? demos? installs?), who arrives, and at what **awareness stage** — the stage picks the copy framework (`references/conversion-craft.md` owns the mapping). Write the findings into the brief using `templates/marketing-brief.md` (product, audience, awareness stage, conversion goal, grain, brand/token source) and confirm it with the user before anything visual — a wrong brief poisons every movement downstream.

## Movement 2 — Explore

- **Post-app fork: an amplification round, not a from-scratch one.** The design language is already decided — do not re-litigate it. Build **2–3 throwaway variants of the committed design language at marketing spectacle**, differing mainly in **hero treatment** (the menu and its guardrails live in `references/hero-treatments.md`) and tone. One `templates/variant-spec.md` per variant keeps the divergence honest.
- **Greenfield fork: a compressed from-scratch direction round** — the `app-design-directions` Phase 1–2 discipline at one-screen scale: distinct directions, real copy from the brief, anti-slop bar.

Either way: variants are **self-contained throwaway mockups under `design/marketing/variants/`** — divergence sketches in the shared rules' sense, screenshot **self-reviewed before showing** (judged on look, at both a phone and a desktop width), then put side-by-side for the user to pick or hybridize. **They are never re-implemented as the spec** — the moment the user picks, the direction converges into the marketing section system, and that system (not the mockup) is what the authored milestones reference.

## Movement 3 — Assets (attended spend)

Marketing pages need art the codebase doesn't have: hero imagery, background plates, an `og:image`. Generate it **now, in the attended session, while the user is watching** — never leave it to an unattended build that discovers taste problems a review round later.

The mechanics live in `references/asset-pipeline.md`; the spine: generation runs through a **committed, provider-pluggable project script** (seed it from `templates/generate-asset.mjs`); the API key travels the **provision-miniature / environment-contract path** and is asserted **by name only** via the project's recorded name-check command — values never read, never pasted. Generate candidates, judge them with the user, iterate cheaply (images cost cents); **chosen assets commit with the plan PR under `design/marketing/`** as design artifacts, and the build milestone owns optimizing them into the app (`public/`-equivalent, dimensions, formats). Video is an **optional attended offer, off by default** — and that offer is generative hero video only; product walkthrough, demo, and onboarding video is `product-video`'s verb, so route there. Under an active autonomy mode, asset generation is a **planned stop point** unless the run's pre-authorized envelope covers it — never silent spend.

## Movement 4 — Author the plan

Author like `spec-change`/`spec-feature` — the shared rules (`${CLAUDE_PLUGIN_ROOT}/references/milestones-and-verification.md`) apply **unchanged**, cited not restated: every done-condition tagged, all applicable dimensions covered, verification named, the plan pass run before the PR opens.

- **The marketing spec** records the brief, the chosen direction, the marketing section system (its tokens and named primitives), the page/section map, and the asset inventory.
- **Milestone fan-out:** a landing page is **one milestone**; a full site is **typically two** (section system + home, then the remaining pages); **three-plus means the work outgrew this verb — stop and use `spec-feature`.**
- **Fidelity conditions name the marketing section system** as their reference (§6 of the shared rules — the workbench-equivalent here). For the post-app fork that chain runs unbroken back to the app workbench's tokens.
- **The conversion-craft floor lands as done-conditions, not advisory prose**: the authored milestones carry the floor from `references/conversion-craft.md` — the pruned section ladder, the awareness-matched copy framework, one primary CTA, the Core Web Vitals budgets, `og:image` + meta, the reduced-motion pass — as checkable conditions with the usual tags.
- **The session ends attended, on the plan PR**: `specs/**` + `design/**` only — the marketing spec, the milestone spec(s), the variant sketches, the chosen assets. Build and pin run through `implement-milestone` → `verify-milestone` as usual, and `review-feature` remains the aesthetic gate on the built surface.

## Where this sits

```
app-design-directions   the app's design system, once           (product UI)
spec-feature            one feature's screens against it        (product UI)
marketing-site          the public face — page or site          ← here (usually post-app)
```
