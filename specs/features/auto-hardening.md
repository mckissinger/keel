# Feature — auto-hardening: close the dogfood-proven gaps in the autonomy postures

**Goal:** the four gaps the x-big-proj (ShipLog) dogfood run surfaced in `auto:run`/`auto:feature`
are closed, so the next unattended run hits none of them: the preflight asserts the repo can
actually auto-merge; both untracked markers expire instead of persisting as standing escalations;
the verifier reads the project's real runtime before judging `[runtime]` conditions; and a
kickoff's outputs seed the run's charter without re-derivation.

**Why now (evidence):** the 2026-07-03 ShipLog auto run ledgered exactly these: entry 002 —
`allow_auto_merge` was false (GitHub's default), `gh pr merge --auto` fell back to an interactive
prompt and the run needed a hand-merge; entry 005 — the fresh verifier returned NOT READY solely
because it assumed a local Docker stack when the project runs hosted `shiplog-dev`; and keel's own
deferral `specs/deferrals/mode-file-binding-ttl.md` records the marker-persistence risk (a
crashed run's `keel-autonomy.json`, or a forgotten `keel-attended-merge.json`, silently arms a
later session). The kickoff→run seam is the remaining manual re-derivation between the two
halves of an end-to-end unattended build.

**No-UI feature** → two-dimension done-conditions (logic/invariants + behavioral completeness);
fidelity does not apply. **Interview record:** decided 2026-07-05 in the combined
autonomy-modes-v2 sitting — TTLs 24h (autonomy mode file) / 8h (attended marker), stale marker =
treated absent (fail closed), guards are the enforcement point (no new writer path — the invoking
skill stays each file's only writer); verifier brief sources from the project's existing
`specs/stack-profile.md` (no new artifact); the kickoff seam is prose in the two skills, no new
machinery.

## Milestones (file→milestone ownership map; no routes — no UI)

| Unit | Milestone | Owns |
|---|---|---|
| Guard/preflight mechanics | `auto-hardening-m1-guards` | `scripts/merge-guard.sh`, `scripts/guard-branch-rules.sh`, **`scripts/session-bootstrap.sh` (its `read_mode_file` copy — the third reader)**, `scripts/check-auto-preflight.sh`, their `.test.sh` suites, `scripts/attended-marker-parity.test.sh`, marker-contract prose in `skills/auto/SKILL.md` + `skills/auto-merge/SKILL.md`, `specs/deferrals/mode-file-binding-ttl.md` update |
| Verb-prose seams | `auto-hardening-m2-seams` | `skills/verify-milestone/SKILL.md`, `agents/verifier.md`, `skills/kickoff/SKILL.md`, the entry-audit paragraph of `skills/auto/SKILL.md`, `specs/deferrals/verifier-project-memory.md` update, **new `scripts/check-skill-anchors.sh` + `scripts/skill-anchors/auto-hardening.txt` + CI wiring** (the prose-anchor lint; anchor sets are file-per-feature so later features add their own file, never edit a shared one) |

**Build order + integration seams:** m1 and m2 touch disjoint files **except**
`skills/auto/SKILL.md` (m1 edits its mode-file contract sentence; m2 edits its entry-audit
paragraph) — different sections, but treat as **sequential (m1 → m2)** to avoid a same-file
rebase. The planned `auto-genesis` feature's m3 also edits both guard scripts: that feature
builds **after this one lands** (recorded in its spec).

**Parallelizable:** no (sequential, above).
