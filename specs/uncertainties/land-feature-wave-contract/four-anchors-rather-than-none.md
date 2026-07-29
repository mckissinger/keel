# Uncertain choice — the new rules are pinned by FOUR anchors in a new anchor file, not left unpinned

**Choice made.** `scripts/skill-anchors/land-feature-wave-contract.txt` declares four positive anchors
over `skills/land-feature/SKILL.md`: the partial-list refusal (with its `exit non-zero having deleted
nothing` clause), the decoupled post-wave-deletion alternative, pending-kept-distinct-from-failure, and
the observed-CI window. Each is a single-line clause carrying its rule's operative meaning, so a reword
that guts the rule drops the anchor.

**Viable alternative considered.** Add no anchor file at all (the milestone's diff condition permits
either: "if an anchor is added ... nothing else"), or pin fewer — one anchor per rule rather than per
clause, which would leave the OR-alternative and the window-sizing half unguarded.

**Why it's uncertain.** The spec neither requires nor forbids anchors, and the anchors lint exists for
prose another contract depends on — arguably a narrower category than "prose that would be bad to
lose." Pinning was chosen because both rules are exactly the class the lint was built for: sentences
whose operative half (the *refusal*, the *non-failure exit code*, the *observed* window) is what makes
them contracts rather than advice, and each was born from a specific field loss that a well-meaning
compression would erase. The cost is real, though: four fixed strings including bold markers make the
subsection expensive to reword, and a reviewer who prefers anchors reserved for cross-skill seams —
or who wants two coarser anchors so the prose stays editable — would cut this back.

**Verified present** — `scripts/check-skill-anchors.sh` reports 66 anchors across 11 feature files
(was 62 across 10).
