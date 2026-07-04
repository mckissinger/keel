---
name: auto-merge
description: Toggle keel's per-session attended auto-merge marker — `keel:auto-merge on` writes an untracked `.claude/keel-attended-merge.json` that lets an explicitly-instructed, verified-pin-gate-passing `gh pr merge --auto` land with no per-merge tap and no build-session refusal; `keel:auto-merge off` removes it. The skill only writes or removes that one marker file — it never issues a merge itself, and the verified-pin gate and the no-agent-initiative rule stay intact.
when_to_use: Human-triggered only, when the user at the keyboard wants to drop the redundant per-merge approval tap (and the build-session merge refusal) for the rest of this session — args `on` / `off`. NOT autonomy (that's keel:auto), NOT a way for the agent to merge on its own initiative — the human invocation IS the authorization, and with no marker every guard behaves exactly as today.
disable-model-invocation: true
---

# Auto-merge (attended, per-session)

Turn off the redundant per-merge tap for a session where **you** are driving. When you have
explicitly told keel to merge a **gate-passing** PR, the per-merge approval prompt is friction,
not a safeguard — the authority is yours and you are exercising it. This skill is the deliberate,
human-invoked switch that says so, for this session only.

`decisions/2026-07-04-attended-auto-merge.md` is the doctrine this executes: the attended toggle
delegates the per-merge **tap** — not the authority — to an explicit human invocation, and unlocks
**only** the `--auto` handoff (the server-side required checks still decide what actually lands).
The verified-pin gate and the no-agent-initiative rule are untouched.

## What the marker unlocks (and what it does not)

When the marker is active — and no autonomy mode file is active, that path takes precedence — both
merge guards honor it for **one** command shape: a **bare** `gh pr merge <pr> --auto
[--squash|--merge|--rebase]` in its own Bash call (the existing `detect_strict_auto` whitelist).

- `scripts/merge-guard.sh`: that shape on a verified-pin-gate-**passing** PR → **allow** (no tap)
  instead of the ask floor. Plain `gh pr merge` (no `--auto`) stays **ask**. Gate **fail** stays
  **deny**. Every other shape is byte-for-byte today's table.
- `scripts/guard-branch-rules.sh` (the build-session guard): that same bare shape → **defer**
  (exit 0) to `merge-guard.sh` instead of the categorical `exit 2` refusal. Every other
  merge-shaped command, and `git commit` on the default branch, still `exit 2`.

**With no marker, every guard behaves exactly as today.** The marker never unlocks a plain merge,
a push, a `git merge` to the default branch, or a bundled/chained `--auto` — only the bare
delegation shape, which is meaningful only where branch protection makes `--auto` real.

## `on` — write the marker

1. Compute a real ISO-8601 timestamp for `created` (e.g. `date -u +%Y-%m-%dT%H:%M:%SZ`) and an
   `invoker` string identifying this human invocation.
2. Write `.claude/keel-attended-merge.json` under the project directory with **exactly** the three
   contract fields — all non-empty strings:

   ```json
   {
     "scope": "session",
     "created": "<the ISO-8601 timestamp>",
     "invoker": "<who invoked this — e.g. human:keel-auto-merge>"
   }
   ```

   `scope` **must** equal `"session"`; any other value, a missing or empty field, or malformed
   JSON makes the marker invalid and both guards fail closed to today's behavior.
3. **Confirm the path stays untracked.** A git-tracked copy is a spoof and is ignored by both
   guards. If the project tracks `.claude/` (check with `git ls-files -- .claude/`), add
   `/.claude/keel-attended-merge.json` to `.gitignore`. **Never `git add` or commit the marker.**
4. Report that attended auto-merge is on for this session, and that an instructed, gate-passing
   `gh pr merge <pr> --auto` will now land without the per-merge tap.

## `off` — remove the marker

Remove `.claude/keel-attended-merge.json` if it is present (a no-op if it is already absent), and
report that the per-merge tap is back in force. Removing it is enough — with the file gone, both
guards are back to today's ask / deny / exit-2 matrix.

## Boundaries

- **This skill writes or removes only `.claude/keel-attended-merge.json`.** It issues **no** merge
  command of its own — the human still types the `gh pr merge <pr> --auto`; the marker only changes
  how the guards score it.
- **The agent never invokes this skill to arm its own merges.** `disable-model-invocation: true`
  keeps the model from calling it; the human invocation is the whole authorization trail — the same
  pattern by which `keel:auto` is the sole writer of the autonomy mode file.
- **Autonomy mode wins.** When a valid `.claude/keel-autonomy.json` is active, the attended marker
  is ignored — the autonomy path governs that decision (`decisions/2026-07-autonomy-modes.md`).
- **The load-bearing gates are untouched.** The verified-pin gate still denies unverified code, and
  `--auto` still lands only when the branch's required checks pass. A stale or forged marker cannot
  merge unsafe code — the same backstop `specs/deferrals/mode-file-binding-ttl.md` records for the
  autonomy mode file covers this marker equally.
