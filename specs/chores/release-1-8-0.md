# Chore batch — release 1.8.0

Minor release that surfaces everything landed since `v1.7.0` (`3b4bee6`) to the
installed runtime — seven milestones and one chore batch, PRs #103–#117. The changes
are fully merged in source but the installed plugin cache reports `1.7.0`: the running
plugin has 17 skills (no `status`, no `harvest`), no Q12 substrate contract, no
gate-presentation contract, no §8 test-authoring doctrine, and the pre-hardening pin
gate. Reinstalling over the same version number is unreliable (the cache dedupes on
version), so the version must move before an update can pick it up. The `v1.8.0`
release tag is cut on merge.

## Applied items

- **plugin-version-1.8.0** — `.claude-plugin/plugin.json` `version` bumped `1.7.0` →
  `1.8.0` (minor: new capabilities, no removals or breaking changes). Since 1.7.0:
  - **pin-gate-hardening** (#104): backtick-aware caveat scan, first-match SHA parse,
    base-ref freshness in `check-verified-pin.sh`; canonical `scripts/repin.sh` +
    self-test.
  - **design-richness** (#106): content-grain reference trigger, content-type →
    workbench primitive, type-hierarchy floors, flatness signals in the vision diff,
    the sixth plan question, review-feature's richness verdict.
  - **gate-doctrine-quickfixes** chore (#107): review-then-pin ordering,
    merge-authority project-scoping, marker-expiry announcements, env-recipe line,
    anchors-test mode fix, stale-xref fix.
  - **status-verb** (#109): the 18th skill — read-only "where are we / what's next"
    derivation + resume entry point, with banner/README wiring.
  - **substrate-contract** (#111): profile Q12 — singleton health checks, unique
    port/identity, invocation path, env command, failure-signature table, duration
    budgets + the 2× timeout rule; entry preflights in the build/verify verbs; debug
    consults the table.
  - **harvest-verb** (#113): the 19th skill — transcript-mining / retrospective verb
    with seeded cursor, human-triggered only.
  - **gate-contract** (#115): `references/gate-presentation.md` (the five-line
    summary block as the attended-gate contract, banner-delivered) + the feature
    Lifecycle section authored/read/updated/closed across four feature verbs.
  - **testing-doctrine** (#117): §8 cross-stack test-authoring doctrine (eight
    rules) + pointers in implement-milestone and spec-foundation.

  Every item landed with its own verified pin on its own PR; no gate, hook, or
  script semantics change in this release beyond those already-verified milestones.
  `.claude-plugin/marketplace.json` carries no `version` field, so it is unchanged.

## Combined checks

`claude plugin validate --strict .`, `bash scripts/check-neutral.sh`,
`bash scripts/check-plan.sh`. The released content itself landed verified per-PR
(pins in each milestone/chore spec) and is unaffected by a version-string change.

## verification

fresh-context verifier subagent against this file + the diff: the branch changes
exactly two files (`.claude-plugin/plugin.json` + this chore spec); the `plugin.json`
diff is exactly the `version` `1.7.0`→`1.8.0` line and no other field; the result is
valid JSON; `marketplace.json` unchanged; nothing else in the tree moves.
`claude plugin validate --strict .` + `check-neutral` + `check-plan` green.
Minor-bump sanity: spot-check that the headline additions are really on `main` to
surface (the `status` and `harvest` skill files exist; profile-interface carries Q12;
`references/gate-presentation.md` exists; the shared rules end at §8;
`scripts/repin.sh` exists). No merge-decision mechanism, skill, script, or hook
behavior is touched by a version string → no `/security-review`. The
version-visible-to-the-installed-runtime effect is a [runtime] property that only a
reinstall proves — carried into the post-merge install (tag + plugin update on
merge), correctly out of branch scope.

verified: clean at 98fd2f2, 2026-07-13, via fresh-context keel:verifier subagent — branch changes exactly two files vs main (plugin.json + this chore spec); the plugin.json diff is the single version 1.7.0→1.8.0 line, JSON valid, marketplace.json unchanged; plugin validate + check-neutral + check-plan green; minor-bump sanity spot-checks pass (status/harvest skills, Q12, gate-presentation.md, §8, repin.sh all present); history 3b4bee6..HEAD~1 shows exactly PRs #103–#117; one commit ahead of main. Runtime pickup deferred to post-merge tag + reinstall per this spec (evidence in PR #119)
