# Change — product-video

One milestone, prose + skill assets (one new skill with references/templates, ladder
wiring, two routing sentences). Approved by Michael 2026-07-16 after an inline research
round (the mid-2026 SaaS video-generation ecosystem: agent-driven browser-screencast
pipelines, AI-enhanced recorders, programmatic-composition agent skills, avatar
platforms) and a mini-interview — all questions resolved on the recommended option:
name `product-video`, Remotion-class brand layer in v1 (user-confirmed after an
explicit should-we-add-it round), sources committed / renders gitignored, all four
content types in scope, ElevenLabs as the TTS template default (user-picked).

## Why

Every keel-built app eventually needs product education video — customer onboarding,
knowledge-base how-tos, feature demos, product tours — and keel has no verb for it.
`marketing-site` explicitly scopes video as "an optional attended offer, off by
default" and means generative hero loops, not product walkthroughs; `demo` is a live
attended session, not a shareable artifact. So today this content is either made
outside the process (no spec, no fidelity chain, goes stale silently the moment the UI
changes) or not made at all.

The mid-2026 ecosystem makes the gap worth closing now. The breakout pattern of the
last six months is the agent-driven pipeline: a coding agent scripts a browser
walkthrough of the real app, records it via the browser driver's screencast API,
narrates with TTS, and assembles an MP4 — the video becomes a *regenerable artifact*
re-run when the product changes, exactly keel's tests-not-recordings doctrine. The
incumbent SaaS tools (Clueso/Guidde-class recorders) prove the demand and the output
bar (auto-zoom, voiceover, a companion step-doc from the same capture) but require a
human to record and cannot inherit a design system. keel already owns everything they
charge for: feature specs as the script source, a seeded runtime and activation driver
(the `[runtime]` walk is already a driven product tour), and a committed design system
whose tokens a programmatic composition layer can consume so the video reads as the
product's own brand — a fidelity chain no off-the-shelf tool has.

## Decisions taken

- **One skill, four content types.** A single `product-video` skill covers feature
  how-to / knowledge-base videos (the core case — per-feature walkthroughs derived
  from feature specs), an onboarding sequence (a "getting started" series over the
  primary flows), a marketing demo reel (a polished product tour composing with
  `marketing-site`'s surface and assets), and a companion step-doc (a markdown
  step-by-step guide generated from the same scenes manifest — the video+doc dual
  output from one capture). Content type is a Discover-phase question, not four
  skills; all four share one pipeline and differ in script source, framing, and
  length.
- **Post-app only — no greenfield fork.** The verb's raw material is a shipped app:
  built features to walk, a seeded no-human runtime to drive (per the stack profile),
  and a committed design system to inherit. The skill states the prerequisite and
  routes a too-early invocation back to the build verbs. v1 records the app's **web
  surface** via the profile's browser driver; capture of non-web surfaces is an
  explicit deferral.
- **Scripts derive from specs, then get confirmed against the real app.** Narration
  scripts and step lists are authored from the feature specs (screens, states,
  primary flows) — not from a human recording session — and each script's step list
  is confirmed by walking the live flow before any render, so the script never
  narrates an aspiration. Per video, the unit of record is a **scenes manifest**
  (per-scene narration text + the driven step + timing), from which the video, its
  subtitles/chapters, and the companion step-doc all derive.
- **The pipeline is four pluggable stages, template defaults never hard
  dependencies.** (1) *Capture*: the profile's browser driver records a scripted
  walkthrough of the seeded dev app via its screencast capability
  (Playwright-class, screencast API — the template default). (2) *Narration*: TTS
  from the scenes manifest — **ElevenLabs is the template default**, provider-
  pluggable (a local engine is the zero-key fallback); the API key travels the
  provision-miniature / environment-contract path and is asserted **by name only**
  via the recorded name-check command — values never read, never pasted.
  (3) *Brand layer*: a programmatic composition layer (**Remotion-class — the
  template default**) builds intro/outro cards, chapter titles, and callout overlays
  **from the app workbench's tokens**, so the video reads as the product's own brand
  — the fidelity chain extended to video. The layer is pluggable: capture + narration
  + assembly produce a complete video without it, so it elevates when present and
  never blocks; the skill's environment contract notes its company-size license
  term. (4) *Assembly*: ffmpeg export (H.264 MP4, subtitles, chapter markers).
- **Sources are committed; renders are not.** The video brief, narration scripts,
  scenes manifests, recorder scripts, and compositions commit — the video is
  regenerable like a test, and re-rendering after a UI change is the point. Rendered
  MP4s land in a **gitignored output directory**; hosting/publishing (help center,
  video platforms) is out of scope for v1. When a feature changes, the regeneration
  doctrine is re-run, not re-record.
