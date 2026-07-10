# Chore batch — release 1.6.0

Minor release that surfaces the `spec-feature-flow-research` chore (PR #98, landed on
`main` at `ca11b52`) to the installed runtime. The change is fully merged in source but the
installed plugin cache reports `1.5.0` built from `fea4d8d` — the running `spec-feature`
skill has no scoped flow-level reference-research provision in Movement 1 (no
`search_flows` interaction-pattern research during state enumeration). Reinstalling over
the same version number is unreliable (the cache dedupes on version), so the version must
move before an update can pick it up. The `v1.6.0` release tag is cut on merge.

## Applied items

- **plugin-version-1.6.0** — `.claude-plugin/plugin.json` `version` bumped `1.5.0` → `1.6.0`
  (minor: new capability — Movement 1 of `spec-feature` now permits a connected
  design-reference MCP's flow-level search (Mobbin `search_flows` as the known instance)
  for interaction-pattern research during state/interaction enumeration, landing as
  UX-completeness done-conditions only, with looks-level pulls staying gated at Movement
  2's novel-archetype divergence-sketch case — added since 1.5.0; no removals or breaking
  changes: no script, hook, gate, or skill frontmatter changed since `fea4d8d`, only the
  one skill-prose paragraph and its chore spec). `.claude-plugin/marketplace.json` carries
  no `version` field, so it is unchanged.

## Combined checks

`claude plugin validate --strict .`, `bash scripts/check-neutral.sh`, `bash
scripts/check-plan.sh`. The flow-research content itself landed verified with #98 (batch
pin at `1a75843`) and is unaffected by a version-string change.

## verification

fresh-context verifier subagent against this file + the diff: the branch changes exactly two
files (`.claude-plugin/plugin.json` + this chore spec); the `plugin.json` diff is exactly the
`version` `1.5.0`→`1.6.0` line and no other field; the result is valid JSON; nothing else in
the tree moves. `claude plugin validate --strict .` + `check-neutral` + `check-plan` green.
No merge-decision mechanism, skill, script, or hook behavior is touched by a version string →
no `/security-review`. The version-visible-to-the-installed-runtime effect is a [runtime]
property that only a reinstall proves — carried into the post-merge install (tag + plugin
update on merge), correctly out of branch scope.

verified: clean at 2590423, 2026-07-10, via fresh-context keel:verifier subagent — the branch
changes exactly two files vs `main` (`.claude-plugin/plugin.json` + this chore spec, `git diff
main --name-only`); the `plugin.json` diff is a single hunk, exactly `version` `1.5.0`→`1.6.0`
with every other field unchanged; `python3 -m json.tool` confirms valid JSON;
`.claude-plugin/marketplace.json` unchanged vs `main` (empty diff, no version field). `claude
plugin validate --strict .` ✔ (exit 0), `scripts/check-neutral.sh` PASS, `scripts/check-plan.sh`
PASS (41 milestone + 14 chore specs well-formed). Minor-bump sanity spot-checked on the branch:
the flow-research paragraph is really there to surface (`search_flows`,
`skills/spec-feature/SKILL.md:37`); `git diff main --name-only -- scripts/ hooks/` empty (no
gate, script, or hook changes); HEAD sits one commit atop the PR #98 merge (`ca11b52`). The
version-visible-to-installed-runtime effect is the disclosed [runtime] property closed by the
post-merge tag + plugin update, out of branch scope. No merge-decision mechanism touched → no
`/security-review`. (evidence: verifier report in PR)
