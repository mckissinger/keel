# Milestone — product-video

Change context: `specs/changes/product-video.md`. One milestone; adds one skill and
wires it — new `skills/product-video/SKILL.md` with three skill-local references
(`references/video-pipeline.md`, `references/script-craft.md`,
`references/content-types.md`) and three templates (`templates/video-brief.md`,
`templates/scenes-manifest.md`, `templates/record-video.mjs`); the grain-ladder /
skills-list / count lines in `README.md`; the orientation banner in
`scripts/session-bootstrap.sh` (both the neutral and mode-active copies) + its
self-test; one routing sentence each in `skills/marketing-site/SKILL.md` and
`skills/marketing-site/references/asset-pipeline.md`. No gates, guards, hooks, or
plugin-root references move. Integration seams: the session-bootstrap banner is
covered by `scripts/session-bootstrap.test.sh` (stays green, gains an assertion for
the new name); `marketing-site` is the wiring pattern to match (the closest post-app
content verb); `marketing-site`'s "video is an optional attended offer" sentences are
the routing seam — they gain a pointer, their scope does not change; the shared
milestone rules (`references/milestones-and-verification.md`) are cited by the skill
body, never restated or re-owned. Neutrality caution for the builder: tool names
(Playwright-class driver, ElevenLabs, Remotion-class layer, ffmpeg) appear only as
hedged, pluggable **template defaults**, never as hard requirements; the skill body
and references never name dogfood projects or real client brands; example content
uses invented products.

## Done-conditions

- [auto] **The skill exists and is well-formed.** `skills/product-video/SKILL.md` has
  valid frontmatter (`name: product-video`, a `description`, a `when_to_use`) and
  passes `scripts/check-skill-frontmatter.sh` (now 23 skills). It does **not** carry
  `disable-model-invocation` — the body states why it is model-invocable (reads only
  the project it runs in; spend is an attended in-session step). The `when_to_use`
  names all four content types (feature how-to / knowledge-base video, onboarding
  sequence, marketing demo reel, companion step-doc), states the post-app
  prerequisite, and distinguishes the verb from `marketing-site` (the marketing
  surface and its generated art, including generative hero video) and from `demo`
  (a live attended walkthrough, not a shareable artifact) so the router picks the
  right verb.
- [auto] **The post-app prerequisite and capture posture are encoded.** The skill
  body states: the verb requires a keel-built app with shipped features, a seeded
  no-human runtime (per the stack profile), and a committed design system; invoked
  too early it routes back to the build verbs rather than improvising. It states
  that v1 records the app's **web surface** via the profile's browser driver and
  names non-web capture as a deferral, alongside the other recorded deferrals
  (avatar presenters, generative-video b-roll, publishing/hosting, localization).
  The body also states that the content type — which of the four — is a
  Discover-phase question, decided in the brief, never by picking a different verb.
