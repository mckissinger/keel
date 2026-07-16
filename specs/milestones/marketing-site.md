# Milestone — marketing-site

Change context: `specs/changes/marketing-site.md`. One milestone; adds one skill and
wires it — new `skills/marketing-site/SKILL.md` with three skill-local references
(`references/conversion-craft.md`, `references/asset-pipeline.md`,
`references/hero-treatments.md`) and three templates (`templates/marketing-brief.md`,
`templates/variant-spec.md`, `templates/generate-asset.mjs`); the grain-ladder /
skills-list / count lines in `README.md`; the orientation banner in
`scripts/session-bootstrap.sh` (both the neutral and mode-active copies) + its
self-test; one routing sentence in `skills/app-design-directions/SKILL.md`. No gates,
guards, hooks, or plugin-root references move. Integration seams: the session-bootstrap
banner is covered by `scripts/session-bootstrap.test.sh` (stays green, gains an
assertion for the new name); `harvest` is the ladder-wiring pattern to match;
`app-design-directions`' "not marketing pages" scoping sentence is the routing seam —
it gains a pointer, its scope does not change; the shared milestone rules
(`references/milestones-and-verification.md`) are cited by the skill body, never
restated or re-owned. Neutrality caution for the builder: the skill body and references
never name dogfood projects or real client brands; example copy uses invented products.

## Done-conditions

- [auto] **The skill exists and is well-formed.** `skills/marketing-site/SKILL.md` has
  valid frontmatter (`name: marketing-site`, a `description`, a `when_to_use`) and
  passes `scripts/check-skill-frontmatter.sh` (now 22 skills). It does **not** carry
  `disable-model-invocation` — the body states why it is model-invocable (reads only
  the project it runs in; spend is an attended in-session step). The `when_to_use`
  names both grains (one landing page / full marketing site) and states the primary
  posture: usually invoked **after the app is built**, with greenfield as the secondary
  fork — and distinguishes it from `app-design-directions` (product UI) so the router
  picks the right verb.
- [auto] **Two context forks are specified, post-app primary.** The skill body
  distinguishes: the *keel-app fork* — Discover reads `specs/` (product skeleton,
  shipped features, `design.md`) and screenshots the running app; the marketing section
  system derives from the app workbench's tokens; staged real product shots are named
  on the hero-treatment menu; placement defaults to a `(marketing)` route group in the
  same app — and the *greenfield fork* — scaffolding is delegated to the kickoff verbs
  in a marketing-scoped posture (the body states what that posture skips, and that a
  compressed brand interview stands in for the product interview), producing a
  keel-managed project whose `design.md` records the brand decisions so a future app
  inherits them. The body also states the platform principle: the marketing surface is
  web regardless of the app's platform, with the standalone scaffold as the vehicle
  when no web app can host a route group.
- [auto] **The grain question and the marketing section system are encoded.** The body
  states: landing page vs full site is decided in Discover; both grains compose from a
  marketing section system (tokens, type scale, named section primitives) established
  by the authored plan and **recorded in the marketing spec the plan PR carries**; for
  the keel-app fork the system derives from the app workbench so the fidelity chain is
  unbroken — the authored milestones' fidelity conditions name the marketing section
  system as their reference per §6 of the shared rules (cited, not restated).
- [auto] **Explore is amplification when a design system exists, divergence-sketch
  discipline either way.** The body states: keel-app fork runs 2–3 throwaway variants
  of the committed design language differing mainly in hero treatment, screenshot
  self-reviewed, user picks; greenfield fork runs a compressed from-scratch direction
  round; variants live under `design/` as divergence sketches and are never
  re-implemented as the spec.
- [auto] **The output contract is a plan, never in-session product code.** The body
  states: the session ends attended on a **plan PR** (`specs/**` + `design/**` only —
  marketing spec, milestone specs, chosen design artifacts); the authored milestone
  specs follow the shared rules unchanged (dimension coverage, one tag per condition,
  named verification); a landing page fans into one milestone, a full site typically
  two, and three-plus means stop and use `spec-feature`; build and pin run through
  `implement-milestone` → `verify-milestone`, with `review-feature` as the aesthetic
  gate. The body also states the ownership boundary: `spec-feature` owns per-feature
  screen design against the app workbench; `marketing-site` owns the marketing surface
  end-to-end, its section system serving as the workbench-equivalent its authored
  milestones' fidelity conditions name — so neither verb absorbs the other.