- **Spend is attended-only.** TTS narration and rendering spend money and taste:
  the first render of a video (the pilot) is generated and judged **in the attended
  session** — voice, pacing, framing — like `marketing-site`'s asset step. The
  **batch renders** the build milestone owns are pre-authorized at the plan PR's
  attended sign-off (the user approves the video inventory and its spend envelope);
  a render outside that envelope is a planned stop point in the build run. Under an
  active autonomy mode, generation is a planned stop point unless the run's
  pre-authorized envelope covers it (§4 of the shared rules — never silent spend).
- **Specs → normal pipeline; the skill never lands pipeline code in-session.** The
  attended session ends on a **plan PR** (video brief + scripts + scenes manifests as
  design artifacts, plus milestone spec(s) — `specs/**` + `design/**` only). The
  build milestone owns landing the committed pipeline (seeded from the skill's
  templates) and rendering the batch; recorder scripts double as committed
  activation coverage where the profile's test tiers support it, so the walkthrough
  that makes the video also regression-guards the flow. One milestone typically;
  two for a large batch; three-plus means the work outgrew the verb — stop and use
  `spec-feature`. Build and pin run through `implement-milestone` →
  `verify-milestone` unchanged.
- **Model-invocable.** Like `marketing-site`: the verb reads only the project it runs
  in, and its spend is an attended in-session step — so "make an onboarding video"
  routes here without a human-trigger gate; no `disable-model-invocation`.
- **Deferrals, recorded up front:** avatar presenters (Synthesia/HeyGen-class),
  generative-video b-roll (Veo/Sora-class), publishing/hosting integration,
  localization/translated narration, non-web surface capture.
- **Ladder wiring + routing seams.** README's grain ladder gains a `Video:` line and
  the skills list a Video bullet (count 22 → 23); both session-bootstrap banner
  copies gain the same line, with the self-test asserting the new name.
  `marketing-site`'s "video is an optional attended offer" sentences (skill body and
  `asset-pipeline.md`) each gain a pointer distinguishing generative hero video
  (stays there) from product walkthrough video (routes here).

## Seams owned up front

- `marketing-site` stays the owner of the marketing surface and its generated art,
  including any generative hero-loop video; `product-video` owns product video
  content end-to-end (how-to, onboarding, demo reel, step-doc). The demo reel
  composes with the marketing surface — it never redesigns it. The skill body states
  the boundary so neither verb absorbs the other.
- `demo` stays the live attended walkthrough ("show me the app, now"); `product-video`
  produces shareable artifacts. The `when_to_use` distinguishes them so the router
  picks the right verb.
- The pipeline scripts are **templates a project commits**, not plugin runtime code —
  keel records the contract (env-named key, names-only, pluggable providers,
  gitignored render dir), never mandates the implementation, mirroring
  `marketing-site`'s asset-script posture.

## Revisions from the adversarial plan pass

Seven findings, all folded in before the PR opened:

- **Two decisions traced to no condition.** "Content type is a Discover-phase
  question" and the header's "shared rules cited, never restated" seam were
  change-context claims no condition enforced; the posture condition and the
  output-contract condition now carry them.
- **The recorder template's API-key clause was incoherent.** The condition required
  `record-video.mjs` to read "its API key" — a carry-over from `marketing-site`'s
  asset script — but the capture stage is the zero-key one; a compliant keyless
  recorder would have bounced. The template is now specified as the
  **pipeline-orchestrator seed** (capture + narration-provider call + assembly),
  with the key clause attached to the narration provider it actually calls.
- **A disjunctive owning location.** "The skill body or `video-pipeline.md` states…"
  let two readers disagree on where the sources-not-renders clauses must live;
  `video-pipeline.md` is now the named owning file.
- **Incidental exactness in the README wiring.** The condition demanded a `Video:`
  line in README's ladder, whose rows carry no colons; now "a Video row matching
  the ladder's existing row format," with the literal `Video:` kept only for the
  session-bootstrap banners, which do use colons.
- **An internal posture contradiction.** The header mandated every tool name be a
  template default "never a hard requirement" while condition 5 named ffmpeg "a
  system dependency"; the assembly clause is now hedged to match the posture.
- **Batch-render spend was ungoverned.** The pilot's spend was attended but the
  build milestone's batch renders traced to no authorization; the spend condition
  (and the Decision above) now record the plan-gate envelope + stop-point rule.

## Milestone

`specs/milestones/product-video.md` — new `skills/product-video/SKILL.md` +
`references/` (video-pipeline, script-craft, content-types) + `templates/`
(video brief, scenes manifest, pipeline-orchestrator script); one line each in `README.md` (ladder +
skills list + count), `scripts/session-bootstrap.sh` (both banner copies) + its test;
one routing sentence each in `skills/marketing-site/SKILL.md` and
`skills/marketing-site/references/asset-pipeline.md`. No gates, guards, hooks, or
plugin-root references move.
