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
