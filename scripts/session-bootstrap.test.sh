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

# Aged ISO-8601 UTC timestamps for mode-file TTL fixtures (GNU or BSD date).
ts_ago() { date -u -d "-$1 hours" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -v-"$1"H +%Y-%m-%dT%H:%M:%SZ; }

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
if printf '%s' "$OUT" | grep -q 'status'; then
  ok "bootstrap names status on the Cross-cut line"
else bad "bootstrap names status on the Cross-cut line"; fi
if printf '%s' "$OUT" | grep -q 'harvest'; then
  ok "bootstrap names harvest on the Cross-cut line"
else bad "bootstrap names harvest on the Cross-cut line"; fi
if printf '%s' "$OUT" | grep -q 'demo'; then
  ok "bootstrap names demo on the Cross-cut line"
else bad "bootstrap names demo on the Cross-cut line"; fi
if printf '%s' "$OUT" | grep -q 'test-health'; then
  ok "bootstrap names test-health on the Cross-cut line"
else bad "bootstrap names test-health on the Cross-cut line"; fi
if printf '%s' "$OUT" | grep -qF 'Done / Decision / Recommend / Glance / Next'; then
  ok "bootstrap carries the five summary-block labels inline"
else bad "bootstrap carries the five summary-block labels inline"; fi

# 2b. The disable-model-invocation skills stay discoverable: each flagged skill's
#     frontmatter carries the flag AND the bootstrap still names it (the [auto] half
#     of composition-walk assertion (d); the live block-vs-allow behavior is attended).
SKILLS_DIR="$(cd "$(dirname "$SCRIPT")/../skills" && pwd)"
for s in kickoff adopt land-feature; do
  if grep -q '^disable-model-invocation: true' "$SKILLS_DIR/$s/SKILL.md" \
     && printf '%s' "$OUT" | grep -q "$s"; then
    ok "flagged skill '$s' carries the flag and is named in the bootstrap"
  else bad "flagged skill '$s': flag present + named in bootstrap"; fi
done

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

# 5b. Autonomy mode (contract in scripts/merge-guard.sh, the reading owner):
#     a VALID .claude/keel-autonomy.json swaps the never-merge invariant for the
#     mode framing; any defect in the file → today's text byte-identical.

# Baseline: the marker-only output (no mode file) — the byte-identity reference.
run_in "$TMP/m1"
BASELINE="$OUT"
if printf '%s' "$BASELINE" | grep -qF 'Never merge; the user reviews and merges'; then
  ok "no mode file: the never-merge invariant line is present verbatim"
else bad "no mode file: the never-merge invariant line is present verbatim"; fi
# The never-merge line carries the attended exception clause: /keel:auto-merge on
# drops the per-merge tap on an instructed, gate-passing --auto — the agent still
# never merges on its own initiative, and with no marker the line holds as written.
if printf '%s' "$BASELINE" | grep -qF '/keel:auto-merge on' \
   && printf '%s' "$BASELINE" | grep -qF -- '--auto' \
   && printf '%s' "$BASELINE" | grep -qiF 'own initiative' \
   && printf '%s' "$BASELINE" | grep -qF 'with no marker'; then
  ok "no mode file: the never-merge line names the /keel:auto-merge attended exception"
else bad "no mode file: the never-merge line names the /keel:auto-merge attended exception"; fi

# The pin line carries the honest two-part-control form in BOTH variants (m2):
# it names the fresh-session verified pin AND the drift half, and no shipped
# line claims the gate alone proves verification.
if printf '%s' "$BASELINE" | grep -qF 'fresh-session verified pin' \
   && printf '%s' "$BASELINE" | grep -qi 'drift'; then
  ok "no-mode pin line names both halves (fresh-session pin + drift gate)"
else bad "no-mode pin line names both halves (fresh-session pin + drift gate)"; fi

# created 1h ago — inside the 24h mode TTL (the 23h/25h boundary is probed below).
MODE_JSON="$(printf '{"level":"run","scope":"whole-project","created":"%s","invoker":"human:keel-auto"}' "$(ts_ago 1)")"

mkdir -p "$TMP/mode1/specs/milestones" "$TMP/mode1/.claude"
printf '%s' "$MODE_JSON" > "$TMP/mode1/.claude/keel-autonomy.json"
run_in "$TMP/mode1"
if [ "$RC" -eq 0 ] && [ -n "$OUT" ]; then ok "valid mode file: bootstrap emitted"
else bad "valid mode file: bootstrap emitted (rc=$RC)"; fi
if ! printf '%s' "$OUT" | grep -qi 'never merge'; then
  ok "mode: the never-merge line is replaced, not restated"
