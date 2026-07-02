# Milestone — hooks-m3-distribution-composition: seeding, backstop docs, composition walk

**Goal:** keel-managed projects seed keel for every collaborator; the docs place hooks as a
local backstop (CI + branch protection stay server-side); and the shipped mechanisms are
proven to compose — with each other and with the flows they must not break.

**Feature:** `specs/features/enforcement-hooks.md`. **No-UI** → two-dimension
done-conditions. **Depends on:** `hooks-m1-bootstrap`, `hooks-m2-guards`.
**Parallelizable:** no (tests the shipped whole).

## Done-conditions

### Logic / invariants
- [auto] `skills/provision/SKILL.md` step 4 (owner of the committed `.claude/settings.json`)
  additionally seeds `extraKnownMarketplaces` (keel's GitHub source) + `enabledPlugins`
  (`keel@keel`); `skills/adopt/SKILL.md` gains the same as an addition to its settings step
  (adopt does not currently write settings.json — this adds it, scoped to the seeding).
- [auto] Backstop placement documented in exactly three places, one sentence each:
  `README.md` (hooks are a local backstop; project CI + branch protection are the
  server-side gate), `skills/land-feature/SKILL.md` (the merge guard's ask is the same
  per-merge approval, now harness-shaped), `references/milestones-and-verification.md` §5
  (the pin gate's local backstop note). No fourth restatement (one-owner sweep).

### Behavioral completeness — the composition walk
- [runtime] **Live composition walk** in a fixture keel project (scripted where possible;
  each assertion's deterministic core lives in the m1/m2 committed self-tests): (a)
  land-feature's merge of a pinned, gate-passing PR reaches the harness **ask** and proceeds
  on approval — the guard does not fight the landing flow; (b) a gate-failing merge attempt
  is **denied** with the gate's reason; (c) verify-milestone's pin write (`git add specs/` +
  `git commit` on the milestone branch) is untouched by the branch guards; (d) the
  SessionStart bootstrap and the `disable-model-invocation` flags coexist — flagged skills
  stay human-only invocable, bootstrap still names them; (e) a non-keel directory session
  shows zero keel hook output.
- [attended] Walk transcript attached to the PR; any composition failure discovered here is a
  stop-point (fix rides this branch or bounces to the owning milestone) — never waved
  through.
- [auto] `claude plugin validate --strict .` and all self-tests green on the branch.

## verification
verifier subagent against this file (seeding + docs greps, one-owner sweep, self-tests) +
the [runtime]/[attended] composition walk above, run serially in the verify session (it
gates the pin — the walk's transcript is the evidence). No new hard invariant beyond m2's →
no separate `/security-review`.

verified: clean at 2dc2c8e, 2026-07-01, via fresh-context verifier subagent — [auto] conditions clean (seeding, 3 backstop docs one-owner, validate + 5 suites green: check-neutral 17/17, check-verified-pin 17/17, session-bootstrap 14/14 incl. case 2b, merge-guard 29/29, guard-branch-rules 16/16); composition walk EXECUTED + user-APPROVED, transcript covers a–e (pass→ask, fail→deny verbatim, pin-write on-branch vs main-blocked, flagged skills named+flagged, non-keel silent) (evidence: walk transcript + verifier report in PR)
