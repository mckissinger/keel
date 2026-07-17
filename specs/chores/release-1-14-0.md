# Chore batch — release 1.14.0

Minor release that surfaces the **product-video** milestone (plan PR #135, code PR
#136, landed on `main` at `7e7e4e2` with its verified pin at `bcfd5b2`) to the
installed runtime. The changes are fully merged in source but the installed plugin
cache reports an earlier version — the running plugin has no `product-video` verb, so
"make an onboarding video" has no skill to route to and the orientation banner carries
no Video line. Reinstalling over the same version number is unreliable (the cache
dedupes on version), so the version must move before an update can pick it up. The
`v1.14.0` release tag is cut on merge.

## Applied items

- **plugin-version-1.14.0** — `.claude-plugin/plugin.json` `version` bumped `1.13.0` →
  `1.14.0` (minor: one new skill, no removals or breaking changes; no gate, hook,
  guard, or script *semantics* change since `ee17db0` — the only script edits are the
  banner's added Video line and its two new test assertions). Since 1.13.0:
  **product-video** (#136) — the new product-education-video verb (feature how-to /
  knowledge-base videos, onboarding sequence, marketing demo reel, companion
  step-doc; post-app only, sources committed / renders gitignored) with its three
  skill-local references (video-pipeline, script-craft, content-types) and three
  templates (video brief, scenes manifest, record-video orchestrator script); ladder
  wiring (README Video row + skills bullet, count 22→23; both session-bootstrap
  banner copies + two test assertions); one routing sentence each in
  `marketing-site`'s skill body and its asset-pipeline reference. Prose + one
  template script, 12 files. `.claude-plugin/marketplace.json` carries no `version`
  field, so it is unchanged.

## Combined checks

`claude plugin validate --strict .`, `bash scripts/check-neutral.sh`,
`bash scripts/check-plan.sh`. The released content itself landed verified with #136
(pin at `bcfd5b2`) and is unaffected by a version-string change.

## verification

fresh-context verifier subagent against this file + the diff: the branch changes
exactly two files (`.claude-plugin/plugin.json` + this chore spec); the `plugin.json`
diff is exactly the `version` `1.13.0`→`1.14.0` line and no other field; the result is
valid JSON; `marketplace.json` unchanged; nothing else in the tree moves.
`claude plugin validate --strict .` + `check-neutral` + `check-plan` green.
Minor-bump sanity: `skills/product-video/SKILL.md` exists with valid frontmatter, the
README ladder and both banner copies carry the Video line, and
`scripts/check-skill-frontmatter.sh` reports 23 skills. History since `ee17db0` is
exactly PRs #135 and #136 (the milestone's plan and code PRs); the branch is one
commit ahead of `main`. No merge-decision mechanism is touched by a version string →
no `/security-review`. The version-visible-to-the-installed-runtime effect is a
[runtime] property that only a reinstall proves — carried into the post-merge install
(tag + plugin update on merge), correctly out of branch scope.
