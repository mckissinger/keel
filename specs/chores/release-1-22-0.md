# Chore batch — release 1.22.0

Minor release that surfaces the **merge-backstop-and-auto-merge** wave to the installed runtime. Two
features' worth of change (plus a model-routing correction and two lane chores) merged on `main` since
`v1.21.0`. The installed plugin cache reports 1.21.0, so the running plugin still has no required-checks
protection doctrine, no `arm-auto-merge` skill, no committed-marker run-through in `implement-feature`,
and still routes builds to the retired Opus 5 pin; the version must move before an update can pick up the
new skill, the corrected build-model frontmatter, and the auto-merge/protection references. The `v1.22.0`
release tag is cut on merge.

## Applied items

- **plugin-version-1.22.0** — `.claude-plugin/plugin.json` `version` bumped `1.21.0` → `1.22.0`
  (**minor**: substantial new capability with no breaking change to the workflow contract — a new skill,
  a new committed-marker authorization path, a full branch-protection doctrine, and a build-model
  correction; nothing removed, no consumer-facing contract broken). Skill count moves **29 → 30** (one
  skill added: `arm-auto-merge`; none removed). Since `v1.21.0` (`f1452fb`), grouped by theme:

  - **The merge backstop becomes real — required checks + full branch protection.** keel's `main` now
    carries full branch protection with four required contexts (`verified-pin`, `plan-lint`, `guards`,
    `security-review`, the last being Anthropic's SHA-pinned claude-code-security-review action), and the
    corpus/guards catch up to the enforced gate:
    - **guard-worktree-branch** (plan #184, code #187) — the branch guards resolve git state from the
      hook's cwd (the checkout the command runs in), while markers stay project-rooted.
    - **land-feature-wave-contract** (plan #185, code #188) — the wave-scripting contract: a deletion
      scope that must equal the full remaining open stack, and a poll window sized to real CI duration
      that keeps "still pending" distinct from failure.
    - **security-review-required-check** (plan #186, code #189) — the autonomy tier's third check gets a
      wiring path; `decisions/2026-07-29-security-review-wiring.md`.
    - **required-checks-wiring** (plan #193, code #195 `required-checks-live` + #196
      `required-checks-doctrine`) — the named checks, the live security-review, and the full protection
      go live; plan-only writes route through plan-only PRs (direct pushes to `main` are dead) and
      independent-wave landing becomes strict-cascade-aware (update → suite → repin per landed sibling).
      `decisions/2026-08-01-required-checks-protection.md`.

  - **per-project auto-merge (committed, human-armed) + the attended run-through posture** (plan #197,
    code #198–#201, reconcile #202) — a committed per-project marker arms `gh pr merge --auto` on every
    gate-passing PR the workflow opens, so a repo whose owner has decided "the required checks are my
    review" stops paying the per-merge tap in every session:
    - **committed-auto-merge-marker** (#198) — the `.claude/keel-auto-merge.json` marker both guards
      honor, an `is_plan_path` carve-out in `check-verified-pin.sh` so it commits, and both guards'
      committed-project rows (precedence mode > attended > committed).
      `decisions/2026-08-02-committed-auto-merge-marker.md`.
    - **arm-auto-merge-skill** (#199, **the new skill**) — the human-invoked
      `disable-model-invocation` writer that asserts branch protection + the three required checks are
      live before it commits the flag; the agent never self-arms. Extracts the protection-assertion
      (`scripts/check-branch-protection.sh`) so the skill and the preflight can never drift.
    - **auto-merge-doctrine** (#200) — the corpus tells the truth about the committed marker:
      `session-bootstrap.sh` orientation, `references/template-contract.md` (arming as the third
      security-review wiring moment), guard-vocabulary consistency, the deferral's RESOLVED closure, and
      `decisions/2026-08-02-per-project-auto-merge-authorization.md`.
    - **implement-feature-run-through** (#201) — under a valid committed marker, `implement-feature`
      runs start-to-finish (build → verify → land the wave → consolidated check → **prepare**
      `review-feature`) and asks mid-run only at true stop-points; it never auto-passes the review.
      `decisions/2026-08-02-implement-feature-run-through.md`.

  - **build-model-opus-4-8** (#192) — the build/execution surfaces repoint `claude-opus-5` →
    `claude-opus-4-8` (the owner reverted after poor Opus 5 field feedback); the independent `verifier`
    stays Fable 5, so the error-decorrelation policy is unchanged. `decisions/2026-08-01-build-model-opus-4-8.md`.
    This is runtime-relevant frontmatter an update at 1.21.0 would not pick up.

  - **code-review-default-lane** (#191) — the correctness-class pre-pin review defaults to plain
    `/code-review`, not ultra.

  - **review-drift-sync** (#183) — a corpus drift-sync chore.

  `.claude-plugin/marketplace.json` carries no `version` field, so it is unchanged.

## Combined checks

`claude plugin validate --strict .`, `bash scripts/check-neutral.sh`, `bash scripts/check-plan.sh`,
`bash scripts/check-skill-frontmatter.sh`, `bash scripts/check-skill-anchors.sh`. The released content
itself landed verified with its own PRs and pins on `main` and is unaffected by a version-string change.

## verification

fresh-context verifier subagent against this file + the diff: the branch changes exactly two files
(`.claude-plugin/plugin.json` + this chore spec); the `plugin.json` diff is exactly the `version`
`1.21.0`→`1.22.0` line and no other field; the result is valid JSON; `marketplace.json` unchanged (no
`version` field); nothing else in the tree moves. Skill count is 30 (one added since 1.21.0:
`arm-auto-merge`). All five combined checks green. History since `v1.21.0` is exactly the PRs enumerated
above, each carrying its own verified pin on `main` (or plan-only exemption); the branch is one commit
ahead of `main`. No merge-decision mechanism, gate, hook, or guard *semantics* is touched by a
version-string bump → no `/security-review`. The version-visible-to-the-installed-runtime effect is a
[runtime] property that only a reinstall proves — carried into the post-merge install (tag + plugin
update on merge), correctly out of branch scope.
