# Chore batch — release 1.2.1

Patch release fixing a plugin-manifest defect that made `keel@keel` report `✘ failed to load`
(the SessionStart + PreToolUse hooks still functioned via auto-load, so the guards fired, but
the plugin surfaced a hook-load error on every session). Discovered while updating the installed
plugin to 1.2.0. The `v1.2.1` release tag is the user's to cut on merge.

## Applied items

- **drop-redundant-hooks-key** — removed `"hooks": "./hooks/hooks.json"` from
  `.claude-plugin/plugin.json`. Claude Code (≥2.1) auto-loads the standard `hooks/hooks.json`
  path, so the explicit `manifest.hooks` reference to that same file registered it a second time
  and failed as a duplicate ("Duplicate hooks file detected: ./hooks/hooks.json resolves to
  already-loaded file … the standard hooks/hooks.json is loaded automatically, so manifest.hooks
  should only reference additional hook files"). `hooks/hooks.json` at the standard path carries
  keel's complete global registration (SessionStart → `session-bootstrap.sh`, PreToolUse Bash →
  `merge-guard.sh`); the skill-scoped `guard-branch-rules.sh` is registered separately via
  SKILL.md and is untouched. Removing the redundant key loses no hook — it clears the duplicate
  so the auto-loaded copy is the sole, clean registration.
- **plugin-version-1.2.1** — `.claude-plugin/plugin.json` `version` bumped `1.2.0` → `1.2.1`
  (patch: a manifest-defect fix, no skill/script/hook *behavior* change and no new capability).
  `.claude-plugin/marketplace.json` carries no `version` field, so it is unchanged.

## Compatibility note

The fix assumes the standard-path auto-load, which Claude Code prescribes in the very error it
emits and which keel already requires (README: "Claude Code ≥ 2.1"). A hypothetical ≥2.1 build
that does *not* auto-load `hooks/hooks.json` would lose the global hooks under this change — the
runtime confirmation below is what closes that, and it is why this is a patch shipped behind the
same install-and-restart dogfood as 1.2.0.

## Combined checks

`claude plugin validate --strict .` (validation passed — note it validates the marketplace
manifest, not the runtime hook-load, so it neither flagged the old duplicate nor is it the proof
here), `bash scripts/check-neutral.sh` (PASS), `bash scripts/check-plan.sh` (PASS). The two
hook-guard self-tests (`merge-guard.test.sh`, `guard-branch-rules.test.sh`) stay green — they
exercise the guard *scripts* directly and are unaffected by the manifest change.

verification: fresh-context verifier subagent against this file + the diff (the `"hooks"` key
removed from `plugin.json`, version bumped `1.2.0`→`1.2.1`, and nothing else; `hooks/hooks.json`
unchanged and still the complete global registration) + `claude plugin validate --strict .` +
`scripts/check-neutral.sh` + `scripts/check-plan.sh`. The load-clears-and-hooks-still-register
confirmation is a [runtime] check that only an install + restart proves (the manifest's effect
is on plugin load, which the committed suites cannot exercise) — carried into the same post-merge
dogfood as 1.2.0, not closable from the branch. No merge-decision mechanism touched → no
`/security-review`.
