# Chore batch — release 1.20.0

Minor release that surfaces the model-routing and decision-surfacing doctrine landed since
`v1.19.0` to the installed runtime. Five PRs merged on `main` — two feature-grain builds
(each under its own verified pin), their two plan PRs, and one prune chore. The installed
plugin cache reports 1.19.0, so the running plugin has none of this behavior (no model/effort
routing, no builder-flagged uncertain-choices at the handoff, and the un-pruned orchestration
prose). Reinstalling over the same version number is unreliable (the cache dedupes on
version), so the version must move before an update can pick it up. The `v1.20.0` release tag
is cut on merge.

## Applied items

- **plugin-version-1.20.0** — `.claude-plugin/plugin.json` `version` bumped `1.19.0` →
  `1.20.0` (minor: additive doctrine + workflow changes, no removals or breaking changes,
  no new top-level skills — count stays 29). Since 1.19.0:
  - **model-effort-routing** (plan #171, build #174, verified pin at `2ad46d6`) — routes each
    keel surface to a model + reasoning effort by grain: new `references/model-routing.md`
    (canonical table, the asymmetry principle, resolution order, complete 29-skill + verifier
    inventory, the verifier effort-escalation rule); model/effort frontmatter on the leaves
    (`agents/verifier.md` opus/high, `implement-milestone` sonnet/high, `debug` effort high);
    effort-only frontmatter on the ten orchestrator/spec verbs (`spec-foundation` xhigh, rest
    high, no pinned model); dispatch-by-`Routing:`-tag prose in `implement-feature`, verifier
    effort-escalation in `implement-feature`/`verify-milestone`, Sonnet worker dispatch in
    `punch-list`, and rework tracking on both the autonomous (`auto` §5) and attended
    (`implement-feature` ledger) paths; the `Routing:` milestone-header field documented in
    `references/milestones-and-verification.md` §4; a new `decisions/2026-07-21-model-effort-routing.md`
    that amends the capability ledger by reference (routing = permanent machinery, not a prune
    candidate).
  - **decision-surfacing** (plan #172, build #175, verified pin at `85266bb`) —
    `implement-milestone` step 8 writes zero-or-more file-per-entry uncertain-choice records
    under `specs/uncertainties/<milestone-slug>/` (three-part logging bar, empty-is-clean rule,
    unlabeled calibration examples); the `verify-milestone` skill session (not the read-only
    verifier subagent) reads that directory and surfaces each entry verbatim alongside the
    correctness report — a complement to verification, never a replacement; documented in
    `references/milestones-and-verification.md` §5.
  - **prune-procedural-prose** (#173) — pruned procedural how-to prose from the three heaviest
    strong-model skills (`implement-feature` −23%, `spec-feature` −24%, `auto` −24%) with every
    invariant, stop-point, and gate rule preserved; `spec-foundation` correctly left untouched
    (invariant-dense, no prunable slack).

  `.claude-plugin/marketplace.json` carries no `version` field, so it is unchanged.

## Combined checks

`claude plugin validate --strict .`, `bash scripts/check-neutral.sh`,
`bash scripts/check-plan.sh`, `bash scripts/check-skill-frontmatter.sh`,
`bash scripts/check-skill-anchors.sh`. The released content itself landed verified with the
PRs and pins above and is unaffected by a version-string change.

## verification

fresh-context verifier subagent against this file + the diff: the branch changes exactly two
files (`.claude-plugin/plugin.json` + this chore spec); the `plugin.json` diff is exactly the
`version` `1.19.0`→`1.20.0` line and no other field; the result is valid JSON;
`marketplace.json` unchanged (no `version` field); nothing else in the tree moves.
`claude plugin validate --strict .` + `check-neutral` + `check-plan` +
`check-skill-frontmatter` (29 skills) + `check-skill-anchors` green. History since `v1.19.0`
is exactly the PRs enumerated above (each build carrying its own verified pin on `main`); the
branch is one commit ahead of `main`. No merge-decision mechanism, gate, hook, or guard
*semantics* is touched by a version-string bump → no `/security-review`. The
version-visible-to-the-installed-runtime effect is a [runtime] property that only a reinstall
proves — carried into the post-merge install (tag + plugin update on merge), correctly out of
branch scope.
verified: clean at d654e3d, 2026-07-22, via fresh-context keel:verifier subagent — confirmed the verified commit is one commit ahead of main changing only `.claude-plugin/plugin.json` (version 1.19.0→1.20.0, valid JSON) and this release spec; `marketplace.json` untouched with no version field; skill count 29; history since v1.19.0 is exactly #171–#175 (routing plan+build, decision-surfacing plan+build, the prune chore) with no omitted or phantom entries; the two cited build pins are live on main (`references/model-routing.md` present, the `specs/uncertainties/<milestone-slug>/` handoff present); all combined checks green (`plugin validate --strict`, check-neutral, check-plan 32 chore specs, check-skill-frontmatter 29 skills, check-skill-anchors) + self-test suites (check-verified-pin 36/0, check-plan 21/0). No gate/guard/hook semantics touched → no `/security-review`. The installed-runtime effect is the [runtime] reinstall, correctly out of branch scope.
