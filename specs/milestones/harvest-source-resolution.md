# Milestone — Harvest enumerates its sources and filters for human input

**Goal:** a harvest run derives its sweep set by enumeration from a defined floor, distinguishes
a broken enumeration from a quiet week, advances that floor only when it actually covered
everything, and extracts human input rather than machine text sharing the user role.

**Change:** `specs/changes/harvest-source-resolution.md`. **No-UI** → two-dimension
done-conditions. **Depends on:** none. **Parallelizable:** n/a (single milestone).

**Draft 5.** Four prior drafts failed; their reports are in this branch's history. Draft 4
closed all of draft 3's CRITICALs and its empirical claims verified independently — the
remaining defects were a known-value check that selected against the correct implementation, a
floor that advanced on incomplete runs, an enumerate-all mandate landing in a shared ladder, and
an anchor string absent from the file it guarded. All four are addressed below.

## Done-conditions

### Logic / invariants

- [auto] **The floor is one labelled watermark line in `specs/reviews/harvest-cursor.md`**, seeded
  `2026-07-18`, and the seed is recorded as a **deliberate write-off**: ~28 never-listed
  directories hold older sessions (`-Users-michaelkissinger-keel` 21,
  `-Users-michaelkissinger-cre-list` 33, `-jarvis-2-0` 13, and others) which this floor places
  permanently out of scope. Enumeration fixes the defect **prospectively only**, and the file
  says so — an unstated write-off would read as a verified non-loss, which it is not.
- [auto] **The watermark advances only on a complete run.** The advance is conditioned on every
  enumerated source having been mined; if any miner returns empty or errors, the watermark
  **does not advance** and the digest records which sources were not covered. Without this, a run
  where 3 of 7 miners fail writes its digest, advances the floor, and buries those sessions below
  it permanently — the original defect reintroduced through this milestone's own fix.
- [auto] **The mining method begins with enumeration, and the command is committed literally.**
  `skills/harvest/SKILL.md` carries the exact command returning
  `directory<TAB>count<TAB>newest-date` per immediate subdirectory of `~/.claude/projects/`
  holding at least one top-level `*.jsonl` newer than the watermark. **`count` is the
  watermark-filtered session count** — the number the sweep and the scope announcement both need
  — not the directory's total. Two properties the real layout requires are retained:
  **`-maxdepth 1`** (nested subagent transcripts are not sessions — one directory holds 10
  top-level against 152 total) and **quoted directory expansion** (every transcript directory
  name begins with `-`, which tools consume as an option flag; several contain spaces).
- [auto] **Step 1 states its scope applicability.** The enumeration is **default-scope**. The
  skill states that a `retro` run does not run it — `retro` enters the ladder at the human-input
  recipe, scoped to its own project's directory, pending the deferral below. Without this, a
  `retro` run reads a sweep-everything instruction that contradicts the frontmatter contract two
  screens above it.
- [auto] **A zero-row enumeration is disambiguated before it is reported.** Zero rows is the
  *expected* result of a quiet week, so stopping unconditionally cries wolf and reporting
  "nothing to mine" unconditionally reproduces the defect. The skill names the discriminator:
  **re-run the enumeration with no floor** — zero rows there means a broken or mistyped root and
  the run stops and asks; non-zero means genuinely nothing new since the watermark and the run
  reports that.
- [auto] **Every returned source is mined regardless of the cursor's table**, and the retired
  per-source rule is **removed from both** `skills/harvest/SKILL.md` **and**
  `specs/reviews/harvest-cursor.md` — including the cursor's `through` column, whose per-source
  dates are the retired mechanism in tabular form. Prose removal that leaves the column standing
  leaves the mechanism visibly operative.
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
  `retro` run. The skill points at it.
- [auto] **`scripts/skill-anchors/harvest.txt` anchors verbatim sentences, not concepts.** Each
  positive anchor is a **full sentence carrying its rule's operative clause** — covering
  `-maxdepth 1`, the quoted-expansion guard, `.origin.kind`, the enumerate-first rule, and the
  zero-row discriminator. A concept-named anchor lets a builder pin a word like `enumerate`,
  which survives any rewrite that guts the rule. **Negative anchors** on strings that **actually
  occur in the files they guard** — verified: `per-source through-mark` appears only in
  `SKILL.md:67`; the cursor's wording is `newer than each source's through-mark`, so a single
  anchor named against both files passes vacuously on the cursor. Both literals are required.
  `bash scripts/check-skill-anchors.sh` green.
- [auto] **No weakening.** Unchanged in the diff: the secret rule, diff-against-HEAD, the
  writes-only-digest-and-cursor rule, **"No cursor in the target repo = ask"**,
  `disable-model-invocation: true`, the two-scope structure, and the
  fan-out-via-read-only-subagents instruction.

### Behavioral completeness

- [auto] **The verifier runs the committed enumeration command and asserts shape, not a point
  value.** The keel row's `count` is ≥1 and **strictly less than** the recursive `*.jsonl` count
  for the same directory (the discriminating property is top-level ≪ recursive; the integers move
  daily — 151 at draft-4 authoring, 152 a day later), and every row has **exactly three**
  tab-delimited fields. Draft 4 asserted a literal 10 here, which a correct watermark-filtered
  build fails.
- [auto] **The verifier runs the committed extraction recipe against one real session and asserts
  two things**: a **non-zero** count of human entries, and **zero** lines matching
  `<command-name>`, `<command-message>`, `<local-command`, or `Base directory for this skill`.
  The first catches the wrong-field-path failure; the second catches envelope leakage that the
  first attempt at this recipe actually exhibited (38 lines where 28 were real).
- [auto] **`specs/reviews/2026-07-18-harvest.md`'s existing caveat is upgraded to a citation** —
  the line cites the shipped recipe by location and states re-derivation is available. No finding
  is rewritten.

verification: fresh-context verifier subagent against this spec, **executing both committed
commands and `bash scripts/check-skill-anchors.sh` itself**, plus the standing suites
(`check-skill-frontmatter`, `check-neutral`, `check-plan`, `claude plugin validate --strict .`).
No runtime walk — skill/reference text, one anchor file, one deferral entry; the two executed
commands are the runtime proof.

## Accepted limitation — stated, not hidden

**Text is a weaker control than a program.** Nothing forces a session to run the enumeration;
the anchors keep the instruction present and correct, not obeyed. Three things make that
proportionate: harvest is `disable-model-invocation` and human-triggered, so a human is present
at every run; the scope announcement surfaces the sweep set before spending; and the verb runs
occasionally, not on a schedule. **If harvest ever becomes scheduled or self-invoked, this
tradeoff expires** and the script version — mapped in detail by four adversarial passes in this
branch's history — is the correct successor.
