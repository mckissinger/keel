# Milestone — Bootstrap window for the verified-pin gate

**Goal:** foundation-window PRs (specs + CI + pin script + CLAUDE.md, the workbench, the
scaffold) pass `check-verified-pin.sh` via an explicit bootstrap window that closes
permanently when the first milestone or chore spec lands — with behavior byte-identical to
today after that point.

**Change:** `specs/changes/bootstrap-gate.md`. **No-UI** → two-dimension done-conditions.
**Depends on:** nothing. **Parallelizable:** n/a (single milestone).

## Done-conditions

### Logic / invariants
- [auto] `scripts/check-verified-pin.sh` gains a bootstrap-window exemption: when no file
  matching `specs/milestones/*.md` or `specs/chores/*.md` exists in the tree at **both** the
  merge-base of `BASE_REF`/`HEAD_REF` **and** at `HEAD_REF`, the script exits 0 with an
  explicit bootstrap-window message stating the reason and that the gate arms when the first
  milestone/chore spec lands. Glob semantics identical to the step-3 spec matcher.
- [auto] **Deletion-proof:** a PR whose merge-base contains any milestone/chore spec never
  enters the window, regardless of what the PR deletes — a head that removes all milestone
  specs still fails exactly as today.
- [auto] **HEAD-side closure:** a code PR that itself adds the first milestone/chore spec is
  validated by the normal pinned path (passes with a valid drift-free pin, fails without) —
  never exempted.
- [auto] **Fail-safe:** if the merge-base cannot be computed, the window is treated as closed
  (no exemption).
- [auto] **Post-window behavior byte-identical:** every pre-existing test case in
  `scripts/check-verified-pin.test.sh` passes unmodified — no existing assertion edited or
  deleted.

### Behavioral completeness
- [auto] New test cases in `scripts/check-verified-pin.test.sh` cover, minimum: (a) a
  foundation-shaped PR (specs/ + `.github/workflows/` + `scripts/` + CLAUDE.md, no
  milestone/chore spec at either end) passes with the bootstrap-window message; (b) the
  deletion case fails; (c) the first-milestone code PR validates normally both with and
  without a pin; (d) a `specs/chores/*.md` file also closes the window.
- [auto] The script's header comment documents the window (it is the canonical
  copy-into-project artifact — its self-documentation is the spec downstream projects read).
- [auto] `skills/spec-foundation/SKILL.md` Repo setup documents the window in ≤2 sentences
  (the foundation PR passes via the bootstrap window; the gate arms itself when the first
  milestone or chore spec lands). No other file restates the rule (one owner).
- [auto] `scripts/check-neutral.sh` exits 0; both script self-tests
  (`check-neutral.test.sh`, `check-verified-pin.test.sh`) pass.

## verification
verifier subagent against this file (script-behavior assertions exercised through the
committed test suite, not re-derived; docs greps for the header + Repo setup sentences +
one-owner sweep) + both script self-tests. **`/security-review` pre-pin** — this loosens the
gate itself (hard invariant); the adversarial questions: can the window be entered after
bootstrap, reopened by deletion or history manipulation, or widened beyond
no-milestones-exist? No surface/action change → no runtime walk.
