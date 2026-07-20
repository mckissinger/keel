# Milestone — Harvest enumerates its sources and filters for human input

**Goal:** a harvest run derives its sweep set by enumeration rather than from a list that can
go stale, and its highest-signal channel carries human input rather than machine text sharing
the user role.

**Change:** `specs/changes/harvest-source-resolution.md`. **No-UI** → two-dimension
done-conditions. **Depends on:** none. **Parallelizable:** n/a (single milestone).

**Third draft, deliberately smaller.** Drafts 1 and 2 shipped a script, a nine-case suite, CI
wiring, a watermark migration and a `retro` filter design; both failed their adversarial pass,
and every CRITICAL was about the *script's* contract rather than the idea. The fix is a command
the skill runs, not a program the repo maintains. Both verifier reports are preserved in the
branch history as the record of what the larger version would have had to get right.

## Done-conditions

### Logic / invariants

- [auto] **The mining method begins with enumeration, and the command is given literally.**
  `skills/harvest/SKILL.md` carries, as the first step of its ladder, the exact command that
  returns the sweep set — every immediate subdirectory of `~/.claude/projects/` holding at least
  one top-level `*.jsonl` newer than the run's floor, printed tab-delimited as
  `directory<TAB>count<TAB>newest-date`. The committed form is the one verified working against
  the real layout on 2026-07-20, and it must retain two properties the layout requires:
  **`-maxdepth 1`** (nested subagent transcripts are not sessions — one directory holds 10
  top-level session files and 140 nested, so omitting this inflates the count ~14×) and
  **quoted directory expansion** (every transcript directory name begins with `-`, which an
  unquoted or unguarded expansion feeds to tools as an option flag; several contain spaces).
- [auto] **The skill states that every returned source is mined regardless of the cursor's
  table**, and the prior instruction to mine only sessions newer than a per-source through-mark
  is **removed from the file**, not supplemented. A retired rule left in place is a rule a fresh
  session may follow.
- [auto] **`specs/reviews/harvest-cursor.md` states its table is a found-record, not a sweep
  input** — no run derives its sweep set from it. The existing per-source rows and the path-drift
  warning stay; only their status changes.
- [auto] **The `retro` scope narrows after enumerating, and does not assume one directory.** The
  skill states that `retro` runs the same enumeration and then keeps the directories belonging to
  the current project — **which is routinely more than one**: worktrees and moved checkouts each
  produce additional directories (keel itself currently spans four). No fixed source count is
  asserted anywhere, because asserting one would recreate the miss this milestone exists to fix.
- [auto] **The signal ladder's step 1 carries a runnable extraction recipe, not a description.**
  Inclusion: entries whose `origin.kind` is `human`, **plus** `<command-args>` content — typed
  slash-command arguments, human intent inside a machine envelope, which a strict `origin.kind`
  filter silently drops. Exclusion: `tool_result` content, `task-notification` origin,
  local-command caveat and command-name/message envelopes, injected skill bodies.
- [auto] **The step states plainly that `type=="user"` alone is not a human-input filter**,
  carrying the measured scar: in one sampled session, user-role entries were **26 `human`, 46
  `task-notification`, 545 with no origin field** — of which **521 were `tool_result`**. A naive
  extraction ingests roughly **24×** more than actual human input.
- [auto] **The fan-out dispatch guidance requires each miner to be given the recipe**, since
  miners inherit the harness and not the skill body — one miner filtering while the others do not
  is how the 2026-07-18 run produced unevenly-derived frequency claims.
- [auto] **The run announces scope before dispatching any subagent**: session count, source
  count, floor date. The skill states this announcement is where an unexpectedly large sweep is
  caught, and that it precedes spending.
- [auto] **`scripts/skill-anchors/harvest.txt` machine-checks the new rules and retires the old
  one.** Positive anchors for the enumerate-first rule and the human-origin rule — the two
  contracts this milestone adds, so a reword cannot quietly drop them. A **negative anchor** on
  the distinctive substring `per-source through-mark`, asserting the retired instruction stays
  absent. `bash scripts/check-skill-anchors.sh` green. Anchors are what make this milestone's
  text durable rather than merely present; without them the "removed, not supplemented" and
  "no weakening" conditions are closable by eyeballing a diff.
- [auto] **No weakening.** Unchanged in the diff: the secret rule, the diff-against-HEAD
  requirement, the writes-only-digest-and-cursor rule, **"No cursor in the target repo = ask"**
  (the only guard against a fresh `retro` mining unbounded history), the update-in-the-same-commit
  rule, `disable-model-invocation: true`, the two-scope structure, and the
  fan-out-via-read-only-subagents instruction.

### Behavioral completeness

- [auto] **The documented command runs and returns sources.** The verifier executes the command
  exactly as committed and confirms it returns at least one source with parseable tab-delimited
  fields. It is read-only and cheap, so a command that has rotted cannot pass this milestone —
  this is the condition that makes the enumeration real rather than aspirational.
- [auto] **`specs/reviews/2026-07-18-harvest.md`'s existing caveat is upgraded to a citation.**
  That digest already says frequency claims "should be re-derived once the filter exists" — a
  condition merely requiring a note would close green with zero work. The delta: that line cites
  the shipped recipe by location and states re-derivation is now available. No finding is
  rewritten or removed here.

## Verification

Verifier subagent against these done-conditions, **running the committed enumeration command and
`bash scripts/check-skill-anchors.sh` itself** rather than trusting a build narrative. Plus the
standing suites: `check-skill-frontmatter`, `check-neutral`, `check-plan`, and `claude plugin
validate --strict .`.

No runtime walk: skill and reference text plus one anchor file, with no rendered surface and no
server-side behaviour.

## Accepted limitation — stated, not hidden

**Text is a weaker control than a program.** Nothing here prevents a session from skipping the
enumeration step; the anchors keep the instruction present and correct, not obeyed. Three things
make that proportionate rather than negligent: harvest is `disable-model-invocation` and
human-triggered, so a human is present at every run; the scope announcement surfaces the sweep
set before any spending, so a skipped step is visible immediately; and the verb runs
occasionally, not on a schedule. **If harvest ever becomes scheduled or self-invoked, this
tradeoff expires** and the script version — already mapped in detail by two adversarial passes in
this branch's history — is the correct successor.
