# Attended marker doesn't cover immediate-merge of an already-green PR

**Parked 2026-07-05.** Surfaced by dogfooding the attended auto-merge toggle
(`decisions/2026-07-04-attended-auto-merge.md`) on this repo, in the same session that landed
PRs #76–#79. The marker works for the case it was designed around — a PR whose required checks
are still running — but not for a PR that is **already green** when the human goes to merge it.

**The gap.** The marker unlocks exactly one command shape: a bare `gh pr merge <pr> --auto
[--squash|--merge|--rebase]` (the `detect_strict_auto` whitelist), and both guards honor only
that shape — there is no agent-side plain-merge path, by deliberate design. But once the repo has
`allow_auto_merge: true` set, `gh pr merge <pr> --auto` on an **already-clean** PR **errors**
(`GraphQL: Pull request is in clean status`) instead of merging: GitHub refuses to *enable*
auto-merge on a PR with no pending required checks. So the agent, under a valid marker and an
explicit human instruction, cannot complete a tap-free merge of an already-green PR — the human
must fall back to a plain `gh pr merge <pr> --squash` in their own shell (the `!` path, outside
the agent tool path).

**Why the setting stays on anyway.** `allow_auto_merge: true` is not the bug and must not be
reverted: the **autonomy path requires it** — an `auto:run` fires `--auto` on a PR whose checks
are still pending, which is exactly what `auto-hardening`'s preflight check (d) asserts as a
precondition. With the setting *off*, `--auto` immediate-merges an already-green PR but cannot
queue a pending one (it errors, needing a retry once green — observed on #77). The friction is
inherent to `--auto`'s two modes; enabling the setting is the correct default, so the residue
lands specifically on **attended immediate-merge of an already-green PR**.

**Why it is deferred, not refused.** The human has a clean, correct workaround already (`!
gh pr merge <pr> --squash` in their shell — the human exercising merge authority the guard is
protecting, not routing around it), so this is an ergonomics increment, not a blocker. And the
obvious fix *widens what the marker unlocks*, which is a doctrine call the attended-merge decision
made narrowly on purpose — it deserves a deliberate `spec-change`, not a quick patch.

**The change when built.** Extend both guards so that, under a valid attended marker (and no
autonomy mode — that path still wins), a bare `gh pr merge <pr> --squash` (or `--merge`/`--rebase`)
with **no** `--auto`, on a **verified-pin-gate-passing** PR, is treated the same as the `--auto`
shape: `merge-guard.sh` → **allow** instead of the ask floor, `guard-branch-rules.sh` → **defer**
instead of `exit 2`. The load-bearing gate is unchanged — an immediate `gh pr merge` still lands
only what the branch's required checks already passed, so "server checks decide what lands" holds
exactly as it does for `--auto`. The whitelist widens from "the `--auto` handoff" to "an
instructed merge of a gate-passing PR, immediate or queued." Weigh this against the reason the
decision scoped to `--auto` originally (a plain `gh pr merge` is a broader, more familiar shape,
so the whitelist must still reject bundled/chained forms and only match the bare single-PR shape).

**Gate.** Needs a decision on whether the attended marker *should* unlock plain immediate-merge
at all (the doctrine question), and if so the widened `detect_strict_auto` whitelist wired into
both guards + `merge-guard.test.sh` / `guard-branch-rules.test.sh` cases (already-green PR under
marker → allow/defer; still rejects bundled/chained merges and the no-marker baseline). Resolve as
its own `spec-change` once the workaround has been lived with enough to confirm the ergonomics are
worth the widened surface.
