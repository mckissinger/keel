# Change — Diamond milestone (multi-parent) landing

**Grain:** one change → one milestone (`spec-change`). **No-UI** (methodology/docs change to keel itself).

## Why (the gap)

`implement-feature` and `land-feature` encode shallow stacks and the retarget-before-delete / conflict-only-rebase cascade, but neither addresses a **diamond milestone** — one that genuinely depends on *all* its sibling milestones **and** carries an "after all land" whole-repo condition. This is a **recurring shape for keel**, not a one-off: features tend to end in a terminal guard/cleanup milestone that locks a whole-repo invariant (the design-track-neutral feature's M6 — "cleanup + guard" — depended on M1–M5 and its extended neutrality guard had to pass on the fully-assembled corpus).

A diamond can't be a normal single-parent stacked PR. Building + verifying it on a conflict-free **integration branch** (a merge of all its parents) works — and is safe precisely because disjoint file ownership makes the integration tree byte-identical to the eventual `main`. But it leaves the diamond branch with **multiple merge bases** vs `main`, so `git diff main...HEAD` (three-dot, what `check-verified-pin.sh` uses) picks an older base and **falsely reports code drift** on the already-verified sibling files at land time. Left un-encoded, this is re-derived under pressure at the merge — exactly the "drawn blood" class `land-feature` exists to prevent.

## The mechanic (proven live, design-track-neutral M6, 2026-07)

- **Build (`implement-feature`):** a milestone that depends on all siblings + an "after all land" whole-repo check is built + verified on a conflict-free **integration branch** (merge of its parent milestones), its PR based on that branch, kept **last**. It cannot be represented as a single-parent stacked PR.
- **Land (`land-feature`):** land it only after all its parents are merged to `main`. Then **rebase the diamond branch onto `main`** (dropping the integration parentage) to collapse the multiple-merge-base artifact → single base, clean own-files-only diff, pin gate verifies cleanly. It's a **conflict-only rebase** (content identical), so re-run the guard/suite green and **re-pin to the new `HEAD^`** with a carry-forward note (reusing the existing conflict-only-rebase rule). Then merge, and **delete the integration scaffolding branch** at the end. The post-wave consolidated check still runs last.

## Scope

Two files. No behavior/tooling change — pure methodology prose. Keep it consistent with the existing "keep stacks shallow / prefer independent off `main`" guidance: the diamond is the **exception** that a genuine multi-parent dependency forces, not a license to build deep stacks.
