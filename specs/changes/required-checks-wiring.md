# Change — required-checks-wiring: the merge backstop becomes real

**One sentence:** keel's doctrine delegates merge authority to "server-side required checks," and this
change makes those checks actually exist and actually gate — on keel's own repo first, and as a
concrete inherited recipe for every downstream keel project — as the stated precondition for
un-deferring `specs/deferrals/per-project-auto-merge.md`.

## The gap being closed

As of 2026-08-01, keel's own `main` had **no branch protection** (`gh api .../branches/main/protection`
→ 404) and one monolithic `guards` CI job — so the check names the doctrine leans on (`verified-pin`,
`plan-lint`, `security-review`) did not exist as separate contexts, and nothing server-side gated a
merge. Separately, the #189 milestone pin recorded that preflight check (b) asserts a required check
*named* `security-review`, not that the job performs a review — the compensating control for
unattended merges was name-shaped.

## Interview decisions (owner, 2026-08-01, in-session)

1. **Protection stance: full, standard-practice protection** — every change to `main` via PR, required
   status checks, branches-up-to-date, admins included. Chosen explicitly "regardless of keel's
   current setup," accepting that the two direct-to-main plan-only flows (`land-feature`
   reconciliation, `review-feature` plan-note) must be amended to open tiny plan-only PRs. Under
   auto-merge those land on green with no added friction (plan-only PRs are pin-exempt).
2. **Security-review job: keel repo + template.** Wired live on keel's own `main` (the hook/guard
   scripts are security-sensitive, and dogfooding proves the recipe) *and* recorded concretely in the
   template contract for downstream projects. Requires an `ANTHROPIC_API_KEY` repo secret (attended
   stop-point) and accepts per-PR API cost.

## Fan-out — two milestones

1. `specs/milestones/required-checks-live.md` — keel-repo wiring: the CI split into named jobs, the
   security-review job, the secret, and full branch protection on `main`.
2. `specs/milestones/required-checks-doctrine.md` — propagation: the two direct-commit flows move to
   plan-only PRs, the template contract records the job + protection recipes, preflight check (b)
   gains the workflow-content assertion, and the decision entry lands. Depends on milestone 1 (it
   records recipes milestone 1 proves).

## Accepted consequences (surfaced by the adversarial plan pass, accepted by design)

- **Fork PRs cannot merge**: the `security-review` context is backed by a repo secret unavailable to
  fork-originated runs. No keel flow depends on fork PRs; recorded, not worked around.
- **Independent-milestone waves gain a per-sibling update-and-repin cycle** under strict
  branches-up-to-date; the doctrine milestone writes the rule into `land-feature` so the first
  post-protection wave follows procedure rather than improvising at a red `verified-pin`.
- **Plan-only PRs must clear all four contexts**, including the review action on docs-only diffs —
  proven live by milestone 1 before the doctrine milestone converts any flow to PRs.

## Relationship to standing doctrine

Nothing here relaxes a gate; every change is in the *enforcement* direction. The human-merge default,
the autonomy carve-outs, and the pin gate are untouched. The per-project auto-merge deferral is **not**
resolved by this change — this builds its stated precondition (the security-review required check,
wired and verified live); un-deferring remains its own future `spec-change`.