- [auto] **The asset pipeline is encoded, spend attended-only.**
  `skills/marketing-site/references/asset-pipeline.md` exists and states: generation runs through a committed
  project-side script (the template below), provider-pluggable with the Gemini image
  API as the template default; the key travels the provision-miniature/env-contract
  path and is asserted by **name only** via the recorded name-check command — values
  never read, never pasted; candidate art is generated and judged in the attended
  session; chosen assets commit with the plan PR under `design/marketing/`; the build
  milestone owns optimization into the app (`public/`, dimensions, formats); under an
  active autonomy mode asset generation is a planned stop point unless the run's
  pre-authorized envelope covers it; video generation is an optional attended offer,
  off by default, with CSS/WebGL motion as the default motion channel.
- [auto] **The asset script template exists and holds the contract.**
  `skills/marketing-site/templates/generate-asset.mjs` exists, reads its API key from an environment variable
  (no literal key anywhere in the file), takes prompt + output path as inputs, and
  carries a header comment stating it is a project-committed template with a swappable
  provider — keel records the contract, never mandates the implementation.
- [auto] **The hero-treatment menu and WebGL guardrails are encoded.**
  `skills/marketing-site/references/hero-treatments.md` exists and names the menu — staged real product
  shots, generated image, CSS gradient/motion, WebGL scene, typographic — and the
  guardrails: WebGL is never the default treatment, always ships a static fallback,
  always respects `prefers-reduced-motion`, and sits under the same performance floor
  as every other treatment.
- [auto] **The conversion-craft floor is encoded and flows into done-conditions.**
  `skills/marketing-site/references/conversion-craft.md` exists and carries: the section ladder (pruned to
  the page's goal, not mandatory in full), the awareness-stage → copy-framework mapping
  (problem-aware → PAS, unaware → AIDA, solution-aware → BAB), the one-primary-CTA
  rule, the Core Web Vitals budgets (LCP < 2.5s, CLS < 0.1, ~1MB page weight), and the
  `og:image` + meta and reduced-motion requirements — and the skill body instructs the
  authored milestones to carry the floor as done-conditions rather than advisory prose.
- [auto] **Templates exist for the brief and the variants.**
  `skills/marketing-site/templates/marketing-brief.md` (product, audience, awareness
  stage, conversion goal, grain, brand/token source) and
  `skills/marketing-site/templates/variant-spec.md` (hero treatment, section
  selection, tone — the amplification-round unit) exist and are named by the skill body
  at their point of use.
- [auto] **The routing seam lands.** `skills/app-design-directions/SKILL.md`'s "not
  marketing pages" scoping sentence now routes to `marketing-site` (one sentence; the
  skill's scope is otherwise unchanged).
- [auto] **Ladder wiring.** `README.md`'s grain ladder gains a `Marketing:` line naming
  `marketing-site` and the skills list gains a Marketing bullet, **and the skill count
  reads 22** (no "21 skills" text survives anywhere in the file); both orientation-banner
  copies in `scripts/session-bootstrap.sh` carry the same `Marketing:` line; and
  `scripts/session-bootstrap.test.sh` gains an assertion that the emitted banner names
  `marketing-site`, with the full suite still passing.
- [auto] **Repo checks green.** `claude plugin validate --strict .`,
  `scripts/check-neutral.sh`, `scripts/check-plan.sh`,
  `scripts/check-skill-frontmatter.sh`, `scripts/check-skill-anchors.sh`, and every
  `scripts/*.test.sh` pass on the branch.

## verification

verifier subagent against this file's done-conditions (all `[auto]`; the new skill is
prose + frontmatter + a template script, closable by reading the named files and
running the named checks).