else bad "mode: the never-merge line is replaced, not restated"; fi
if printf '%s' "$OUT" | grep -q 'level: run' && printf '%s' "$OUT" | grep -q 'whole-project'; then
  ok "mode: the active level and scope are named"
else bad "mode: the active level and scope are named"; fi
if printf '%s' "$OUT" | grep -qF -- '--auto' \
   && printf '%s' "$OUT" | grep -qF 'specs/runs/' \
   && printf '%s' "$OUT" | grep -qF 'required checks' \
   && printf '%s' "$OUT" | grep -qi 'stop-points still halt'; then
  ok "mode framing: --auto delegation + would-be-ask ledger + stop-points still halt"
else bad "mode framing: --auto delegation + would-be-ask ledger + stop-points still halt"; fi
if printf '%s' "$OUT" | grep -q 'implement-milestone'; then
  ok "mode: the grain ladder survives the swap"
else bad "mode: the grain ladder survives the swap"; fi
if printf '%s' "$OUT" | grep -q 'status'; then
  ok "mode: the Cross-cut line names status"
else bad "mode: the Cross-cut line names status"; fi
if printf '%s' "$OUT" | grep -q 'harvest'; then
  ok "mode: the Cross-cut line names harvest"
else bad "mode: the Cross-cut line names harvest"; fi
if printf '%s' "$OUT" | grep -q 'demo'; then
  ok "mode: the Cross-cut line names demo"
else bad "mode: the Cross-cut line names demo"; fi
if printf '%s' "$OUT" | grep -q 'test-health'; then
  ok "mode: the Cross-cut line names test-health"
else bad "mode: the Cross-cut line names test-health"; fi
if printf '%s' "$OUT" | grep -qF 'Done / Decision / Recommend / Glance / Next'; then
  ok "mode bootstrap carries the five summary-block labels inline"
else bad "mode bootstrap carries the five summary-block labels inline"; fi
if printf '%s' "$OUT" | grep -qF 'fresh-session verified pin' \
   && printf '%s' "$OUT" | grep -qi 'drift'; then
  ok "mode pin line names both halves (fresh-session pin + drift gate)"
else bad "mode pin line names both halves (fresh-session pin + drift gate)"; fi
mwords="$(printf '%s' "$OUT" | wc -w | tr -d ' ')"
if [ "$mwords" -gt 0 ] && [ "$mwords" -lt 700 ]; then ok "mode bootstrap under the token budget ($mwords words < 700)"
else bad "mode bootstrap word bound ($mwords words, want 1..699)"; fi

# feature level is named too.
mkdir -p "$TMP/mode2/specs/milestones" "$TMP/mode2/.claude"
printf '{"level":"feature","scope":"autonomy-modes","created":"%s","invoker":"human:keel-auto"}' "$(ts_ago 1)" \
  > "$TMP/mode2/.claude/keel-autonomy.json"
run_in "$TMP/mode2"
if printf '%s' "$OUT" | grep -q 'level: feature' && printf '%s' "$OUT" | grep -q 'autonomy-modes'; then
  ok "mode: feature level + its scope are named"
else bad "mode: feature level + its scope are named"; fi

# genesis level is recognized too (auto-genesis-m3: all three mode-file readers
# stay in parity — a genesis session self-orients like feature/run).
mkdir -p "$TMP/mode2g/specs/milestones" "$TMP/mode2g/.claude"
printf '{"level":"genesis","scope":"idea-slug","created":"%s","invoker":"human:keel-auto"}' "$(ts_ago 1)" \
  > "$TMP/mode2g/.claude/keel-autonomy.json"
run_in "$TMP/mode2g"
if printf '%s' "$OUT" | grep -q 'level: genesis' && printf '%s' "$OUT" | grep -q 'idea-slug'; then
  ok "mode: genesis level + its scope are named"
else bad "mode: genesis level + its scope are named"; fi

# Fail-closed matrix: each defect yields the no-mode text BYTE-IDENTICAL.
for defect in \
  'malformed-json:{"level":"run","scope":' \
  'unknown-level:{"level":"total","scope":"x","created":"c","invoker":"i"}' \
  'missing-field:{"level":"run","scope":"x","created":"c"}'; do
  name="${defect%%:*}"; payload="${defect#*:}"
  d="$TMP/mode-$name"
  mkdir -p "$d/specs/milestones" "$d/.claude"
  printf '%s' "$payload" > "$d/.claude/keel-autonomy.json"
  run_in "$d"
  if [ "$RC" -eq 0 ] && [ "$OUT" = "$BASELINE" ]; then
    ok "mode file $name → no mode, today's text byte-identical"
  else bad "mode file $name → no mode, today's text byte-identical (rc=$RC)"; fi
