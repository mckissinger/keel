# Chore batch — release 1.12.0

Minor release that surfaces the **env-check-preflight** milestone (plan PR #129, code
PR #130, landed on `main` at `041b781` with its verified pin at `da3279d`) to the
installed runtime. The changes are fully merged in source but the installed plugin
cache reports `1.11.0` — the running plugin's Q12 has no env name-check command, no
direct-read ban, and no denial signature row, so project sessions (the `bidlevel`
incident's shape) keep hitting `.env*` read denials and improvising workarounds.
Reinstalling over the same version number is unreliable (the cache dedupes on
version), so the version must move before an update can pick it up. The `v1.12.0`
release tag is cut on merge.

## Applied items

- **plugin-version-1.12.0** — `.claude-plugin/plugin.json` `version` bumped `1.11.0` →
  `1.12.0` (minor: new contract capability in existing skills/reference, no removals
  or breaking changes; no gate, hook, guard, or script semantics change since
  `f539ef0`). Since 1.11.0: **env-check-preflight** (#130) — Q12 gains the committed
  env name-check command (names/status only, never values) and the direct-read ban
  (sessions never read `.env*`; the recorded command is the sanctioned path), the
  denial signature row, provision authoring (steps 3 + 6), name-check clauses in both
  entry preflights, and derivation-list/run-preflight alignment in
  spec-foundation/adopt. Prose-only, 6 files. `.claude-plugin/marketplace.json`
  carries no `version` field, so it is unchanged.

## Combined checks

`claude plugin validate --strict .`, `bash scripts/check-neutral.sh`,
`bash scripts/check-plan.sh`. The released content itself landed verified with #130
(pin at `da3279d`) and is unaffected by a version-string change.

## verification

fresh-context verifier subagent against this file + the diff: the branch changes
exactly two files (`.claude-plugin/plugin.json` + this chore spec); the `plugin.json`
diff is exactly the `version` `1.11.0`→`1.12.0` line and no other field; the result is
valid JSON; `marketplace.json` unchanged; nothing else in the tree moves.
`claude plugin validate --strict .` + `check-neutral` + `check-plan` green.
Minor-bump sanity: `references/profile-interface.md` carries the env name-check
command bullet and the `.env*` denial signature row; both entry preflights name the
recorded name-check command. History since `f539ef0` is exactly PRs #129 and #130 (the
milestone's plan and code PRs); the branch is one commit ahead of `main`. No merge-decision mechanism is touched by a version
string → no `/security-review`. The version-visible-to-the-installed-runtime effect is
a [runtime] property that only a reinstall proves — carried into the post-merge
install (tag + plugin update on merge), correctly out of branch scope.
verified: clean at 304dc9e, 2026-07-14, via fresh-context keel:verifier subagent (one finding — a history line omitting the plan PR — fixed and re-verified clean by the same agent) — branch changes exactly two files vs main (plugin.json + this chore spec); the plugin.json diff is the single version 1.11.0→1.12.0 line, JSON valid, marketplace.json unchanged; plugin validate + check-neutral + check-plan green; Q12 name-check bullet + denial signature row + both entry-preflight clauses present; history f539ef0..HEAD~1 is exactly PRs #129 and #130; one commit ahead of main. Runtime pickup deferred to post-merge tag + reinstall per this spec (evidence in PR #131)
