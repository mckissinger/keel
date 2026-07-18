# Chore batch — release 1.18.0

Minor release that surfaces the **logo verb** (plan PR #152; milestone code PRs #153,
#154 — landed on `main` at `8ccaa14` and `3ad6ebb` with verified pins at `dee79d6` and
`2f0dff0`, the latter carried forward from `d740ae4` after the stacked-merge rebase)
to the installed runtime. The brand-mark verb is fully merged in source but the
installed plugin cache reports 1.17.0 — the running plugin has no `logo` skill, so
"design a logo for my product" has no verb to route to and the orientation banner
carries no Logo line. Reinstalling over the same version number is unreliable (the
cache dedupes on version), so the version must move before an update can pick it up.
The `v1.18.0` release tag is cut on merge.

## Applied items

- **plugin-version-1.18.0** — `.claude-plugin/plugin.json` `version` bumped `1.17.0` →
  `1.18.0` (minor: one new skill, no removals or breaking changes; no gate, hook,
  guard, or script *semantics* change since `f88c079` — the only script edits are the
  banners' `Logo` line with its test assertions and three new `g7-*` skill-eval
  fixtures). Since 1.17.0: the **logo verb** — `logo` (#153 — the brand-mark skill:
  four-movement session contract (dual-fork Discover, parametric concepts under
  render-and-verify, attended iteration, kit + ONE integration milestone), the
  `logo-craft.md` reference (parametric construction, anti-slop bans, the three
  quality gates, deliverable matrix + naming, font + legal rules), and the
  `brand-kit-manifest.md` + `render-contact-sheet.mjs` templates) plus its wiring
  (#154 — README Logo ladder row + grain bullet, count 28→29; both session-bootstrap
  banner copies + test assertions; one routing sentence in `marketing-site` (Discover
  consumes the committed kit); three `g7-*` fixtures; the `logo-brand-collateral`
  deferral). Prose + one template script, 14 files across the two PRs (12 content
  files + the two milestone specs' appended pin lines). `.claude-plugin/marketplace.json`
  carries no `version` field, so it is unchanged.

## Combined checks

`claude plugin validate --strict .`, `bash scripts/check-neutral.sh`,
`bash scripts/check-plan.sh`. The released content itself landed verified with
#153/#154 (pins above) and is unaffected by a version-string change.

## verification

fresh-context verifier subagent against this file + the diff: the branch changes
exactly two files (`.claude-plugin/plugin.json` + this chore spec); the `plugin.json`
diff is exactly the `version` `1.17.0`→`1.18.0` line and no other field; the result is
valid JSON; `marketplace.json` unchanged; nothing else in the tree moves.
`claude plugin validate --strict .` + `check-neutral` + `check-plan` green.
Minor-bump sanity: `skills/logo/SKILL.md` exists with valid frontmatter (no
`disable-model-invocation` — logo is model-invocable by design), the README ladder
and both banner copies carry the `Logo` line, and
`scripts/check-skill-frontmatter.sh` reports 29 skills. History since `f88c079` is
exactly PRs #152, #153, and #154 (the plan PR and the feature's two code PRs); the
branch is one commit ahead of `main`. No merge-decision mechanism is touched by a
version string → no `/security-review`. The version-visible-to-the-installed-runtime
effect is a [runtime] property that only a reinstall proves — carried into the
post-merge install (tag + plugin update on merge), correctly out of branch scope.
