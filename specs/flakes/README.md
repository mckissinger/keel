# Flakes

File-per-flake ledger of tests (or spec surfaces) that fail intermittently — each recorded with
its **measured reproduction rate** so a verifier can classify a new observation against a known
rate instead of re-litigating "is this real?" every session. One `<slug>.md` per open flake,
**drained by a batch chore** (a `specs/chores/<slug>.md` that fixes the batch and closes the
files it covered). This deliberately parallels `specs/deferrals/` (file-per-entry, this README
documenting the convention) so parallel branches never collide on a shared ledger (§4 of
`references/milestones-and-verification.md`).

A flake and a deferral are **distinct artifacts**: a deferral is an improvement consciously
parked pending a trigger; a flake is a measured, closable instance of intermittent failure. They
live in sibling directories and are surfaced separately by `status`.

The directory is **established empty** — adoption, not backfill. keel has no open flakes to
record today, and historical `lessons/` learnings are not migrated here (a lesson is a durable
learning; a flake is a tracked, measured, closable instance).

## Flake-file shape

Each `specs/flakes/<slug>.md` records all of:

- **id / slug** — the flake's stable identifier (the filename stem).
- **Attached path** — the spec or test path the flake attaches to (the suite / spec / surface
  that fails intermittently).
- **Measured reproduction rate(s)** — in the measured form: a fraction or count such as
  `2/6 clean main`, `1/5 prod only`, or `~50 runs to slug exhaustion` — never a vague
  "sometimes". A new reproduction adds its own measured rate.
- **Hit count** — a single integer that **rises by one each time the flake recurs**; it is the
  escalation signal a reader acts on.
- **First-seen and last-seen dates** — when the flake was first recorded and when it most
  recently recurred.
- **Escalation / closing condition** — what a rising hit count escalates to (a reader's judgment
  that the batch is worth draining now), and what closes the file: the **batch chore** that fixes
  the underlying flakiness and retires the entries it covered.

## Escalation is a recorded hit count a reader acts on

Escalation is **by the recorded hit count**, read and acted on by a human or a verifier — never
an automated trigger. There is **no repeat-count threshold** that promotes a flake (or a
`lessons/` file) into a milestone after N recurrences: the earlier draft that proposed
"after N repeats, promote automatically" is superseded and is not built here. The hit count
informs a judgment; it does not fire a mechanism.
