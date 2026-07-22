# Chore batch — release 1.19.0

Minor release that surfaces the doctrine and workflow work landed since `v1.18.0` to the
installed runtime. Five spec-driven features/changes merged on `main` — each under its own
verified pin — plus supporting chores. The installed plugin cache reports 1.18.0, so the
running plugin has none of this behavior (no flake ledger, no poisoned-environment guard,
no suite-execution doctrine, the pre-hardening provision contract, the old harvest
source-resolution, and the session banner that stays silent one level above a keel repo).
Reinstalling over the same version number is unreliable (the cache dedupes on version), so
the version must move before an update can pick it up. The `v1.19.0` release tag is cut on
merge.

## Applied items

- **plugin-version-1.19.0** — `.claude-plugin/plugin.json` `version` bumped `1.18.0` →
  `1.19.0` (minor: additive doctrine + workflow changes, no removals or breaking changes,
  no new top-level skills — count stays 29). Since 1.18.0:
  - **harvest source-resolution** (#159, verified pin at `7810b30`) — harvest enumerates
    sources from the filesystem and filters for human input, replacing the prior
    resolution path; plus the `harvest-e-tier` chore (#157) and the 2026-07-18 harvest
    digest/cursor (#156).
  - **flake-ledger** (#165) — adopts the CRE flake-tracking practice: the `specs/flakes/`
    ledger (with its `README.md`) and the skill wiring that records and consults it.
  - **verify-environment-integrity** (#164) — the poisoned-environment guard woven into
    the verify path.
  - **provision-hardening** (#166) — substrate-contract hardening: OS-accurate port band,
    name-derived port, scripted fragile gates, target classification.
  - **suite-execution-doctrine** (#167) — §9, how a suite is run and proven.
  - **marketing-mobbin-sites-scope** (#169) — scopes marketing reference pulls to the
    website/Sites corpus, never the mobile-app corpus.
  - Supporting script change: `scripts/session-bootstrap.sh` now points at a nested
    keel-managed subdirectory (naming it and the entry verb) instead of staying silent
    when the session opened one level above the project — a runtime-visible banner change
    covered by `session-bootstrap.test.sh`.

  `.claude-plugin/marketplace.json` carries no `version` field, so it is unchanged.

## Combined checks

`claude plugin validate --strict .`, `bash scripts/check-neutral.sh`,
`bash scripts/check-plan.sh`, `bash scripts/check-skill-frontmatter.sh`,
`bash scripts/check-skill-anchors.sh`. The released content itself landed verified with
the PRs and pins above and is unaffected by a version-string change.

## verification

fresh-context verifier subagent against this file + the diff: the branch changes exactly
two files (`.claude-plugin/plugin.json` + this chore spec); the `plugin.json` diff is
exactly the `version` `1.18.0`→`1.19.0` line and no other field; the result is valid JSON;
`marketplace.json` unchanged (no `version` field); nothing else in the tree moves.
`claude plugin validate --strict .` + `check-neutral` + `check-plan` +
`check-skill-frontmatter` (29 skills) + `check-skill-anchors` green. History since
`v1.18.0` is exactly the PRs enumerated above (each carrying its own verified pin on
`main`); the branch is one commit ahead of `main`. No merge-decision mechanism, gate,
hook, or guard *semantics* is touched by a version-string bump → no `/security-review`.
The version-visible-to-the-installed-runtime effect is a [runtime] property that only a
reinstall proves — carried into the post-merge install (tag + plugin update on merge),
correctly out of branch scope.
