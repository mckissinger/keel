# Per-project (committed) auto-merge toggle + its security-review compensation

**RESOLVED 2026-08-02 by feature `per-project-auto-merge`** (`specs/features/per-project-auto-merge.md`;
plan PR #197, milestones #198/#199 + the doctrine/run-through wave). The four gate items are met:

1. **Committed-setting shape decided.** The marker is `.claude/keel-auto-merge.json` (fields
   `scope: "project"`, `created`, `invoker`), honored only from the repo's **server default branch**.
   It lands as a **plan-only PR** via a pin-gate plan-path carve-out in `scripts/check-verified-pin.sh`
   rather than the tracked `.claude/settings.json` sketched below —
   `decisions/2026-08-02-committed-auto-merge-marker.md` records the shape, transport, and why the
   pin gate exempts it.
2. **The security-review-required precondition is wired and verified live** — the required-checks floor
   shipped in PRs #195/#196 (full branch protection; `security-review` a required check backed by real
   workflow **content**, asserted by `scripts/check-branch-protection.sh` check (b2)). The arming skill
   (`keel:arm-auto-merge`, #199) reuses that exact assertion and refuses to write the marker unless it
   is live — so the "agent-armed `--auto` in an unwatched session" blast radius the note below feared is
   answered by the required-checks compensating control, not by trusting the marker.
3. **The self-arm concern is closed mechanically, not by prose:** the marker is written **only** by the
   human-invoked `disable-model-invocation` arming skill (the agent never self-arms), the guards honor it
   only from server truth behind a fail-closed fetch, and any marker-touching PR is forced to a human tap.
4. **The attended-vs-headless detection question is left deferred BY DECISION, not omission** — it stays
   in `mode-file-binding-ttl.md` (the harness exposes no confirmed per-session attended/headless signal).
   The required-checks floor makes the distinction **unnecessary for safety**: whether a session is
   watched or not, nothing lands that the three required checks did not inspect. The standing-authorization
   doctrine is `decisions/2026-08-02-per-project-auto-merge-authorization.md`.

The original parking rationale is preserved verbatim below as the record of why it was deferred.

---

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
