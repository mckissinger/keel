# Milestone — Platform posture: auto-mode, min-version, security-guidance, Stop-hook wiring

**Goal:** keel records its stance on unattended permission mode (auto mode, never
skip-permissions), a minimum Claude Code version, the security-guidance companion, and an
optional Stop-hook pin-gate wiring — all as notes/optional, no gate behavior change.

**Change:** `specs/changes/platform-posture.md`. **No-UI** → two-dimension done-conditions.
**Depends on:** nothing. **Parallelizable:** yes (prose; disjoint from living-specs).

## Done-conditions

### Logic / invariants
- [auto] `skills/provision/SKILL.md` gains an unattended-run posture subsection + one
  generated-CLAUDE.md line: auto mode (classifier-gated, research preview) for unattended runs,
  never `--dangerously-skip-permissions`; a blocked run is a stop-point; the committed allowlist
  keeps denials rare; auto mode complements — never replaces — the allowlist and the human merge
  gate, and the ~17% false-negative rate is named as why the merge gate stays.
- [auto] `README.md` gains a requirements line naming a minimum Claude Code version (the floor
  for hooks / `disable-model-invocation` / the Workflow tool keel uses).
- [auto] `references/milestones-and-verification.md` §3 notes the first-party
  security-guidance plugin as a companion during hard-invariant `implement-milestone` work,
  with `/security-review` explicitly still the pre-pin gate (unchanged).
- [auto] Optional Stop-hook wiring note in provision step 4 + one sentence in §5: a project may
  wire `check-verified-pin.sh` (BASE_REF=origin/main) as a Stop hook / goal condition; framed
  optional-never-mandated; states the three traps (exit 1 → needs exit 2 / `{"decision":"block"}`
  wrapper; scope to code-PR sessions; avoid the `check-neutral` goal-condition denylisted string).

### Behavioral completeness
- [auto] `scripts/check-neutral.sh` exits 0 — specifically confirm the Stop-hook/goal wording
  did not introduce a denylisted goal-condition string (the trap the spec calls out).
- [auto] No gate behavior change: `scripts/check-verified-pin.sh` and all other scripts
  untouched vs `main`; all script self-tests pass; `check-plan.sh` still passes the corpus.
- [auto] One-owner: auto-mode posture stated once in provision (+ the CLAUDE.md line it
  authors); the Stop-hook option stated in provision + §5 without a third restatement.

## verification
verifier subagent against this file (prose greps for each of the four notes + the trap wording;
one-owner sweep) + `scripts/check-neutral.sh` (with explicit attention to the goal-condition
denylist) + `check-plan.sh` + all script self-tests. No surface/action change → no runtime
walk; no hard invariant loosened (optional wirings only) → no `/security-review`.

verified: clean at 02f7467, 2026-07-01, via verifier subagent (evidence in PR #57)
