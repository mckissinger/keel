# Milestone — required-checks-live: keel's own main gets real required checks

**Goal:** keel's repo goes from zero server-side enforcement to the standard protected-main shape: the
CI contexts the doctrine names exist as separate named checks, a real security-review job runs on every
PR, and branch protection makes all of them — plus the PR requirement itself — binding on every change
to `main`, admins included.

**Change:** `specs/changes/required-checks-wiring.md`. **No-UI** → two-dimension done-conditions
(logic + behavioral completeness). **Depends on:** nothing. **Parallelizable:** no. **Routing:**
reasoning-heavy — this wires the merge gate itself; a wrong context name or a soft protection setting
silently un-gates every future merge.

**Attended stop-points, in order:** (1) the owner adds the `ANTHROPIC_API_KEY` repo secret before the
security-review job can pass; (2) branch protection is applied via `gh api` only after the split
workflow exists on the branch — applying it earlier would wedge `main` behind contexts that can never
report, and any PR already open at flip time from a pre-split branch reports only `guards` and must be
updated to the split workflow before it can merge. Both stop-points are flagged mid-build; neither is
routed around.

## Done-conditions

### Logic / invariants

- [auto] `.github/workflows/ci.yml` defines **four** jobs whose check contexts are exactly
  `verified-pin`, `plan-lint`, `guards`, and `security-review`: `verified-pin` runs
  `check-verified-pin.test.sh` and (on `pull_request` only, with `fetch-depth: 0` and
  `BASE_REF=origin/${{ github.base_ref }}`) `check-verified-pin.sh HEAD`; `plan-lint` runs
  `check-plan.test.sh` + `check-plan.sh`; `guards` runs every remaining existing step of today's job
  (neutrality, bootstrap/merge-guard/branch-rules/marker-parity self-tests, auto-preflight self-test,
  skill frontmatter + anchors, `claude plugin validate --strict .`) — **no existing step is dropped**;
  `security-review` invokes Anthropic's `claude-code-security-review` action **pinned to a full commit
  SHA** (not a tag), passes the API key from `secrets.ANTHROPIC_API_KEY`, runs on `pull_request`, and
  declares least-privilege `permissions:` — exactly `contents: read` plus `pull-requests: write` (the
  action posts PR comments), nothing broader. `file:line` evidence per job.
- [auto] Branch protection on `main` (via `gh api repos/{owner}/{repo}/branches/main/protection`)
  shows: `required_status_checks.strict == true` with contexts exactly
  `verified-pin`, `plan-lint`, `guards`, `security-review`; `enforce_admins.enabled == true`;
  `required_pull_request_reviews` present with `required_approving_review_count == 0` (a PR is
  required; a second human approval is not — the checks are the reviewers); `restrictions == null`.
- [auto] `gh api repos/{owner}/{repo}/actions/secrets` lists a secret named `ANTHROPIC_API_KEY`
  (names only — the value is never read), and `gh api repos/{owner}/{repo}` still shows
  `allow_auto_merge == true`.
- [auto] The four self-test suites named in the `verified-pin`/`plan-lint`/`guards` jobs pass locally
  on the milestone branch, unchanged — this milestone edits **only** `.github/workflows/ci.yml` among
  code paths; `scripts/`, `hooks/`, and `skills/` have empty diffs.

### Behavioral completeness

- [auto] The workflow's `push: [main]` trigger still runs the self-test battery (the `guards` job at
  minimum) so a landed merge is still smoke-checked post-merge; the `security-review` job does **not**
  run on `push` (it reviews PR diffs).
- [auto] **The gate is proven on a plan-only diff, not just the code PR:** a scratch **plan-only** PR
  (docs-only paths, opened during the build and closed unmerged after evidence capture) shows all four
  contexts — `security-review` included — completing successfully on a markdown-only diff, evidenced
  by `gh api repos/{owner}/{repo}/commits/<sha>/check-runs` output recorded in the milestone PR body.
  This is the flow class the doctrine milestone converts to PRs; if the review action cannot go green
  on a docs-only diff, every future plan PR would be unmergeable, so it is proven here first.
- [attended] The milestone's own code PR demonstrates the gate end-to-end: all four contexts report on
  the PR, and GitHub refuses the merge until all four are green — observed by the owner at landing
  (this is the one condition that can only be seen on the live PR, after the pin).

## verification

verifier subagent against this file — every `[auto]` condition checked with `file:line` / `gh api`
evidence (the four job definitions and their exact context names, the SHA-pinned action and its
permissions block, the protection JSON field-by-field, the secret name listing, the empty diffs
outside `ci.yml`); suites run, not re-derived. **Dispatch the verifier at `xhigh`**
(reasoning-heavy). **`/security-review` of the milestone's diff is a pre-pin precondition** — the
adversarial questions: does any job leak the secret to an untrusted context (a fork PR, an injected
step), is the action pinned such that a tag-move cannot swap its code, and does the protection JSON
leave any merge path (admin, direct push, unlisted context) un-gated; confirmed findings are
remediated before the pin.

verified: clean-with-notes at f7a5709, 2026-08-02, via fresh-context verifier subagent (keel:verifier,
`claude-fable-5` at `xhigh` per the reasoning-heavy escalation floor, decorrelated from the build) —
all six [auto] condition groups evidenced: the four-job split maps every one of the former monolithic
job's 17 steps with nothing dropped (merge-base 8e0b395 diff), the security-review job SHA-pinned to
the real upstream commit `0c6a49f…` with exactly `contents: read` + `pull-requests: write` and the
secret-fed `claude-api-key` input; live protection JSON field-by-field (strict true, the four exact
contexts, enforce_admins enabled, PR required at zero approvals, no restrictions); `ANTHROPIC_API_KEY`
listed by name and `allow_auto_merge` true; local suites green (36+21 self-tests, plan/neutrality/
frontmatter/anchors linters PASS) with the code diff touching only `.github/workflows/ci.yml`;
push-vs-PR trigger behavior confirmed; and the scratch-PR condition closed with PR #194 (docs-only
diff, closed unmerged) showing all four contexts completed/success at 4380dae via the check-runs API,
the final security-review run proven **uncached** (`Cache not found` + `claudecode-scan: success`)
after the action's per-PR cache-mask hazard was discovered and neutralized (recorded in
`specs/walks/2026-08-02-security-review-cache-mask.md`). Pre-pin `/security-review` of the milestone
diff: **no findings**. Notes carried: the check-runs output is pasted into the milestone PR body at
open (sequencing), and the [attended] observation of the gate on the milestone's own PR stays open by
design until landing. One uncertainty record surfaced for adjudication
(`specs/uncertainties/required-checks-live/scratch-pr-base.md`). (evidence: verifier +
security-review reports in PR)
