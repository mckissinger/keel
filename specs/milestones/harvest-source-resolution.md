# Milestone — Harvest enumerates its sources and filters for human input

**Goal:** a harvest run derives its sweep set by enumeration from a defined floor, distinguishes
a broken enumeration from a quiet week, advances that floor only when it actually covered
everything, and extracts human input rather than machine text sharing the user role.

**Change:** `specs/changes/harvest-source-resolution.md`. **No-UI** → two-dimension
done-conditions. **Depends on:** none. **Parallelizable:** n/a (single milestone).

**Draft 6.** Five prior drafts failed; their reports are in this branch's history. Draft 5's
empirical claims all verified independently, but its two behavioral-completeness conditions were
passed by the broken builds they named, its complete-run rule would have frozen the watermark
permanently, and it credited the leading-dash hazard to the wrong guard. Those three plus seven
lesser findings are addressed below.

## Done-conditions

### Logic / invariants

- [auto] **The floor is one watermark line in `specs/reviews/harvest-cursor.md` at a fixed
  location in a fixed format**: the first line of the file body, immediately under the H1, of the
  form `**Watermark:** YYYY-MM-DD`. `skills/harvest/SKILL.md` carries the literal command that
  reads it. Draft 5 said "one labelled watermark line" and left the label, format, and position
  open — three builders, three unparseable files.
- [auto] **The watermark is seeded `2026-07-18`, and the seed is recorded as a deliberate
  write-off**: ~27 never-listed directories hold older sessions
  (`-Users-michaelkissinger-keel` 21, `-Users-michaelkissinger-cre-list` 33, `-jarvis-2-0` 13,
  and others) which this floor places permanently out of scope. Enumeration fixes the defect
  **prospectively only**, and the file says so — an unstated floor reads as verified coverage,
  which is precisely the failure this change exists to end.
- [auto] **The watermark advances only when every enumerated source produced a returned miner
  report.** The discriminator is **returned vs did-not-return, not findings vs no findings**: a
  miner that reports "nothing of note in these sessions" is a *complete* result and does not hold
  the floor. Incomplete means a miner errored, was skipped, or its dispatch was aborted. On an
  incomplete run the watermark does not advance and the digest names the uncovered sources.
  Draft 5 said "returns empty or errors", which would have frozen the floor forever — most miners
  legitimately return little (the 2026-07-18 run: eleven miners, roughly ten claims).
- [auto] **The mining method begins with enumeration, and the command is committed literally.**
  `skills/harvest/SKILL.md` carries the exact command returning
  `directory<TAB>count<TAB>newest-date` per immediate subdirectory of `~/.claude/projects/`
  holding at least one top-level `*.jsonl` newer than the watermark. **`count` is the
  watermark-filtered top-level session count** — the number the sweep and the scope announcement
  both need.
- [auto] **The two real-layout hazards are stated as two separate guards, correctly attributed.**
  (a) **`-maxdepth 1`** — nested subagent transcripts are not sessions; one directory holds 10
  top-level entries against a recursive total an order of magnitude larger. (b) **The directory
  argument is always a full path, never a bare basename** — every transcript directory name
  begins with `-`, which `find` consumes as an option flag and errors on; **quoting does not fix
  this**, a path prefix does. Quoting is a *separate* guard, for the several names containing
  spaces. Draft 5 credited the dash hazard to quoting and would have anchored that error
  verbatim; verified false at authoring time — `find "-Users-…" -maxdepth 1` errors, while the
  same name reached through `~/.claude/projects/*/` expansion returns 10.
- [auto] **Step 1 is default-scope, and `retro`'s scoping is left open.** The skill states that
  `retro` does not run the enumeration and enters the ladder at the human-input recipe; it does
  **not** say what `retro` sweeps instead. Draft 5 wrote "scoped to its own project's directory",
  which is the singular-directory assumption the change document proves false (CRE Launch spans
  two directories sharing no discriminating substring). The scoping is a deferral, and a deferred
  question is not answered in passing.
- [auto] **A zero-row enumeration is disambiguated before it is reported.** Zero rows is the
  *expected* result of a quiet week, so stopping unconditionally cries wolf and reporting
  "nothing to mine" unconditionally reproduces the defect. The skill names the discriminator:
  **re-run the enumeration with no floor** — zero rows there means a broken or mistyped root and
  the run stops and asks; non-zero means genuinely nothing new since the watermark.
- [auto] **Every enumerated source is mined, and the retired name-matching mechanism is removed
  wherever it appears.** Four sites, all named because a fifth pass found each of them still
  standing behind a narrower removal scope:
  1. `skills/harvest/SKILL.md` — the `per-source through-mark` rule.
  2. `skills/harvest/SKILL.md` — the cursor section's framing that it "records per transcript
     source which sessions are already covered" and its "never re-mine covered sessions" heading,
     both of which describe the retired lookup.
  3. `specs/reviews/harvest-cursor.md` — the contract sentence stating sources are identified by
     directory name "so a run can match them mechanically", and the `newer than each source's
     through-mark` rule.
  4. `specs/reviews/harvest-cursor.md` — the ⚠ Path drift section's interim instruction to
     "reconcile them against this table", whose `until harvest resolves sources by project
     identity` clause this change satisfies. The incident narrative stays as provenance; the
     instruction goes.
- [auto] **The cursor's `through` column is removed and the table is relabelled** a historical
  coverage record — read for provenance, never consulted to decide what to mine. Draft 5 removed
  the column without saying what the table then is, leaving three columns of directory names with
  no defined consumer.
