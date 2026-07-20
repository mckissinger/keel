# Milestone — Harvest asserts its own coverage

**Goal:** a harvest run can no longer under-report because a project's checkout moved or was
never listed — coverage is enumerated, announced, and machine-checked rather than assumed.

**Change:** `specs/changes/harvest-source-resolution.md`. **No-UI** → two-dimension
done-conditions. **Depends on:** none. **Parallelizable:** with
`harvest-human-input-filter` (disjoint files apart from `scripts/skill-anchors/harvest.txt`,
which is append-only — sequence them if built concurrently).

**Second draft.** The first failed its adversarial plan pass with three CRITICALs, two of
which reproduced the very defect the milestone exists to fix. Conditions below carry the
specific guards those findings demanded; the failure modes are named so a builder cannot
re-open them by accident.

## Done-conditions

### Logic / invariants

- [auto] **`scripts/harvest-sources.sh` exists, is executable, and enumerates totally.** Given a
  watermark date, it returns every immediate subdirectory of the transcript root (default
  `~/.claude/projects/`, overridable by env var for testability) holding at least one `*.jsonl`
  modified after that date. **Enumeration is unconditional**: the script reads no list of
  expected sources, accepts no source-name list, and consults no cursor or record file — it
  cannot inherit the staleness it exists to prevent. An optional **scope-filter path argument**
  is applied strictly *after* enumeration, narrowing the result without narrowing the sweep.
- [auto] **Output is parseable, not prose.** One line per source, **tab-delimited**:
  `directory-name<TAB>session-count<TAB>newest-session-date`. Ordering is stable
  (session-count descending, then name). The authoritative timestamp is the session file's
  **mtime**, stated in the script's header comment, so counts cannot drift between readings.
- [auto] **A missing or unreadable root fails loudly, and is distinguishable from an empty
  result.** Root absent, unreadable, or mis-set → **nonzero exit** with a diagnostic on stderr.
  A legitimate "nothing newer than the watermark" → exit 0, no output. *These two must not share
  an observable*: the first draft made them identical, which reproduced the original defect
  (silence read as dormancy) with a new cause.
- [auto] **`scripts/harvest-sources.test.sh` is green and its cases discriminate.** Against a
  fixture transcript root: (1) a directory with sessions newer than the watermark is listed;
  (2) a directory whose sessions are all older is not; (3) **the decoy-record case — a
  cursor-shaped file listing only a subset of the fixture's directories is present, and an
  active directory absent from that file is still returned.** This is the regression lock: it
  fails if the script ever learns to consult such a file, which is the coupling that caused the
  observed miss. (4) a directory with no `*.jsonl` is not listed; (5) hidden directories are
  skipped; (6) an empty result exits 0 and prints nothing; (7) **a nonexistent root exits
  nonzero**; (8) the scope filter narrows the result to matching directories only, and the
  unfiltered enumeration is unaffected by its presence; (9) output parses as tab-delimited
  fields.
- [auto] **The new suite is wired into CI.** `.github/workflows/ci.yml` gains a step running
  `bash scripts/harvest-sources.test.sh`, matching the existing per-test-script pattern (the
  workflow enumerates each suite explicitly and does **not** glob, so an unwired suite runs once
  at verification and never again).
- [auto] **`specs/reviews/harvest-cursor.md` carries a single global watermark**, explicitly
  labelled authoritative, **seeded at `2026-07-18`**. That value is safe rather than assumed:
  the only two sources still marked through 07-12 (`-Users-michaelkissinger-cre-launch`,
  `-Users-michaelkissinger-new-test-proj`) have **zero** sessions after that date — verified,
  newest 2026-06-22 and 2026-07-06 respectively — so the collapse loses no coverage. The
  per-source table is retained but **demoted to a found-record**, and the file's own contract
  text states that no run may derive its sweep set from it.
- [auto] **`skills/harvest/SKILL.md`'s cursor section is replaced, not supplemented.** A run
  reads the global watermark, invokes `scripts/harvest-sources.sh` (named by path) for its sweep
  set, and mines every source returned. The prior per-source through-mark instruction is
  **removed from the file** — a retired rule left in place is a rule a fresh session may follow.
  A **nonzero exit from the script stops the run and reports**; there is no fallback to the
  found-record, because a silent fallback restores the original bug.
- [auto] **`retro` scope narrows by filter, not by a separate mechanism.** A `retro` run invokes
  the same script with the scope-filter argument set to its own project's transcript
  directory(ies), so enumeration stays total while the mined set stays local. The skill states
  this explicitly. **Observable: a `retro` run's announced source count is 1.**
- [auto] **The run announces scope before dispatching any subagent**: session count, source
  count, and watermark date. The skill states that this announcement — not a mid-run gate — is
  where an unexpectedly large sweep is caught, and that it precedes spending.
- [auto] **Watermark advance is defined and lossless at the edges.** The watermark advances to
  the **enumeration-start timestamp**, written in the same commit as the digest. Sessions still
  in flight at that timestamp are **recorded in the found-record as excluded and remain
  available to a later run** — preserving the carve-out the per-source table used to express and
  the first draft silently deleted.
- [auto] **The found-record is maintained, not merely retained.** Each run appends its found
  sources — directory, session count, digest that covered them — in the same commit as the
  digest, so per-source provenance survives the demotion.
- [auto] **`allowed-tools` names the script literally.** The frontmatter grant gains
  `Bash(scripts/harvest-sources.sh *)` — **not** `Bash(bash *)`, which would be an unbounded
  shell grant contradicting the skill's read-only sweep-set posture.
- [auto] **`scripts/skill-anchors/harvest.txt` machine-checks the protected rules.** Positive
  anchors for: the secret rule, the diff-against-HEAD requirement, the writes-only-digest-and-
  cursor rule, **"No cursor in the target repo = ask"** (the only guard against a fresh `retro`
  mining unbounded history), and the update-in-the-same-commit rule. **A negative anchor**
  asserting the retired per-source through-mark instruction stays absent. `bash
  scripts/check-skill-anchors.sh` green. This replaces prose "no weakening" conditions, which a
  verifier closes by eyeballing a diff and which pass on a reworded gut.
- [auto] **Unchanged in the diff:** `disable-model-invocation: true`, the two-scope structure,
  and the fan-out-via-read-only-subagents instruction.

### Behavioral completeness

- [auto] **The end-to-end miss is demonstrably closed**: with the fixture root containing a
  directory that no record mentions, the script returns it and the skill's documented flow mines
  it. Test case (3) is the mechanical half; the negative anchor is the textual half. Neither
  alone closes this — the first draft claimed the test proved it, and it did not.
- [auto] **A run whose transcript root does not exist stops and reports** rather than announcing
  zero sources. Covered by test case (7) plus the skill's stop-on-nonzero contract.

## Verification

Verifier subagent against these done-conditions, **running `bash scripts/harvest-sources.test.sh`
and `bash scripts/check-skill-anchors.sh` itself** rather than trusting a build narrative. Plus
the standing suites: `check-skill-frontmatter`, `check-neutral`, `check-plan`, and `claude plugin
validate --strict .`.

No runtime walk: this milestone ships a shell script and skill/reference text, with no rendered
surface and no server-side behaviour. The script's test suite is the runtime proof.

**Not closable by inspection.** Conditions naming test cases require those cases to have been
*executed* green; conditions naming anchors require `check-skill-anchors` to have been *run*. A
verifier that reads the script and reasons that it "looks like it enumerates" has closed nothing
— that was precisely the first draft's defect.
