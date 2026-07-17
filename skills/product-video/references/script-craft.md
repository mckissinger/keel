# Script craft — from spec to scenes manifest

## Derivation, not recording

Narration scripts and step lists **derive from the feature specs** — the screens,
enumerated states, and primary flows the spec already records — **never from a
human recording session.** The spec is the source of truth for what the feature
does; the script narrates that truth. This is the whole economic point: a script
derived from specs regenerates when the spec's feature changes; a human recording
is stale the day the UI moves.

**Then confirm against the live app before any render.** Walk each script's step
list through the seeded runtime (the profile's browser driver, the same substrate
the verification walk uses) and fix any step the real app contradicts — a renamed
button, a moved field, a state the spec described but the build refined. The script
must narrate what the app actually does today, not what the plan once said.

## The scenes manifest — the unit of record

Per video, one manifest (`templates/scenes-manifest.md`): an ordered list of
scenes, each carrying

- **narration** — the sentence(s) spoken over this scene,
- **step** — the driven action the viewer watches (navigate, click, fill, submit),
- **timing** — the scene's intended duration, derived from the narration length.

Everything downstream derives from this one file: the recorded walkthrough (the
steps), the TTS narration (the text), the subtitles and chapter markers (text +
timing), and the companion step-doc (scene-per-step). Change the manifest,
regenerate everything; nothing is edited downstream of it.

## Pacing guidance (ranges, not gates)

- **Narration per scene:** ~10–25 words. Under 10 the scene is probably part of
  its neighbor; over 25 the viewer is listening to a paragraph while nothing
  happens — split the scene.
- **Steps per video:** ~5–12 driven steps for a how-to; a video pushing past that
  is usually two tasks (see `content-types.md` for per-type lengths).
- **Dead air:** every scene shows an action. A scene whose step is "look at the
  screen" for more than a beat is a sign the narration belongs on the previous
  action.
- **Openings:** state the outcome first ("by the end you'll have X"), then move.
  The first five seconds decide whether a viewer stays.

## Voice

The brief's voice/tone line governs word choice: education content reads calm and
second-person ("you'll see…"), a demo reel reads confident and present-tense.
Written for the ear — short sentences, no nested clauses, numbers a listener can
hold. Read every script aloud once before rendering; the ear catches what the eye
approves.
