# Change — Platform posture: auto-mode, min-version, security-guidance, Stop-hook wiring

**Grain:** one change → one milestone (`spec-change`). **No-UI** (methodology prose).
**Stacked on:** nothing (targets `main`).

## Why (the gap)

Item 16 from the research pass — four small platform-posture notes keel doesn't yet make, all
sourced from Anthropic's published guidance:

1. **No stance on unattended-run permission mode.** Neither auto mode nor
   `--dangerously-skip-permissions` is named anywhere in keel. Anthropic's auto-mode post: it's
   classifier-gated (research preview), headless runs abort after repeated blocks (3
   consecutive / 20 total), and its measured 17% false-negative rate is itself the argument for
   keeping the human merge gate. keel should say: unattended runs use auto mode (never
   skip-permissions), a blocked run is a stop-point, and the committed allowlist is what keeps
   denials rare — auto mode complements it.
2. **No minimum Claude Code version recorded.** The plugin manifest schema has no
   version-requirement field, so this belongs as a README requirements line (the hooks +
   `disable-model-invocation` + workflow features keel now uses have version floors).
3. **The first-party security-guidance plugin isn't mentioned** as a companion during
   hard-invariant `implement-milestone` work; `/security-review` stays the pre-pin gate.
4. **The pin gate's in-session enforcement isn't wired.** keel ships `check-verified-pin.sh` but
   wires it only at CI — which fires after a session already declared done. Anthropic's
   escalation ladder ranks a deterministic Stop-hook above prose. An optional wiring note
   (Stop hook / goal condition, BASE_REF=origin/main) lets a project refuse to end "done" on a
   milestone branch without a valid pin.

## The mechanic

1. **`skills/provision/SKILL.md`** (owner of settings.json posture) gains a short subsection +
   one generated-CLAUDE.md line: unattended runs use auto mode (classifier-gated, research
   preview), never `--dangerously-skip-permissions`; a blocked run is a stop-point; the
   allowlist keeps denials rare; auto mode complements, never replaces, the committed allowlist
   and the human merge gate (the 17% false-negative figure is the reason the merge gate stays).
2. **`README.md`** gains a requirements line: minimum Claude Code version (the floor for hooks,
   `disable-model-invocation`, and the Workflow tool keel relies on).
3. **`references/milestones-and-verification.md` §3** adversarial-review paragraph notes the
   first-party security-guidance plugin as a companion during hard-invariant milestone work;
   `/security-review` remains the pre-pin gate.
4. **Optional Stop-hook wiring note** in provision step 4 + one sentence in §5: a project may
   wire `check-verified-pin.sh` (BASE_REF=origin/main) as a Stop hook or goal condition so a
   session can't end "done" on a milestone branch without a valid pin — framed exactly like the
   lint-hook stance (optional, never mandated). **Implementation traps to state:** the script
   exits 1; Stop-hook blocking needs exit 2 / `{"decision":"block"}` (a one-line wrapper); scope
   it to sessions that open code PRs (implement-milestone sessions legitimately end pin-less);
   do **not** write the literal string that `check-neutral.sh` denylists for goal-condition
   phrasing — check the neutrality guard before wording it.

**Not weakened:** all four are notes/optional wirings; no gate behavior changes, no mandate
added. Auto mode is presented as complementing the existing allowlist + human merge, not
replacing them.

## Scope

Prose in `skills/provision/SKILL.md`, `README.md`, `references/milestones-and-verification.md`
(§3 + §5). `check-neutral.sh` green (verify the Stop-hook wording doesn't trip the goal-condition
denylist). No script behavior change.
