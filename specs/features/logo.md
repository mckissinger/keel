# Feature — logo: the brand-mark verb (SVG-direct logo kit)

**Goal:** keel gains a `logo` verb — an attended, model-invocable session in the
Marketing band (sibling of `marketing-site` / `product-video`) that designs a
product's logo and ships the **logo kit**: SVG masters per lockup (horizontal /
stacked / icon-only) × colorway (full color / monochrome / reversed), the favicon/PWA
matrix, an OG image and social avatar, a usage sheet, and a recorded font + license +
trademark note. The core technique is **SVG-direct generation under parametric
construction** (the mark is computed from a construction grid — circle geometry,
unit-multiple strokes, flat color — never freehand paths) iterated through a
**render-and-verify loop** (render the SVG, inspect the raster with vision, revise)
with the user art-directing the shortlist. The session ends on a **plan PR in the
product's repo** carrying the kit under `design/brand/` plus ONE authored integration
milestone (favicons/manifest/OG wired into the app through the normal pipeline).
Three objective quality gates ride as `[auto]`-checkable conditions: **16px
legibility, monochrome survival, dark/light reversal.**

**Why now (evidence):** `marketing-site` has no upstream source for the brand mark —
its hero, header, favicon, and OG all improvise one today. The 2026-07-18 research
pass (session-recorded, subagent web sweep) found: SVG-direct with render-and-verify
is the dominant credible agent pattern (every circulating Claude Code logo skill is
SVG-direct); auto-tracing diffusion output produces anchor-point bloat (the
image→vectorize pipeline is the path to avoid); practitioners who use image models
treat them as concept explorers whose winner is **rebuilt** as clean vector; real
convergence takes 6–17 attended iterations; the three quality gates above are the
industry heuristics and are fully automatable; AI-generated marks are
trademark-registrable but **not copyrightable** (Thaler v. Perlmutter affirmed;
SCOTUS declined cert 2026-03), so the kit must carry the clearance/human-modification
caution; SIL-OFL fonts are logo-cleared with text converted to outlines. keel's
differentiator over the prior art is the verification story: quality gates as
done-conditions, kit as committed design artifacts, integration through the pin gate.

**No-UI feature** (the deliverable is skill prose, references, templates, wiring) →
two-dimension done-conditions; the design track is skipped. The *skill it ships*
produces visual artifacts, but their aesthetic gate is in-session art direction by
the user — recorded in the skill's own contract, not a keel-repo redline.

**flow research:** ran — web research via delegated subagent (technique landscape,
practitioner workflows, prior-art Claude Code logo skills, quality heuristics,
licensing, deliverable conventions). Findings that became done-conditions: SVG-direct
core + parametric construction; render-and-verify loop; the three automatable quality
gates; concept fan-out via parallel subagents then human shortlist; deliverable
matrix + naming convention; favicon/PWA minimal set; OFL-fonts-outlined rule;
copyright/trademark caution. Key sources: simonwillison.net (SVG benchmark),
neonwatty.com/posts/logo-designer-skill-claude-code (closest prior art),
evilmartians.com (favicon matrix), openfontlicense.org, stemerlaw.com /
tish.law (Thaler + trademark posture as of 2026).

**Interview record (decided 2026-07-18, this session):** **Scope: logo kit** — the
mark and its mechanical derivatives only; brand collateral beyond the mark (decks,
cards, banners, a guidelines site) is a recorded deferral. **Verb name `logo`**, in
the Marketing band. **SVG-direct is the core; the image-model concept round is an
optional, off-by-default attended-spend stage** — offered like `marketing-site`'s
video offer, run through the committed asset-generation script path (key asserted by
name only), concepts are direction-pickers whose winner is rebuilt as clean SVG,
never auto-traced into the deliverable; no provider is ever required. **Kit +
integration milestone**: the session authors ONE milestone spec (favicon/manifest/OG
wiring) built by the normal pipeline; the kit itself commits with the plan PR under
`design/brand/`. **Dual fork** mirroring `marketing-site`: post-app (derive palette +
type lineage from committed `specs/design.md`; mark and product read as one brand)
and brand-first/greenfield (the session's brand decisions are recorded so a later
`design.md` inherits them). When `specs/gtm/` exists, positioning informs brand
personality — consumed, never required. **Model-invocable** (no
`disable-model-invocation`): plan-only output in the repo it runs in; the only spend
is the optional attended concept stage. **Quality gates as conditions**: the
integration milestone the skill authors carries the 16px / monochrome / reversal
gates tagged `[auto]` against a committed contact-sheet render script. Wordmarks use
OFL (or license-verified) fonts with text converted to outlines; font name + license
recorded in the kit manifest. The kit manifest carries the
trademark-registrable / not-copyrightable note verbatim from the craft reference.

## Milestones (file→milestone ownership map; no routes — no UI)

| Unit | Milestone | Owns |
|---|---|---|
| Skill + craft | `logo-m1-skill-craft` | new `skills/logo/SKILL.md`; new `skills/logo/references/logo-craft.md`; new `skills/logo/templates/brand-kit-manifest.md`, `skills/logo/templates/render-contact-sheet.mjs` |
| Wiring | `logo-m2-wiring` | `README.md` (Marketing-band ladder line for `logo`, skills-list bullet, count 28 → 29); `scripts/session-bootstrap.sh` (both banner copies) + `scripts/session-bootstrap.test.sh` (assertion); one routing sentence in `skills/marketing-site/SKILL.md`; new skill-eval fixtures `scripts/skill-eval/fixtures/g7-*.json`; new `specs/deferrals/logo-brand-collateral.md` |

**Build order + integration seams:** sequential **m1 → m2**. m2's routing sentence
and fixtures cite m1's skill. m1 creates only new files; every shared-file edit
(README, bootstrap + test, `marketing-site`) is owned by m2 alone — no two milestones
touch a shared file. The `marketing-site` seam is one added sentence — Discover
consumes the committed logo kit (`design/brand/`) when it exists rather than
improvising a mark — and must not change that skill's scope. The optional concept
stage **cites** `marketing-site`'s asset-generation mechanics
(`skills/marketing-site/references/asset-pipeline.md`) rather than restating them —
if that cross-skill citation proves wrong at build time (plugin-root vs skill-local
resolution), the builder surfaces it rather than duplicating the reference.
Neutrality: no image-model vendor, font foundry, or rendering tool named as required
— hedged as-of-2026-07 examples; `check-neutral.sh` scans `references/` and `skills/`
and the prose must pass as written.

**Parallelizable:** no (sequential, above).

## Lifecycle

- **Interview + synthesis sign-off:** 2026-07-18, this session (attended; scope /
  concepting / integration resolved; research summarized in-session; signed off
  "stick with your original plan").
- **Composition/redline gate:** not applicable — no-UI feature.
- **Plan PR:** opened at the end of this session (plan-only: `specs/**`); number
  recorded in the PR once open.
- **Per-milestone build + pin:** state derives from
  `specs/milestones/logo-m1-skill-craft.md` and `specs/milestones/logo-m2-wiring.md`.
- **Post-wave reconciliation:** `land-feature` reconciles `README.md` and this spec
  when the wave lands.
- **review-feature:** not applicable — no-UI feature; the acceptance gate is each
  milestone's verifier pass plus first dogfood (a real `logo` session on a product
  repo, kit committed and integration milestone built), findings routed back as
  spec-changes.
