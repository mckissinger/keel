#!/usr/bin/env bash
#
# Self-test for session-bootstrap.sh (+ its hooks.json wiring). Builds throwaway
# project dirs in a temp dir and asserts the hook's exit code and output for
# each marker shape. No network, no fixtures.
#
# Run: bash scripts/session-bootstrap.test.sh

set -uo pipefail
SCRIPT="$(cd "$(dirname "$0")" && pwd)/session-bootstrap.sh"
HOOKS_JSON="$(cd "$(dirname "$0")/.." && pwd)/hooks/hooks.json"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

pass=0 failc=0
ok()  { echo "ok   - $1"; pass=$((pass + 1)); }
bad() { echo "FAIL - $1"; failc=$((failc + 1)); }

run_in() { # dir → sets OUT + RC (harness shape: CLAUDE_PROJECT_DIR points at the project)
  local dir="$1"
  OUT="$(CLAUDE_PROJECT_DIR="$dir" bash "$SCRIPT" 2>/dev/null)" && RC=0 || RC=$?
}

# 1. No keel marker → exit 0, NO output (silent everywhere keel isn't).
mkdir -p "$TMP/plain/src"
echo "just a repo" > "$TMP/plain/README.md"
run_in "$TMP/plain"
if [ "$RC" -eq 0 ] && [ -z "$OUT" ]; then ok "no-marker dir: exit 0, empty output"
else bad "no-marker dir: exit 0, empty output (rc=$RC, out=${#OUT} bytes)"; fi

# 1b. Same, resolved via cwd when CLAUDE_PROJECT_DIR is unset.
OUT="$(cd "$TMP/plain" && env -u CLAUDE_PROJECT_DIR bash "$SCRIPT" 2>/dev/null)" && RC=0 || RC=$?
if [ "$RC" -eq 0 ] && [ -z "$OUT" ]; then ok "no-marker dir via cwd fallback: exit 0, empty output"
else bad "no-marker dir via cwd fallback (rc=$RC, out=${#OUT} bytes)"; fi

# 2. specs/milestones/ marker → bootstrap emitted, under the token budget.
mkdir -p "$TMP/m1/specs/milestones"
run_in "$TMP/m1"
words="$(printf '%s' "$OUT" | wc -w | tr -d ' ')"
if [ "$RC" -eq 0 ] && [ -n "$OUT" ]; then ok "specs/milestones marker: bootstrap emitted"
else bad "specs/milestones marker: bootstrap emitted (rc=$RC)"; fi
if [ "$words" -gt 0 ] && [ "$words" -lt 700 ]; then ok "bootstrap under the token budget ($words words < 700)"
else bad "bootstrap word bound ($words words, want 1..699)"; fi
if printf '%s' "$OUT" | grep -q 'implement-milestone' \
   && printf '%s' "$OUT" | grep -qi 'never merge'; then
  ok "bootstrap carries the grain ladder + invariants"
else bad "bootstrap carries the grain ladder + invariants"; fi

# 3. specs/stack-profile.md marker → bootstrap emitted.
mkdir -p "$TMP/m2/specs"
echo "# stack profile" > "$TMP/m2/specs/stack-profile.md"
run_in "$TMP/m2"
if [ "$RC" -eq 0 ] && [ -n "$OUT" ]; then ok "stack-profile.md marker: bootstrap emitted"
else bad "stack-profile.md marker: bootstrap emitted (rc=$RC)"; fi

# 4. CLAUDE.md mentioning the verified-pin process → bootstrap emitted.
mkdir -p "$TMP/m3"
echo "merges are gated by the verified-pin process" > "$TMP/m3/CLAUDE.md"
run_in "$TMP/m3"
if [ "$RC" -eq 0 ] && [ -n "$OUT" ]; then ok "CLAUDE.md verified-pin marker: bootstrap emitted"
else bad "CLAUDE.md verified-pin marker: bootstrap emitted (rc=$RC)"; fi

# 5. A CLAUDE.md that never mentions verified-pin is NOT a marker.
mkdir -p "$TMP/m4"
echo "generic project instructions" > "$TMP/m4/CLAUDE.md"
run_in "$TMP/m4"
if [ "$RC" -eq 0 ] && [ -z "$OUT" ]; then ok "plain CLAUDE.md is not a marker: silent"
else bad "plain CLAUDE.md is not a marker (rc=$RC, out=${#OUT} bytes)"; fi

# 6. The shipped script carries its executable bit.
if [ -x "$SCRIPT" ]; then ok "session-bootstrap.sh is executable"
else bad "session-bootstrap.sh is executable"; fi

# 7. hooks.json declares the compact matcher (post-compaction re-injection).
if grep -q 'compact' "$HOOKS_JSON"; then ok "hooks.json declares the compact matcher"
else bad "hooks.json declares the compact matcher"; fi

# 8. hooks.json is valid JSON.
if command -v jq >/dev/null 2>&1; then
  if jq -e . "$HOOKS_JSON" >/dev/null 2>&1; then ok "hooks.json is valid JSON (jq)"
  else bad "hooks.json is valid JSON (jq)"; fi
elif command -v python3 >/dev/null 2>&1; then
  if python3 -c 'import json,sys; json.load(open(sys.argv[1]))' "$HOOKS_JSON" >/dev/null 2>&1; then
    ok "hooks.json is valid JSON (python3)"
  else bad "hooks.json is valid JSON (python3)"; fi
else
  bad "hooks.json is valid JSON (no jq or python3 available to parse it)"
fi

echo "-------------------------------------"
echo "$pass passed, $failc failed"
[ "$failc" -eq 0 ]
