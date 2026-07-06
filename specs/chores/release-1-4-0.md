# Chore batch — release 1.4.0

Minor release that surfaces the `review-hardening` feature (PRs #90 gate → #91 ci-doctrine
→ #92 skills, plus the #93 prose chore, all landed on `main`) to the installed runtime. The
feature is fully merged in source but the installed plugin cache still reports `1.3.0` with
the pre-hardening build — the running `check-verified-pin.sh` still passes open on a missing
merge base and classifies `specs/stack-profile.md` as plan, the running
`guard-branch-rules.sh` still exits 0 reader-less, the running skills still demand
`design/mockups/` as a precondition, and `check-skill-anchors.sh` has no negative-anchor
support. Reinstalling over the same version number is unreliable (the cache dedupes on
version), so the version must move before a reinstall can pick up the hardening. The
`v1.4.0` release tag is the user's to cut on merge.

## Applied items

- **plugin-version-1.4.0** — `.claude-plugin/plugin.json` `version` bumped `1.3.0` → `1.4.0`
  (minor: new capabilities — the merge-base fail-closed precondition + runtime-affecting
  plan carve-outs in the shipped gate, the reader-less fail-closed branch guard, keel's
  self-gate CI pattern, negative anchors in the anchor lint, the debug→punch-list/spec-change
  routing rule, the require-branches-up-to-date protection requirement — added since 1.3.0;
  no removals or breaking changes: every existing gate verdict, guard exit code, and skill
  frontmatter is unchanged for previously-valid inputs, per the m1–m3 suites).
  `.claude-plugin/marketplace.json` carries no `version` field, so it is unchanged.

## Combined checks

`claude plugin validate --strict .` (validation passed), `bash scripts/check-neutral.sh`
(PASS), `bash scripts/check-plan.sh` (PASS). The review-hardening suites — check-verified-pin
(27), guard-branch-rules (55), merge-guard (102), session-bootstrap (36), check-skill-anchors
(14) and the rest — already landed with #90–#93 and are unaffected by a version-string change.

## verification

fresh-context verifier subagent against this file + the diff: the branch changes exactly two
files (`.claude-plugin/plugin.json` + this chore spec); the `plugin.json` diff is exactly the
`version` `1.3.0`→`1.4.0` line and no other field; the result is valid JSON; nothing else in
the tree moves. `claude plugin validate --strict .` + `check-neutral` + `check-plan` green.
No merge-decision mechanism, skill, script, or hook behavior is touched by a version string →
no `/security-review`. The version-visible-to-the-installed-runtime effect is a [runtime]
property that only a reinstall proves — carried into the post-merge install (the user cuts the
`v1.4.0` tag and reinstalls), correctly out of branch scope.
