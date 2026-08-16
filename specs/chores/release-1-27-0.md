# Chore batch — release 1.27.0

Minor release surfacing everything merged since the 1.26.0 release commit (#222) to the
installed runtime. Installed plugins report `1.26.0`; the version must move before
`claude plugin update` can pick these up (the version string, not a git tag, is what
plugin update consumes).

## Applied items

- **plugin-version-1.27.0** — `.claude-plugin/plugin.json` `version` bumped
  `1.26.0` → `1.27.0` (minor: one new skill and one new workflow, no removals, no
  breaking changes; skill count 32 → 33; workflow count 2 → 3; agent count unchanged
  at 2). Since 1.26.0:
  - **babysit-prs** (#226 plan, #227 implementation, milestone pin `verified: clean at
    91ac588`): new `skills/babysit-prs/SKILL.md` (the background landing-cycle babysitter
    verb, `disable-model-invocation: true`) + new `workflows/babysit-prs.js` (settle-only
    watch → update-branch + CI-green `repin.sh` re-pin or drop → drain under an active
    mode / committed marker with bare un-chained emissions, or hold with one batched
    report). One pointer sentence each in `skills/land-feature/SKILL.md` (plus its
    ships-none sentence amended to name the shipped workflow) and
    `skills/implement-feature/SKILL.md`'s run-through path;
    `references/model-routing.md` default list gains `babysit-prs` (coverage count
    32 → 33); new anchor file `scripts/skill-anchors/babysit-prs.txt` (8 anchors,
    repo total 85 → 93); one uncertainty record under `specs/uncertainties/babysit-prs/`.
  - **CI npm cache + test-health growth probe** (#224, chore pin at 7ebf6fe):
    `.github/workflows/ci.yml` guards job caches `~/.npm` for the Claude CLI install;
    `skills/test-health/SKILL.md` gains the duration-growth-vs-prior-audit probe (1.5×
    threshold).
  - Plan-only merges, for the record: reviews #223 (build-model era mining) and #225
    (harness efficiency mining) under `specs/reviews/`; the babysit-prs plan #226 under
    `specs/changes/` + `specs/milestones/`.
  - Guard/hook semantics deltas since `1.26.0`: none — no guard script, gate, preflight,
    or never-auto list changed (#227's no-weakening condition, verified in its pin:
    `merge-guard.sh`, `repin.sh`, the pin-gate scripts, and `session-bootstrap.sh` all
    byte-unchanged). The only new skill frontmatter is `babysit-prs`'s own
    (`disable-model-invocation: true`, no `model:`/`effort:` pin, default-list routing).
  `.claude-plugin/marketplace.json` carries no `version` field, so it is unchanged.

## Combined checks

`claude plugin validate --strict .`, `bash scripts/check-neutral.sh`,
`bash scripts/check-plan.sh`, `bash scripts/check-skill-frontmatter.sh`,
`bash scripts/check-skill-anchors.sh`, plus the script self-tests. The released content
itself landed verified with #227 (its milestone pin) and #224 (its batch pin) and is
unaffected by a version-string change.

verified: clean at d835da4, 2026-08-16, via fresh-context verifier subagent — version line is the sole plugin.json change (byte-compared against origin/main with the version line excluded; branch diff is exactly that one file), delta record complete and accurate vs ffa4239..origin/main (exactly #223/#224/#225/#226/#227; skill count 32 → 33 and workflow count 2 → 3 by git ls-tree at both revisions; agents unchanged at 2; babysit-prs milestone pin 91ac588 and #224 chore pin 7ebf6fe both present on main; anchors 85 → 93 with the new file's 8), no guard/hook deltas (merge-guard.sh, repin.sh, check-verified-pin.sh, session-bootstrap.sh empty diff across the release window), marketplace.json version-field-free and unchanged, plugin validate --strict + 4 check scripts + all 13 script self-tests (486 assertions, 0 failed) green at this SHA. (evidence: verifier report in PR)
