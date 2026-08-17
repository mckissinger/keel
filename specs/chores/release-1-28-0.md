# Chore batch — release 1.28.0

Minor release surfacing everything merged since the 1.27.0 release commit (#228) to the
installed runtime. Installed plugins report `1.27.0`; the version must move before
`claude plugin update` can pick these up (the version string, not a git tag, is what
plugin update consumes).

## Applied items

- **plugin-version-1.28.0** — `.claude-plugin/plugin.json` `version` bumped
  `1.27.0` → `1.28.0` (minor: a shipped-script behavior addition and CI/doctrine
  changes, no removals, no breaking changes; skill count unchanged at 33, workflow
  count unchanged at 3, agent count unchanged at 2). Since 1.27.0:
  - **plan-only-fast-path** (#229 plan, #231 implementation, milestone pin
    `verified: clean at 52dc4c9`): `scripts/check-verified-pin.sh` gains the
    `--plan-only-check` classification mode (fail-closed; reuses `is_plan_path`; never
    reads pins or the bootstrap window) **and the `--no-renames` hardening on both gate
    diffs** — the pre-pin security review's confirmed rename-smuggling fix, recorded in
    the milestone spec as sanctioned drift (a code file `git mv`'d into a plan path now
    classifies as code in both the mode and the gate's plan-only exemption; strictly
    fail-closed). `scripts/check-verified-pin.test.sh` grows 32 → 43 cases (all
    appended; the suite prints 51 assertions — some cases assert twice). Keel's `.github/workflows/ci.yml` `guards` job classifies on
    `pull_request` and early-exits its steps on plan-only diffs (exit code absorbed
    into an output; no job-level `if:`; no `paths:` filters; `verified-pin`,
    `plan-lint`, `security-review` byte-unchanged). `references/profile-interface.md`
    Q11 gains the fast-path scar clause; `skills/spec-foundation/SKILL.md` wires the
    early-exit at kickoff; new anchor file `scripts/skill-anchors/plan-only-fast-path.txt`
    (6 anchors, repo total 93 → 99).
  - **Committed per-project auto-merge marker armed on keel itself** (#230, plan-only):
    `.claude/keel-auto-merge.json` (`scope: "project"`, `invoker:
    human:keel-arm-auto-merge`) now on the default branch — a repo posture change, not
    a plugin content change; recorded here because the release window contains it.
  - Guard/hook semantics deltas since `1.27.0`: **one, deliberate and fail-closed** —
    the `--no-renames` change to `check-verified-pin.sh` above (its self-test suite
    locks it at case 42). `merge-guard.sh`, `repin.sh`, `session-bootstrap.sh`,
    `guard-branch-rules.sh`, and every preflight are byte-unchanged across the window.
    No skill frontmatter changed.
  `.claude-plugin/marketplace.json` carries no `version` field, so it is unchanged.

## Combined checks

`claude plugin validate --strict .`, `bash scripts/check-neutral.sh`,
`bash scripts/check-plan.sh`, `bash scripts/check-skill-frontmatter.sh`,
`bash scripts/check-skill-anchors.sh`, plus the script self-tests. The released content
itself landed verified with #231 (its milestone pin) and is unaffected by a
version-string change.

verified: clean at 26ceb38, 2026-08-16, via fresh-context verifier subagent — version line is the sole plugin.json change (byte-compared vs origin/main; branch diff exactly one file), delta record audited vs 6613e5c..origin/main (exactly #229/#230/#231; skills 33 / workflows 3 / agents 2 unchanged by ls-tree at both revisions; milestone pin 52dc4c9 present on main; --no-renames at both gate diff invocations; marker on main with scope project; anchors 93 → 99; merge-guard.sh, repin.sh, session-bootstrap.sh, guard-branch-rules.sh byte-unchanged across the window; ci.yml delta confined to the guards job with the three universal jobs byte-identical), one delta-record inaccuracy found (test-case count claimed 33 → 43; actual 32 → 43) and corrected before this pin, marketplace.json version-field-free, plugin validate --strict + 4 check scripts + all 13 self-test suites green at this SHA. (evidence: verifier report in PR)
