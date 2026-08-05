# Change — prep-auto-merge reporting-context probe: PR head, not the default-branch head

## What & why

`keel:prep-auto-merge` (shipped 1.23.0, `skills/prep-auto-merge/SKILL.md`) probes
`gh api …/commits/<default-sha>/check-runs` in **two** places — to derive the check-contract's
`required_checks` (step 1b) and to confirm the review job reported before requiring it (step 2). But the
`security-review` workflow the skill scaffolds is **`pull_request`-only** (a verbatim copy of keel's own,
which never runs on a push to `main`), so it **structurally never reports on the default-branch head.**

Surfaced dogfooding prep on `crelaunch` (2026-08-04): the operator had to reason around the skill's literal
instruction, because:
- **(a) the confirmation can never succeed** for `security-review` — the skill's `commits/<default-sha>/…`
  probe would forever report it "not yet reporting", withholding the required check indefinitely;
- **(b) the derived `required_checks` would omit `security-review`** — the default-head probe captures the
  push-triggered checks (`verified-pin`, `plan-lint`/`typecheck · lint · test`, `guards`) but misses the
  PR-only one, generating an incomplete contract.

The fix: probe the **PR head**, where every merge-gating context reports — including PR-only ones. This is
a **prose correction to the skill's procedure only**; it changes nothing about *what* prep scaffolds (the
template and the `check-branch-protection.sh` assertion are untouched), and `keel:arm-auto-merge` still
independently re-asserts the live floor regardless of what prep did.

## The corrected probe

- **Confirmation (step 2).** Confirm the review job **produced its context by going green on a PR** — the
  scaffold PR's own head — via `gh pr checks <pr>` (or `gh api …/commits/<pr-head-sha>/check-runs`), and
  that it was a **real scan, not the cached-skip hollow green** (the existing cache-mask caveat). Reframe the
  wedge gate: **require the `security-review` context only once (a) it has gone green on a PR** (proving the
  job runs and emits the context) **AND (b) the workflow is merged to `main`** (so every future PR inherits
  it). The post-merge default-head `check-runs` probe is dropped as the wedge signal — it can't see a
  PR-only check.
- **Derivation (step 1b) — with a concrete, unambiguous source rule.** At contract-generation time the
  scaffold PR does not yet exist (the check-contract file is committed *into* that same PR), so "a PR head"
  must name a specific commit. Resolve it as: `required_checks` = the union of
  1. the contexts observed on the repo's **most-recent PR** (open or merged) — `gh pr checks <that-pr>` (or
     `commits/<its-head-sha>/check-runs`) — the freshest observation of what actually gates PRs today
     (**most-recent** so the set can't drift to a stale long-merged PR's job names); **or**, when the repo
     has **no** PR at all, the repo's **CI workflow job/context names** (parse `.github/workflows/*.yml`),
     which are always present and always current; **plus**
  2. the scaffolded `security-review` context name, **added explicitly** — it has not run anywhere at
     generation time, so it is named (prep knows it — it is the job it is scaffolding), never observed.

  The **human confirms the full generated set in the PR** (the standing backstop against a wrong/stale
  derivation). Standing invariants hold: still **never** read `gh api …/protection`'s required-status-checks
  list, and still **include every check the repo already enforces** (a committed contract *replaces* the
  asserted set).

## Root cause worth recording

The `commits/<sha>/check-runs` API only returns checks that ran **on that commit**. A `pull_request`-only
workflow runs on PR head commits, never on the branch head a push produces. Any prep/arm logic that wants to
observe the *merge-gating* set must look at a **PR head**, because that is the only commit where PR-only
contexts (the security-review among them) and push-triggered contexts both appear.

The narrow inverse — a **push-only-triggered** existing check, visible on the default head but not a PR head
— is not a real regression: a required context that never runs on PRs would itself wedge every PR, so a
functioning PR-gating repo does not have one. The CI-job-names source (which lists every job regardless of
trigger) plus the human confirmation of the generated set cover it if it somehow arises.

## Scope

`skills/prep-auto-merge/SKILL.md` (the two probe sites + the wedge-gate reframing),
`scripts/skill-anchors/prep-auto-merge.txt` (lock the corrected prose), and a new
`decisions/2026-08-04-prep-reporting-probe.md` (amends `decisions/2026-08-03-prep-auto-merge.md` by
reference). The **landed** `specs/milestones/prep-auto-merge.md` and `decisions/2026-08-03-prep-auto-merge.md`
are **historical — not rewritten.** `scripts/check-prep-auto-merge.test.sh` and
`templates/security-review.yml` are **unaffected** (this is a procedure-prose fix, not an artifact change).
No-UI keel plugin change → no workbench/design. One milestone.
