# hooks-m3 — composition walk PLAN

Companion to `specs/milestones/hooks-m3-distribution-composition.md`. That milestone's
behavioral-completeness done-condition is a **[runtime] live composition walk** with an
**[attended]** transcript. A build subagent has **no live Claude Code session**, so the walk
below is **authored, not executed**. It enumerates each assertion (a–e) with the exact command
and the observation the attended `/verify-milestone` session must record.

## Status

- **NOT EXECUTED.** No live-session evidence exists yet. Do not treat this file as walk
  evidence; the walk transcript is produced in the attended verify session and attached to the
  PR (that transcript, not this plan, gates the pin).
- **Headless probes already run on this branch (deterministic cores):** the assertions'
  deterministic cores live in the m1/m2 committed self-tests, all green on this branch —
  `merge-guard.test.sh` (29/29), `guard-branch-rules.test.sh` (16/16),
  `session-bootstrap.test.sh` (11/11), plus `check-neutral` (17/17) and `check-verified-pin`
  (17/17). A scratchpad probe additionally exercised the composition-specific script behavior
  for (c), (d), (e) headlessly (7/7). What remains for the attended session is the **live-harness
  half** of each assertion: that the harness actually surfaces the ask/deny prompt, that a
  flagged skill is genuinely un-model-invocable yet human-invocable in a real session, and that
  a real session in a non-keel dir is silent end to end.

## Fixture

A throwaway keel-managed project (has `specs/milestones/` + `scripts/check-verified-pin.sh`),
on a milestone branch with an open, pinned, gate-passing PR against `main`, plus keel installed
as a plugin so its hooks are live. A second plain (non-keel) directory for (e).

## The walk — run each in a live Claude Code session, record the transcript

### (a) land-feature's merge of a pinned, gate-passing PR reaches the harness **ask** and proceeds on approval
- **Do:** in the fixture, with a pinned PR whose `check-verified-pin.sh` passes, run the
  land-feature merge step — e.g. ask the session to `gh pr merge <n> --merge`.
- **Observe:** the PreToolUse merge guard emits `permissionDecision: "ask"` with reason
  "verified-pin gate passed — per-merge human approval"; the harness shows the approval prompt;
  on approval the merge proceeds. The guard does **not** block or fight the landing flow.
- **Deterministic core (committed):** `merge-guard.test.sh` — "git merge <default> + passing
  gate → ask", "gh pr merge + resolvable PR context + passing gate → ask".

### (b) a gate-failing merge attempt is **denied** with the gate's reason
- **Do:** move the fixture PR to a state its `check-verified-pin.sh` rejects (e.g. code drift
  past the pinned SHA, or a missing `verified:` line), then attempt the same merge.
- **Observe:** the guard emits `permissionDecision: "deny"` and the reason is the gate's own
  stderr text verbatim; the merge does not proceed.
- **Deterministic core (committed):** `merge-guard.test.sh` — "failing gate → deny with the
  stderr reason verbatim".

### (c) verify-milestone's pin write is untouched by the branch guards
- **Do:** on a milestone branch (not `main`), run the pin write verify-milestone performs —
  `git add specs/ && git commit -m "verify: pin <slug> ..."`.
- **Observe:** the branch guard (`guard-branch-rules.sh`, active under implement-milestone /
  implement-feature) does **not** block it — exit 0, no stderr. (Control: the same commit on
  `main` is blocked with exit 2 and the branch-first message.)
- **Headless probe (executed, this branch):** scratchpad probe — pin write on the milestone
  branch: exit 0, silent; control commit on default branch: exit 2. Deterministic core:
  `guard-branch-rules.test.sh` commit-on-branch vs commit-on-main.

### (d) SessionStart bootstrap and the `disable-model-invocation` flags coexist
- **Do:** open a session in the fixture; inspect the bootstrap orientation; attempt to invoke a
  flagged skill (`adopt`, `land-feature`) by model choice vs. by explicit human `/` invocation.
- **Observe:** the bootstrap orientation still **names** the flagged skills (they appear in the
  grain ladder); the harness will **not** let the model auto-invoke a `disable-model-invocation:
  true` skill, but the human can still invoke it explicitly. The two mechanisms don't collide —
  naming a skill in orientation is not model-invoking it.
- **Headless probe (executed, this branch):** `adopt` and `land-feature` frontmatter both carry
  `disable-model-invocation: true`; the bootstrap output (keel-managed dir) names both. The
  live half — that the harness actually blocks model-invocation while allowing human invocation
  — is the attended part.

### (e) a non-keel directory session shows zero keel hook output
- **Do:** open a session in the plain (non-keel) directory; observe SessionStart; run an
  ordinary non-merge Bash command.
- **Observe:** the SessionStart bootstrap produces **no** output (exit 0, silent); the merge
  guard stays silent on non-merge commands. No keel hook text appears anywhere in the session.
- **Headless probe (executed, this branch):** `session-bootstrap.sh` in a non-keel dir: exit 0,
  zero output; `merge-guard.sh` on `ls -la` there: exit 0, zero output. Deterministic core:
  `session-bootstrap.test.sh` keel/non-keel gate.

## On failure

Any composition failure discovered in the walk is a **stop-point** (per the milestone's
[attended] condition): the fix rides this branch or bounces to the owning milestone (m1/m2) —
never waved through. Re-run the affected assertion after the fix.
