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
   JSON makes the marker invalid and both guards fail closed to today's behavior. **TTL: 8h.**
   The guards honor the marker only while `created` is within 8 hours of now; past that it is
   treated as absent and the per-merge tap returns. There is no refresh path — re-run
   `keel:auto-merge on` (a fresh human invocation) to renew it for another session.

   **Why 8h.** The TTL exists to bound how long a marker can outlive the human who minted it, so
   it is sized to one attended working day: long enough that a single sitting never has the tap
   reappear mid-run, short enough that a marker forgotten at end of day is dead before the next
   one starts. **The TTL must exceed the project's own end-to-end CI duration** — otherwise a PR
   opened under a valid marker can go green *after* the marker expires, and the merge the user
   already authorized hits the approval prompt anyway. 8h clears typical CI (minutes to ~1h) by a
   wide margin. If this project's CI is slow enough that the gap between opening a PR and its
   checks going green approaches 8h, that assumption no longer holds — see below.
3. **Confirm the path stays untracked.** A git-tracked copy is a spoof and is ignored by both
   guards. If the project tracks `.claude/` (check with `git ls-files -- .claude/`), add
   `/.claude/keel-attended-merge.json` to `.gitignore`. **Never `git add` or commit the marker.**
4. Report that attended auto-merge is on for this session, and that an instructed, gate-passing
   `gh pr merge <pr> --auto` will now land without the per-merge tap. **Announce the marker's
   concrete expiry time** — `created` + 8h, stated as an actual clock time (e.g. "expires at
   2026-07-12T06:30Z"), not just "in 8 hours" — so the user knows exactly when the tap returns.

### Expiry vs. pending merges

The marker lapsing must never silently strand green PRs. When PRs in flight are expected to go
green near or after the marker's expiry (long CI, an overnight wave), the session must do one of
two things **while the marker is still valid**:

- queue the server-side handoff now — issue the instructed, gate-passing
  `gh pr merge <pr> --auto` (per the rules above) before the marker lapses, so GitHub's required
  checks land the PR whenever they pass, marker or no marker; or
- prompt the user to re-arm — a fresh `keel:auto-merge on` — while the current marker is still
  present, rather than letting it expire and discovering the stranded PRs later.

Doing neither and letting the marker quietly expire over a wave of pending PRs is a failure mode,
not a safe default.

**Slow-CI repos.** Where a full check run can take hours, the ordinary case — not the edge case —
is a PR going green *after* the marker expires, landing the user back at the approval prompt for
a merge they already authorized. In such a project, queue the server-side handoff (the first
bullet above) as the default rather than the fallback: issue the instructed `gh pr merge <pr>
--auto` as soon as the PR is up and the gate passes, while the marker is unambiguously valid, and
let GitHub's required checks land it whenever they finish. Do not wait for checks to go green
before issuing the handoff — that wait is exactly what burns the TTL. Before starting a wave in a
slow-CI repo, check the marker's remaining life against the expected check duration; if the
remaining life is shorter, ask the user to re-arm first. The 8h TTL is not adjustable per
invocation — the handoff-first pattern, not a longer marker, is the answer for slow CI.

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
