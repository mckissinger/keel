# 2026-08-02 — The committed per-project auto-merge marker: shape, transport, and why the pin gate exempts it

Records the resolved design fork for milestone `committed-auto-merge-marker` (M1 of
`specs/features/per-project-auto-merge.md`): what a keel repo commits to arm `gh pr merge --auto` for
every session, how it lands under the full protection contract shipped by
`decisions/2026-08-01-required-checks-protection.md`, and why exempting it from the verified-pin gate
is coherent rather than a hole in that gate.

## What was decided

**The marker is `.claude/keel-auto-merge.json`, and `check-verified-pin.sh`'s `is_plan_path()` gains
it as a single-file plan-path carve-out.** Arming is therefore a **plan-only PR** (the marker is the
only changed file → the pin gate treats the PR as plan-only → exempt → passes with no `verified:`
pin). Both merge guards honor the marker only when it is present on the default branch, and any PR
that touches the marker is forced to a human merge tap. The marker's only writer/remover is the M2
arming skill (`disable-model-invocation`, human-invoked); the agent never self-arms.

### Why the pin gate is the wrong instrument here (the rationale)

A `verified:` pin exists to prove **unwatched** verification — that code merging to `main` was
checked by a fresh session that no one was watching, and has not drifted since. The committed marker
inverts both premises:

- **It carries no code.** A pin is a code-verification instrument; against a pure-configuration flag
  it has *nothing to verify*. Requiring one would be ceremony, not a control.
- **Arming is human-attended by construction.** The M2 skill is `disable-model-invocation` — a human
  runs it, it asserts branch protection + the three required checks are live, and only then commits
  the flag. The right proof that arming is safe is that **live protection-assertion**, not a pin
  standing in for verification that already happened in the open.
- **Every subsequent merge is still gated.** The marker only arms `--auto`; the required-checks floor
  on the protected branch (`verified-pin`, `plan-lint`, `security-review`, `guards`) decides every
  actual merge. Nothing lands that those checks did not pass, armed or not.

So the carve-out removes a useless instrument from one plan-only file; it does not remove a control.

## The alternatives rejected

- **(a) Route arming through the chore-lane pin.** Give the marker PR a chore pin so it satisfies the
  gate as-is. Rejected: it manufactures a code-verification artifact for a file with no code to
  verify, and it drags the whole chore-lane machinery (`punch-list`, a chore `verified:` record) onto
  a one-line config commit. Ceremony that dilutes what a pin *means*.
- **(c) Relocate the marker to `specs/`** so it is a plan path with no carve-out needed. Rejected: the
  guards read `.claude/`-scoped project state (the mode file, the attended marker) and this marker is
  a sibling of exactly that runtime state; moving it to `specs/` divorces the flag from where its
  peers live and where a reader looks for session/project merge posture. The carve-out is one named
  line; the relocation is a worse home for the file forever.

(These are labeled (a) and (c) to match the feature spec's fork options; (b) "treat the marker as a
plan-path in the pin gate" is the chosen path.)

## Confronting the pin gate's own classification principle

`check-verified-pin.sh:50-51` carries the inverse carve-out with the comment that
**runtime-affecting spec files are *code*, not plan** (`specs/stack-profile.md`,
`specs/run-command-inventory.txt` are pulled *into* the code set precisely because a runtime reads
them). This marker is unmistakably runtime-affecting — **both** merge guards decide on it — yet it is
classified as *plan*. That looks like a direct contradiction of the stated principle. It is not, and
here is why the two carve-outs are coherent together:

- The stack-profile carve-out exists because those files are runtime-affecting **and a `verified:`
  pin can meaningfully bind them** — they describe how the project builds/runs, so a drift in them is
  a drift a verification pass should have caught. Pulling them into the code set puts them *under* the
  pin's drift check. The principle is really "if a pin can and should verify it, treat it as code."
- The marker is runtime-affecting **but a pin cannot bind it** (no code) — and, crucially, its
  authority is gated **elsewhere and more strongly** than a pin would: by the human-merge-tap rule on
  any marker-touching PR, plus the required-checks floor. The pin is not the control that keeps this
  file honest, so classifying it as code to force a pin would add an empty instrument while the real
  controls sit outside the pin gate entirely.

The unifying rule, stated so the two carve-outs don't read as arbitrary: **a runtime-affecting file is
code when a pin is the instrument that keeps it honest, and plan when its integrity is enforced by a
stronger control that a pin would only shadow.** The marker is the second case.

## The drift-window consequence, accepted explicitly

Plan paths are skipped by the post-pin drift check (that is what "plan-only PRs are pin-exempt"
means). So a marker file that rode *inside a pinned code PR's* diff would be **invisible to the drift
check** — the check would not notice a `.claude/keel-auto-merge.json` change slipped into a code PR
after the pin was written. This is a real, accepted consequence, and it is closed by a **different**
mechanical control, not by the pin gate: the **human-tap rule** in `merge-guard.sh` forces any
merge-shaped command whose target PR touches the marker to `ask`. That same PR *touches the marker*,
so it is never auto-merged and a human sees the change before it lands. The drift check's blind spot
for this file is therefore covered by the tap rule that sits in front of every auto-merge — belt to
the pin gate's suspenders.

## Status

This entry is the reviewed record for the `is_plan_path` carve-out; the carve-out and this entry land
together in the M1 code PR, verified by a fresh `verify-milestone` session (never self-pinned). The
root-of-trust read (marker honored only from `origin/$DEFAULT_BRANCH`) and the human-tap rule are the
two mechanical controls that move "the agent never self-arms" from prose to enforcement — see the M1
milestone spec's done-conditions for their `file:line` contracts.
