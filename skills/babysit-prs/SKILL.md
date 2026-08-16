---
name: babysit-prs
description: Background babysitter for the landing cycle — watch a queue of landing-approved PRs, update branches onto the moved base, re-pin under the CI-green rule, and drain merges under a standing authorization or hold everything prepared for the user's taps with one batched report. Automates the waiting, never the authorizing.
when_to_use: When a queue of reviewed, landing-approved PRs would otherwise be babysat by hand — watching checks, clicking update-branch, re-pinning, waiting to tap merge. Dispatched by land-feature / implement-feature for a feature wave, or directly for an ad-hoc queue (chore, review, punch-list PRs). NOT for building or verifying (implement/verify-milestone), NOT the merge-doctrine owner (that's land-feature, whose rules this executes), and NEVER a source of merge authority — with no active mode and no committed marker it merges nothing.
disable-model-invocation: true
---

# Babysit PRs

Run `land-feature`'s per-sibling landing cycle in the background so green PRs stop waiting
on human attention. The measured cost this removes
(`specs/reviews/2026-08-16-harness-efficiency.md`): ~75 hours of attended CI-wait/merge
choreography across five projects — single merges sitting pending for 210–464 minutes.
The cycle itself is fully prescribed prose (`skills/land-feature/SKILL.md`, the
protection-contract paragraph and the cascade rule); this verb executes that prose in a
loop, and restates none of it.

**It automates the cycle's waiting, never its authorizing.**
The babysitter never merges without a standing human authorization: an active mode or the committed marker.

## The queue — operationally defined, two modes

- **Hold mode** (no drain authorization): the queue is the explicit PR list given at
  dispatch, or — invoked bare — **every open non-draft PR**. Breadth is safe here because
  preparing is merge-free.
- **Drain mode** (an active `keel:auto` mode, or a valid committed
  `.claude/keel-auto-merge.json` marker on the default branch): the queue is **only** the
  explicit list the dispatching human or verb named, or — under the committed marker —
  the marker's own standing scope (gate-passing open non-draft PRs).
- In both modes,
  the workflow never infers landing approval from GitHub review state alone — review approval and green checks are necessary signals, never a sufficient derivation.
- The per-session attended marker (`.claude/keel-attended-merge.json`) is **not** a drain
  authorization here — it governs the interactive per-merge flow it was designed for
  (recorded at intake, `specs/changes/babysit-prs.md`).

## The loop — watch → prepare → drain-or-hold

Run the saved workflow `babysit-prs` with `{ queue: [<pr-numbers>] }` (omit `queue` to
derive per the mode rules above; pass `authorization: "mode"` only when an active
`keel:auto` orchestrator is the dispatcher — the workflow verifies the committed marker
itself and takes nothing else on the dispatcher's word). It:

- **watches** settle-only per `references/dispatch-and-monitoring.md` — one announcement
  at watch start with the expected duration, then blocking settle calls (all-settled or
  first-failure; empty `gh` output is a failed read to re-check, never a conclusion), the
  wait window sized from the repo's observed CI durations;
- **prepares** — when a landing moves the base: update each remaining PR, classify the
  diff old-pin → new-tip; empty outside plan paths → wait for the re-fired checks and, on
  green, re-pin via `scripts/repin.sh` citing the CI-green rule
  (`references/milestones-and-verification.md` §5); anything else (conflict, code drift,
  update failure) drops the PR from the loop with the reason;
- **drains or holds** — with a drain authorization, each merge is emitted per the
  emission contract in `scripts/merge-guard.sh`'s header (its own bare, un-chained
  `gh pr merge <pr> --auto` call); a stacked queue merges bottom-up with merge commits —
  never squash a stacked PR — with retarget-before-delete and close+reopen, per `land-feature`.
  With no drain authorization it prepares everything and ends on **one** batched final
  report (the ready list + the dropped list with reasons), which the dispatching session
  presents as the attended ask per `references/gate-presentation.md` — keel has no push
  channel and this verb invents no notification infrastructure.

## Boundaries

- **No marker, no merge:**
  with neither an active mode nor a valid committed marker, the workflow contains no merge invocation on any path — it prepares and holds.
- **A genuinely red required check is report-only:**
  the PR drops from the loop with the failing check named — no close/reopen re-fire, no retry, never a fix.
  Fixes route through the normal verbs; flakes through the flake doctrine.
- **The babysitter never edits code:**
  its only writes are `scripts/repin.sh`'s plan-only pin commits and branch updates via `gh pr update-branch`.
  It never resolves conflicts, never writes a first pin (`repin.sh` refuses one by contract).
- **Branch deletion is decoupled:** it deletes no branch an open descendant is based on,
  and deletes branches at all only when its queue equals the full remaining open stack —
  otherwise deletion is a post-wave step (or the user's). Never a `--delete-branch`
  bundled into a drain emission — the closed merge shape excludes it.
- **`land-feature` stays the doctrine owner** — the post-wave consolidated check and the
  spec reconciliation are its steps, run by its process after the wave lands, never by
  this loop.
- **Human-dispatched only** (`disable-model-invocation: true`): a session never
  self-invokes a verb that can reach a merge lane; the `implement-feature` run-through
  path follows the workflow as doctrine dispatch, which this flag does not bind.

## Where this sits

```
implement-feature → [PRs open] → babysit-prs (background: prepare + drain/hold) → land-feature's post-wave steps
                                    ↑ also directly, for any ad-hoc green-PR queue
```
