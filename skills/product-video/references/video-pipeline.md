# The video pipeline — four pluggable stages

Every tool named here is a **template default, never a hard dependency** — the
project commits its own pipeline (seeded from `templates/record-video.mjs`) and may
swap any stage's provider; keel records the contract, never mandates the
implementation. The stages, in order:

## 1. Capture

The **profile's browser driver** records a scripted walkthrough of the **seeded
dev app** — the same no-human authenticated state the verification walk uses. The
template default is a Playwright-class driver using its screencast capability:
the recorder script drives the scenes manifest's steps against the live app while
the driver captures frames. The recorder script is ordinary driver code, which is
why it can double as committed activation coverage (the skill body owns that
contract).

## 2. Narration

TTS renders each scene's narration text from the scenes manifest. **ElevenLabs is
the template default**, and the stage is provider-pluggable — a **local TTS engine
is the zero-key fallback** (slower and plainer, but the pipeline completes with no
key at all). The API key travels the **provision-miniature /
environment-contract path** and is asserted **by name only** via the project's
recorded name-check command — values never read, never pasted. Per-scene audio
clips are aligned to the capture by the manifest's timings.

## 3. Brand layer

A programmatic composition layer — **Remotion-class is the template default** —
builds the intro/outro cards, chapter titles, and callout overlays **from the app
workbench's tokens** (palette, type, spacing), so the video reads as the product's
own brand: the fidelity chain extended to video. The layer is **pluggable**:
capture + narration + assembly produce a complete video without it — it elevates
when present and never blocks. Note in the project's environment contract that
Remotion-class layers carry a **company-size license term** (free below a small
head-count, licensed above it) — record the project's posture there.

## 4. Assembly

Mux the captured video, aligned narration, and (when present) the brand layer into
the export — an H.264 MP4 plus **subtitles and chapter markers**, both derived
from the scenes manifest. ffmpeg is the template default assembler, recorded in
the project's environment contract when used.

## Sources are committed; renders are not (the owning statement)

- **Committed**: the video brief, narration scripts, scenes manifests, recorder
  scripts, and compositions — the video's sources, versioned like tests.
- **Not committed**: rendered MP4s land in a **gitignored output directory**
  (e.g. an ignored `design/videos/out/`) — large, derived, and stale-able
  binaries never enter history.
- **Hosting/publishing is out of scope for v1** — where the rendered files go
  (help center, video platform) is a recorded deferral.
- **The regeneration doctrine:** when a feature changes, **re-run the pipeline —
  never re-record by hand.** The committed sources are the recording; a stale
  video is one render away from true, and the recorder-as-activation-coverage
  contract means a broken step list surfaces as a test failure first.
