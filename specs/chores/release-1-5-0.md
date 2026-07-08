# Chore batch — release 1.5.0

Minor release that surfaces the `visual-reference-pipeline` change (PRs #95 spec → #96
implementation, both landed on `main`) to the installed runtime. The change is fully merged
in source but the installed plugin cache still reports `1.4.0` built from `76700ec` — the
running `app-design-directions` skill has no visual-reference ladder (no design-reference
MCP / Mobbin step, no `references/visual-reference.md`, no deconstruction-before-pixels
flow), and the running `review-feature` / `spec-feature` skills carry the pre-#96 wording.
Reinstalling over the same version number is unreliable (the cache dedupes on version), so
the version must move before a reinstall can pick up the change. The `v1.5.0` release tag is
the user's to cut on merge.

## Applied items

- **plugin-version-1.5.0** — `.claude-plugin/plugin.json` `version` bumped `1.4.0` → `1.5.0`
  (minor: new capability — the visual-reference pipeline in `app-design-directions`
  (references before directions, deconstruction before pixels, the design-reference-MCP
  ladder with Mobbin as the known instance, the new `references/visual-reference.md` and the
  `anti-slop.md` addition) plus the aligned one-line edits in `review-feature` and
  `spec-feature` — added since 1.4.0; no removals or breaking changes: no script, hook,
  gate, or skill frontmatter changed since `76700ec`, only skill prose and references).
  `.claude-plugin/marketplace.json` carries no `version` field, so it is unchanged.

## Combined checks

`claude plugin validate --strict .` , `bash scripts/check-neutral.sh`, `bash
scripts/check-plan.sh`. The visual-reference-pipeline content itself landed verified with
#96 and is unaffected by a version-string change.

## verification

fresh-context verifier subagent against this file + the diff: the branch changes exactly two
files (`.claude-plugin/plugin.json` + this chore spec); the `plugin.json` diff is exactly the
`version` `1.4.0`→`1.5.0` line and no other field; the result is valid JSON; nothing else in
the tree moves. `claude plugin validate --strict .` + `check-neutral` + `check-plan` green.
No merge-decision mechanism, skill, script, or hook behavior is touched by a version string →
no `/security-review`. The version-visible-to-the-installed-runtime effect is a [runtime]
property that only a reinstall proves — carried into the post-merge install (the user cuts
the `v1.5.0` tag and reinstalls), correctly out of branch scope.
