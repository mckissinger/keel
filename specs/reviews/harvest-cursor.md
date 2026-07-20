# Harvest cursor — the floor, and what past runs covered

**Watermark:** 2026-07-18

Contract (see `skills/harvest/SKILL.md`): every harvest run **enumerates its sources from the
filesystem** at step 0, using the watermark above as its floor, and mines every source that
enumeration returns. The run updates this file in the same commit as the digest it writes.
**The watermark advances only when every enumerated source produced a returned miner report** —
a miner that found nothing is a complete result; a miner that errored or was skipped holds the
floor where it is.

The table below is a **historical coverage record**. It is provenance — read it to see what a
past digest covered. It is **not** an input to what a run sweeps, and nothing is matched against
it by name.

## ⚠ The 2026-07-18 write-off — this floor is not verified coverage

**Sessions older than the watermark are out of scope permanently, by decision, not because
anyone read them.** 27 transcript directories holding **126 sessions** never appeared in this
table at all and so were never mined — among them `-Users-michaelkissinger-keel` (21),
`-Users-michaelkissinger-cre-list` (33), and `-Users-michaelkissinger-jarvis-2-0` (13). Mining
them would cost more subagent spend than months-old material is worth, and the user chose the
write-off explicitly on 2026-07-20.

Enumeration fixes the source-resolution defect **prospectively only**. Read this floor as "we
decided to stop here," never as "everything below is covered."

## Coverage record

| source dir (under `~/.claude/projects/`) | sessions covered | digest that covered them |
| --- | --- | --- |
| `-Users-michaelkissinger-cre-launch` | 14 (Jun 15–22) | `2026-07-12-transcript-harvest.md` + `2026-07-12-skill-mining.md` |
| `-Users-michaelkissinger-Dev-Projects-new-test-proj` | 27 (Jul 5–18) | `2026-07-12-transcript-harvest.md` + `2026-07-12-skill-mining.md` + `2026-07-18-harvest.md` |
| `-Users-michaelkissinger-new-test-proj` | 2 (Jul 6) | `2026-07-12-transcript-harvest.md` + `2026-07-12-skill-mining.md` |
| `-Users-michaelkissinger-Dev-Projects-keel` | 11 (through Jul 18) | `2026-07-12-skill-mining.md` + `2026-07-18-harvest.md` |
| `-Users-michaelkissinger-Dev-Projects-cre-list` | 13 (Jul 12–18) | `2026-07-18-harvest.md` |
| `-Users-michaelkissinger-test-proj-1` | 18 (Jul 11–18) | `2026-07-18-harvest.md` |
| `-Users-michaelkissinger-Dev-Projects-keel--claude-worktrees-keele-marketing-strategy-54976c` | 7 (Jul 11–18) | `2026-07-18-harvest.md` |
| `-Users-michaelkissinger-Dev-Projects-test-landing-page` | 2 (Jul 17) | `2026-07-18-harvest.md` |
| `-Users-michaelkissinger-Dev-Projects-jarvis-2-0--claude-worktrees-project-status-check-8fe0cc` | 2 (Jul 17–18) | `2026-07-18-harvest.md` |
| `-Users-michaelkissinger-Dev-Projects-ai-re-dev` | 1 (Jul 17) | `2026-07-18-harvest.md` |
| `-Users-michaelkissinger-Dev-Projects-keel--claude-worktrees-keele-hardening-skill-aceb19` | 1 (Jul 17) | `2026-07-18-harvest.md` |
| `-Users-michaelkissinger-Dev-Projects` | 1 (Jul 17) | `2026-07-18-harvest.md` |

## Provenance — the path drift that motivated enumeration

**CRE Launch moved checkouts and this file did not follow it.** Its sessions now land in
`-Users-michaelkissinger-Dev-Projects-cre-list`; the older `-Users-michaelkissinger-cre-launch`
row and `-Users-michaelkissinger-cre-list` are **prior homes of the same project**. The
2026-07-18 run's first sweep read only the listed dirs, found nothing newer than Jun 22, and
reported the project dormant — while 13 uncovered sessions sat in the unlisted directory.

A moved checkout is indistinguishable from an inactive project when sources are matched by
directory string. That is why step 0 enumerates and this table no longer decides anything.

Relay is the same project throughout under two dirs
(`-Users-michaelkissinger-new-test-proj`, `-Users-michaelkissinger-Dev-Projects-new-test-proj`).
