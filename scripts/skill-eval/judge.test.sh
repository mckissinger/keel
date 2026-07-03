#!/usr/bin/env bash
#
# Self-test for judge.js — the eval scorer. Covers single-case scoring
# (should-trigger, should-not-trigger, mismatch) and the description-variant A/B
# comparative mode, including the committed superpowers fixture. Node built-ins
# only; no network, no live `claude -p`.
#
# Run: bash scripts/skill-eval/judge.test.sh

set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
JUDGE="$HERE/judge.js"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

pass=0 failc=0

# score <desc> <expected> <detected> <want-exit>
score() {
  local desc="$1" exp="$2" det="$3" want="$4" got
  node "$JUDGE" score --expected "$exp" --detected "$det" >/dev/null 2>&1 && got=0 || got=$?
  if [ "$got" -eq "$want" ]; then
    echo "ok   - $desc"; pass=$((pass + 1))
  else
    echo "FAIL - $desc (exit $got, want $want)"; failc=$((failc + 1))
  fi
}

# --- Single-case scoring (exit 0 = pass, 1 = fail) ----------------------------

# should-trigger: intended skill detected → pass.
score "should-trigger: intended verb fired → pass" spec-feature spec-feature 0

# should-not-trigger (nothing should fire): expected none, nothing fired → pass.
score "should-not-trigger: expected none, nothing fired → pass" none none 0

# should-not-trigger (sibling correctly fires while the confusable verb stays
# silent): expected the sibling, that sibling detected → pass. Here the point is
# that spec-change did NOT fire on a punch-list-shaped prompt.
score "should-not-trigger: correct sibling fired (confusable stayed silent) → pass" punch-list punch-list 0

# mismatch: intended verb X, a DIFFERENT verb detected → fail (the superpowers
# style confusion: implement-milestone expected, implement-feature fired).
score "mismatch: wrong verb fired → fail" implement-milestone implement-feature 1

# mismatch: intended verb X, nothing fired → fail.
score "mismatch: expected a verb, nothing fired → fail" spec-change none 1

# Verdict JSON shape: score prints a parseable {pass:false} on a mismatch.
verdict="$(node "$JUDGE" score --expected implement-milestone --detected implement-feature 2>/dev/null || true)"
if printf '%s' "$verdict" | grep -q '"pass":false'; then
  echo "ok   - score emits a JSON verdict with pass:false on mismatch"; pass=$((pass + 1))
else
  echo "FAIL - score verdict JSON (got: $verdict)"; failc=$((failc + 1))
fi

# --- A/B comparative mode -----------------------------------------------------

# A small synthetic A/B input: variant B is strictly more accurate.
cat > "$TMP/ab-synth.json" <<'EOF'
{
  "skill": "implement-feature",
  "pair": "implement-feature/implement-milestone",
  "variantA": { "label": "A", "cases": [
    { "expected": "implement-feature", "detected": "implement-feature" },
    { "expected": "implement-milestone", "detected": "implement-feature" }
  ]},
  "variantB": { "label": "B", "cases": [
    { "expected": "implement-feature", "detected": "implement-feature" },
    { "expected": "implement-milestone", "detected": "implement-milestone" }
  ]}
}
EOF
ab="$(node "$JUDGE" ab "$TMP/ab-synth.json" 2>/dev/null || true)"
if printf '%s' "$ab" | grep -q '"better": "variantB"'; then
  echo "ok   - A/B: judge picks the more accurate variant (variantB)"; pass=$((pass + 1))
else
  echo "FAIL - A/B synthetic comparative (got: $ab)"; failc=$((failc + 1))
fi
# Variant A accuracy 0.5, variant B accuracy 1.0 — assert both tallied.
if printf '%s' "$ab" | grep -q '"accuracy": 0.5' && printf '%s' "$ab" | grep -q '"accuracy": 1'; then
  echo "ok   - A/B: per-variant accuracy tallied (0.5 vs 1.0)"; pass=$((pass + 1))
else
  echo "FAIL - A/B per-variant accuracy (got: $ab)"; failc=$((failc + 1))
fi

# The committed superpowers fixture: the workflow-summary variant (A) is LESS
# accurate than its trimmed variant (B) — the shipped finding, scored offline.
SP="$HERE/fixtures/ab/superpowers-implement-feature.json"
absp="$(node "$JUDGE" ab "$SP" 2>/dev/null || true)"
if printf '%s' "$absp" | grep -q '"better": "variantB"'; then
  echo "ok   - superpowers fixture: trimmed variant (B) out-triggers the workflow-summary (A)"; pass=$((pass + 1))
else
  echo "FAIL - superpowers fixture comparison (got: $absp)"; failc=$((failc + 1))
fi

echo "-------------------------------------"
echo "$pass passed, $failc failed"
[ "$failc" -eq 0 ]
