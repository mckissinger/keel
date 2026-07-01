# M6 — Cleanup + guard: README claim, vestigial README, neutrality guard extension

**Feature:** design-track-neutral. **Depends on:** M2 + M3 + M5 (the guard's new checks require the corpus already clean). **Parallelizable:** no — runs last.
**Files owned:** `README.md`, `skills/app-design-directions/README.md`, `scripts/check-neutral.sh`, `scripts/check-neutral.test.sh`.

## Goal

Land the parked cleanups and extend the neutrality guard to lock the new design-neutrality invariants so they can't regress — the same discipline as `check-verified-pin`.

## Done-conditions

1. **[auto] README neutrality claim reconciled.** The top-level `README.md` no longer claims keel "works the same" for a mobile app without qualification. It states honestly: the build/verify spine + design track are **framework-neutral by profile**, **web is the proven/tested path**, and **mobile is derivable via the profile** and hardened when a real mobile project runs (per "neutral seams now, web hardened"). The "15 skills" / grain-ladder content stays accurate.
2. **[auto] Vestigial design README removed/folded.** `skills/app-design-directions/README.md` no longer presents the skill as a standalone product with `cp -r … ~/.claude/skills/` install instructions and self-referential research notes that contradict the plugin install story — it is removed, or reduced to a short pointer consistent with the plugin.
3. **[auto] Guard extended for design-neutrality.** `scripts/check-neutral.sh` gains checks that fail when `@theme`, Lucide, or Recharts (or an equivalent web-hardcode) appears **in the shared neutral corpus** (`references/milestones-and-verification.md`, `references/profile-interface.md`, `skills/implement-milestone`, `skills/spec-feature`, `skills/spec-change`, `skills/verify-milestone`) — while **not** flagging the design-track files (`skills/app-design-directions/**`, `references/motion-cookbook.md`) where such names are legitimate examples. The scoping is explicit.
4. **[auto] Guard self-test covers the new checks.** `scripts/check-neutral.test.sh` gains cases proving the new behavior: a shared-corpus fixture containing `@theme` **fails**; a design-track fixture containing `@theme` **passes**. `bash scripts/check-neutral.test.sh` is green.
5. **[auto] Whole-repo clean.** After all milestones land, `bash scripts/check-neutral.sh` passes on the repo, and `node --check` on both workflows still passes (no regression). CI (`.github/workflows/ci.yml`) is green.
6. **[completeness] No dangling references.** Removing/folding the design README leaves no broken links from other docs.

## Verification

`verification: verifier subagent against this milestone's done-conditions, + bash scripts/check-neutral.test.sh + bash scripts/check-neutral.sh`.

verified: clean at eb6c7c5, 2026-07-01, via verifier subagent against done-conditions + adversarial guard injection (in-corpus @theme→exit 1, design-track @theme→exit 0) + check-neutral.test.sh (12/12) + check-neutral.sh + node --check on both workflows (all six DCs PASS; evidence in PR). [carry-forward: originally verified clean at d1273b3 on the M1–M5 integration; conflict-only rebase onto main (identical content, guard suite re-run green) re-pinned to eb6c7c5]
