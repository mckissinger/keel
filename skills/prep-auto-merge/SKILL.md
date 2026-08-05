---
name: prep-auto-merge
description: Prepare a repo's auto-merge prerequisites so `keel:arm-auto-merge` can pass — `keel:prep-auto-merge` runs the shared `scripts/check-branch-protection.sh` assertion to discover what's missing, then SCAFFOLDS what it can safely generate (the `.github/workflows/security-review.yml` review workflow copied verbatim from keel's SHA-pinned recipe, and — for a repo whose check NAMES differ from keel's — the names-only `.claude/keel-auto-merge-checks.json`) as a plain code PR the human reviews and merges, and PRINTS (never runs) the exact branch-protection + `allow_auto_merge` `gh api` commands for the human to apply. It never sets the `ANTHROPIC_API_KEY` secret (a credential), never mutates a security setting itself, and never arms — it prepares, then points at `keel:arm-auto-merge`. Provisioning stays separate from certifying: the tool that builds the floor is never the tool that certifies it.
when_to_use: Human-triggered only, once per repo, BEFORE `keel:arm-auto-merge` — when arming a repo gaps because it has no required security-review workflow, its check NAMES differ from keel's, or `allow_auto_merge` is off, and you want the prerequisites prepared rather than hand-assembled from the gap messages. NOT `keel:arm-auto-merge` (that certifies the prerequisites are live and commits the marker; run it AFTER this). NOT a way for the agent to provision or arm itself — the human invocation is the authorization, and this skill only opens a scaffold PR and prints commands.
effort: high
disable-model-invocation: true
---

# Prep auto-merge (scaffold the prerequisites, then hand to arming)

`keel:arm-auto-merge` is a **pure certifier**: it asserts a repo's protection is live and commits the
marker only on green — it never sets any of that up, and deliberately must not (the required-checks
backstop is safe precisely because arming *independently verifies* the floor rather than *building* it —
`decisions/2026-08-02-per-project-auto-merge-authorization.md`, `decisions/2026-08-01-required-checks-protection.md`).
So on a repo that isn't set up, arming just names each gap. **This skill prepares those prerequisites** —
scaffolding what it can safely generate and printing the exact commands for what it must not run — then
hands to `keel:arm-auto-merge`. It is a **separate** skill on purpose: the tool that builds the floor is
never the tool that certifies it.

## What it does — and the hard line it never crosses

- **Discovers the gaps by reusing the assertion, never re-authoring it.** It runs
  `scripts/check-branch-protection.sh` — the same code arming runs — and maps each GAP to a targeted
  remediation. It inlines **no** copy of the branch-protection logic; if the assertion changes, it changes
  in that one script.
- **Scaffolds — as a plain code PR the human merges:** the review workflow, and (for a name-mismatch repo)
  the check-contract. It opens **one** PR with those files and stops.
- **Prints — never runs:** the branch-protection and `allow_auto_merge` `gh api` commands. These are the
  load-bearing floor; mutating them stays in the human's hands.
- **Reminds — never sets:** the `ANTHROPIC_API_KEY` secret is a credential; the human sets it.
- **Never arms.** It points at `keel:arm-auto-merge` as the next step. It issues no `gh pr merge`, writes no
  auto-merge marker, and calls no `gh api -X PUT/PATCH` and no `gh secret set` of its own.

## The ordered flow (a required context that no job yet reports wedges every PR)

The tier-1 recipe's load-bearing caveat: **never add a required status-check context before its job has
reported at least once**, or every PR in the repo wedges (`references/template-contract.md` tier 1,
`decisions/2026-08-01-required-checks-protection.md`). So prep is a **gated sequence**, not one shot — even
though the goal is near-one-command:

