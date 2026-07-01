# Diamond milestone (multi-parent) — build + land handling

**Change:** diamond-milestone-land. **Depends on:** nothing (docs/methodology change). **Parallelizable:** n/a (single milestone).
**Files owned:** `skills/land-feature/SKILL.md`, `skills/implement-feature/SKILL.md`.

## Goal

Encode, in the build + land skills, how to handle a **diamond milestone (multi-parent)** — one that genuinely depends on *all* its sibling milestones **and** carries an "after all land" whole-repo done-condition — so the integration-branch build and the rebase-to-`main` + re-pin at land time are not re-derived, and the multiple-merge-base pin-gate false positive is anticipated rather than hit. See `specs/changes/diamond-milestone-land.md` for the why. This is a **no-UI** change: correctness + completeness done-conditions, no fidelity, no runtime walk.

## Done-conditions

1. **[auto] land-feature defines the diamond case.** `skills/land-feature/SKILL.md` gains a subsection (placed after "When a review fix forces a rebase (the cascade)" and before "The post-wave consolidated check"), titled for the **diamond milestone (multi-parent)**. It states: (a) the trigger — a milestone depending on *all* siblings **plus** an "after all land" whole-repo check, distinct from a plain linear stack; (b) land it **only after all its parents are merged to `main`**; (c) then **rebase the diamond branch onto `main`** to collapse the multiple-merge-base artifact into a single base (a clean own-files-only diff); (d) it is a **conflict-only rebase** (content identical), so **re-run the guard/suite green and re-pin to the new `HEAD^`** with a carry-forward note — explicitly reusing the existing conflict-only-rebase rule, not inventing a new one; (e) then **merge, and delete the integration scaffolding branch**. It names **why** the rebase is needed: multiple merge bases make the three-dot `check-verified-pin.sh` diff falsely report drift on the already-verified sibling files.

2. **[auto] implement-feature names the integration-branch build.** `skills/implement-feature/SKILL.md` gains a concise pointer (at the Build step / the "keep stacks shallow" guidance) stating that a genuine **diamond** — depends on all siblings + an "after all land" whole-repo check — is built + verified on a **conflict-free integration branch** (a merge of its parent milestones; safe because disjoint file ownership makes the integration tree == the eventual `main`), its PR **based on that integration branch**, kept **last**, with the finish handed to `land-feature`. It must **not** contradict the existing "keep any stack as shallow as the genuine dependency chain requires / prefer independent milestones off `main`" guidance — the diamond is framed as the exception a real multi-parent dependency forces, not license for deep stacks.

3. **[completeness] Consistent + no dangling refs.** Both edits reuse existing vocabulary — the cascade section's **conflict-only rebase → re-run suite → re-pin to `HEAD^` + carry-forward note**, and the **retarget-before-delete** / close+reopen choreography — rather than restating divergent versions. The two skills stay consistent with each other (implement-feature builds it on the integration branch; land-feature rebases that branch onto `main` and finishes it). The post-wave consolidated check is noted to still run last. No section headers, cross-references, or the grain-ladder/handoff wording are left dangling by the insertions.

4. **[auto] Neutrality holds.** `bash scripts/check-neutral.sh` passes (both files are in the blanket neutral corpus; the new prose introduces no banned stack/command language, war-story project name, or editing scar).

## Verification

`verification: verifier subagent against this milestone's done-conditions, + bash scripts/check-neutral.sh`.

verified: clean at 8534f99, 2026-07-01, via verifier subagent against done-conditions + bash scripts/check-neutral.sh (all four DCs PASS; encoded mechanic cross-checked as technically sound against check-verified-pin.sh's three-dot diff; evidence in PR)
