# Change — marketing-site

One milestone, prose + skill assets (one new skill with references/templates, ladder
wiring, one routing sentence). Approved by Michael 2026-07-16 after an inline research
round (ecosystem skills, image/video API posture, WebGL hero patterns) and a four-question
mini-interview — all four resolved on the recommended option: name `marketing-site`,
build through the normal milestone pipeline, assets generated in the attended session,
greenfield output keel-managed.

## Why

Every keel-built app eventually needs a marketing surface, and keel has no verb for it.
`app-design-directions` explicitly scopes itself out ("This skill is for **product
UI** …, not marketing pages"), so today a landing page is either improvised outside the process (no spec, no
pin, no fidelity chain to the app's design system) or forced through `spec-feature`,
which interviews for product screens and knows nothing about conversion structure, hero
treatments, or generated marketing assets. The ecosystem's landing-page skills are
copy-strong and design-weak — fixed section ladders and copy frameworks, no asset
pipeline, no design-system inheritance — which is exactly the half keel already owns
machinery for (diverge-cheap/converge-real, screenshot self-review, the workbench as
fidelity source). Encoding the marketing-specific half next to that machinery is the
gap this verb closes.

## Decisions taken

- **One skill, two grains.** A single `marketing-site` skill covers one landing page
  *or* a full marketing site (home / pricing / about / legal / …) — the grain is a
  Discover-phase question, not two skills. Both grains compose from a **marketing
  section system** (tokens, type scale, section primitives: hero, feature band, proof
  strip, pricing table, footer) that the authored plan establishes first, so "upgrade
  the landing page to a full site" later is composition, never a redesign.
- **Two context forks, post-app primary.** *Keel-app fork* (the common case, invoked
  after the app is built): Discover reads `specs/` (product skeleton, shipped features,
  `design.md`) and screenshots the running app; the marketing section system derives
  from the app's workbench tokens so product and marketing read as one brand; real
  staged product shots join the hero-treatment menu; placement defaults to a
  `(marketing)` route group in the same app. *Greenfield fork* (secondary, no codebase):
  the scaffold is delegated to the normal kickoff verbs in a marketing-scoped posture —
  a compressed brand interview standing in for the product interview, a minimal
  keel-managed Next.js project with lightweight `specs/` and a `design.md` recording the
  brand decisions — so the normal build/verify verbs run and a future app inherits the
  brand instead of contradicting it.
- **Explore is an amplification round, not a from-scratch direction round, when a design
  system exists.** Keel-app fork: 2–3 throwaway variants of the *committed* design
  language at marketing spectacle — differing mainly in hero treatment — screenshot
  self-reviewed, user picks. Greenfield fork: a compressed from-scratch direction round
  (the `app-design-directions` diverge-cheap discipline, one screen). Either way the
  variants are divergence sketches under `design/`, never re-implemented as the spec —
  the fidelity reference the authored milestones name is the marketing section system
  (§6 of the shared rules, applied unchanged).
- **Specs → normal pipeline; the skill never builds product code in-session.** The
  attended session ends on a **plan PR** (marketing spec + milestone specs + chosen
  design artifacts, `specs/**` + `design/**` only). A landing page fans into one
  milestone; a full site typically two; three-plus means it outgrew the verb — stop and
  use `spec-feature`. Build and pin run through `implement-milestone` →
  `verify-milestone` unchanged; `review-feature` remains the aesthetic gate.
- **Assets are generated in the attended session, through a committed script.** The
  skill ships a provider-pluggable script template (Gemini image API default — current
  cost posture: cents per image; the provider is a template default, never a hard
  dependency) that a project commits and runs; the API key travels the
  provision-miniature/env-contract path (names asserted via the recorded name-check
  command — values never read, never pasted). Candidate art is generated and judged
  live while the user is present; chosen assets commit with the plan PR as design
  artifacts under `design/marketing/`; the build milestone owns optimizing them into
  the app (`public/`, dimensions, formats). **Spend is attended-only**: under an active
  autonomy mode, asset generation is a planned stop point unless the run's
  pre-authorized envelope covers it (§4 of the shared rules — never silent spend).
  Video generation (Veo/Sora-class, ~$1–3 per hero loop at mid-2026 prices) is an
  **optional attended offer, off by default** — CSS/WebGL motion is the default motion
  channel.
- **The hero-treatment menu is explicit, and WebGL is guarded.** The menu: staged real
  product shots (keel-app fork's strongest option), generated image, CSS
  gradient/motion, WebGL scene (React-Three-Fiber-class), typographic. WebGL is never
  the default, always ships a static fallback, always respects
  `prefers-reduced-motion`, and sits under the same performance floor as everything
  else.
- **The conversion-craft floor is encoded as a reference and flows into
  done-conditions.** Section ladder (hero → proof → problem → solution → features →
  testimonials → pricing → FAQ → final CTA, pruned to the page's goal),
  awareness-stage → copy-framework mapping (problem-aware → PAS, unaware → AIDA,
  solution-aware → BAB), one primary CTA per page, Core Web Vitals budgets (LCP < 2.5s,
  CLS < 0.1, page weight ~1MB), `og:image` + meta, reduced-motion pass. The skill
  instructs the authored milestones to carry these as done-conditions — the floor is
  buildable and verifiable, not advisory prose.
- **The marketing surface is web regardless of the app's platform.** A mobile app still
  gets a web marketing site; when there is no web app to host a route group, the
  greenfield-style standalone scaffold is the vehicle.
- **Model-invocable.** Unlike `harvest`, this verb reads only the project it runs in and
  its spend is an attended in-session step — so "build me a landing page" routes here
  without a human-trigger gate; no `disable-model-invocation`.
- **Ladder wiring + routing seam.** README's grain ladder gains a `Marketing:` line and
  the skills list a Marketing bullet (count 21 → 22); both session-bootstrap banner
  copies gain the same line, with the self-test asserting the new name.
  `app-design-directions`' "not marketing pages" scoping sentence gains a pointer to
  `marketing-site` so the exclusion routes instead of dead-ending.

## Seams owned up front

- `spec-feature` stays the owner of per-feature screen design against the app workbench;
  `marketing-site` owns the marketing surface end-to-end (its section system is the
  workbench-equivalent the authored milestones' fidelity conditions name). The skill
  body states the boundary so neither verb absorbs the other.
- The greenfield fork *delegates* scaffolding to kickoff verbs rather than re-owning
  them — the skill states what the marketing-scoped posture skips, and owns only the
  delta.
- The asset script is a **template** a project commits, not plugin runtime code — keel
  records the contract (env-named key, names-only, output paths), never mandates the
  implementation, mirroring the env name-check command's posture.

## Revisions from the adversarial plan pass

- **The spec-feature ownership boundary gained an enforcing condition.** The "Seams
  owned up front" commitment ("the skill body states the boundary so neither verb
  absorbs the other") traced to no done-condition — a builder could satisfy every
  condition without the body carrying the seam. The output-contract condition now
  requires the boundary statement explicitly.
- **Skill-local paths made unambiguous.** Four conditions named `references/…` and
  `templates/…` root-relative — colliding with the repo's real plugin-root
  `references/` directory the milestone simultaneously promises not to touch; a literal
  verifier would bounce on the wrong directory. All skill-local files are now written
  `skills/marketing-site/…` in the conditions.
- **The greenfield brand-interview substitution traced.** "A compressed brand interview
  standing in for the product interview" was a change-context decision no condition
  enforced; the fork condition now names it. (The change context's Next.js naming stays
  context-only by design — the milestone spec keeps the repo's stack-neutral wording.)
- **A misquote corrected.** The change context bolded the wrong span of
  `app-design-directions`' scoping sentence; the quote now matches the source's
  emphasis.

## Milestone

`specs/milestones/marketing-site.md` — new `skills/marketing-site/SKILL.md` +
`references/` (conversion-craft, asset-pipeline, hero-treatments) + `templates/`
(marketing brief, variant spec, asset script); one line each in `README.md` (ladder +
skills list + count), `scripts/session-bootstrap.sh` (both banner copies) + its test;
one routing sentence in `skills/app-design-directions/SKILL.md`. No gates, guards,
hooks, or plugin-root references move.
