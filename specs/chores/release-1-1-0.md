# Chore batch — release 1.1.0

Single-item release chore: bump the plugin version so the first published release since
1.0.0 ships the work merged to `main` — the autonomy-modes feature (PRs #60–65) plus
everything merged since the packaging chore established versioning. Per the semver policy
(README v1 note): releases ship on version bumps via release tags, **not** on every merge to
main — this is that deliberate bump. The `v1.1.0` release tag is the user's to cut on merge.

## Applied items

- **plugin-version-1.1.0** — `.claude-plugin/plugin.json` `version` bumped `1.0.0` → `1.1.0`
  (minor: the autonomy-modes feature is additive — a new `keel:auto` skill plus mode-aware
  guards, no breaking change to existing skills or scripts). No other field touched.
  `.claude-plugin/marketplace.json` carries no `version` field (the version resolves from
  `plugin.json`), so it is unchanged.
- **marketplace-ref-followup** — the tags-vs-main release-surface question this bump surfaces
  is parked in `specs/deferrals/marketplace-ref-tags-vs-main.md` (plan-only), not resolved
  here.

## Combined checks

`claude plugin validate --strict .` (validation passed), `bash scripts/check-neutral.sh`
(PASS), `bash scripts/check-plan.sh` (PASS) — all green on the branch. No script or skill
behavior changed; the diff is one version string plus this spec and the deferral note.

verification: fresh-context verifier subagent against this file + the diff (version bumped
`1.0.0`→`1.1.0` in `plugin.json` and nowhere else; no code/skill/script behavior change) +
`claude plugin validate --strict .` + `scripts/check-neutral.sh` + `scripts/check-plan.sh`.
No runtime surface → no walk; no mechanism touched → no `/security-review`.
