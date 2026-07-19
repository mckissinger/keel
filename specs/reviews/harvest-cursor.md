# Harvest cursor — sessions already mined

Contract (see `skills/harvest/SKILL.md`): every harvest run reads this file first, mines
only sessions **newer than each source's through-mark**, and updates this file in the same
commit as the digest it writes. Sources are identified by their transcript-directory names
under `~/.claude/projects/` so a run can match them mechanically.

Seeded 2026-07-12 with the pilot's coverage (14 + 21 + 5 sessions across the two pilot
digests). One project's 21 sessions span two transcript directories — the checkout moved —
so both dirs are listed and both are covered.

| source dir (under `~/.claude/projects/`) | sessions covered | through | digest that covered them |
| --- | --- | --- | --- |
| `-Users-michaelkissinger-cre-launch` | 14 (Jun 15–22) | 2026-07-12 | `2026-07-12-transcript-harvest.md` + `2026-07-12-skill-mining.md` |
| `-Users-michaelkissinger-Dev-Projects-new-test-proj` | 19 (Jul 5–12) | 2026-07-12 | `2026-07-12-transcript-harvest.md` + `2026-07-12-skill-mining.md` |
| `-Users-michaelkissinger-new-test-proj` | 2 (Jul 6) | 2026-07-12 | `2026-07-12-transcript-harvest.md` + `2026-07-12-skill-mining.md` |
| `-Users-michaelkissinger-Dev-Projects-keel` | 5 (through Jul 12) | 2026-07-12 | `2026-07-12-skill-mining.md` |
| `-Users-michaelkissinger-Dev-Projects-cre-list` | 13 (Jul 12–18) | 2026-07-18 | `2026-07-18-harvest.md` |
| `-Users-michaelkissinger-Dev-Projects-new-test-proj` | +8 (Jul 12–18) | 2026-07-18 | `2026-07-18-harvest.md` |
| `-Users-michaelkissinger-Dev-Projects-keel` | +6 (Jul 16–18) | 2026-07-18 | `2026-07-18-harvest.md` |
| `-Users-michaelkissinger-test-proj-1` | 18 (Jul 11–18) | 2026-07-18 | `2026-07-18-harvest.md` |
| `-Users-michaelkissinger-Dev-Projects-keel--claude-worktrees-keele-marketing-strategy-54976c` | 7 (Jul 11–18) | 2026-07-18 | `2026-07-18-harvest.md` |
| `-Users-michaelkissinger-Dev-Projects-test-landing-page` | 2 (Jul 17) | 2026-07-18 | `2026-07-18-harvest.md` |
| `-Users-michaelkissinger-Dev-Projects-jarvis-2-0--claude-worktrees-project-status-check-8fe0cc` | 2 (Jul 17–18) | 2026-07-18 | `2026-07-18-harvest.md` |
| `-Users-michaelkissinger-Dev-Projects-ai-re-dev` | 1 (Jul 17) | 2026-07-18 | `2026-07-18-harvest.md` |
| `-Users-michaelkissinger-Dev-Projects-keel--claude-worktrees-keele-hardening-skill-aceb19` | 1 (Jul 17) | 2026-07-18 | `2026-07-18-harvest.md` |
| `-Users-michaelkissinger-Dev-Projects` | 1 (Jul 17) | 2026-07-18 | `2026-07-18-harvest.md` |

## ⚠ Path drift — read this before trusting a "source went quiet" conclusion

**CRE Launch moved checkouts and this cursor did not follow it.** Its sessions now land in
`-Users-michaelkissinger-Dev-Projects-cre-list`; the older `-Users-michaelkissinger-cre-launch`
row (through Jun 22) and `-Users-michaelkissinger-cre-list` are **prior homes of the same
project**. The 2026-07-18 run's first sweep read only the listed dirs, found nothing newer
than Jun 22, and reported the project dormant — while 13 uncovered sessions sat in the
unlisted directory.

A moved checkout is indistinguishable from an inactive project when sources are matched by
directory string. Until harvest resolves sources by project identity (slate item 1), **every
run must enumerate all dirs under `~/.claude/projects/` with sessions newer than its floor
and reconcile them against this table** rather than mining only what is listed here.

Relay is the same project throughout under two dirs
(`-Users-michaelkissinger-new-test-proj`, `-Users-michaelkissinger-Dev-Projects-new-test-proj`).

The harvesting session itself (`d08ba4aa`, Jul 18, keel repo) is excluded as in-flight and
remains available to a later run.