- [auto] **The signal ladder's step 1 carries the executed recipe.** Inclusion: entries whose
  **top-level** `.origin.kind` is `human`, plus **non-empty** `<command-args>` content — typed
  slash-command arguments, human intent inside a machine envelope. Exclusion: `tool_result`
  content, `task-notification` origin, `<command-name>` / `<command-message>` /
  local-command-caveat envelopes, injected skill bodies. The path is `.origin.kind`, **not**
  `.message.origin.kind` — the latter returns nothing for all 617 user entries in the sampled
  session, so that one wrong character yields zero human entries while satisfying every prose
  condition.
- [auto] **The step states plainly that `type=="user"` alone is not a human-input filter**,
  carrying the measured scar: 26 `human`, 46 `task-notification`, 545 with no origin field, of
  which 521 are `tool_result` — roughly 24× more than actual human input.
- [auto] **The fan-out dispatch guidance requires each miner to be given the recipe**, since
  miners inherit the harness and not the skill body.
- [auto] **The run announces scope before dispatching any subagent**: session count, source
  count, watermark date.
- [auto] **`retro` scope is an open deferral, not a guess.** A `specs/deferrals/` entry records
  that `retro`'s narrowing rule is unresolved — name-matching is what broke, and the two CRE
  Launch directories share no discriminating substring — closing condition: the first genuine
  `retro` run, which asks the user for its bound. The skill points at it.
- [auto] **`scripts/skill-anchors/harvest.txt` anchors verbatim sentences, not concepts.** Each
  positive anchor is a **full sentence carrying its rule's operative clause** — covering
  `-maxdepth 1`, the **full-path** guard (not the quoting guard), `.origin.kind`, the
  enumerate-first rule, and the zero-row discriminator. **Negative anchors on all four retired
  literals**, each named against the file it actually occurs in — verified at authoring:
  `per-source through-mark` occurs only in `skills/harvest/SKILL.md`, while the cursor's wording
  is `newer than each source's through-mark`, so one anchor covering both files passes vacuously
  on one of them. `bash scripts/check-skill-anchors.sh` green.
- [auto] **No weakening.** Unchanged in the diff: the secret rule, diff-against-HEAD, the
  writes-only-digest-and-cursor rule, **"No cursor in the target repo = ask"**,
  `disable-model-invocation: true`, the two-scope structure, and the
  fan-out-via-read-only-subagents instruction.

### Behavioral completeness

- [auto] **The verifier proves the committed enumeration discriminates against both broken
  builds, by measurement rather than by a bound.** It computes three counts for one directory it
  selects at run time (any directory where the three differ — not hardcoded to keel, whose
  activity varies):
  - **A** = top-level, watermark-filtered — what the committed command must emit for that row
  - **B** = recursive, watermark-filtered
  - **C** = top-level, unfiltered

  Assertions: the emitted count **equals A**, and **A < B** (proves `-maxdepth 1` is present) and
  **A < C** (proves the watermark filter is present). If no directory yields three distinct
  values, the verifier reports the check **inconclusive and escalates** — it does not pass by
  default. Draft 5 asserted only "emitted < unfiltered recursive", which measurement showed is
  satisfied by dropping `-maxdepth 1` (32 < 153) *and* by dropping the watermark (10 < 153) — it
  passed both builds it existed to reject.
- [auto] **The verifier proves the sweep set is derived from the filesystem, not from the
  cursor.** The committed enumeration command's text contains **no reference to the cursor's
  table**, and its output contains **more than one row**. This is the property the whole change
  exists for; draft 5 asserted only on a single directory already listed in the cursor, which an
  enumeration that read the old list would have satisfied.
- [auto] **The verifier runs the committed extraction recipe against one real session and asserts
  three things**: a **non-zero** count of `.origin.kind == "human"` entries; **at least one**
  line derived from `<command-args>`, run against a session known to contain typed slash-command
  arguments (the inclusion half, untested in draft 5); and **zero** lines matching
  `<command-name>`, `<command-message>`, `<local-command`, or `Base directory for this skill`.
  The first catches the wrong-field-path failure; the third catches envelope leakage that the
  first attempt at this recipe actually exhibited (38 lines where 28 were real).
- [auto] **`specs/reviews/2026-07-18-harvest.md`'s existing caveat is upgraded to a citation** —
  the line cites the shipped recipe by location and states re-derivation is available. No finding
  is rewritten.

verification: fresh-context verifier subagent against this spec, **executing the enumeration and
extraction commands and `bash scripts/check-skill-anchors.sh` itself**, plus the standing suites
(`check-skill-frontmatter`, `check-neutral`, `check-plan`, `claude plugin validate --strict .`).
No runtime walk — skill/reference text, one anchor file, one deferral entry; the executed
commands are the runtime proof.

## Accepted limitation — stated, not hidden

**Text is a weaker control than a program.** Nothing forces a session to run the enumeration;
the anchors keep the instruction present and correct, not obeyed. Three things make that
proportionate: harvest is `disable-model-invocation` and human-triggered, so a human is present
at every run; the scope announcement surfaces the sweep set before spending; and the verb runs
occasionally, not on a schedule. **If harvest ever becomes scheduled or self-invoked, this
tradeoff expires** and the script version — mapped in detail by the adversarial passes in this
branch's history — is the correct successor.