- [auto] **The four content types are encoded.**
  `skills/product-video/references/content-types.md` exists and, for each of the
  four types, states its script source, framing, and target-length guidance:
  feature how-to / knowledge-base video (per-feature, derived from that feature's
  spec), onboarding sequence (a series over the product skeleton's primary flows),
  marketing demo reel (composes with the `marketing-site` surface and assets —
  never redesigns them), and companion step-doc (a markdown step-by-step guide
  derived from the same scenes manifest as its video, not authored separately).
- [auto] **Script derivation is encoded.**
  `skills/product-video/references/script-craft.md` exists and states: narration
  scripts and step lists derive from the feature specs (screens, states, primary
  flows) — never from a human recording session; each script's step list is
  confirmed by walking the live flow before any render; the per-video unit of
  record is the **scenes manifest** (per-scene narration text + driven step +
  timing), from which the video, its subtitles/chapters, and the companion
  step-doc all derive; and it carries pacing guidance (narration length per step,
  step-count bounds per video) as ranges, not point values.
- [auto] **The pipeline is encoded as four pluggable stages.**
  `skills/product-video/references/video-pipeline.md` exists and states the four
  stages with their template defaults, each explicitly a default never a hard
  dependency: (1) capture — the profile's browser driver records a scripted
  walkthrough of the seeded dev app via its screencast capability
  (Playwright-class); (2) narration — TTS from the scenes manifest, ElevenLabs as
  the template default, provider-pluggable with a local engine named as the
  zero-key fallback, the API key traveling the provision-miniature /
  environment-contract path and asserted **by name only** via the recorded
  name-check command — values never read, never pasted; (3) brand layer — a
  programmatic composition layer (Remotion-class) builds intro/outro cards, chapter
  titles, and callout overlays **from the app workbench's tokens**, is pluggable
  (capture + narration + assembly produce a complete video without it), and carries
  the company-size license note in the environment contract; (4) assembly — export with
  subtitles and chapter markers, ffmpeg as the template default, recorded in the
  project's environment contract when used.
- [auto] **The sources-not-renders doctrine is encoded.**
  `skills/product-video/references/video-pipeline.md` states (the skill body may
  echo, but this file is the owning location): the video brief, narration scripts, scenes manifests,
  recorder scripts, and compositions are committed; rendered MP4s land in a
  **gitignored output directory**; hosting/publishing is out of scope for v1; and
  the regeneration doctrine — when a feature changes, re-run the pipeline, never
  re-record by hand.
- [auto] **Spend is attended-only.** The skill body states: the pilot render of a
  video is generated and judged in the attended session (voice, pacing, framing);
  under an active autonomy mode, generation is a planned stop point unless the
  run's pre-authorized envelope covers it — citing §4 of the shared rules, not
  restating them. The body also states how **batch-render** spend (the renders the
  build milestone owns) is authorized: the user approves the video inventory and
  its spend envelope at the plan PR's attended sign-off; a render outside that
  envelope is a planned stop point in the build run — never silent spend.
- [auto] **The output contract is a plan, never in-session pipeline code.** The
  skill body states: the session ends attended on a **plan PR** (`specs/**` +
  `design/**` only — the video brief, narration scripts, and scenes manifests as
  design artifacts, plus the authored milestone spec(s)); the build milestone owns
  landing the committed pipeline (seeded from the skill's templates) and rendering
  the batch; **recorder scripts double as committed activation coverage where the
  profile's test tiers support it**, so the walkthrough that makes the video also
  regression-guards the flow; fan-out is one milestone typically, two for a large
  batch, and three-plus means stop and use `spec-feature`; the authored milestone
  spec(s) follow the shared rules unchanged (dimension coverage, one tag per
  condition, named verification — cited, not restated); build and pin run through
  `implement-milestone` → `verify-milestone` unchanged. The body also
  states the ownership boundary: `marketing-site` owns the marketing surface and
  its generated art end-to-end; `product-video` owns product video content
  end-to-end — so neither verb absorbs the other.
- [auto] **Templates exist for the brief, the manifest, and the recorder.**
  `skills/product-video/templates/video-brief.md` (content type, subject features,
  audience, voice/tone, video inventory) and
  `skills/product-video/templates/scenes-manifest.md` (per-scene narration text +
  driven step + timing — the unit of record) exist and are named by the skill body
  at their point of use. `skills/product-video/templates/record-video.mjs` exists
  as the **pipeline-orchestrator seed** — it drives the scripted capture, calls the
  narration provider reading that provider's API key from an environment variable
  (no literal key anywhere in the file), and assembles the export — and carries a
  header comment stating it is a project-committed template with swappable
  providers — keel records the contract, never mandates the implementation.
- [auto] **The routing seams land.** The "video is an optional attended offer"
  sentence in `skills/marketing-site/SKILL.md` and its counterpart in
  `skills/marketing-site/references/asset-pipeline.md` each gain one sentence
  routing product walkthrough / demo / onboarding video to `product-video`
  (generative hero video stays where it is; neither file's scope otherwise
  changes).
- [auto] **Ladder wiring.** `README.md`'s grain ladder gains a Video row naming
  `product-video` (matching the ladder's existing row format) and the skills list
  gains a Video bullet, **and the skill count reads 23** (no "22 skills" text
  survives anywhere in the file); both
  orientation-banner copies in `scripts/session-bootstrap.sh` carry the same
  `Video:` line; and `scripts/session-bootstrap.test.sh` gains an assertion that
  the emitted banner names `product-video`, with the full suite still passing.
- [auto] **Repo checks green.** `claude plugin validate --strict .`,
  `scripts/check-neutral.sh`, `scripts/check-plan.sh`,
  `scripts/check-skill-frontmatter.sh`, `scripts/check-skill-anchors.sh`, and every
  `scripts/*.test.sh` pass on the branch.

## verification

verifier subagent against this file's done-conditions (all `[auto]`; the new skill is
prose + frontmatter + a template script, closable by reading the named files and
running the named checks).
