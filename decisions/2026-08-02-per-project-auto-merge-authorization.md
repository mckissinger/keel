# 2026-08-02 — The committed per-project marker is a standing, human-made merge authorization

Records the **authorization doctrine** for committed per-project auto-merge — distinct from
`decisions/2026-08-02-committed-auto-merge-marker.md`, which decided the marker's *shape/transport*.
This entry answers: *what does an armed marker actually authorize, why is it safe, and what stays
human?* It amends by reference (editing nothing in place)
`decisions/2026-07-04-attended-auto-merge.md`, extending that decision's per-session logic to the
project grain.

## What was decided

**A committed `.claude/keel-auto-merge.json` (`scope: "project"`) on the default branch is a
standing, human-made authorization** for one narrow command shape — a bare, un-chained
`gh pr merge <pr> --auto` on a **verified-pin-gate-passing** PR — to land without the per-merge tap,
in **every** session of the repo, watched or not, until a human removes it. It is not a capability
the agent grants itself: the marker's only writer is the human-invoked, `disable-model-invocation`
`keel:arm-auto-merge` skill, and any PR that touches the marker is forced to a human tap.

### Why a standing authorization is safe here

The marker removes the human merge eyeball from unwatched sessions. That is the **same** exposure an
autonomy mode creates, and it is compensated by the **same** control, not a weaker one:

- **The required-checks floor is the reviewer.** `--auto` lands a PR only when the branch's required
  status checks pass — `verified-pin`, `plan-lint`, and a **real** `security-review` (workflow
  content, not just a name). Whether a session is attended or headless, nothing lands that those
  three checks did not inspect. This is why the deferral's original "distinguish attended from
  headless context" question is left deferred **by decision**: the floor makes the distinction
  unnecessary for safety (`specs/deferrals/per-project-auto-merge.md`,
  `specs/deferrals/mode-file-binding-ttl.md`).
- **Arming is gated on that floor being live.** `keel:arm-auto-merge` asserts branch protection +
  the three required checks + `allow_auto_merge` (via `scripts/check-branch-protection.sh`, the same
  code the auto-run preflight uses) and **refuses to write the marker** on any gap. So the marker can
  only exist where its compensating control already exists.
- **The load-bearing gates are untouched.** The verified-pin gate still denies unverified code; the
  marker only removes the redundant *tap* on a PR the checks already clear, never the *authority* and
  never the checks.

### Precedence — `mode > attended > committed`

When more than one authorization is present, the guards resolve in one fixed order: an active
autonomy **mode** file wins, else the per-session **attended** marker, else the **committed**
per-project marker. The committed marker is the **lowest-priority, always-on floor** — a mode or an
attended session overrides how a given merge is scored, but in their absence the committed marker
governs. The two guards speak in **different vocabularies and must never be conflated**:
`scripts/merge-guard.sh` (the PreToolUse decision hook) **emits `allow`** for the committed-project
row on a bare, gate-passing `gh pr merge <pr> --auto`; `scripts/guard-branch-rules.sh` (the
build-session guard) does not emit `allow` at all — it **`exit 0` (defers)** to `merge-guard.sh` on
that same shape, letting the decision hook render the allow/ask/deny verdict. (`decisions/2026-07-05-autonomy-modes-v2.md`
owns the mode half of the ordering.)

### Arming is the third security-review wiring moment

The `security-review` required check is wired **before any auto posture arms**. There were two such
moments (genesis at bootstrap; an already-standing attended project as `auto:feature`/`auto:run`
preflight remediation); `keel:arm-auto-merge` is the **third** — arming committed per-project
auto-merge asserts and, if needed attended, wires the same check before writing the marker. This
adds a **trigger** to the wiring set, not a change to the required-check set (still the three).
Recorded in `references/template-contract.md` tier 1.

### What stays human — unchanged

The marker authorizes the **merge tap**, nothing else. `review-feature` (the aesthetic/completeness
gate), the feature-spec sign-off, and the **never-auto list** are **untouched** — a committed marker
never passes any of them, and the run-through (`skills/implement-feature/SKILL.md`) **prepares**
`review-feature` and stops there rather than rendering a verdict. The agent still never merges on its
own initiative; the human invocation of `keel:arm-auto-merge` is the entire authorization trail.
