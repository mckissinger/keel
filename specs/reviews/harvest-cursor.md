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
