# Chore batch — release 1.17.0

Minor release that surfaces the **measure verb** (plan PR #148; milestone code PRs
#149, #150 — landed on `main` at `c9085f6` and `42a2a23` with verified pins at
`61314a5` and `8a50a84`, the latter carried forward from `4bc6f03` after the
stacked-merge rebase) to the installed runtime. The growth grain's fourth verb is
fully merged in source but the installed plugin cache reports 1.16.0 — the running
plugin has no `measure` skill, so "define our activation metric" has no verb to route
to and the orientation banner's Growth line carries three verbs, not four.
Reinstalling over the same version number is unreliable (the cache dedupes on
version), so the version must move before an update can pick it up. The `v1.17.0`
release tag is cut on merge.

## Applied items

- **plugin-version-1.17.0** — `.claude-plugin/plugin.json` `version` bumped `1.16.0` →
  `1.17.0` (minor: one new skill, no removals or breaking changes; no gate, hook,
  guard, or script *semantics* change since `6b8c276` — the only script edits are the
  banner's `measure` addition with its new test assertion, three new `g6-*` skill-eval
  fixtures, and the new `measure.txt` anchors file). Since 1.16.0: the **measure
  verb** — `measure` (#149 — the growth grain's metrics layer: doctrine §10
  Measurement appended to `references/growth-operations.md` with the cohort-attribution
  and read-only rules, the two-mode skill (authoring → `specs/gtm/metrics.md` plan PR;
  read-only cohort readout), the `metrics-spec.md` + `funnel-readout.mjs` templates,
  and the `2026-07-17-growth-measurement` decision record) plus its wiring (#150 —
  README Growth row + skills bullet, count 27→28; both session-bootstrap banner copies
  + one test assertion; one routing sentence each in `run-growth` and `gtm`; the
  `measure.txt` cohort-attribution anchor; three `g6-*` fixtures; two deferral entries
  — person-level attribution, feature-usage analytics). Prose + one template script,
  18 files across the two PRs (16 content files + the two milestone specs' appended
  pin lines). `.claude-plugin/marketplace.json` carries no `version`
  field, so it is unchanged.

## Combined checks

`claude plugin validate --strict .`, `bash scripts/check-neutral.sh`,
`bash scripts/check-plan.sh`. The released content itself landed verified with
#149/#150 (pins above) and is unaffected by a version-string change.

## verification

fresh-context verifier subagent against this file + the diff: the branch changes
exactly two files (`.claude-plugin/plugin.json` + this chore spec); the `plugin.json`
diff is exactly the `version` `1.16.0`→`1.17.0` line and no other field; the result is
valid JSON; `marketplace.json` unchanged; nothing else in the tree moves.
`claude plugin validate --strict .` + `check-neutral` + `check-plan` green.
Minor-bump sanity: `skills/measure/SKILL.md` exists with valid frontmatter (no
`disable-model-invocation` — measure is model-invocable by design), the README ladder
and both banner copies carry `measure` on the Growth line, and
`scripts/check-skill-frontmatter.sh` reports 28 skills. History since `6b8c276` is
exactly PRs #148, #149, and #150 (the plan PR and the feature's two code PRs); the
branch is one commit ahead of `main`. No merge-decision mechanism is touched by a
version string → no `/security-review`. The version-visible-to-the-installed-runtime
effect is a [runtime] property that only a reinstall proves — carried into the
post-merge install (tag + plugin update on merge), correctly out of branch scope.
verified: clean at 59d1e5d, 2026-07-18, via fresh-context keel:verifier subagent — branch changes exactly two files vs main (plugin.json + this chore spec); the plugin.json diff is the single version 1.16.0→1.17.0 line, JSON valid, marketplace.json unchanged (no version field); plugin validate + check-neutral + check-plan green; measure skill present with valid frontmatter (model-invocable, no disable-model-invocation), README + both banner copies carry measure on the Growth line, 28 skills reported; history 6b8c276..main is exactly PRs #148, #149, #150; one commit ahead of main; verifier corrected this spec's file count (16 → 18 incl. the two pin-line spec edits), fixed pre-pin. Runtime pickup deferred to post-merge tag + reinstall per this spec (evidence in PR #151)
