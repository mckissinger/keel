# Milestone — measure-m2-wiring

Feature context: `specs/features/measure.md`. Second of two; surfaces `measure` in the
ladder and banners, lands the routing seams into the two existing growth skills, pins
the doctrine's cohort-attribution sentence, adds the routing fixtures, and records the
two deferrals. Depends on m1 (the anchor pins m1's doctrine sentence verbatim; the
routing sentences cite m1's skill). Every edit to a shared file in this wave is owned
here alone. The `run-growth` and `gtm` edits are one sentence each — scope, gates, and
`run-growth`'s human-trigger posture are unchanged. Neutrality caution as m1.

## Done-conditions

- [auto] **Ladder wiring.** `README.md`'s grain-ladder `Growth:` line names `measure`
  alongside `gtm → spec-campaign → run-growth`, the skills-list Growth bullet gains
  `measure` (one verb's worth of description: metrics spec + read-only cohort
  readout), **and the skill count reads 28** — no stale count text survives anywhere
  in the file; both orientation-banner copies in `scripts/session-bootstrap.sh`
  carry `measure` on their Growth line (with `run-growth` still marked
  human-triggered — `measure` is not); and `scripts/session-bootstrap.test.sh`
  gains an assertion that the emitted banner names `measure`, with the full suite
  still passing.
- [auto] **The run-growth seam lands.** `skills/run-growth/SKILL.md` gains one
  sentence: the cycle brief (step 3) cites the latest cohort readout when the
  campaign's pinned product repo carries `specs/gtm/metrics.md` — produced by
  `measure`'s readout mode, never by this verb. One sentence; the skill's six-step
  contract, gates, `disable-model-invocation`, and scope are otherwise unchanged
  and the file is otherwise byte-identical to `main`.
- [auto] **The gtm seam lands.** `skills/gtm/SKILL.md` gains one sentence: the
  metrics layer — activation definition, funnel, readout — is `measure`'s,
  downstream, and `gtm` does not author `specs/gtm/metrics.md`. One sentence; the
  skill's scope is otherwise unchanged and the file is otherwise byte-identical to
  `main`.
- [auto] **The cohort-attribution rule is anchored.**
  `scripts/skill-anchors/measure.txt` exists (new file, file-per-feature — no edit
  to `growth.txt`) and pins the doctrine's cohort-attribution sentence verbatim
  from `references/growth-operations.md`, and `scripts/check-skill-anchors.sh`
  passes with it.
- [auto] **Boundary fixtures exist for the suite.** New file-per-entry fixtures under
  `scripts/skill-eval/fixtures/` (`g6-*.json`) cover at least: a prompt that should
  fire `measure` in authoring shape (defining activation/growth metrics before
  campaigns start), a `measure`-vs-`run-growth` boundary case (asking whether a
  past campaign produced signups/activation — a read, expected `measure`), and a
  `gtm`-vs-`measure` boundary case (asking what the north-star metric should be —
  expected `measure`) — each in the existing fixture shape
  (`{prompt, expected, boundary}`), each a valid-JSON file under the directory the
  eval harness discovers fixtures from, with the eval self-tests still passing.
- [auto] **The deferrals are recorded.**
  `specs/deferrals/measure-person-level-attribution.md` (linking outreach contacts
  to product accounts; gated on an attended privacy decision recorded before any
  join work starts) and `specs/deferrals/measure-feature-usage.md` (per-feature
  usage/engagement analytics beyond the growth funnel) each exist in the deferrals
  ledger's format with an explicit risk/trigger note.
- [auto] **Repo checks green.** `claude plugin validate --strict .`,
  `scripts/check-neutral.sh`, `scripts/check-plan.sh`,
  `scripts/check-skill-frontmatter.sh`, `scripts/check-skill-anchors.sh`, and every
  `scripts/*.test.sh` pass on the branch.

## verification

verifier subagent against this file's done-conditions (all `[auto]`; the milestone is
wiring, fixtures, and ledger entries, closable by reading the named files, diffing the
two one-sentence seams against the base branch, and running the named checks —
including the session-bootstrap and skill-eval self-tests).

verified: clean at 4bc6f03, 2026-07-18, via verifier subagent against this spec's done-conditions — all 7 conditions evidenced with file:line, both one-sentence seams byte-identical-otherwise vs main, anchor verbatim-matched, plugin validate + 4 repo checks + 11 script self-tests + eval self-tests green (evidence in PR #150)
