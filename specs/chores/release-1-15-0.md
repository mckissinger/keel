# Chore batch — release 1.15.0

Minor release that surfaces two landed milestones to the installed runtime: the
**harden** verb (plan PR #140, code PR #141, landed on `main` at `02ccfa2` with its
verified pin at `24de6eb`) and the **marketing-reference-research** wiring (plan PR
#138, code PR #139, landed at `58446d6` with its verified pin at `d5702eb`). Both are
fully merged in source but the installed plugin cache reports 1.14.0 — the running
plugin has no `harden` verb to route "are we ready to launch" to, and the orientation
banner carries no Harden line. Reinstalling over the same version number is
unreliable (the cache dedupes on version), so the version must move before an update
can pick it up. The `v1.15.0` release tag is cut on merge.

## Applied items

- **plugin-version-1.15.0** — `.claude-plugin/plugin.json` `version` bumped `1.14.0`
  → `1.15.0` (minor: one new skill plus one skill-local reference, no removals or
  breaking changes; no gate, hook, guard, or script *semantics* change since
  `280e693` — the only script edits are the banner's added Harden line and its two
  new test assertions). Since 1.14.0:
  **harden** (#141) — the pre-launch production-readiness audit verb (profile-derived
  sweep across application security incl. supply chain and the Q7-gated AI surface /
  reliability + data safety / operations + launch readiness; evidence-backed
  findings, attended triage, grain-mapped remediation slate, dated go/no-go report
  under `specs/reviews/`) with its three probe references and two templates; ladder
  wiring (README Harden row + Hardening bullet, count 23→24; both session-bootstrap
  banner copies + two test assertions); one routing sentence each in
  `agents/verifier.md` and `skills/verify-milestone/SKILL.md`. And
  **marketing-reference-research** (#139) — the new
  `skills/marketing-site/references/reference-research.md` owning the marketing
  reference-pull delta, with its wiring sentences in `marketing-site`'s skill body
  and sibling references. Prose only, no template scripts.
  `.claude-plugin/marketplace.json` carries no `version` field, so it is unchanged.

## Combined checks

`claude plugin validate --strict .`, `bash scripts/check-neutral.sh`,
`bash scripts/check-plan.sh`. The released content itself landed verified with #141
(pin at `24de6eb`) and #139 (pin at `d5702eb`) and is unaffected by a version-string
change.

## verification

fresh-context verifier subagent against this file + the diff: the branch changes
exactly two files (`.claude-plugin/plugin.json` + this chore spec); the
`plugin.json` diff is exactly the `version` `1.14.0`→`1.15.0` line and no other
field; the result is valid JSON; `marketplace.json` unchanged; nothing else in the
tree moves. `claude plugin validate --strict .` + `check-neutral` + `check-plan`
green. Minor-bump sanity: `skills/harden/SKILL.md` exists with valid frontmatter,
`skills/marketing-site/references/reference-research.md` exists, the README ladder
and both banner copies carry the Harden line, and
`scripts/check-skill-frontmatter.sh` reports 24 skills. History since `280e693` is
exactly PRs #138, #139, #140, and #141 (two milestones' plan and code PRs); the
branch is one commit ahead of `main`. No merge-decision mechanism is touched by a
version string → no `/security-review`. The version-visible-to-the-installed-runtime
effect is a [runtime] property that only a reinstall proves — carried into the
post-merge install (tag + plugin update on merge), correctly out of branch scope.
