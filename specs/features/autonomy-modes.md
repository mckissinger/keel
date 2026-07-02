# Feature — Autonomy modes: auto:feature and auto:run

**Grain:** one feature → five milestones (`spec-feature`). **No-UI** (skill prose + shell
scripts + docs). Signed off 2026-07-02.

## Definition

keel gains two human-triggered autonomy postures — **`keel:auto feature`** (attended spec,
unattended build-verify-pin-land of one feature, per-feature debrief) and **`keel:auto run
[scope]`** (from any project state, take recorded defaults silently, ledger every would-be
ask, auto-land continuously, batched per-feature debrief at run end) — by moving merge
authority from per-merge human approval to **server-side required checks** (`gh pr merge
--auto`; verified-pin + plan-lint + the profile CI ladder + a blanket security-review check),
plumbing a mode signal through the merge guard and session bootstrap, and hardening provision
with an **auto-provision envelope** (pre-authed CLIs, standing sandbox env-var library,
machine-to-machine secret flow, swap-after-attended) plus a shipped preflight script. The
whole thing is scoped by a `decisions/` entry amending the model-capability ledger's
permanent-human-merge-gate doctrine **for these modes only**. `--dangerously-skip-permissions`
stays banned; go-live/live-keys and spend beyond pre-authorized caps stay attended at every
level.

## Interview outcome (resolved decisions)

- **Naming** (user decision): one skill, `keel:auto`, args `feature` / `run [scope]`.
  Human-triggered only (`disable-model-invocation: true`) — the agent can never escalate its
  own autonomy.
- **Posture, not phase** (user decision): `auto:run` is invocable at any project state —
  half-built included. It opens with an **entry-state audit** (grain-ladder position → the
  run's definition of done for the given scope) and picks up from there. Features specced
  attended just build; unspecced features get `spec-feature` in default-taking mode with the
  synthesis ledgered.
- **Auto-merge is delegation to GitHub's required checks, never to agent judgment**: under an
  active mode, only `gh pr merge --auto` on a gate-passing PR becomes `allow`; plain
  `gh pr merge` stays `ask` even in auto mode; gate failure stays `deny`. The build-session
  branch guard (`guard-branch-rules.sh`) is untouched — build sessions still never merge;
  landing runs through the land-feature choreography from the orchestrating session.
- **Security gate** (user decision): **blanket in auto modes** — the auto-mode preflight
  requires a security-review CI job as a *required* branch-protection check on every code PR.
  Attended keel unchanged (per-invariant pre-pin rule stays as-is).
- **Design pick in auto:run** (user decision, accepted trade): the agent picks a direction
  and **ledgers** the rationale + comparison artifact; the user adjudicates at the debrief.
  A possible redesign pass is the accepted cost of zero interrupts. Recorded as an explicit
  accepted-trade in the decisions entry.
- **Deferred-decisions ledger**: every gate that would have asked writes its decision +
  rationale to `specs/runs/<run-id>/` (file-per-entry, per the shared rules' no-shared-file
  discipline), committed with the work it explains. Silent deferral stays banned; *recorded*
  deferral is the mode's contract.
- **Debrief**: per-feature granularity, batched scheduling. Mandatory — features can be
  *built-verified-merged* but not *feature-done* until adjudicated at `review-feature`;
  flagged gaps become refinement milestones (a candidate next auto run). `auto:feature`
  debriefs its one feature at feature end.
- **Mode signal**: a run-scoped, untracked mode file (`.claude/keel-autonomy.json`: level,
  scope, created-at, invoker) written **only** by the human-triggered `keel:auto` skill, read
  by the merge guard + session bootstrap, cleared at run end. The write path is the
  authorization trail.
- **Pre-provisioning** (user decision): contract prose in provision + a **shipped preflight
  script** that dry-runs the run's command inventory against the committed allowlist
  (names, never values), asserts the required checks are actually *required* in branch
  protection, and fails closed. Rationale: headless auto-mode runs abort after repeated
  classifier blocks (3 consecutive / 20 total) — an undrained prompt kills the run, so the
  preflight is a hard entry gate.
- **Stop-points keep today's semantics**: halt + surface, never route around, never widen
  permissions mid-run. Plan PRs (plan-only, gate-exempt) auto-land under both modes via the
  same `--auto` path with plan-lint as their required check.
- **Never auto, at any level**: `--dangerously-skip-permissions`, go-live / live-key swaps,
  spend beyond the pre-authorized caps.

## Milestones (build order)

| # | Milestone | What |
|---|---|---|
| 1 | `auto-m1-doctrine` | `decisions/` entry amending the model-capability ledger (scoped reversal, stated trades); README + §5 note |
| 2 | `auto-m2-mode-plumbing` | mode-file contract; merge-guard `--auto`-allow path under mode; session-bootstrap conditional text; self-tests |
| 3 | `auto-m3-envelope-preflight` | provision auto-provision envelope prose + generated-CLAUDE.md line; `check-auto-preflight.sh` + self-test |
| 4 | `auto-m4-skills` | new `keel:auto` skill; mode deltas across land-feature / implement-feature / spec-feature / review-feature / interview / spec-change / punch-list / app-design-directions; ledger + debrief prose |
| 5 | `auto-m5-composition` | composition walk: end-to-end mode dry-run proving guards, gate, `--auto` flow, ledger, and no-mode regression don't fight each other |

m2 ∥ m3 parallelizable (disjoint files); m4 depends on m1–m3; m5 last (tests the shipped
whole).

## File → milestone ownership map

| Path | Owner |
|---|---|
| `decisions/2026-07-autonomy-modes.md`, `README.md`, `references/milestones-and-verification.md` §5 note | m1 |
| `scripts/merge-guard.sh` (+ test), `scripts/session-bootstrap.sh` (+ test), mode-file contract | m2 |
| `skills/provision/SKILL.md` envelope section, `scripts/check-auto-preflight.sh` (+ test) | m3 |
| `skills/auto/SKILL.md` (new), mode-delta sections in the eight existing skills | m4 |
| walk artifacts under `specs/walks/` | m5 |

## Seams

- `scripts/check-verified-pin.sh` — **unchanged**; the merge guard keeps invoking the
  project's copy (one owner). The mode only changes what a PASS maps to for `--auto`.
- `skills/provision/SKILL.md` step 4 — owns the committed settings.json + the existing
  unattended-run posture section; m3 extends it in place (one-owner: the posture is stated
  once, in provision).
- `skills/land-feature/SKILL.md` — keeps `disable-model-invocation: true` and its attended
  choreography; m4 adds one mode-delta note, and the `keel:auto` skill *references* the
  choreography rather than restating it.
- `decisions/2026-07-01-model-capability-ledger.md` — never edited; the m1 entry *amends by
  reference* (the ledger stays the record of why the gate existed; the new entry scopes the
  exception).
