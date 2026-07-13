# Chore batch — release 1.10.0

Minor release that surfaces the **worktree-isolation** feature (plan PR #122, code PRs
#123 and #124, reconciled on `main` at `a82dd69`; pins at `b65b807` and `08a2c14`,
archived in `specs/milestones/_landed/`) to the installed runtime. The changes are
fully merged in source but the installed plugin cache reports `1.9.0` — the running
plugin has no Q13 isolation contract, an unconditional serialization rule, and a sweep
that can never close `[runtime]`. Reinstalling over the same version number is
unreliable (the cache dedupes on version), so the version must move before an update
can pick it up. The `v1.10.0` release tag is cut on merge.

## Applied items

- **plugin-version-1.10.0** — `.claude-plugin/plugin.json` `version` bumped `1.9.0` →
  `1.10.0` (minor: new capability, opt-in, no removals or breaking changes). Since
  1.9.0:
  - **isolation-contract** (#123): profile **Q13 — parallel-session (worktree)
    isolation contract** (instance identity, datastore recipe, per-instance env,
    teardown, allocation, proven flag + per-run isolation assertion); the spine's
    serialization rule, provision's one-stack mitigation, and Q12's gateway remedy
    each gained the proven-Q13 conditional — serial/single-stack stays the default.
  - **parallel-runtime-verification** (#124): the `verify-all-milestones` sweep may
    close `[runtime]` per-instance only under an orchestrator-passed proven-Q13
    brief (scoped walk; live never; default blocked path byte-identical to before);
    the verifier agent's bounded instance-scoped mutation license; the canonical
    reference/verify-milestone/implement-feature/punch-list reconciled.
  - The feature's reconciliation commit (`a82dd69`): Lifecycle closed, both milestone
    specs archived — plan-only.

  Both milestones landed with their own verified pins on their own PRs; the sweep's
  fail-safe default was proven byte-identical to the prior behavior at verification.
  `.claude-plugin/marketplace.json` carries no `version` field, so it is unchanged.

## Combined checks

`claude plugin validate --strict .`, `bash scripts/check-neutral.sh`,
`bash scripts/check-plan.sh`. The released content itself landed verified per-PR and
is unaffected by a version-string change.

## verification

fresh-context verifier subagent against this file + the diff: the branch changes
exactly two files (`.claude-plugin/plugin.json` + this chore spec); the `plugin.json`
diff is exactly the `version` `1.9.0`→`1.10.0` line and no other field; the result is
valid JSON; `marketplace.json` unchanged; nothing else in the tree moves.
`claude plugin validate --strict .` + `check-neutral` + `check-plan` green.
Minor-bump sanity: `references/profile-interface.md` carries Q13;
`workflows/verify-all-milestones.js` carries the isolation brief and passes
`node --check`; both milestone specs sit in `specs/milestones/_landed/` with their
pins. History since `8e33d59` is exactly PRs #122–#124 plus the reconciliation
commit; the branch is one commit ahead of `main`. No merge-decision mechanism is
touched by a version string → no `/security-review`. The
version-visible-to-the-installed-runtime effect is a [runtime] property that only a
reinstall proves — carried into the post-merge install (tag + plugin update on
merge), correctly out of branch scope.
