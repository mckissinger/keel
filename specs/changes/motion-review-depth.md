# Change — Motion review depth (choreography + frame-by-frame scrub)

**Grain:** one change → one milestone (`spec-change`). **No-UI** (methodology/docs change to keel
itself). **Stacked on:** `live-surfaces` (edits the same interaction-craft region).

## Why (the gap)

Sourced from the July 2026 design-engineering research pass (Emil Kowalski's published review
practice). Two review-side techniques that separate "the motion is specced" from "the motion is
right" are absent from keel's gates:

1. **Entrance choreography has no ordering rule.** When several elements enter together, the
   craft floor covers stagger timing but not *sequence*: the practitioner rule is animate by
   **importance** (title → primary content → secondary chrome), not by document position — an
   element that sits higher on the page but matters less enters later. Without the rule, builders
   default to DOM order and `review-feature` has no basis to flag it.
2. **The review gate judges motion at full speed only.** Timing flaws — two states overlapping
   mid-crossfade, easing that snaps, a transform-origin drift — are invisible at full speed and
   obvious frame-by-frame. The builder-side habit exists (`motion-cookbook.md` "Debugging
   motion"), but `review-feature`'s interaction-feel step has no recording+scrub technique, and
   the profile's Q8.4 names only still-capture, so a review session has no declared way to get a
   recording even when the driver supports one.

## The mechanic

Three files, additive:

1. **`references/interaction-craft.md`** — one bullet in "The feel of components":
   **choreograph entrances by importance** — when several elements enter together, order the
   sequence by what matters most, not by document position (credited inline to the
   animations.dev practice, consistent with the header credit).
2. **`skills/review-feature/SKILL.md`** — the step-3 **interaction-feel** verdict gains: (a) the
   choreography check (entrance order matches importance), and (b) the **frame-by-frame scrub**:
   when the profile's Q8.4 driver can capture a recording, record the feature's key transitions
   and step through them frame by frame (or at 2–5× slowdown); findings land in the existing
   `| Before | After | Why |` table. When the driver has no recording capability, fall back to
   the slowed live replay per `motion-cookbook.md`'s debugging guidance.
3. **`references/profile-interface.md`** — **Q8.4 extended in place** (no new question, no
   renumbering): the screenshot/review driver may also declare an optional **recording
   capability** (how a rendered interaction is captured as video/frames), consumed by
   `review-feature`'s frame-by-frame motion review; absent it, motion review degrades to slowed
   live replay. Tool mentions hedged (*e.g.* forms), consistent with the question's existing
   web-reference style.

**Not weakened:** the interaction-feel judgment stays human+vision at `review-feature` (nothing
moves to `[auto]`); Q8.4's still-capture contract is unchanged; the recording capability is
optional — no profile is forced to grow one.

## Scope

Three markdown files, pure prose. `profile-interface.md` is a spine file: no web hardcode
(@theme/icon/chart package names), all tools hedged. `check-neutral.sh` stays green.
