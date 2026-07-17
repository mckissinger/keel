# Chore batch — release 1.16.0

Minor release that surfaces the **growth suite** (plan PR #143; milestone code PRs
#144, #145, #146 — landed on `main` at `7a72973`, `89e9f23`, `4389cb5` with verified
pins at `ef296f7`, `9551eff`, `66061b5`) to the installed runtime. The Growth grain is
fully merged in source but the installed plugin cache reports an earlier version — the
running plugin has no `gtm` / `spec-campaign` / `run-growth` verbs, so "position my
product" has no skill to route to and the orientation banner carries no Growth line.
Reinstalling over the same version number is unreliable (the cache dedupes on
version), so the version must move before an update can pick it up. The `v1.16.0`
release tag is cut on merge.

## Applied items

- **plugin-version-1.16.0** — `.claude-plugin/plugin.json` `version` bumped `1.15.0` →
  `1.16.0` (minor: three new skills, no removals or breaking changes; no gate, hook,
  guard, or script *semantics* change since `f88918d` — the only script edits are the
  banner's added Growth line and its two new test assertions, plus four new skill-eval
  fixtures and one new anchors file). Since 1.15.0: the **growth suite** — the operate
  grain: `gtm` (#144 — per-product positioning/ICP/channel verb with three templates,
  plus the operate-grain doctrine `references/growth-operations.md` and the grain's
  decision record), `spec-campaign` (#145 — campaign authoring in the growth-ops repo
  with source-ladders + channel-contracts references, campaign-spec template, and the
  `push-approved.mjs` / `readback.mjs` pipeline templates), and `run-growth` (#146 —
  the human-triggered cycle verb, `disable-model-invocation: true`), with ladder
  wiring (README Growth row + skills bullet, count 24→27; both session-bootstrap
  banner copies + two test assertions), one routing sentence in `marketing-site`'s
  Discover, the `growth.txt` queue-invariant anchor, four `g5-*` fixtures, and three
  deferral entries (growth-status, ads templates, SMS). Prose + two template scripts,
  24 files across the three PRs. `.claude-plugin/marketplace.json` carries no
  `version` field, so it is unchanged.

## Combined checks

`claude plugin validate --strict .`, `bash scripts/check-neutral.sh`,
`bash scripts/check-plan.sh`. The released content itself landed verified with
#144/#145/#146 (pins above) and is unaffected by a version-string change.

## verification

fresh-context verifier subagent against this file + the diff: the branch changes
exactly two files (`.claude-plugin/plugin.json` + this chore spec); the `plugin.json`
diff is exactly the `version` `1.15.0`→`1.16.0` line and no other field; the result is
valid JSON; `marketplace.json` unchanged; nothing else in the tree moves.
`claude plugin validate --strict .` + `check-neutral` + `check-plan` green.
Minor-bump sanity: `skills/gtm/SKILL.md`, `skills/spec-campaign/SKILL.md`, and
`skills/run-growth/SKILL.md` exist with valid frontmatter (`run-growth` carrying
`disable-model-invocation: true`), the README ladder and both banner copies carry the
Growth line, and `scripts/check-skill-frontmatter.sh` reports 27 skills. History since
`f88918d` is exactly PRs #144, #145, and #146 (the feature's code PRs; the plan
PR #143 landed before the 1.15.0 release); the branch is one commit ahead of
`main`. No merge-decision mechanism is
touched by a version string → no `/security-review`. The
version-visible-to-the-installed-runtime effect is a [runtime] property that only a
reinstall proves — carried into the post-merge install (tag + plugin update on
merge), correctly out of branch scope.
verified: clean at 273b10b, 2026-07-17, via fresh-context keel:verifier subagent — branch changes exactly two files vs main (plugin.json + this chore spec); the plugin.json diff is the single version 1.15.0→1.16.0 line, JSON valid, marketplace.json unchanged; plugin validate + check-neutral + check-plan green; all three growth skills present with valid frontmatter (run-growth human-triggered), README + both banner copies carry the Growth line, 27 skills reported; history f88918d..main is exactly PRs #144, #145, #146 (the verifier corrected this spec's original claim — plan PR #143 landed before the 1.15.0 release); one commit ahead of main. Runtime pickup deferred to post-merge tag + reinstall per this spec (evidence in PR #147)
