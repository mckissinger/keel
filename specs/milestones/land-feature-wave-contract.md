# Milestone — land-feature-wave-contract: the wave-scripting contract

**Goal:** `skills/land-feature/SKILL.md` states the contract a project-authored wave-automation script
must satisfy, so a faithful automation of the choreography can no longer close a stacked PR
unrecoverably (prefix-invocation branch deletion) or report green PRs as failed (a check-wait window
shorter than the project's CI).

**Change:** `specs/changes/land-feature-wave-contract.md`. **No-UI** → two-dimension done-conditions
(logic + behavioral completeness). **Depends on:** nothing (prose-only, one file). **Parallelizable:**
yes. **Routing:** mechanical — the rules are settled by the field evidence; this transcribes them.

## Done-conditions

### Logic / invariants

- [auto] `skills/land-feature/SKILL.md` gains a **wave-scripting contract** subsection (placed with the
  stacked-series material, before Boundaries) stating both rules: **(1) deletion scope** — a script that
  deletes head branches must refuse to run unless its argument list equals the **full remaining open
  stack** (derivable from `gh pr list` by base-chain), exiting non-zero having deleted nothing on a
  partial list, **or** must decouple branch deletion into an explicit post-wave step that runs only
  after every stacked PR is merged or retargeted; **(2) check-wait semantics** — an exhausted poll
  window reports *still pending — re-check* (distinct from failure, e.g. by exit code and message),
  never `✗`/failure, and the window is sized to the project's **observed** CI duration, not a default.
  Two-readers bar: a reader who has never seen cre-list's script can state both rules and why each
  exists from this subsection alone.
- [auto] The subsection carries the scar in one or two sentences — a prefix invocation deleted a live
  base and closed its descendant PR unrecoverably (recreate was the only recovery), and a poll window
  shorter than the e2e shards read every green stacked PR as failed — without naming any project.
- [auto] The existing choreography is untouched: the numbered stacked-series sequence, the cascade
  rules, the diamond section, the consolidated check, the reconciliation, and the Boundaries section
  have empty diffs — this milestone only adds the subsection.
- [auto] The milestone's diff touches **only** `skills/land-feature/SKILL.md` (and, if an anchor is
  added for the new load-bearing sentences, `scripts/skill-anchors/` — nothing else).

### Behavioral completeness

- [auto] `scripts/check-skill-anchors.sh`, `scripts/check-skill-frontmatter.sh`, and
  `scripts/check-neutral.sh` pass on the edited file (the contract constrains behavior, not
  implementation — it names no stack framework or script language; process tooling the skill already
  uses, like the `gh` CLI, is in-house).
- [auto] All script self-test suites pass unchanged, and `claude plugin validate --strict .` passes.

## verification

verifier subagent against this file — each `[auto]` condition checked with `file:line` evidence; the
lints and suites run, not re-derived. **Dispatch the verifier at `high`** (mechanical). No
`/security-review` — no gate, guard, or script changes; the prose-only diff condition is the proof.

verified: clean-with-notes at 5902911, 2026-07-29, via fresh-context verifier subagent (keel:verifier,
`claude-fable-5` at `high` per this mechanical milestone, decorrelated from the Opus-5 build) against this spec's
done-conditions — every `[auto]` condition evidenced with `file:line`: the subsection at
`skills/land-feature/SKILL.md:29-34`, placed between the numbered stacked-series sequence and the cascade section
and well before Boundaries, carrying both rules with every enumerated specific (deletion scope — refuse unless the
argument list equals the full remaining open stack, derivable from `gh pr list` by walking each open PR's base
back to `main`, exiting non-zero having deleted nothing on a partial list, or deletion decoupled into an explicit
post-wave step gated on every stacked PR being merged or retargeted; check-wait — an exhausted window reports
"still pending — re-check", kept distinct from failure by exit code and message, never a failure marker, with the
window sized to the project's observed CI duration rather than a script default). The two-readers bar was judged
**strictly and passes**: both rules' rationale is self-contained in the subsection. The scar is carried in one
sentence with no project name or foreign PR number leaking (grep-verified). The change is **pure insertion** — one
hunk, 7 insertions, 0 deletions — so the numbered sequence, cascade, diamond, consolidated check, reconciliation,
Boundaries, and autonomy-mode sections all have empty diffs. Four anchors added in
`scripts/skill-anchors/land-feature-wave-contract.txt`, house format, each present verbatim (lint 62→66 anchors,
10→11 files). Adversarially confirmed: the rules are codable, they reference rather than duplicate step 2 and stay
consistent with step 5, and they bind observable behavior only — no implementation overreach. Full unfiltered
suite run: 11 suites, **389 passed / 0 failed**, plus `check-skill-anchors.sh`, `check-skill-frontmatter.sh` (29
skills), `check-neutral.sh`, `check-plan.sh`, and `claude plugin validate --strict .` all PASS. No
`/security-review` — prose + anchors only, no gate/guard/script behavior touched, as this line's proof requires.
Two non-blocking notes: the two `specs/uncertainties/` records ride the branch in a separate commit (plan paths per
§5, which mandates they ride the milestone branch — the milestone commit's own diff is exactly the two permitted
paths), and the skill hardens the spec's "e.g. by exit code and message" example into a requirement. Both logged
uncertainties were judged genuine spec-silent calls. (evidence: verifier report in PR)
