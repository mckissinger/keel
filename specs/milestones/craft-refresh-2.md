# Milestone — Craft refresh 2: vocabulary parity, review depth, live-surface completions

**Goal:** keel's craft references carry the source-verified July deltas — a curated
vocabulary extension, reviewer mechanics with teeth (delete-first, hard flags, Block/Approve),
the four missing live-surface rules, and cross-container/curved-path motion patterns — as
pure additions.

**Change:** `specs/changes/craft-refresh-2.md`. **No-UI** → two-dimension done-conditions.
**Depends on:** nothing. **Parallelizable:** n/a (single milestone).

## Done-conditions

### Logic / invariants
- [auto] `references/interaction-craft.md` named vocabulary gains exactly these curated
  terms, one line each in keel's voice: **pop-in**, **shared-element transition**
  (disambiguated from morph — travel between surfaces vs in-place shape change),
  **continuity transition**, **anticipation**, **follow-through**, **perceptual duration**,
  **mask** (disambiguated from clip-path — soft/fadeable edges), **skeleton/shimmer**,
  **number ticker + tabular numbers**, **parallax**, **page transition**. The existing 8
  terms are unchanged in the diff.
- [auto] The same file's review section gains all five reviewer mechanics: (a) a
  cohesion/personality standard including the delete-when-unsure move; (b) a hard-flag
  trigger list (minimum: scale(0)/pure-fade entrances, unjustified >300ms UI durations,
  keyframed animation on rapidly-retriggered elements, ungated hover effects, symmetric
  press/hold timing, everything-at-once entrances where a stagger belongs); (c) an ordered
  remedial hierarchy starting at delete (delete → reduce → fix easing → fix origin → make
  interruptible → move to GPU → asymmetric timing → polish); (d) the review verdict ends in
  an explicit Block/Approve with stated block criteria; (e) reviewer posture — default to
  flagging, approval is earned, findings cite file:line.
- [auto] The same file's live-surfaces section gains the four missing rules — the streamed
  answer **grows into the screen** after anchoring (never pushes content away), **arbitrary
  navigation** (jump-to-message, message links, search, unread markers) as behaviors,
  **long-thread responsiveness** as an obligation, and **live-surface accessibility**
  (keyboard focus preserved through streaming; arrivals announced at a comfortable pace,
  cross-referencing the a11y semantics floor) — plus **reopen at the last user message**
  named as the default reopen position.
- [auto] `references/motion-cookbook.md` gains: a **curved-path** technique entry (when a
  trajectory reads better than a straight translate; arc-style APIs as the hedged web
  example); a **cross-container motion** pattern (flatten the logical tree to one
  layer/coordinate space for motion that crosses container boundaries; transient affordances
  — drag/drop targets — render as overlays above the whole composition, never intrinsic
  per-container; place-at-full-size-then-slide to avoid resize jitter); and a brief
  **3D/perspective** entry so `interaction-craft.md`'s "3D" pointer no longer dangles.
- [auto] **No weakening:** existing vocabulary terms, review-table rows, live-surface state
  grammar, and cookbook entries unchanged in the diff — pure addition.

### Behavioral completeness
- [auto] The dangling-pointer fix resolves: the craft file's "3D" reference points at content
  that now exists in the cookbook (grep both sides).
- [auto] `scripts/check-neutral.sh` exits 0; both script self-tests pass; `scripts/`
  untouched vs `main`.

## verification
verifier subagent against this file (docs greps: term list present with existing terms
untouched, five reviewer mechanics, four live-surface rules + reopen default, cookbook
entries + resolved pointer, no-weakening sweep) + `scripts/check-neutral.sh` + both script
self-tests. No surface/action change → no runtime walk; no hard invariant → no
`/security-review`.

verified: clean at 89d45ef, 2026-07-01, via fresh-context verifier subagent — all conditions pass: 11 vocabulary terms in house format with the pre-existing 8 untouched, all five reviewer mechanics incl. the exact 8-step remedial hierarchy and six hard flags, four live-surface rules + reopen-at-last-user-message default, cookbook curved-path/cross-container/3D entries resolving the dangling "3D" pointer, zero deletions across a 2-file diff, check-neutral PASS + 12/12 + 17/17 self-tests with scripts/ untouched; the disclosed reopen-bullet overlap is consistent (the new bullet specializes the existing "last meaningful position" rule for conversation surfaces) (evidence: verifier report in PR)
