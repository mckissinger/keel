# Milestone — Motion review depth

**Goal:** entrance choreography is a floor rule builders and reviewers share, and
`review-feature`'s interaction-feel verdict gains the frame-by-frame scrub with an optional
Q8.4 recording capability behind it — additive, nothing moved out of the human gate.

**Change:** `specs/changes/motion-review-depth.md`. **No-UI** → two-dimension done-conditions.
**Depends on:** `live-surfaces` (stacked — edits the same interaction-craft region).
**Parallelizable:** n/a (single milestone).

## Done-conditions

### Logic / invariants
- [auto] `references/interaction-craft.md` "The feel of components" gains a **choreograph
  entrances by importance** bullet: when several elements enter together, sequence by
  importance (most important first), not document position — an element higher on the page
  but less important enters later. Credited consistent with the file's credit style.
- [auto] `skills/review-feature/SKILL.md` step-3 interaction-feel gains: the choreography
  check (entrance order matches importance) and the **frame-by-frame scrub** — when the
  profile's Q8.4 driver declares a recording capability, record key transitions and step
  through frame by frame (or 2–5× slowdown); fallback when no recording capability = slowed
  live replay per `motion-cookbook.md`'s debugging guidance; findings phrased in the existing
  `| Before | After | Why |` table.
- [auto] `references/profile-interface.md` **Q8.4 extended in place** (no new question,
  Q8.5/Q8.6 un-renumbered): an optional **recording capability** (interaction captured as
  video/frames) consumed by `review-feature`'s motion review, degrading to slowed live replay
  when absent. All tool mentions hedged (*e.g.*), matching the question's existing style; no
  web hardcode (@theme / icon / chart package names) introduced into the spine.
- [auto] **No weakening / no gate movement:** interaction-feel remains part of the human
  `review-feature` gate (not reclassified `[auto]`); Q8.4's existing still-capture text
  unchanged; the recording capability is explicitly optional.

### Behavioral completeness
- [auto] Cross-references resolve: review-feature's existing pointer to interaction-craft.md
  unchanged and the new scrub text points at the profile's Q8.4 and motion-cookbook.md
  correctly; no other spine files (references/milestones-and-verification.md,
  skills/implement-milestone, skills/spec-feature, skills/spec-change, skills/verify-milestone)
  touched vs the stack base.
- [auto] `scripts/check-neutral.sh` exits 0; `check-neutral.test.sh` and
  `check-verified-pin.test.sh` self-tests pass; `scripts/` untouched vs `main`.

## verification
verifier subagent against this file (docs greps: choreography bullet present + credited,
review-feature scrub + fallback + table phrasing present, Q8.4 extended in place with hedged
tools and no renumbering, no-weakening sweep) + `scripts/check-neutral.sh` + both script
self-tests. No surface/action change → no runtime walk; no hard invariant → no
`/security-review`.
