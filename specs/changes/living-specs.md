# Change — Living specs: post-merge reconciliation + orient-first

**Grain:** one change → one milestone (`spec-change`). **No-UI** (methodology prose).
**Stacked on:** nothing (targets `main`).

## Why (the gap)

Two adjacent lifecycle gaps the research pass surfaced (items 13–14), both about what a spec
means *after* its code lands:

1. **No post-merge reconciliation.** keel has the deferrals archive and drift-rides-the-branch,
   but nothing reconciles specs *after* a pin merges. keel's own repo already shows the smell —
   a flat `specs/milestones/` with landed and future milestones intermixed, and `features/`
   that can describe superseded reality. The CLAUDE.md template says "resolve in favor of the
   spec" with no post-merge carve-out — the exact ambiguity that lets a later session "fix"
   correct merged code to match a stale spec. OpenSpec's archive-on-merge is the proven fix;
   keel's verified pin gives it a safe reconciliation moment OpenSpec lacks.
2. **No fixed session-start protocol.** keel mandates *derived* status but never says *when*;
   a pre-existing red is discovered mid-build and entangled with the milestone's own diff, so
   "did this milestone break that" becomes unrecoverable. Anthropic's long-running-agents post
   prescribes a fixed start protocol; Willison codifies "first run the tests."

## The mechanic

1. **Post-merge reconciliation** — a final `land-feature` step (after the post-wave check):
   in one plan-only commit, update `specs/features/<feature>.md` (and 00-product/01-architecture
   if shapes changed) to merged reality, and archive completed milestone specs into
   `specs/milestones/_landed/` (mirroring the `deferrals/_closed.md` precedent). **Gate
   interaction:** `check-verified-pin.sh`'s spec glob matches `specs/milestones/*.md` — archive
   strictly post-merge (the reconciliation commit is plan-only, so the bootstrap/plan-only
   exemption covers it), and confirm the archived path isn't re-scanned as an active spec.
2. **Spec-authority rule** — in `milestones-and-verification.md` §5 + the CLAUDE.md template's
   Derived-status bullet: after a pin merges, the milestone spec is **historical — code is
   authoritative**; never "fix" merged code to match a stale spec. Living docs
   (features/product/architecture) are updated by whichever later milestone invalidates them —
   extending implement-milestone step 6's drift rule from "drift I caused" to "living docs my
   change made stale."
3. **Orient-first** — an "Orient first" step before implement-milestone's "Branch first," plus
   the CLAUDE.md template (slotting alongside the existing Derived-status/preflight bullets):
   every fresh/resumed build session (a) derives state — pins in `specs/milestones/` + `gh pr
   list` + recent `git log`; (b) re-reads the milestone spec + stack profile from `main`; (c)
   runs the profile's cheapest committed rung once **before** writing code — a pre-existing red
   is a stop-point or routes to `debug`, never absorbed into the milestone.

**Not weakened:** the drift-rides-the-branch rule and the deferrals archive are unchanged; this
extends them to the post-merge moment and adds a start protocol.

## Scope

Prose in `skills/land-feature/SKILL.md`, `skills/implement-milestone/SKILL.md`,
`skills/spec-foundation/SKILL.md` (CLAUDE.md template + the `_landed/` structure note),
`references/milestones-and-verification.md` §5. `check-neutral.sh` green; `check-plan.sh` must
still pass (the `_landed/` archive path must not trip the lint — confirm or scope the lint's
glob). No script behavior change.