done

# Wrong-typed field: a JSON-number scope is not a string → no mode, under
# EITHER encoder path (jq/python3 parity in mode_json_str).
d="$TMP/mode-wrong-type"
mkdir -p "$d/specs/milestones" "$d/.claude"
printf '%s' '{"level":"run","scope":5,"created":"c","invoker":"i"}' > "$d/.claude/keel-autonomy.json"
run_in "$d"
if [ "$RC" -eq 0 ] && [ "$OUT" = "$BASELINE" ]; then
  ok "mode file wrong-typed scope (number) → no mode, today's text byte-identical"
else bad "mode file wrong-typed scope (number) → no mode, today's text byte-identical (rc=$RC)"; fi

# Spoof: a git-TRACKED mode file violates the untracked contract → no mode.
d="$TMP/mode-tracked"
mkdir -p "$d/specs/milestones" "$d/.claude"
printf '%s' "$MODE_JSON" > "$d/.claude/keel-autonomy.json"
git -C "$d" init -q
git -C "$d" add -f .claude/keel-autonomy.json
git -C "$d" -c user.email=t@keel.test -c user.name=t commit -qm spoof
run_in "$d"
if [ "$RC" -eq 0 ] && [ "$OUT" = "$BASELINE" ]; then
  ok "git-tracked mode file is a spoof → no mode, today's text byte-identical"
else bad "git-tracked mode file is a spoof → no mode, today's text byte-identical (rc=$RC)"; fi

# 5b-ttl. TTL (24h): an expired (25h) mode file → the no-mode baseline byte-
# identical; a fresh (23h) one → the mode orientation. Parity with the guards'
# verdicts on the same fixtures (the deferral's cross-reader parity clause).
d="$TMP/mode-expired"
mkdir -p "$d/specs/milestones" "$d/.claude"
printf '{"level":"run","scope":"whole-project","created":"%s","invoker":"human:keel-auto"}' "$(ts_ago 25)" \
  > "$d/.claude/keel-autonomy.json"
run_in "$d"
if [ "$RC" -eq 0 ] && [ "$OUT" = "$BASELINE" ]; then
  ok "expired mode file (25h) → no-mode baseline byte-identical (TTL)"
else bad "expired mode file (25h) → no-mode baseline byte-identical (TTL) (rc=$RC)"; fi

d="$TMP/mode-fresh23"
mkdir -p "$d/specs/milestones" "$d/.claude"
printf '{"level":"run","scope":"whole-project","created":"%s","invoker":"human:keel-auto"}' "$(ts_ago 23)" \
  > "$d/.claude/keel-autonomy.json"
run_in "$d"
if [ "$RC" -eq 0 ] && printf '%s' "$OUT" | grep -q 'level: run' \
   && ! printf '%s' "$OUT" | grep -qi 'never merge'; then
  ok "fresh mode file (23h, inside 24h TTL) → the mode orientation"
else bad "fresh mode file (23h, inside 24h TTL) → the mode orientation (rc=$RC)"; fi

d="$TMP/mode-badts"
mkdir -p "$d/specs/milestones" "$d/.claude"
printf '{"level":"run","scope":"whole-project","created":"not-a-timestamp","invoker":"human:keel-auto"}' \
  > "$d/.claude/keel-autonomy.json"
run_in "$d"
if [ "$RC" -eq 0 ] && [ "$OUT" = "$BASELINE" ]; then
  ok "unparseable created → no-mode baseline byte-identical"
else bad "unparseable created → no-mode baseline byte-identical (rc=$RC)"; fi

# 5c. The keel:auto verb is named in BOTH orientation variants (m4: the modes
#     are drivable, so every session — mode or no mode — knows the verb exists).
run_in "$TMP/m1"
if printf '%s' "$OUT" | grep -q 'keel:auto'; then
  ok "no-mode orientation names keel:auto among the verbs"
else bad "no-mode orientation names keel:auto among the verbs"; fi
run_in "$TMP/mode1"
if printf '%s' "$OUT" | grep -q 'keel:auto'; then
  ok "mode orientation names keel:auto among the verbs"
else bad "mode orientation names keel:auto among the verbs"; fi

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
