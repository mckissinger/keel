---
name: status
description: Read-only "where are we / what's next" — the canonical state derivation and resume entry point. Derives project state from spec + git + GitHub truth and leads with the single next keel verb.
when_to_use: When the user asks where things stand or what's next, after a killed or compacted session, or whenever a session needs orientation before picking a verb. NOT for changing anything — it derives and reports only.
allowed-tools: Bash(git status *), Bash(git log *), Bash(git branch *), Bash(git diff *), Bash(git rev-parse *), Bash(git worktree list*), Bash(gh pr list*), Bash(gh pr view*), Bash(gh pr checks*)
---

# Status

Answer "where are we, and what's next?" from ground truth. This is the one owner of the state sweep every other verb used to re-derive ad hoc — the other skills point here.

**The hard rule: derive and report; fix nothing, write nothing, merge nothing, never cache.** State is re-derived from spec + git + GitHub truth on **every invocation** — status lives in the spec; derive, don't store. A stale answer is worse than no answer, and a status run that "quickly fixes" something it found has left its lane.

## Sources — the sweep reads all of these

- Milestone specs' `verified:` pins — `specs/milestones/`, including `specs/milestones/_landed/`.
- Feature specs (`specs/features/`) + `specs/00-product.md`'s backlog order — what exists vs what's specced.
- Chore-batch pins under `specs/chores/`.
- The deferrals ledger — every open `specs/deferrals/<slug>.md` (closed items live in `_closed.md` and are out of scope): what was consciously pushed, and whether its reopen trigger has arrived.
- Open PRs with base branch + CI state (`gh pr list`, `gh pr checks`).
- Local branches vs `main`, worktrees, and dirty working-tree state.
- The autonomy mode file / auto-merge marker — presence **and** expiry.

## Output contract — glance-first, in this order

1. **The single next action, first.** One keel verb + its argument (`/verify-milestone <slug>`, `/spec-feature <slug>`, "merge PR #12") — the reader should be able to stop after line one.
2. **Per-unit state.** Each in-scope feature/milestone classified into **exactly one** lifecycle state — specced / building / built-unverified / verified-pinned / PR-open / merged / feature-done-pending-review — with its evidence (the pin line, the PR number, the branch).
3. **Blocked-on-user.** Unmerged green PRs, pending attended gates, expired or expiring markers — the things only the user can move.
4. **Open deferrals.** Every open entry in `specs/deferrals/` — one line each: slug, one-clause summary, and whether its reopen trigger has arrived (**triggered** entries listed first, since a triggered deferral is a candidate for the next action in line one). Draining the ledger must not depend on the operator remembering it exists, so this section appears even when nothing is triggered — as a bare count plus slugs when the list is long.

**Budget: roughly twenty lines.** Detail on request, never by default — the report is a glance, not an audit trail.

## Resume mode

After a killed, compacted, or handed-off session, the same derivation yields a **"resume from X"** report: the in-flight branch, the open PR, the dirty worktree, orphaned background work. Resuming from that evidence is preferred over restarting the work — a half-built branch with a spec on `main` is a position, not a mess.
