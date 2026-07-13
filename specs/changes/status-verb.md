# Change — status-verb

One milestone: a new read-only `status` skill — the canonical "where are we / what's
next" derivation — plus its ladder wiring and two single-owner pointers. Approved by
Michael 2026-07-12 (slate group C item 6; `reviews/2026-07-12-structural-review.md` §1
"missing state plane" — the highest-frequency, cheapest item on the slate).

## Why

State derivation is keel's one many-implementations-no-owner rule: every skill
re-derives project state ad hoc ("orient first" in implement-milestone, the entry-state
audit in `auto`, land-feature's sweep), every compaction summary hand-reconstructs it,
and the dogfood transcripts show the user asking "where are we / what's next /
are all PRs merged?" 15+ times across two projects — plus real resume incidents
(orphaned wave agents, killed sessions) with nothing to grab onto. The gates each have
one canonical owner; state has none. This verb is that owner.

## Decisions taken

- **Read-only, always safe.** The skill derives and reports; it fixes nothing, writes
  nothing, merges nothing. Derived from spec+git+GitHub truth on every invocation —
  never cached (keel's own "status lives in the spec; derive, don't store" doctrine).
- **Sources**: milestone specs' `verified:` pins (+ `_landed/`), feature specs +
  `00-product.md` backlog order, chore-batch pins, the deferrals ledger, open PRs with
  base + CI state, local branches vs `main`, worktrees + dirty state, autonomy mode
  file / auto-merge marker presence + expiry.
- **Output contract, glance-first**: the single next action (a keel verb + argument)
  leads; then per-unit classification into exactly one lifecycle state with evidence
  (pin line / PR # / branch); then a blocked-on-user list (unmerged green PRs, pending
  attended gates, expired markers). Whole report ≤ ~20 lines.
- **Resume entry point**: after a killed/compacted session, the same derivation reports
  "resume from X" (branch, open PR, dirty worktree) instead of restarting work.
- **Single-owner pointers, not rewrites**: `implement-milestone`'s orient step and
  `auto`'s entry-state audit each gain one sentence naming this skill's derivation as
  the shared state sweep — their own steps (green-baseline rung, charter seed) stay
  theirs. No other skill changes.
- **Ladder wiring**: the README grain ladder/skills list gains the verb (cross-cutting,
  next to `debug`) and its skill count bumps to 18; the session-bootstrap orientation
  banner (both copies) gains the verb and its self-test asserts the new line.
- **Honest frontmatter semantics**: `allowed-tools` is a grant, not a restriction — the
  skill pre-approves an enumerated read-only command set for promptless sweeps; the
  read-only guarantee itself is the skill's stated hard rule.
- Model may self-invoke it (no `disable-model-invocation`) — it is read-only and is
  exactly what a disoriented session should reach for.

## Milestone

`specs/milestones/status-verb.md` — new `skills/status/SKILL.md`; one line each in
`README.md`, `scripts/session-bootstrap.sh` (both banner copies) + its test,
`skills/implement-milestone/SKILL.md`, `skills/auto/SKILL.md`.
