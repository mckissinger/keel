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
  matching `specs/milestones/**.md` or `specs/chores/**.md` exists in the tree at **both**
  the tip of `BASE_REF` **and** at `HEAD_REF`, the script exits 0 with an explicit
  bootstrap-window message stating the reason and that the gate arms when the first
  milestone/chore spec lands. Glob semantics match the step-3 spec matcher, robust to git
  path-quoting (unusual filenames must still close the window). *(Amended during build: the
  plan said merge-base; the pre-pin security review reproduced a HIGH bypass — a branch
  rooted at a pre-first-spec commit makes the merge-base predate the spec and re-enters the
  window — so the window is judged at the base tip, which no branch root can influence.)*
- [auto] **Deletion-proof and root-proof:** a PR whose base tip contains any milestone/chore
  spec never enters the window — neither by deleting specs at HEAD nor by rooting the branch
  at a pre-first-spec commit (the reproduced attack; asserted by a dedicated test case).
- [auto] **HEAD-side closure:** a code PR that itself adds the first milestone/chore spec is
  validated by the normal pinned path (passes with a valid drift-free pin, fails without) —
  never exempted.
- [auto] **Fail-safe:** an unresolvable `BASE_REF`/`HEAD_REF` fails the gate closed — explicit
  `git rev-parse --verify` guards on both refs run before any diff, covered by test cases.
  *(Amended after the first verification bounced this condition: the plan claimed `set -e`
  kills the script at the diff, but the failure hides inside a process substitution and the
  empty diff read as "no changes — pass" — a fail-open the verifier reproduced. The guards
  make the claimed property actually true.)*
- [auto] **Post-window behavior identical:** every pre-existing assertion in
  `scripts/check-verified-pin.test.sh` keeps its expected outcome, with one build-discovered
  fixture amendment: case 4 ("code PR touching no milestone spec fails") presumed a
  post-bootstrap repo but sat on a base with no milestone specs — inside the window it never
  anticipated — so its fixture re-bases onto a window-closed base while its expectation
  stands unweakened. (Its original shape, pure code off a spec-less base, is the scaffold PR
  the window exists to pass, asserted as a new case.) No other case's fixture or expectation
  changes.

### Behavioral completeness
- [auto] New test cases in `scripts/check-verified-pin.test.sh` cover, minimum: (a) a
  foundation-shaped PR (specs/ + `.github/workflows/` + `scripts/` + CLAUDE.md, no
  milestone/chore spec at either end) passes with the bootstrap-window message; (b) the
  deletion case fails; (c) the first-milestone code PR validates normally both with and
  without a pin; (d) a `specs/chores/*.md` file also closes the window; (e) the pre-spec
  branch-root attack fails post-bootstrap; (f) an unusual (non-ASCII) spec filename still
  closes the window.
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
