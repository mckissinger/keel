# Milestone — auto-merge-doctrine: the corpus tells the truth about committed per-project auto-merge

**Goal:** with the committed marker shipped (M1) and its arming skill live (M2), the corpus stops
saying things the marker now makes false and starts teaching it: the session-start orientation line no
longer claims "with no marker this line holds exactly as written" as if the per-session marker were
the only exception, the template contract records arming as a **third** security-review wiring moment,
the deferral is closed, the guard vocabulary is consistent, and a decision entry records the standing
per-project authorization stance.

**Feature:** `specs/features/per-project-auto-merge.md`. **No-UI** → two-dimension done-conditions.
**Depends on:** `committed-auto-merge-marker` + `arm-auto-merge-skill` (doctrine describes the shipped
rows + the arming skill). **Parallelizable:** yes — with `implement-feature-run-through` (disjoint
files). **Routing:** reasoning-heavy — it edits merge-authority orientation prose that a reader takes
as ground truth; wrong wording misstates who may merge. Dispatch the verifier at `xhigh`.

## Done-conditions

### Logic / invariants

- [auto] **`scripts/session-bootstrap.sh`'s merge-orientation line (~L200) is amended** so it is true
  under a committed marker. Today it reads that the *only* exception is a per-session
  `/keel:auto-merge` invocation and "with no marker this line holds exactly as written." The amendment
  names **both** markers as exceptions to the never-merge default — the per-session attended marker
  **and** the committed per-project marker (armed by `keel:arm-auto-merge`, honored in every session)
  — and preserves the standing invariants intact: the agent still never merges *on its own
  initiative*; under either marker an **explicitly-instructed**, gate-passing bare
  `gh pr merge <pr> --auto` may land without the per-merge tap; and the never-claim-an-unobservable-
  outcome line is untouched. Both decision pointers are cited
  (`decisions/2026-07-04-attended-auto-merge.md` + the new
  `decisions/2026-08-02-per-project-auto-merge-authorization.md`).
- [auto] **`scripts/session-bootstrap.test.sh` is updated in lockstep** — it currently pins the
  orientation output to literal substrings (`/keel:auto-merge on`, `--auto`, `own initiative`,
  `with no marker`). M3 owns this file: its assertions are rewritten to match the amended line —
  keeping the substrings that remain true (`--auto`, `own initiative`) and replacing the
  now-removed `with no marker this line holds` phrasing with an assertion of the amended text (both
  markers named). The suite is green after the edit; the orientation change and its test move
  together in this milestone's diff (this is why the test is M3-owned, not an untouched suite).
- [auto] **`references/template-contract.md`'s autonomy-tier wiring list records arming as a third
  trigger.** Today the security-review check is wired at two moments (genesis at bootstrap; an
  already-standing attended project as preflight remediation at `auto:feature`/`auto:run`). The
  amendment adds **`keel:arm-auto-merge`** as a third: arming committed per-project auto-merge asserts
  and (if needed, attended) wires the same required check before it writes the marker — the committed
  marker is the same "human eyeball removed in unwatched sessions" trigger the autonomy tier already
  compensates for, so it wires the same control. Stated as an addition to the trigger set, not a
  change to the set of required checks (still the three).
- [auto] **`specs/deferrals/per-project-auto-merge.md` is closed with a RESOLVED banner** (in place,
  the `mode-file-binding-ttl.md` precedent, not the `_closed.md` archive) recording: resolved
  2026-08-02 by feature `per-project-auto-merge`; the committed-setting shape decided
  (`.claude/keel-auto-merge.json`, pin-gate plan-path carve-out —
  `decisions/2026-08-02-committed-auto-merge-marker.md`); the security-review-required precondition
  satisfied live (PRs #195/#196); and the **attended-vs-headless detection question left deferred** to
  `mode-file-binding-ttl.md` **by decision, not omission** (the required-checks floor makes the
  distinction unnecessary for safety). The original body is preserved below the banner as the record
  of why it was parked.
- [auto] **A new append-only `decisions/2026-08-02-per-project-auto-merge-authorization.md`** records
  the standing-authorization doctrine (distinct from M1's shape decision): that a committed marker is
  a **standing, human-made authorization** for `--auto` in every session of the repo; that it is
  safe because it rides the identical required-checks compensating control as autonomy mode; the
  precedence `mode > attended > committed`; that `review-feature` and the never-auto list are
  untouched; and that arming is the third security-review wiring moment. It amends by reference
  (editing nothing in place) `decisions/2026-07-04-attended-auto-merge.md`.

### Behavioral completeness

- [auto] **Corpus coherence:** `grep -rn "no marker this line holds" scripts/ references/ skills/`
  returns **empty** (the exact stale phrase the orientation line carried today is gone everywhere —
  a precise, non-judgment empty-result check chosen because it matches the one live instance verbatim);
  and `grep -rn "keel-auto-merge.json\|arm-auto-merge" scripts/ skills/ references/ decisions/` shows
  the committed marker and its arming skill named consistently across the reader family (guard header
  from M1, orientation line, template contract, decision entries) — no reader describes a marker shape
  or arming path that differs from what M1/M2 shipped.
- [auto] **Guard vocabulary is consistent:** the doctrine prose describes the guards' outputs in their
  real vocabulary — `merge-guard.sh` **emits `allow`**, `guard-branch-rules.sh` **`exit 0` (defers)** —
  never conflating the two, matching M1's shipped rows.
- [auto] **All lints and suites green:** `claude plugin validate --strict .`,
  `check-skill-frontmatter.sh`, `check-skill-anchors.sh`, `check-plan.sh`, `check-neutral.sh`, and
  every script self-test suite pass — including the **updated `session-bootstrap.test.sh`** (this
  milestone changes no script *logic* — only orientation text in `session-bootstrap.sh`, its matching
  test assertions, and prose/markdown elsewhere).
- [auto] **No unowned surface moved:** `git diff --stat` is confined to `scripts/session-bootstrap.sh`
  (orientation text only), `scripts/session-bootstrap.test.sh` (matching assertions),
  `references/template-contract.md`, `specs/deferrals/per-project-auto-merge.md`,
  `decisions/2026-08-02-per-project-auto-merge-authorization.md`, and this milestone spec. The M1/M2
  gate scripts, guards, arming skill, and `implement-feature` have empty diffs.

## verification

verifier subagent against this file — every `[auto]` condition with `file:line` evidence: the
orientation line names both markers and preserves all three cited invariants, the template-contract
trigger list adds arming as a third moment without changing the required set, the deferral banner
records all four resolution facts (shape, precondition, deferred-by-decision detection, date) with the
original body preserved, the decision entry records the standing-authorization stance + precedence +
untouched gates, the two greps return the intended buckets, and the guard vocabulary is exact. Suites
run, not re-derived. **Dispatch the verifier at `xhigh`**. **`/security-review` of the milestone's
diff is a pre-pin precondition** — the adversarial question: does any amended orientation/doctrine
prose overstate the authorization (e.g. imply the agent may self-arm, or that the marker relaxes the
required checks) — it must not; confirmed findings remediated before the pin.
