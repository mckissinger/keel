#!/usr/bin/env bash
#
# Self-test for check-plan.sh. Builds throwaway spec corpora in a temp dir and
# asserts the lint's exit code for each. No network, no fixtures.
#
# Run: bash scripts/check-plan.test.sh

set -uo pipefail
SCRIPT="$(cd "$(dirname "$0")" && pwd)/check-plan.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

pass=0 failc=0
check() { # desc  expected_exit
  local desc="$1" exp="$2" got
  bash "$SCRIPT" "$ROOT" >/dev/null 2>&1 && got=0 || got=$?
  if [ "$got" -eq "$exp" ]; then
    echo "ok   - $desc"; pass=$((pass + 1))
  else
    echo "FAIL - $desc (got exit $got, want $exp)"; failc=$((failc + 1))
  fi
}
fresh() { ROOT="$TMP/$1"; mkdir -p "$ROOT/specs/milestones" "$ROOT/specs/chores"; }

# 1. A clean milestone spec passes.
fresh c1-clean
cat > "$ROOT/specs/milestones/m1.md" <<'EOF'
# Milestone — m1

## Done-conditions
- [auto] the invariant holds; covered by the committed unit tier.
- [runtime] the surface activates on dev + prod builds (deterministic core
  covered by `tests/m1.spec.ts`).
- [attended] aesthetic sign-off at review.

## verification
verifier subagent against this file + the committed suites.
EOF
check "clean milestone spec passes" 0

# 2. An untagged done-condition fails.
fresh c2-untagged
cat > "$ROOT/specs/milestones/m1.md" <<'EOF'
# Milestone — m1

## Done-conditions
- [auto] the invariant holds.
- the route renders without errors.

## verification
verifier subagent.
EOF
check "untagged done-condition fails" 1

# 2b. A checkbox-style bracket is not a valid tag.
fresh c2b-checkbox
cat > "$ROOT/specs/milestones/m1.md" <<'EOF'
# Milestone — m1

## Done-conditions
- [ ] the route renders.

## verification
verifier subagent.
EOF
check "checkbox-style untagged bullet fails" 1

# 2c. Two tags on one condition fail.
fresh c2c-double
cat > "$ROOT/specs/milestones/m1.md" <<'EOF'
# Milestone — m1

## Done-conditions
- [auto] [runtime] the action commits.

## verification
verifier subagent.
EOF
check "double-tagged condition fails" 1

# 3. A [runtime] condition naming no committed test fails.
fresh c3-runtime-bare
cat > "$ROOT/specs/milestones/m1.md" <<'EOF'
# Milestone — m1

## Done-conditions
- [runtime] the page looks right when a human loads it.

## verification
verifier subagent.
EOF
check "[runtime] without a named test fails" 1

# 3b. A [runtime] condition naming its test in a continuation line passes.
fresh c3b-runtime-cont
cat > "$ROOT/specs/milestones/m1.md" <<'EOF'
# Milestone — m1

## Done-conditions
- [runtime] the flow works live (deterministic core covered by
  the committed e2e suite).

## verification
verifier subagent.
EOF
check "[runtime] naming its test in a continuation line passes" 0

# 4. A missing verification section fails.
fresh c4-noverif
cat > "$ROOT/specs/milestones/m1.md" <<'EOF'
# Milestone — m1

## Done-conditions
- [auto] the invariant holds; covered by the committed unit tier.
EOF
check "missing verification section fails" 1

# 4b. A `verification:` line (no heading) satisfies the section rule.
fresh c4b-verifline
cat > "$ROOT/specs/milestones/m1.md" <<'EOF'
# Milestone — m1

## Done-conditions
- [auto] the invariant holds; covered by the committed unit tier.

verification: verifier subagent against this file.
EOF
check "bare verification: line passes" 0

# 5. A missing Done-conditions section fails.
fresh c5-nodc
cat > "$ROOT/specs/milestones/m1.md" <<'EOF'
# Milestone — m1

Some prose, no conditions.

## verification
verifier subagent.
EOF
check "missing Done-conditions section fails" 1

