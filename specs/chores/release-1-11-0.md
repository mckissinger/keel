# Chore batch — release 1.11.0

Minor release that surfaces the **design-directions-content-grain** milestone (plan PR
#126, code PR #127, landed on `main` at `c92497d` with its verified pin at `fa212f4`)
to the installed runtime. The changes are fully merged in source but the installed
plugin cache reports `1.10.0` — the running `app-design-directions` has no content-type
inventory, a controls-and-materials-only workbench build, and no flatness-signal
self-reviews. Reinstalling over the same version number is unreliable (the cache
dedupes on version), so the version must move before an update can pick it up. The
`v1.11.0` release tag is cut on merge.

## Applied items

- **plugin-version-1.11.0** — `.claude-plugin/plugin.json` `version` bumped `1.10.0` →
  `1.11.0` (minor: new capability in an existing skill, no removals or breaking
  changes; no gate, hook, guard, or script semantics change since `f36ec8a`). Since
  1.10.0: **design-directions-content-grain** (#127) — `skills/app-design-directions`
  gains the source-side design-richness items: Phase 0 content-type inventory (+
  design-brief template slot), Phase 4 content-type primitives in the workbench
  gallery, the shared rules' §3 flatness signals cited in the Phase 2/3.5/4 reviews,
  the hierarchy-carriers line (direction-spec template / Phase 1 / Phase 3 decision
  file with the binding sentence), and content-type coverage in the Phase 0.5 pull +
  Phase 3.5 spread. Prose-only, 4 files, all under `skills/app-design-directions/`.
  `.claude-plugin/marketplace.json` carries no `version` field, so it is unchanged.

## Combined checks

`claude plugin validate --strict .`, `bash scripts/check-neutral.sh`,
`bash scripts/check-plan.sh`. The released content itself landed verified with #127
(pin at `fa212f4`) and is unaffected by a version-string change.

## verification

fresh-context verifier subagent against this file + the diff: the branch changes
exactly two files (`.claude-plugin/plugin.json` + this chore spec); the `plugin.json`
diff is exactly the `version` `1.10.0`→`1.11.0` line and no other field; the result is
valid JSON; `marketplace.json` unchanged; nothing else in the tree moves.
`claude plugin validate --strict .` + `check-neutral` + `check-plan` green.
Minor-bump sanity: `skills/app-design-directions/SKILL.md` carries the content-type
inventory (Phase 0) and the content-type primitives in the Phase 4 build;
`templates/direction-spec.md` carries the hierarchy-carriers line. History since
`eafd744` is exactly PR #127; the branch is one commit ahead of `main`. No
merge-decision mechanism is touched by a version string → no `/security-review`. The
version-visible-to-the-installed-runtime effect is a [runtime] property that only a
reinstall proves — carried into the post-merge install (tag + plugin update on merge),
correctly out of branch scope.
verified: clean at 24905bf, 2026-07-13, via fresh-context keel:verifier subagent — branch changes exactly two files vs main (plugin.json + this chore spec); the plugin.json diff is the single version 1.10.0→1.11.0 line, JSON valid, marketplace.json unchanged; plugin validate + check-neutral + check-plan green; content-type inventory + Phase 4 primitives + hierarchy-carriers line present; history eafd744..HEAD~1 is exactly PR #127; one commit ahead of main. Runtime pickup deferred to post-merge tag + reinstall per this spec (evidence in PR #128)
