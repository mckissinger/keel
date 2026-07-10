# Chore batch — release 1.7.0

Minor release that surfaces the `spec-feature-reference-enforcement` milestone (plan PR
#100, code PR #101, landed on `main` at `fed8464` with its verified pin at `a5d6bbb`) to the
installed runtime. The change is fully merged in source but the installed plugin cache
reports `1.6.0` — the running `spec-feature` still treats reference research as permissive
("may be consulted" / "may be fed"), records no `flow research:` entry or sketch lineage,
and the running `review-feature` does not consult feature-spec lineage. Reinstalling over
the same version number is unreliable (the cache dedupes on version), so the version must
move before an update can pick it up. The `v1.7.0` release tag is cut on merge.

## Applied items

- **plugin-version-1.7.0** — `.claude-plugin/plugin.json` `version` bumped `1.6.0` → `1.7.0`
  (minor: new capabilities — spec-feature's design-reference-MCP touchpoints become
  default-on when a source is connected, with the mandatory `flow research:` feature-spec
  entry, sketch lineage recorded with retroactive citation banned, the autonomy-mode ledger
  clause, and review-feature's consultation of feature-spec sketch lineage — added since
  1.6.0; no removals or breaking changes: the flows-not-looks boundary, the
  novel-archetype-only gating, the pure-recomposition guard, and the text-only floor all
  survive; no script, hook, gate, or skill frontmatter changed since `9cfebcb`, only skill
  prose in two files plus this release's own specs). `.claude-plugin/marketplace.json`
  carries no `version` field, so it is unchanged.

## Combined checks

`claude plugin validate --strict .`, `bash scripts/check-neutral.sh`, `bash
scripts/check-plan.sh`. The reference-enforcement content itself landed verified with #101
(pin at `a5d6bbb`) and is unaffected by a version-string change.

## verification

fresh-context verifier subagent against this file + the diff: the branch changes exactly two
files (`.claude-plugin/plugin.json` + this chore spec); the `plugin.json` diff is exactly the
`version` `1.6.0`→`1.7.0` line and no other field; the result is valid JSON; nothing else in
the tree moves. `claude plugin validate --strict .` + `check-neutral` + `check-plan` green.
No merge-decision mechanism, skill, script, or hook behavior is touched by a version string →
no `/security-review`. The version-visible-to-the-installed-runtime effect is a [runtime]
property that only a reinstall proves — carried into the post-merge install (tag + plugin
update on merge), correctly out of branch scope.

verified: clean at d34b92b, 2026-07-10, via fresh-context keel:verifier subagent — the branch
changes exactly two files vs `main` (`.claude-plugin/plugin.json` + this chore spec); the
`plugin.json` diff is a single hunk, exactly `version` `1.6.0`→`1.7.0` with every other field
unchanged; `python3 -m json.tool` confirms valid JSON; `marketplace.json` unchanged (empty
diff, no version field). `claude plugin validate --strict .` ✔, `check-neutral.sh` PASS,
`check-plan.sh` PASS (42 milestone + 15 chore specs). Minor-bump sanity: the default-on
flow-research paragraph (`spec-feature/SKILL.md:37`), the `flow research:` entry (`:61`,
`:75`), and review-feature's sketch-lineage consultation (`review-feature/SKILL.md:25`) are
really there to surface; `git diff main --name-only -- scripts/ hooks/` empty; HEAD's parent
is the PR #101 merge (`fed8464`). The version-visible-to-installed-runtime effect is the
disclosed [runtime] property closed by the post-merge tag + plugin update, out of branch
scope. No merge-decision mechanism touched → no `/security-review`. (evidence: verifier
report in PR)