# 6. Fidelity-mentioning conditions with no named reference fail; naming one passes.
fresh c6-fidelity-bare
cat > "$ROOT/specs/milestones/m1.md" <<'EOF'
# Milestone — m1

## Done-conditions
- [auto] fidelity: the screen uses the right tokens and spacing.

## verification
verifier subagent.
EOF
check "fidelity condition without a named reference fails" 1

fresh c6b-fidelity-named
cat > "$ROOT/specs/milestones/m1.md" <<'EOF'
# Milestone — m1

## Done-conditions
- [auto] fidelity: layout matches the feature's workbench composition.

## verification
verifier subagent.
EOF
check "fidelity condition naming its reference passes" 0

# 7. The legacy numbered condition style (pre-dash-bullet era) is grandfathered.
fresh c7-legacy
cat > "$ROOT/specs/milestones/m1.md" <<'EOF'
# Milestone — m1

## Done-conditions

1. **[auto] The thing exists.** It does the thing.
2. **[completeness] Coherence intact.** No dangling refs.

## Verification

`verification: verifier subagent against this milestone's done-conditions`.
EOF
check "legacy numbered style is grandfathered" 0

# 8. A chore spec with a valid pin-line shape passes.
fresh c8-chore-valid
cat > "$ROOT/specs/chores/batch.md" <<'EOF'
# Chore batch

- **item-1** — a tiny fix.

verified: clean at abc1234, 2026-07-01, via punch-list (evidence in PR #9)
EOF
check "chore spec with valid pin-line shape passes" 0

# 8b. A chore spec with no pin yet passes (the pin lands in the code PR).
fresh c8b-chore-nopin
echo "# Chore batch, not yet pinned" > "$ROOT/specs/chores/batch.md"
check "chore spec without a pin line passes" 0

# 8c. A chore pin with a pending caveat fails.
fresh c8c-chore-pending
cat > "$ROOT/specs/chores/batch.md" <<'EOF'
# Chore batch

verified: clean at abc1234, 2026-07-01, via punch-list — pending the live check
EOF
check "chore pin with a pending caveat fails" 1

# 8d. A chore pin with no parseable sha fails.
fresh c8d-chore-nosha
cat > "$ROOT/specs/chores/batch.md" <<'EOF'
# Chore batch

verified: clean, trust me
EOF
check "chore pin with no parseable sha fails" 1

# 8e. Backtick escape: a caveat word inside a backticked domain term passes (the scan
#     is whole-line minus backticked spans — identical to check-verified-pin.sh's).
fresh c8e-chore-backtick
cat > "$ROOT/specs/chores/batch.md" <<'EOF'
# Chore batch

verified: clean at abc1234, 2026-07-12, via punch-list over the `pending-leads` suite (evidence in PR #9)
EOF
check "chore pin with a backticked caveat-word domain term passes" 0

# 8f. A bare trailing caveat still fails (the backtick strip never rescues a real caveat).
fresh c8f-chore-bare-caveat
cat > "$ROOT/specs/chores/batch.md" <<'EOF'
# Chore batch

verified: clean at abc1234, 2026-07-12, via punch-list — pending the runtime walk
EOF
check "chore pin with a bare trailing caveat fails" 1

# 8g. First-match SHA parse: a carry-forward clause mentioning a second SHA in the
#     ' at <hex>,' shape parses to the FIRST — the line's shape stays valid.
fresh c8g-chore-carry
cat > "$ROOT/specs/chores/batch.md" <<'EOF'
# Chore batch

verified: clean at abc1234, 2026-07-12, via punch-list (evidence in PR #9) — carried forward from deadbee: previously at deadbee, 2026-07-01
EOF
check "chore pin with a carry-forward second SHA parses to the first (passes)" 0

# 9. Empty spec dirs pass (bootstrap-compatible), as does a repo with none.
fresh c9-empty
check "empty spec dirs pass" 0

ROOT="$TMP/c9b-nodirs"; mkdir -p "$ROOT"
check "missing spec dirs pass" 0

echo "-------------------------------------"
echo "$pass passed, $failc failed"
[ "$failc" -eq 0 ]
