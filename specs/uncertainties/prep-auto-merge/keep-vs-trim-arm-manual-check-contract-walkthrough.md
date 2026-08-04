# Uncertainty — kept arm-auto-merge's manual check-contract walkthrough as an explicit fallback

**The choice made.** In `skills/arm-auto-merge/SKILL.md`'s "First, once per project" section, I **kept**
the hand-authoring walkthrough for `.claude/keel-auto-merge-checks.json` and added a lead paragraph
framing `keel:prep-auto-merge` as the easy path, with the rest of the section relabeled the **manual
fallback / reference for what prep generates**.

**The viable alternative.** **Trim** the section to a one-line pointer at `keel:prep-auto-merge` (the tool
that now generates the contract), deleting the hand-authoring shape entirely — so there is exactly one
authoritative procedure for the artifact and no chance of two prose copies drifting.

**Why it's uncertain.** The milestone spec explicitly left this a **deliberate build call** (done-condition
`skills/arm-auto-merge/SKILL.md`, line 134-139: "trim it to a pointer … *or* keep it explicitly as the
manual fallback"). I chose keep because: (1) a maintainer arming a repo without running prep still needs the
contract's shape, precedence, and never-weakens rules in one place; (2) the walkthrough already carries the
security rationale (why names-only, why no `pattern`/`external`) that a bare pointer would strand; (3) the
relabel to "manual fallback / reference" removes the *silent-drift* risk the done-condition worried about —
it's now explicitly the reference, not a second "authoritative" path. A reasonable reviewer could still
prefer the trim: two prose descriptions of the same JSON shape (here and in prep's SKILL.md) can drift on a
future contract change even when one is labelled the reference, and DRY would delete one. If the contract
shape changes again, revisit whether the manual copy still earns its place.
