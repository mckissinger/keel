# Milestone — The signal ladder distinguishes human input from machine text

**Goal:** harvest's highest-signal channel actually carries human input. A finding of the form
"the user asked twice" is derived from what the user typed, not from machine text that shares
the user role.

**Change:** `specs/changes/harvest-source-resolution.md`. **No-UI** → two-dimension
done-conditions. **Depends on:** none. **Parallelizable:** with `harvest-source-resolution`
(disjoint files apart from `scripts/skill-anchors/harvest.txt`, which is append-only —
sequence them if built concurrently).

**Why this is its own milestone:** it shares no file and no failure mode with source
resolution. The first draft bundled them, and the adversarial pass flagged the seam — the
change doc itself introduced this half with the word "Separately."

## Done-conditions

### Logic / invariants

- [auto] **The signal ladder's step 1 carries a runnable extraction recipe, not a description.**
  It specifies **inclusion** of entries whose `origin.kind` is `human`, **plus** `<command-args>`
  content — typed slash-command arguments, which are human intent inside a machine envelope and
  which a strict `origin.kind` filter silently drops. It specifies **exclusion** of `tool_result`
  content, `task-notification` origin, local-command caveat and command-name/message envelopes,
  and injected skill bodies. The recipe is given in directly runnable form so a fresh session
  does not reinvent it per run.
- [auto] **The step states plainly that `type=="user"` alone is not a human-input filter**, and
  carries the measured scar that makes the case concrete: in one sampled session, user-role
  entries were **26 `human`, 46 `task-notification`, and 545 with no origin field** — of which
  **521 were `tool_result`** and the remaining 24 were command envelopes and injected skill
  bodies. A naive extraction ingests roughly **24×** more than actual human input.
- [auto] **The fan-out dispatch instruction carries the filter.** The skill's subagent-dispatch
  guidance requires each miner to be given the recipe, since miners inherit the harness and not
  the skill body — one miner applying the filter while the others do not is how the 2026-07-18
  run produced unevenly-derived frequency claims.
- [auto] **`scripts/skill-anchors/harvest.txt` gains a positive anchor** for the human-origin
  rule, so it cannot be quietly reworded away. `bash scripts/check-skill-anchors.sh` green.
- [auto] **No weakening:** step 2 of the ladder (the mechanism-marker grep over full
  transcripts) and the fan-out-via-read-only-subagents instruction are unchanged in the diff.

### Behavioral completeness

- [auto] **`specs/reviews/2026-07-18-harvest.md`'s existing caveat is upgraded to a citation.**
  That digest already says frequency claims "should be re-derived once the filter exists" — a
  condition requiring merely that a note exist would close green with zero work. The delta:
  that line must now **cite the shipped recipe by location** and state that re-derivation is
  available, converting an open caveat into an actionable pointer. No finding is rewritten or
  removed by this milestone.

## Verification

Verifier subagent against these done-conditions, **running `bash scripts/check-skill-anchors.sh`
itself**. Plus the standing suites: `check-skill-frontmatter`, `check-neutral`, `check-plan`,
and `claude plugin validate --strict .`.

No runtime walk: skill and reference text only.

**Known limitation, accepted:** the recipe's correctness against real transcripts is not
machine-checked by this milestone — the anchor proves the rule is present and stays present, not
that it extracts correctly. Proving extraction would need a committed transcript fixture, which
would mean committing session data to this repo. Recorded here as the deliberate boundary rather
than left as an unstated gap; the first genuine re-derivation under the new recipe is the real
proof, and it is follow-on analysis, not this milestone.
