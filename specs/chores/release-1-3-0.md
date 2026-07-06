# Chore batch — release 1.3.0

Minor release that surfaces the `auto-genesis` feature (PRs #84 doctrine → #85 posture →
#86 guards, all landed on `main`) to the installed runtime. The feature is fully merged in
source but the installed plugin cache still reports `1.2.1` with the pre-genesis build — the
running `skills/auto/SKILL.md` names only two postures and the running `merge-guard.sh` /
`guard-branch-rules.sh` whitelists are still `feature | run`, so a `level: "genesis"` mode
file would be treated absent and the genesis posture cannot run. Reinstalling over the same
version number is unreliable (the cache dedupes on version), so the version must move before a
reinstall can pick up genesis. The `v1.3.0` release tag is the user's to cut on merge.

## Applied items

- **plugin-version-1.3.0** — `.claude-plugin/plugin.json` `version` bumped `1.2.1` → `1.3.0`
  (minor: `auto:genesis` is a new capability — a third autonomy posture with its own
  doctrine, skill contract, and guard-recognized `level` — added since 1.2.1, no removals or
  breaking changes). `.claude-plugin/marketplace.json` carries no `version` field, so it is
  unchanged.

## Combined checks

`claude plugin validate --strict .` (validation passed), `bash scripts/check-neutral.sh`
(PASS), `bash scripts/check-plan.sh` (PASS). The genesis feature's own suites — merge-guard
(97), guard-branch-rules (39), session-bootstrap (34) and the rest — already landed with
#84–#86 and are unaffected by a version-string change.

## verification

fresh-context verifier subagent against this file + the diff: the branch changes exactly two
files (`.claude-plugin/plugin.json` + this chore spec); the `plugin.json` diff is exactly the
`version` `1.2.1`→`1.3.0` line and no other field; the result is valid JSON; nothing else in
the tree moves. `claude plugin validate --strict .` + `check-neutral` + `check-plan` green.
No merge-decision mechanism, skill, script, or hook behavior is touched by a version string →
no `/security-review`. The version-visible-to-the-installed-runtime effect is a [runtime]
property that only a reinstall proves — carried into the post-merge install (the user cuts the
`v1.3.0` tag and reinstalls), correctly out of branch scope.
