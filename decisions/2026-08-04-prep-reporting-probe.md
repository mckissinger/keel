# 2026-08-04 — prep-auto-merge probes the PR head, not the default-branch head

Records the fix for milestone `prep-auto-merge-reporting-probe`
(`specs/milestones/prep-auto-merge-reporting-probe.md`, `specs/changes/prep-auto-merge-reporting-probe.md`).
Amends `decisions/2026-08-03-prep-auto-merge.md` **by reference** — that file is not edited; it remains the
record of the original design.

## The bug

`keel:prep-auto-merge` (shipped 1.23.0) probed `gh api …/commits/<default-sha>/check-runs` in two places —
to derive the check-contract's `required_checks` and to confirm the review job reported before requiring it.
But the `security-review` workflow prep scaffolds is a verbatim copy of keel's own, which is
**`pull_request`-only**: it never runs on a push to `main`, so it **structurally never reports on the
default-branch head**. Consequences of a literal follow:

- **(a)** the confirmation for `security-review` could never succeed — the default-head probe would forever
  report it "not yet reporting", withholding the required check indefinitely;
- **(b)** the derived `required_checks` omitted `security-review` — the default-head probe captures the
  push-triggered checks (`verified-pin`, `plan-lint` / `typecheck · lint · test`, `guards`) but misses the
  PR-only one, generating an incomplete contract.

Surfaced dogfooding prep on `crelaunch` (PR #161, 2026-08-04): the operator reasoned around the skill's
literal instruction by using the scaffold PR's own real green as the confirmation — the correct move, which
the skill now encodes.

## Root cause

`GET /commits/<sha>/check-runs` only returns checks that ran **on that commit**. A `pull_request`-only
workflow runs on **PR head** commits, never on the branch head a push produces. Any prep/arm logic that wants
to observe the **merge-gating** set must look at a PR head — the one commit where PR-only contexts (the
`security-review` among them) and push-triggered contexts both appear.

## The fix

Both probe sites in `skills/prep-auto-merge/SKILL.md` move to the **PR head**:

- **Confirmation** = the review job **going green on a PR** (the scaffold PR's own head, since adding the
  workflow makes it run there), via `gh pr checks <pr>`, and a **real scan, not a cached-skip hollow green**
  (the existing cache-mask caveat). The wedge gate is reframed: require the `security-review` context only
  once **(a)** it has gone green on a PR **and (b)** the workflow is merged to `main` (so every future PR
  inherits it). The post-merge default-head probe is dropped — it can't see a PR-only check.
- **Derivation** sources `required_checks` from the repo's **most-recent PR** head (`gh pr checks`), with the
  repo's **CI workflow job/context names** as the fallback when no PR exists, **plus** the scaffolded
  `security-review` context name added **explicitly** (not observable until it first runs). Standing
  invariants unchanged: never read `gh api …/protection`'s required-status-checks list; include every check
  the repo already enforces; the human confirms the generated set.

The narrow inverse — a **push-only-triggered** required check, visible on the default head but not a PR head —
is not a real regression: a required context that never runs on PRs would itself wedge every PR, so a
functioning PR-gating repo does not have one; the CI-job-names source and the human confirmation cover it.

## What holds

Prose-and-anchor correction only. The scaffold **template** and `scripts/check-branch-protection.sh` are
**untouched**, so `keel:arm-auto-merge` still independently re-asserts the live floor regardless of what prep
did. `scripts/check-prep-auto-merge.test.sh` is unaffected. A **negative skill-anchor**
(`!skills/prep-auto-merge/SKILL.md commits/<default-sha>/check-runs`) makes the old probe's reintroduction a
permanent CI failure, not merely a one-time merge grep.