1. **Scaffold the prerequisites PR.** Run `scripts/check-branch-protection.sh` to see the gaps, then:
   - **(b2) — no review content:** copy `skills/prep-auto-merge/templates/security-review.yml`
     **verbatim** into the target repo's `.github/workflows/` (never re-type or regenerate it — the
     committed template is the tested artifact; the pinned SHA is kept in lockstep with keel's own
     `.github/workflows/ci.yml` review job). **Collision:** if the repo already has a `security-review`-shaped
     workflow (or a differently-named review job), **warn and leave the existing file untouched** — surface
     the mismatch for the human; never blindly overwrite a review they may already run.
   - **(b) — check NAMES differ from keel's:** author `.claude/keel-auto-merge-checks.json`, a **names-only**
     contract (`decisions/2026-08-03-arm-auto-merge-check-contract.md`; **no `pattern`/`external`**). Its
     `required_checks` are the repo's **actually-reporting** check contexts, read from a **PR head** — the
     one commit where PR-only checks (the `security-review` among them) *and* push-triggered checks both
     report. Because the scaffold PR does not exist yet when this file is authored, pin the source to the
     repo's **most-recent PR** (open or merged): `gh pr checks <most-recent-pr>` (equivalently
     `gh api repos/{owner}/{repo}/commits/<pr-head-sha>/check-runs --jq '.check_runs[].name'`) — **most-recent**
     so the set can't drift to a stale long-merged PR. If the repo has **no PR at all**, fall back to the
     repo's own **CI workflow job/context names** (from `.github/workflows/`). Then **add the scaffolded
     `security-review` context name explicitly** — it has not run anywhere yet, so it is named, never
     observed. Two hard lines: **never** `gh api …/protection`'s required-status-checks list (404/incomplete
     on exactly this repo — that is the gap), and **never** the default-branch head (a PR-only check never
     reports there). It must **include every check the repo already enforces** (a committed contract *replaces* the
     asserted set, so a narrow read would silently weaken the floor). Present the full generated set to the
     human to confirm in the PR. Shape:

     ```json
     { "required_checks": ["<reporting context>", "…"], "security_review": { "check": "security-review" } }
     ```

   - Commit these on a branch and open **one plain code PR** with `gh pr create`. **Do not push to the
     default branch, do not merge** — the human reviews and merges.

2. **Once the review job has gone green on a PR and the workflow is on `main`, apply the protection + auto-merge.**
   The `security-review` context may be required only when **both** hold: **(a)** it has **gone green on a PR**
   — the scaffold PR's own head is the first, since adding the workflow makes it run on that PR — confirmed
   via `gh pr checks <pr>` (equivalently `gh api repos/{owner}/{repo}/commits/<pr-head-sha>/check-runs`), **and
   it was a real scan, not the cached-skip hollow green** (see the cache caveat below); **and (b)** the
   workflow is **merged to `main`**, so every future PR inherits it. Never probe the default-branch head — a
   PR-only check never reports there. Until **both** hold, print only the next step (*"merge the workflow PR;
   its `security-review` runs on the PR itself"*).
   **Never** a protection command that requires a not-yet-reporting context — that is the wedge.
   Once both hold, **print** (do not run) these, for the human
   to apply:

   ```bash
   # Branch protection — required checks (the reporting contexts, including security-review),
   # strict up-to-date, PR required with zero approvals (the checks are the reviewers), enforce_admins.
   gh api -X PUT repos/{owner}/{repo}/branches/<default>/protection --input - <<'JSON'
   {
     "required_status_checks": {
       "strict": true,
       "checks": [ { "context": "security-review" }, { "context": "<other reporting context>" } ]
     },
     "enforce_admins": true,
     "required_pull_request_reviews": { "required_approving_review_count": 0 },
     "restrictions": null
   }
   JSON
   ```

   ```bash
   # Allow auto-merge so the `--auto` land path queues instead of stalling.
   gh api -X PATCH repos/{owner}/{repo} -f allow_auto_merge=true
   ```

   **Caveat to pass on (live dogfood):** the review action's per-PR cache can mask an environmentally-failed
   scan as a later hollow green (`security-review: skipped`); after any such failure, delete the PR's
   `claudecode-*` caches or confirm the scan executed before trusting a green
   (`specs/walks/2026-08-02-security-review-cache-mask.md`).

3. **Set the secret (the human, always).** Remind: set the `ANTHROPIC_API_KEY` Actions secret so the review
   job can run — **per repository** for personal-account repos (they can't share Actions secrets), or once
   as an **organization** secret granted to the repo if it's under a GitHub org. This skill never sets it.

4. **Hand off to arming.** Once the workflow PR is merged, the protection + `allow_auto_merge` commands are
   applied, and the secret is set, the prerequisites are live — run **`keel:arm-auto-merge`**, which
   *independently* re-asserts all of it and commits the marker only on green.

## Boundaries

- **This skill only opens the scaffold PR and prints commands.** It issues **no** `gh api -X PUT/PATCH`, no
  `gh secret set`, and no `gh pr merge` / marker write of its own. The one mutation it performs is opening
  the scaffold PR (like `keel:arm-auto-merge` opens the marker PR) — the human merges it.
- **Provisioning is separate from certifying.** This skill prepares the floor; `keel:arm-auto-merge`
  certifies it. They are two skills so a bug in the preparer can never masquerade as certification — arming
  re-runs the independent assertion regardless of what prep did.
- **The agent never invokes this skill to provision its own arming.** `disable-model-invocation: true`
  keeps the model from calling it; the human invocation is the whole authorization trail.
- **The assertion is reused, never re-authored.** Gap discovery is `scripts/check-branch-protection.sh` —
  the single source arming and preflight also call. Never inline a second copy here.
