# Chore batch — release 1.2.0

Single-item release chore: bump the plugin version so the next published release ships the
work merged to `main` since `v1.1.0` — the permission-hygiene change (PR #67), the
skill-trigger-evals feature (PRs #68–70), the adopt-fixture reconcile chore (PR #71), and the
attended-merge-toggle change (PRs #72–73). Per the semver policy (README v1 note): releases
ship on version bumps via release tags, **not** on every merge to main — this is that
deliberate bump. The `v1.2.0` release tag is the user's to cut on merge.

## Applied items

- **plugin-version-1.2.0** — `.claude-plugin/plugin.json` `version` bumped `1.1.0` → `1.2.0`
  (minor: everything since v1.1.0 is additive — a new `keel:auto-merge` skill plus the
  attended-marker rows in both merge guards, the structural skill-frontmatter lint, and the
  session-eval harness; no breaking change to existing skills or scripts). No other field
  touched. `.claude-plugin/marketplace.json` carries no `version` field (the version resolves
  from `plugin.json`), so it is unchanged.
- **marketplace-ref-followup** — the tags-vs-main release-surface question this bump surfaces
  remains parked in `specs/deferrals/marketplace-ref-tags-vs-main.md` (plan-only), not resolved
  here.

## Combined checks

`claude plugin validate --strict .` (validation passed), `bash scripts/check-neutral.sh`
(PASS), `bash scripts/check-plan.sh` (PASS) — all green on the branch. No script or skill
behavior changed; the diff is one version string plus this spec.

verification: fresh-context verifier subagent against this file + the diff (version bumped
`1.1.0`→`1.2.0` in `plugin.json` and nowhere else; no code/skill/script behavior change) +
`claude plugin validate --strict .` + `scripts/check-neutral.sh` + `scripts/check-plan.sh`.
No runtime surface → no walk; no mechanism touched → no `/security-review`.
