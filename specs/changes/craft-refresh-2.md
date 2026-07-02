# Change — Craft refresh 2: vocabulary parity, review depth, live-surface completions

**Grain:** one change → one milestone (`spec-change`). **No-UI** (docs change to keel's craft
references). **Stacked on:** nothing (targets `main`).

## Why (the gap)

The July craft layer (PRs #30–37) was mined from design-eng discourse through mid-June 2026.
A source-verified re-sweep (live X timelines + primary docs, 2026-07-01) found four deltas
that post-date or escaped that pass:

1. **Vocabulary** — Emil Kowalski shipped a full motion glossary as a skill
   (github.com/emilkowalski/skills, 06-29; ~80 terms). Keel's named vocabulary has 8. Most of
   his list keel already carries as unnamed principles, but a curated set is genuinely absent
   — and naming is the point of the vocabulary section (a builder can't be told "use a
   continuity transition here" if keel never names one). The craft file also advertises "3D"
   as living in the cookbook, which has no such entry — a dangling pointer.
2. **Review depth** — his `review-animations` skill (06-18) carries five reviewer mechanics
   keel's motion-review section lacks: a cohesion/personality standard ("when unsure whether
   motion feels right, the strongest move is often to delete it"), an explicit hard-flag
   trigger list, an ordered remedial hierarchy (delete first), a Block/Approve verdict with
   stated criteria, and default-to-flag posture with file:line citations.
3. **Live surfaces** — shadcn's streaming-chat spec + MessageScroller primitive (06-26)
   encode 15 rules; keel's live-surfaces section (PR #33) already carries 11. Missing four:
   grow-into-the-screen after anchoring, arbitrary navigation (jump-to-message, links,
   search, unread markers), long-thread responsiveness as an obligation, and live-surface
   accessibility (preserved keyboard focus, paced announcements). Plus one default worth
   naming: reopen at the last user message.
4. **Techniques** — curved-path motion (Motion's new `arc()` API) is absent entirely, and
   mitchellh's cross-container animation architecture (06-25) yields two platform-neutral
   patterns keel has nothing on: flatten the logical tree to one layer so motion can cross
   container boundaries, and render transient affordances (drag/drop targets) as overlays
   above the whole composition, never intrinsic per-container.

**Deliberately scoped:** vocabulary lands as a curated subset serving build/review use — not
the full glossary (looping/ambient and performance-jargon terms stay out; a reference skills
load into context stays curated, not encyclopedic). "Animate by importance" was also
re-sourced and found already present (`interaction-craft.md` choreography rule) — no change.

## The mechanic

Two files, additive, mirroring the #30–37 pattern:

1. **`references/interaction-craft.md`** — the named vocabulary gains ~11 curated terms
   (pop-in; shared-element transition disambiguated from morph; continuity transition;
   anticipation; follow-through; perceptual duration; mask disambiguated from clip-path;
   skeleton/shimmer; number ticker + tabular numbers; parallax; page transition), each one
   line in keel's voice. The review section gains the five reviewer mechanics (cohesion
   standard + delete-when-unsure, hard-flag triggers, remedial hierarchy, Block/Approve
   verdict, posture + citation rule). The live-surfaces section gains the four missing rules
   + the reopen-at-last-user-message default.
2. **`references/motion-cookbook.md`** — a curved-path technique entry (when a trajectory
   reads better than a straight translate; `arc()`-style APIs as the web example, hedged), a
   cross-container motion pattern (flatten-to-one-layer + overlay affordances +
   place-at-full-size-then-slide), and a brief 3D/perspective entry resolving the dangling
   pointer.

**Not weakened:** the existing 8 vocabulary terms, review-table rows, and live-surface state
grammar are unchanged — pure addition, same as the a11y-floor precedent.

## Scope

Two markdown files, pure prose. `check-neutral.sh` stays green (both are design-track craft
files; web mechanisms appear as hedged examples, per house precedent). Sources: Emil's skills
repo (animation-vocabulary, review-animations), shadcn MessageScroller docs + June chat
changelog, motion.dev/docs/arc, X posts 2070281069631611056 / 2070273858154987537
(@mitchellh) — all fetched and diffed against the current files on 2026-07-01.
