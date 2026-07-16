# Chore batch — release 1.13.0

Minor release that surfaces the **marketing-site** milestone (plan PR #132, code PR
#133, landed on `main` at `90dea69` with its verified pin at `056ef9b`) to the
installed runtime. The changes are fully merged in source but the installed plugin
cache reports an earlier version — the running plugin has no `marketing-site` verb, so
"build me a landing page" has no skill to route to and the orientation banner carries
no Marketing line. Reinstalling over the same version number is unreliable (the cache
dedupes on version), so the version must move before an update can pick it up. The
`v1.13.0` release tag is cut on merge.

## Applied items

- **plugin-version-1.13.0** — `.claude-plugin/plugin.json` `version` bumped `1.12.0` →
  `1.13.0` (minor: one new skill, no removals or breaking changes; no gate, hook,
  guard, or script *semantics* change since `28c55d5` — the only script edits are the
  banner's added Marketing line and its two new test assertions). Since 1.12.0:
  **marketing-site** (#133) — the new marketing-surface verb (landing page or full
  marketing website, post-app primary with a greenfield fork) with its three
  skill-local references (conversion-craft, asset-pipeline, hero-treatments) and three
  templates (marketing brief, variant spec, generate-asset script); ladder wiring
  (README Marketing line + skills bullet, count 21→22; both session-bootstrap banner
  copies + two test assertions); one routing sentence in `app-design-directions`.
  Prose + one template script, 12 files. `.claude-plugin/marketplace.json` carries no
  `version` field, so it is unchanged.

## Combined checks

`claude plugin validate --strict .`, `bash scripts/check-neutral.sh`,
`bash scripts/check-plan.sh`. The released content itself landed verified with #133
(pin at `056ef9b`) and is unaffected by a version-string change.

## verification

fresh-context verifier subagent against this file + the diff: the branch changes
exactly two files (`.claude-plugin/plugin.json` + this chore spec); the `plugin.json`
diff is exactly the `version` `1.12.0`→`1.13.0` line and no other field; the result is
valid JSON; `marketplace.json` unchanged; nothing else in the tree moves.
`claude plugin validate --strict .` + `check-neutral` + `check-plan` green.
Minor-bump sanity: `skills/marketing-site/SKILL.md` exists with valid frontmatter, the
README ladder and both banner copies carry the Marketing line, and
`scripts/check-skill-frontmatter.sh` reports 22 skills. History since `28c55d5` is
exactly PRs #132 and #133 (the milestone's plan and code PRs); the branch is one
commit ahead of `main`. No merge-decision mechanism is touched by a version string →
no `/security-review`. The version-visible-to-the-installed-runtime effect is a
[runtime] property that only a reinstall proves — carried into the post-merge install
(tag + plugin update on merge), correctly out of branch scope.
verified: clean at 72fe862, 2026-07-16, via fresh-context keel:verifier subagent — branch changes exactly two files vs main (plugin.json + this chore spec); the plugin.json diff is the single version 1.12.0→1.13.0 line, JSON valid, marketplace.json unchanged; plugin validate + check-neutral + check-plan green; marketing-site skill present with valid frontmatter, README + both banner copies carry the Marketing line, 22 skills reported; history 28c55d5..main is exactly PRs #132 and #133; one commit ahead of main. Runtime pickup deferred to post-merge tag + reinstall per this spec (evidence in PR #134)
