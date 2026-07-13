# Chore batch — release 1.9.0

Minor release that surfaces the `helper-verbs` milestone (plan PR #118, code PR #120,
landed on `main` at `9740f9c` with its verified pin at `49e52f2`) to the installed
runtime. The changes are fully merged in source but the installed plugin cache reports
`1.8.0` — the running plugin has 19 skills, no `demo` and no `test-health`.
Reinstalling over the same version number is unreliable (the cache dedupes on
version), so the version must move before an update can pick it up. The `v1.9.0`
release tag is cut on merge.

## Applied items

- **plugin-version-1.9.0** — `.claude-plugin/plugin.json` `version` bumped `1.8.0` →
  `1.9.0` (minor: new capabilities — the `demo` skill, the mid-build attended
  gateless show-me-the-app verb, and the `test-health` skill, the suite
  flakiness/efficiency audit that decomposes into keel grains — plus their
  README/banner wiring; skill count 19 → 21; no removals or breaking changes; no
  gate, hook, or guard semantics change since `fe402d8` — the banner gained the two
  verb names, covered by its self-test). `.claude-plugin/marketplace.json` carries no
  `version` field, so it is unchanged.

## Combined checks

`claude plugin validate --strict .`, `bash scripts/check-neutral.sh`,
`bash scripts/check-plan.sh`. The helper-verbs content itself landed verified with
#120 (pin at `49e52f2`) and is unaffected by a version-string change.

## verification

fresh-context verifier subagent against this file + the diff: the branch changes
exactly two files (`.claude-plugin/plugin.json` + this chore spec); the `plugin.json`
diff is exactly the `version` `1.8.0`→`1.9.0` line and no other field; the result is
valid JSON; `marketplace.json` unchanged; nothing else in the tree moves.
`claude plugin validate --strict .` + `check-neutral` + `check-plan` green.
Minor-bump sanity: `skills/demo/SKILL.md` and `skills/test-health/SKILL.md` exist and
README reads 21 skills. History since `fe402d8` is exactly PRs #118 and #120; the
branch is one commit ahead of `main`. No merge-decision mechanism, skill, script, or
hook behavior is touched by a version string → no `/security-review`. The
version-visible-to-the-installed-runtime effect is a [runtime] property that only a
reinstall proves — carried into the post-merge install (tag + plugin update on
merge), correctly out of branch scope.
