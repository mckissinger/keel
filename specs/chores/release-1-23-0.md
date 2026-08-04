# Chore batch — release 1.23.0

Minor release that surfaces the **auto-merge setup** follow-ons to the installed runtime. Since `v1.22.0`
two changes merged on `main`: the committed per-project **check-contract** (`arm-auto-merge` now honors a
repo's own required-check names) and a new **`prep-auto-merge`** skill (the human-invoked preparer that
scaffolds a repo's auto-merge prerequisites so `arm-auto-merge` can certify them). The installed plugin
cache reports 1.22.0, so the running plugin has no `prep-auto-merge` skill and its `arm-auto-merge` still
gaps on any consuming repo whose CI check names differ from keel's; the version must move before an update
can pick up the new skill and the check-contract logic. The `v1.23.0` release tag is cut on merge.

## Applied items

- **plugin-version-1.23.0** — `.claude-plugin/plugin.json` `version` bumped `1.22.0` → `1.23.0`
  (**minor**: additive capability with no breaking change to the workflow contract — a new skill and a new
  optional committed-config path; nothing removed, no consumer-facing contract broken). Skill count moves
  **30 → 31** (one skill added: `prep-auto-merge`; none removed). Since `v1.22.0` (`bd4162c`):

  - **arm-auto-merge-check-contract** (plan #204, code #205) — `keel:arm-auto-merge`'s protection assertion
    (`scripts/check-branch-protection.sh`) now honors a committed per-project **check-contract**,
    `.claude/keel-auto-merge-checks.json`, read fail-closed from the server default branch: a consuming repo
    declares its *own* required-check context names (and which is its security-review check) instead of
    keel's plugin-repo defaults, fixing the pure-name-mismatch GAP (the motivating `crelaunch` incident:
    `verified-pin gate` / `typecheck · lint · test` vs keel's names). The contract declares **names only**
    (no `pattern`/`external` — both stay env-only / keel-default so a committed value can never weaken the
    (b2) content scan; this survived a four-round never-weakens saga, resolved by dropping the weakenable
    surface). Precedence operator-override (`PREFLIGHT_*`) > committed contract > keel default; malformed or
    empty fails closed. `decisions/2026-08-03-arm-auto-merge-check-contract.md`.

  - **prep-auto-merge** (plan #206, code #207, **the new skill**) — the human-invoked
    `disable-model-invocation` preparer that gets a repo ready for `keel:arm-auto-merge` **without the
    certifier building the floor it certifies** (assert ≠ provision). It reuses `check-branch-protection.sh`
    to discover gaps, then scaffolds — as a plain code PR the human merges — the `security-review.yml`
    workflow (copied **verbatim** from a committed template whose action SHA is kept in lockstep with keel's
    own) and, for a name-mismatch repo, the names-only check-contract generated from the repo's
    actually-reporting check contexts. It **prints** (never runs) the branch-protection / `allow_auto_merge`
    `gh api` commands, gated so it withholds a command requiring a not-yet-reporting `security-review`
    context (the wedge caveat); **reminds** about the `ANTHROPIC_API_KEY` secret (never sets it); and
    **never arms** — it points at `keel:arm-auto-merge`. `decisions/2026-08-03-prep-auto-merge.md`.

  `.claude-plugin/marketplace.json` carries no `version` field, so it is unchanged.

## Combined checks

`claude plugin validate --strict .`, `bash scripts/check-neutral.sh`, `bash scripts/check-plan.sh`,
`bash scripts/check-skill-frontmatter.sh`, `bash scripts/check-skill-anchors.sh`. The released content
itself landed verified with its own PRs and pins on `main` and is unaffected by a version-string change.

## verification

fresh-context verifier subagent against this file + the diff: the branch changes exactly two files
(`.claude-plugin/plugin.json` + this chore spec); the `plugin.json` diff is exactly the `version`
`1.22.0`→`1.23.0` line and no other field; the result is valid JSON; `marketplace.json` unchanged (no
`version` field); nothing else in the tree moves. Skill count is 31 (one added since 1.22.0:
`prep-auto-merge`). All five combined checks green. History since `v1.22.0` is exactly the PRs enumerated
above (#204/#205 + #206/#207), each carrying its own verified pin on `main` (or plan-only exemption); the
branch is one commit ahead of `main`. No merge-decision mechanism, gate, hook, or guard *semantics* is
touched by a version-string bump → no `/security-review`. The version-visible-to-the-installed-runtime
effect is a [runtime] property that only a reinstall proves — carried into the post-merge install (tag +
plugin update on merge), correctly out of branch scope.

verified: clean at f9032df, 2026-08-03, via fresh-context keel:verifier subagent — exactly two files change (.claude-plugin/plugin.json version 1.22.0→1.23.0 only, valid JSON; this chore spec); marketplace.json unchanged (no version field); skill count 31 (prep-auto-merge added since 1.22.0, absent at the v1.22.0 tag); history since v1.22.0 is exactly #204/#205/#206/#207; one commit ahead of main; all 5 combined checks green; no gate/guard/hook semantics in the diff → no /security-review.
