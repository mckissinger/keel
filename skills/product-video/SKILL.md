---
name: product-video
description: Generate product education video for a shipped app — feature how-to / knowledge-base videos, an onboarding sequence, a marketing demo reel, and companion step-docs — by deriving narration scripts from the feature specs, recording a scripted walkthrough of the seeded app through the profile's browser driver, narrating with pluggable TTS, compositing a token-true brand layer, and exporting through a committed, regenerable pipeline. Ends on a plan PR the normal pipeline builds.
when_to_use: When the user wants video content about their product — "make an onboarding video," "we need how-to videos for the knowledge base," "record a feature demo," "make a product tour." Covers four content types — feature how-to / knowledge-base video, onboarding sequence, marketing demo reel, companion step-doc — the type is decided in Discover, not by picking a different verb. Post-app only — the raw material is a shipped app with a seeded runtime and a committed design system. NOT for the marketing surface or its generated art including generative hero video — that is marketing-site; NOT for a live attended walkthrough of the app right now — that is demo, which produces no shareable artifact.
---

# Product Video

You are acting as the product-education lead for a shipped app. The deliverable is a
**plan the normal pipeline builds**: a confirmed video brief, per-video narration
scripts and scenes manifests derived from the specs, a judged pilot render, and
authored milestone spec(s) — never pipeline code landed in this session.

The founding doctrine: **a product video is a regenerable artifact, not a
recording.** Its sources — script, scenes manifest, recorder script, composition —
are committed like tests; the rendered file is disposable output. When a feature
changes, the pipeline re-runs; nobody re-records. This is what makes video content
that stays true to the product affordable at all.

Two boundaries, stated once: `marketing-site` owns the marketing surface and its
generated art end-to-end, including any generative hero-loop video; `product-video`
owns product video content end-to-end — how-to, onboarding, demo reel, step-doc — so
neither verb absorbs the other. The **marketing demo reel** composes with the
marketing surface and its assets; it never redesigns them. And `demo` is the live
attended session ("show me the app, now"); this verb produces shareable artifacts.

This verb is deliberately **model-invocable** (no `disable-model-invocation`): it
reads only the project it runs in, and the only spend it can incur — TTS narration
and rendering — is an attended, in-session step (with batch renders governed by the
plan-gate envelope below), so "make an onboarding video" routes here without a
human-trigger gate.

## Prerequisite — post-app only

The raw material is a shipped app: **built features to walk** (the specs describe
what shipped, not aspirations), a **seeded no-human runtime to drive** (per the
stack profile — the same substrate the verification walk uses), and a **committed
design system to inherit** (the workbench tokens the brand layer consumes). Invoked
before those exist, this verb has nothing true to record — route back to the build
verbs rather than improvising.

v1 records the app's **web surface** through the profile's browser driver. Capture
of non-web surfaces is a recorded deferral, alongside the others: avatar presenters,
generative-video b-roll, publishing/hosting integration, and localized narration.

## The workflow at a glance

```
1 DISCOVER  → prerequisite check; content type (which of the four), subject
              features, audience, voice → video brief, confirmed
2 SCRIPT    → per-video narration + step list derived from the feature specs,
              confirmed against the live flow → scenes manifests (+ step-docs)
3 PILOT     → render ONE video attended (spend), judge voice/pacing/framing live,
              fold the judgment back into the scripts
4 AUTHOR    → milestone spec(s) per the shared rules → plan PR
              → build via implement-milestone → verify-milestone
```

## Movement 1 — Discover

**Check the prerequisite** (above) before anything else.

**Pick the content type — a Discover-phase question, decided in the brief, never by
picking a different verb.** The four types and their craft live in
`references/content-types.md`: feature how-to / knowledge-base video (the core
case), onboarding sequence, marketing demo reel, companion step-doc. One invocation
may plan several (a KB batch, a series); the brief carries the inventory.

**Interview the content delta, not the whole product**: which features, who watches
(a prospect, a new user, a power user — the type constrains this), and the voice
(narration tone, pace). Write the findings into `templates/video-brief.md` —
content type, subject features, audience, voice/tone, and the **video inventory**
(every video this plan will produce, each with a slug) — and confirm it with the
user before any script is written.

## Movement 2 — Script

Scripts are **derived from the feature specs, never from a human recording
session** — the craft lives in `references/script-craft.md`. For each video in the
inventory: derive the narration script and the step list from the feature's spec
(its screens, states, and primary flows), then **confirm the step list by walking
the live flow** before any render — the script must narrate what the app actually
does today.

The per-video unit of record is the **scenes manifest**
(`templates/scenes-manifest.md`): per scene, the narration text, the driven step,
and the timing. The video, its subtitles and chapters, and the **companion
step-doc** (when the brief orders one) all derive from this one file — the step-doc
is never authored separately.

Scripts and manifests are plan artifacts: they live under `design/videos/<slug>/`
and ship with the plan PR.

## Movement 3 — Pilot (attended spend)

Render **one** video from the inventory now, in the attended session, and judge it
with the user — voice, pacing, framing. Narration and rendering cost money and
taste; the pilot is where both are settled while the user is present, exactly like
`marketing-site`'s asset step. Fold the judgment back into the scripts and
manifests; iterate cheaply (a narration re-render costs cents).

The pipeline mechanics — capture, narration, brand layer, assembly, and every
template default — live in `references/video-pipeline.md`; seed the orchestrator
from `templates/record-video.mjs` in the working tree to run the pilot. Nothing
from this movement lands as code in the plan PR — the build milestone owns landing
the committed pipeline.

**Spend is attended-only.** The pilot is judged live. The **batch renders** the
build milestone owns are pre-authorized here: the user approves the video inventory
and its spend envelope at the plan PR's attended sign-off, and a render outside
that envelope is a planned stop point in the build run — never silent spend. Under
an active autonomy mode, generation is a planned stop point unless the run's
pre-authorized envelope covers it (§4 of the shared rules).

## Movement 4 — Author the plan

Author like `spec-change`/`spec-feature` — the shared rules
(`${CLAUDE_PLUGIN_ROOT}/references/milestones-and-verification.md`) apply
**unchanged**, cited not restated: the authored milestone spec(s) follow them —
dimension coverage, one tag per condition, named verification — and the plan pass
runs before the PR opens.

- **The session ends attended, on a plan PR**: `specs/**` + `design/**` only — the
  video brief, the narration scripts and scenes manifests under
  `design/videos/<slug>/`, and the authored milestone spec(s).
- **The build milestone owns** landing the committed pipeline (seeded from this
  skill's templates) and rendering the batch within the pre-authorized envelope.
  **Recorder scripts double as committed activation coverage where the profile's
  test tiers support it** — the walkthrough that makes the video also
  regression-guards the flow, so the video's step list breaking is a test failure,
  not a stale MP4.
- **Fan-out:** one milestone typically; two for a large batch; three-plus means the
  work outgrew this verb — stop and use `spec-feature`.
- Build and pin run through `implement-milestone` → `verify-milestone` unchanged.

## Where this sits

```
marketing-site   the public face — page or site, and its generated art
demo             the live attended walkthrough — no artifact
product-video    shareable product video, regenerable from committed sources   ← here (post-app)
```
