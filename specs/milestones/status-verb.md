# Milestone — status-verb

Change context: `specs/changes/status-verb.md`. One milestone; adds one skill and wires
it — new `skills/status/SKILL.md`, one ladder line in `README.md`, the orientation
banner in `scripts/session-bootstrap.sh` (both the neutral and mode-active copies) +
its self-test, and one pointer sentence each in `skills/implement-milestone/SKILL.md`
and `skills/auto/SKILL.md`. No gates, guards, or templates change. Integration seams:
the session-bootstrap banner is covered by `scripts/session-bootstrap.test.sh` (which
must stay green and gains an assertion for the new line); the orient/audit steps in
implement-milestone and auto keep their own non-state work (green-baseline rung,
charter seed) — the pointer names the shared derivation only.

## Done-conditions

- [auto] **The skill exists and is well-formed.** `skills/status/SKILL.md` has valid
  frontmatter (`name: status`, a `description`, a `when_to_use`) and passes
  `scripts/check-skill-frontmatter.sh` (now 18 skills). It does **not** carry
  `disable-model-invocation` (read-only; self-invocation is safe and intended).
- [auto] **Read-only as a hard rule + a promptless read set.** The skill body states
  the hard rule: derive and report; fix nothing, write nothing, merge nothing, never
  cache — state is re-derived from spec + git + GitHub truth on every invocation. The
  frontmatter's `allowed-tools` pre-approves an **enumerated read-only command set** so
  the sweep runs promptless — `Bash(git status *)`, `Bash(git log *)`,
  `Bash(git branch *)`, `Bash(git diff *)`, `Bash(git rev-parse *)`,
  `Bash(git worktree list*)`, `Bash(gh pr list*)`, `Bash(gh pr view*)`,
  `Bash(gh pr checks*)` — and grants no Edit/Write. (`allowed-tools` is a grant, not a
  restriction — the read-only guarantee is the stated rule, per keel's own recorded
  semantics; the condition claims promptless reads, not harness-blocked writes.)
- [auto] **The derivation sources are enumerated.** The skill body names, as the sweep's
  inputs: milestone specs' `verified:` pins including `specs/milestones/_landed/`,
  feature specs + `specs/00-product.md` backlog order, chore-batch pins
  (`specs/chores/`), the deferrals ledger, open PRs with base branch + CI state, local
  branches vs `main`, worktrees + dirty working-tree state, and the autonomy mode file /
  auto-merge marker (presence + expiry).
- [auto] **The output contract is glance-first.** The skill body specifies the report
  shape in this order: (1) **the single next action** — one keel verb + its argument —
  first; (2) per-unit state: each in-scope feature/milestone classified into exactly
  one lifecycle state (specced / building / built-unverified / verified-pinned /
  PR-open / merged / feature-done-pending-review) with its evidence (pin line, PR
  number, branch); (3) a **blocked-on-user** list (unmerged green PRs, pending attended
  gates, expired/expiring markers); and a stated size budget of roughly twenty lines —
  detail on request, never by default.
- [auto] **Resume is a named mode.** The skill body states that after a killed,
  compacted, or handed-off session the same derivation yields a "resume from X" report
  (in-flight branch, open PR, dirty worktree, orphaned background work) and that
  resuming from it is preferred over restarting the work.
- [auto] **Ladder wiring.** `README.md`'s grain ladder / skills list names `status` as
  cross-cutting (alongside `debug`) **and its skill count reads 18** (no "17 skills"
  text survives anywhere in the file); both orientation-banner copies in
  `scripts/session-bootstrap.sh` carry it on their Cross-cut line; and
  `scripts/session-bootstrap.test.sh` gains an assertion that the emitted banner names
  `status`, with the full suite still passing.
- [auto] **Single-owner pointers.** `skills/implement-milestone/SKILL.md`'s orient step
  and `skills/auto/SKILL.md`'s entry-state audit each contain one sentence naming
  **the `status` skill** (that literal backticked skill reference, greppable as
  ``the `status` skill``) as the owner of the canonical state sweep, while retaining
  their own non-state work (the cheapest-rung baseline check; the charter seed + run
  definition-of-done) unchanged.
- [auto] **Repo checks green.** `claude plugin validate --strict .`,
  `scripts/check-neutral.sh`, `scripts/check-plan.sh`,
  `scripts/check-skill-frontmatter.sh`, `scripts/check-skill-anchors.sh`, and every
  `scripts/*.test.sh` pass on the branch.

## verification

verifier subagent against this file's done-conditions (all `[auto]`; the new skill is
prose + frontmatter, closable by reading the named files and running the named checks).

verified: clean at bca9552, 2026-07-12, via verifier subagent against this spec's done-conditions — all 8 conditions evidenced, 5 repo checks + 11 script self-tests green (evidence in PR #109)
