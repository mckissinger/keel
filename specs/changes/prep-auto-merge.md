# Change — prep-auto-merge: a human-invoked skill that prepares a repo's auto-merge prerequisites

**One sentence.** A new human-invoked keel skill (`keel:prep-auto-merge`) that discovers what a repo is
missing for `keel:arm-auto-merge` to pass and prepares it — scaffolding the security-review workflow (and,
for a name-mismatch repo, the names-only check-contract) as a PR you merge, and printing the exact
branch-protection / `allow_auto_merge` commands for you to run — **without** the certifier ever building
the floor it certifies.

## Why (motivating context, 2026-08-03)

Arming `crelaunch` (and any consuming repo whose CI ≠ keel's) gaps because the repo has no required
security-review workflow and `allow_auto_merge=false` — its own infra to wire. Today `keel:arm-auto-merge`
is a **pure certifier** (assert-first, write-only-on-green): it names each gap and its remediation, but it
never sets any of it up, and it deliberately must not — the whole safety basis of the required-checks
backstop is that arming *independently verifies* the floor rather than *provisioning* it
(`decisions/2026-08-02-per-project-auto-merge-authorization.md`, `decisions/2026-08-01-required-checks-protection.md`).
So setup is manual, guided only by the gap messages. The owner wants near-one-command setup; this change
gives it while keeping provisioning **separate** from arming.

## Settled design (owner-approved 2026-08-03, in-session)

- **A separate, human-invoked skill — assert ≠ provision.** `keel:prep-auto-merge`, `disable-model-invocation`,
  runs against the current repo. It PREPARES and points at `keel:arm-auto-merge` as the next step; it never
  arms. It is **not** a `prep` arg on arm-auto-merge: the tool that certifies the floor must never be the
  tool that built it, or a bug in the builder would create a weak floor the same tool then certifies as
  strong.
- **Discovers gaps by reusing the assertion, never re-authoring it.** It runs
  `scripts/check-branch-protection.sh` (the same code arm-auto-merge runs) and maps each GAP class —
  (b) required-checks / name mismatch, (b2) security-review content, (d) `allow_auto_merge`, and a
  present-but-absent/mismatched check-contract — to a **targeted** remediation, not a blind dump.
- **Scaffolds what it can safely generate, as a PR you merge.** (1) `.github/workflows/security-review.yml`
  matching keel's own dogfooded recipe — the review action pinned to a **full commit SHA** (kept in lockstep
  with keel's own `security-review` job, single source), least-privilege `permissions:`, `pull_request`
  trigger, the API key from `${{ secrets.ANTHROPIC_API_KEY }}` — **materialized as a verbatim file copy**, so
  what lands is exactly the tested template. (2) When the repo's required-check *names* differ from keel's,
  the names-only `.claude/keel-auto-merge-checks.json` (the #205 contract), with `required_checks` derived
  from the repo's **actually-reporting** check contexts (check-runs on the default-branch head, or the repo's
  CI job names) — **never** from `gh api …/protection`'s required list (which is exactly what's missing/wrong
  on a repo that needs prepping) — and presented to the human to confirm in the PR (it must never silently
  drop a check the repo already enforces, since a committed contract *replaces* the asserted set). Both land
  as a **plain code PR the human reviews and merges**.
- **Print-only for the security-settings mutations (owner-approved).** For branch protection (the required
  contexts + `strict` + zero-approval PR-required + `enforce_admins`) and `allow_auto_merge=true`, the skill
  **prints the exact `gh api` commands** for the human to run. It does **not** run them — these are the
  load-bearing floor, and mutating them stays attended and in the human's hands (never the skill's).
- **The `ANTHROPIC_API_KEY` secret is always the human's.** The skill reminds (per-repo for personal-account
  repos; an org-level secret if under a GitHub org) but **never** sets it — a credential is out of bounds.
- **An ordered flow, because a required context that no job yet reports wedges every PR.** The recipe's
  own caveat: never add the `security-review` required context before its job reports, or the repo wedges.
  So prep is a guided sequence: ① scaffold the workflow (+contract) PR → you merge it and let it run once →
  ② apply the printed protection + `allow_auto_merge` commands (now that the check reports) → ③ run
  `keel:arm-auto-merge`. The skill also carries the live-dogfood cache-mask caveat
  (`specs/walks/2026-08-02-security-review-cache-mask.md`).

## Scope guard

Minimal per the owner's standing rule: **discover gaps → scaffold the workflow (+ the check-contract when
names differ) as a PR → print the protection / `allow_auto_merge` commands → remind about the secret →
point at `keel:arm-auto-merge`.** Not a general repo-provisioning framework; it prepares exactly the four
preflight checks (b)/(b2)/(d) + the check-contract, nothing more.

## Where it sits

```
keel:prep-auto-merge   (prepare a repo's auto-merge prerequisites)   ← new, here
keel:arm-auto-merge    (certify the prerequisites are live, then commit the marker)
```
