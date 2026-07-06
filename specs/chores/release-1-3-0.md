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

verified: clean at 307a0e3, 2026-07-05, via fresh-context keel:verifier subagent — the branch
changes exactly two files vs `main` (`.claude-plugin/plugin.json` + this chore spec, `git diff
main --name-only`); the `plugin.json` diff is a single hunk, exactly `version` `1.2.1`→`1.3.0`
with every other field unchanged context; `python3 -m json.tool` confirms valid JSON;
`.claude-plugin/marketplace.json` unchanged vs `main` (empty diff); `claude plugin validate
--strict .` `✔ Validation passed` (exit 0), `scripts/check-neutral.sh` PASS, `scripts/check-plan.sh`
PASS (37 milestone + 8 chore specs well-formed). Minor bump (auto:genesis is a new capability, no
removals/breaking changes). The version-visible-to-installed-runtime effect is the disclosed
[runtime] property closed by the user's post-merge tag + reinstall, out of branch scope. No
merge-decision mechanism touched → no `/security-review`. (evidence: verifier report in PR)
