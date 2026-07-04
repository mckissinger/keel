# Per-project (committed) auto-merge toggle + its security-review compensation

**Parked 2026-07-04.** The attended auto-merge toggle
(`specs/changes/attended-merge-toggle.md`) ships **per-session only**: a human-invoked,
untracked marker that lives while the user is at the keyboard. The **per-project** variant — a
committed setting that turns the same behavior on for *every* session in a repo — is deferred
to its own session, at the user's request (they want to dogfood it before committing to it).

**The gap.** A committed per-project flag (e.g. `keel.attendedAutoMerge: true` in the tracked
`.claude/settings.json`) would be always-on, including in **headless / build / autonomous**
sessions where no human is watching. There, the *agent* can arm `gh pr merge --auto` on a PR it
opened, and GitHub lands it the moment checks go green — with no human eyeball on the diff. That
is exactly the line `decisions/2026-07-01-model-capability-ledger.md` and
`decisions/2026-07-autonomy-modes.md` draw between "the human authorized this" and "the agent
decided this."

**Why it is deferred, not refused.** The per-session marker already delivers the user's actual
need (no tap, no build-session refusal) with the human inherently in the loop, so per-project is
a *convenience* increment, not a blocker. And it carries a real added blast radius (agent-armed
merges in unwatched sessions) that wants a deliberate design pass, not a rider on the
per-session change.

**The change when built.** Add the per-project setting, and — because it removes the human
eyeball in headless runs — **require the same compensating control the autonomy path uses:** a
blanket **security-review** check that is *actually required* on the protected branch (reuse
`scripts/check-auto-preflight.sh`'s branch-protection assertion, don't re-author it), so an
agent-armed `--auto` in an unwatched session still cannot land code no reviewer — human or
check — inspected. Consider whether the guards should also distinguish attended from headless
context (a per-session signal the harness exposes to a PreToolUse hook), which overlaps the open
question in `mode-file-binding-ttl.md`.

**Gate.** Needs (a) a decision on the committed-setting shape and where it lives, and (b) the
security-review-required precondition wired and verified live — plus, ideally, the attended-vs-
headless detection question from `mode-file-binding-ttl.md` resolved. Resolve as its own
`spec-change` once the user has dogfooded the per-session toggle and decided per-project is
worth the added surface.
