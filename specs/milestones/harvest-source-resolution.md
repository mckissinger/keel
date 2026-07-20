# Milestone — Harvest enumerates its sources and filters for human input

**Goal:** a harvest run derives its sweep set by enumeration from a defined floor, stops rather
than shrugging when that enumeration returns nothing, and extracts human input rather than
machine text sharing the user role.

**Change:** `specs/changes/harvest-source-resolution.md`. **No-UI** → two-dimension
done-conditions. **Depends on:** none. **Parallelizable:** n/a (single milestone).

**Draft 4.** Three prior drafts failed their adversarial pass; the reports are in this branch's
history. Both commands below were **executed against the real transcript layout while authoring
this spec**, and the recipe was iterated until its envelope leakage measured zero — the
conditions commit the verified forms, not sketches.

## Done-conditions

### Logic / invariants

- [auto] **The floor is defined and lives in one place.** `specs/reviews/harvest-cursor.md`
  carries a single explicitly-labelled watermark line — the date through which all sources are
  covered — seeded `2026-07-18`. Every run's enumeration uses it as its lower bound, and the run
  advances it in the same commit as the digest. Without this the sweep has no lower bound and a
  conforming build either re-mines all history or invents a date.
- [auto] **The mining method begins with enumeration, and the command is committed literally.**
  `skills/harvest/SKILL.md` carries, as the first step of its ladder, the exact command
  returning `directory<TAB>count<TAB>newest-date` for every immediate subdirectory of
  `~/.claude/projects/` holding at least one top-level `*.jsonl` newer than the watermark. It
  must retain two properties the real layout requires: **`-maxdepth 1`** — nested subagent
  transcripts are not sessions, and one directory holds 10 top-level against 151 total, so
  omitting it inflates counts ~15× — and **quoted directory expansion**, because every transcript
  directory name begins with `-` (which tools consume as an option flag) and several contain
  spaces.
- [auto] **Every returned source is mined regardless of the cursor's table**, and the prior
  instruction to mine only sessions newer than a per-source through-mark is **removed from both**
  `skills/harvest/SKILL.md` **and** `specs/reviews/harvest-cursor.md`. The cursor's opening
  contract text currently states that rule in imperative voice — leaving it there keeps a retired
  rule live in the file a run reads first.
- [auto] **A zero-row enumeration stops the run and asks.** The skill states that an empty result
  is never read as "nothing to mine": a mistyped root, a renamed transcript directory, or a floor
  in the future all produce zero rows, and reporting "0 sources" from any of them reproduces the
  exact defect this milestone exists to fix — silence read as dormancy.
- [auto] **The signal ladder's step 1 carries the executed recipe.** Inclusion: entries whose
  **top-level** `.origin.kind` is `human`, plus **non-empty** `<command-args>` content — typed
  slash-command arguments, human intent inside a machine envelope, which an origin-only filter
  drops. Exclusion: `tool_result` content, `task-notification` origin, `<command-name>` /
  `<command-message>` / local-command-caveat envelopes, and injected skill bodies. The field path
  is `.origin.kind`, **not** `.message.origin.kind` — the latter returns nothing for all 617 user
  entries in the sampled session, and a recipe carrying that one wrong path yields zero human
  entries while satisfying every prose condition.
- [auto] **The step states plainly that `type=="user"` alone is not a human-input filter**,
  carrying the measured scar: 26 `human`, 46 `task-notification`, 545 with no origin field, of
  which 521 are `tool_result` — roughly 24× more than actual human input.
- [auto] **The fan-out dispatch guidance requires each miner to be given the recipe**, since
  miners inherit the harness and not the skill body — one miner filtering while others do not is
  how the 2026-07-18 run produced unevenly-derived frequency claims.
- [auto] **The run announces scope before dispatching any subagent**: session count, source
  count, watermark date. The skill states this announcement is where an unexpectedly large sweep
  is caught, and that it precedes spending.
- [auto] **`retro` scope is recorded as an open deferral, not designed.** A `specs/deferrals/`
  entry records that `retro`'s narrowing rule is unresolved — name-matching is what broke, and
  the two CRE Launch directories share no discriminating substring — with the closing condition
  being the first genuine `retro` run. The skill points at that deferral rather than carrying a
  guessed rule.
- [auto] **`scripts/skill-anchors/harvest.txt` anchors what a reword would drop.** Positive
  anchors on: `-maxdepth 1`, the quoted-expansion guard, `.origin.kind`, the enumerate-first
  rule, and the stop-on-zero rule — the five strings whose loss silently breaks the fix, rather
  than the pre-existing rules a reword is unlikely to touch. A **negative anchor** on the
  distinctive substring `per-source through-mark`, named against **both** the skill and the
  cursor. `bash scripts/check-skill-anchors.sh` green.
- [auto] **No weakening.** Unchanged in the diff: the secret rule, the diff-against-HEAD
  requirement, the writes-only-digest-and-cursor rule, **"No cursor in the target repo = ask"**,
  `disable-model-invocation: true`, the two-scope structure, and the
  fan-out-via-read-only-subagents instruction.

### Behavioral completeness

- [auto] **The verifier runs the committed enumeration command and checks a known value.** It
  returns tab-delimited rows, and the row for `-Users-michaelkissinger-Dev-Projects-keel` shows a
  **top-level** count (10 at authoring time, not 151) — a command that dropped `-maxdepth 1`, or
  emitted the wrong field count, fails here rather than passing a prose read.
- [auto] **The verifier runs the committed extraction recipe against one real session and
  asserts two things**: it yields a **non-zero** count of human entries, and **zero** lines
  matching `<command-name>`, `<command-message>`, `<local-command`, or `Base directory for this
  skill`. The first catches the wrong-field-path failure; the second catches the envelope leakage
  that the first attempt at this recipe actually exhibited (38 lines where 28 were real).
- [auto] **`specs/reviews/2026-07-18-harvest.md`'s existing caveat is upgraded to a citation.**
  That digest already says frequency claims "should be re-derived once the filter exists," so a
  condition merely requiring a note closes green with zero work. The delta: the line cites the
  shipped recipe by location and states re-derivation is available. No finding is rewritten.

## Verification

Verifier subagent against these done-conditions, **executing both committed commands and `bash
scripts/check-skill-anchors.sh` itself** rather than trusting a build narrative. Plus the
standing suites: `check-skill-frontmatter`, `check-neutral`, `check-plan`, and `claude plugin
validate --strict .`.

No runtime walk: skill and reference text plus one anchor file and one deferral entry, with no
rendered surface and no server-side behaviour. The two executed commands are the runtime proof.

## Accepted limitation — stated, not hidden

**Text is a weaker control than a program.** Nothing here forces a session to run the
enumeration; the anchors keep the instruction present and correct, not obeyed. Three things make
that proportionate: harvest is `disable-model-invocation` and human-triggered, so a human is
present at every run; the scope announcement surfaces the sweep set before any spending; and the
verb runs occasionally, not on a schedule. **If harvest ever becomes scheduled or self-invoked,
this tradeoff expires** and the script version — mapped in detail by three adversarial passes in
this branch's history — is the correct successor.
