# Chore batch — release 1.21.0

Minor release that surfaces the `two-model-routing` policy change to the installed runtime. One
feature's worth of change (a plan PR + a code PR) merged on `main` since `v1.20.1`. The installed
plugin cache reports 1.20.1, so the running plugin still routes every surface under the old
three-tier policy (Opus 4.8 / Sonnet); the version must move before an update can pick up the new
routing frontmatter and reference. The `v1.21.0` release tag is cut on merge.

## Applied items

- **plugin-version-1.21.0** — `.claude-plugin/plugin.json` `version` bumped `1.20.1` → `1.21.0`
  (**minor**: a behavioral change to how keel routes models, not a corrective patch — the routing
  policy, the `Routing:`-tag contract, and the verification-doctrine model all move. No new or
  removed skills — count stays 29; no skill added or deleted). Since 1.20.1:
  - **two-model-routing** (plan #179 at `316a04b`, code #181 with verified pin at `43ffa6f`) —
    collapses the three-tier routing to two models: every build/execution surface runs **Opus 5**
    (`claude-opus-5`) and the independent `verifier` runs **Fable 5** (`claude-fable-5`), a
    decorrelated stronger check; **Sonnet is retired** from keel routing. Concretely:
    `agents/verifier.md` → `claude-fable-5`; `skills/implement-milestone` → `claude-opus-5`;
    the `implement-feature` build subagent always Opus 5 with the milestone `Routing:` tag now
    driving **effort only** (not model); `punch-list` workers → `claude-opus-5`; the cheap-model-bounce
    rework ledger retired from `auto` §5 and `implement-feature`. `references/model-routing.md`'s
    guiding principle is restated from cost-economy to **error-decorrelation** (verify on a different,
    at-least-as-capable model than you generate on), and `references/milestones-and-verification.md`
    §4 updated so the `Routing:` tag sets effort, not the build model. New append-only
    `decisions/2026-07-25-two-model-routing.md` records the policy. Orchestrators, spec verbs, `debug`,
    and the default-rule skills stay `inherit`, so the owner's `/model` choice still governs those
    sessions.

  `.claude-plugin/marketplace.json` carries no `version` field, so it is unchanged.

## Combined checks

`claude plugin validate --strict .`, `bash scripts/check-neutral.sh`, `bash scripts/check-plan.sh`,
`bash scripts/check-skill-frontmatter.sh`, `bash scripts/check-skill-anchors.sh`. The released
content itself landed verified with the PRs and pin above and is unaffected by a version-string change.

## verification

fresh-context verifier subagent against this file + the diff: the branch changes exactly two files
(`.claude-plugin/plugin.json` + this chore spec); the `plugin.json` diff is exactly the `version`
`1.20.1`→`1.21.0` line and no other field; the result is valid JSON; `marketplace.json` unchanged
(no `version` field); nothing else in the tree moves. All five combined checks green. History since
`v1.20.1` is exactly the two PRs enumerated above (the code PR carrying its own verified pin on `main`);
the branch is one commit ahead of `main`. No merge-decision mechanism, gate, hook, or guard *semantics*
is touched by a version-string bump → no `/security-review`. The version-visible-to-the-installed-runtime
effect is a [runtime] property that only a reinstall proves — carried into the post-merge install
(tag + plugin update on merge), correctly out of branch scope. The routing change's own `[attended]`
dogfood (runtime honors the Fable 5 / Opus 5 pins at dispatch) belongs to `two-model-routing`, already
landed — not re-opened by a version bump.
