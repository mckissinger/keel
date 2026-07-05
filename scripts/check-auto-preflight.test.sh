#!/usr/bin/env bash
#
# Self-test for check-auto-preflight.sh. Builds throwaway project fixtures in a
# temp dir, stubs `gh` on PATH (no network), and asserts the gate's exit code
# and — because the preflight's whole security posture is names-never-values —
# that no env-var VALUE ever appears in its output.
#
# Run: bash scripts/check-auto-preflight.test.sh

set -uo pipefail
SCRIPT="$(cd "$(dirname "$0")" && pwd)/check-auto-preflight.sh"
REAL_BASH="$(command -v bash)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

pass=0 failc=0
ok()  { echo "ok   - $1"; pass=$((pass + 1)); }
bad() { echo "FAIL - $1"; failc=$((failc + 1)); }

# gh stub: `gh api .../protection` → $GH_PROT_FILE (check b); any other `gh api`
# (the repos/{owner}/{repo} lookup, check d) → $GH_REPO_FILE. A missing/unset
# file for either → a 404-shaped failure (fail-closed path under test).
mkdir -p "$TMP/bin"
cat > "$TMP/bin/gh" <<'EOF'
#!/usr/bin/env bash
case "$*" in
  *protection*)
    if [ -n "${GH_PROT_FILE:-}" ] && [ -f "$GH_PROT_FILE" ]; then cat "$GH_PROT_FILE"; exit 0; fi
    echo "gh: Branch not protected (HTTP 404)" >&2; exit 1 ;;
  *)
    if [ -n "${GH_REPO_FILE:-}" ] && [ -f "$GH_REPO_FILE" ]; then cat "$GH_REPO_FILE"; exit 0; fi
    echo "gh: Not Found (HTTP 404)" >&2; exit 1 ;;
esac
EOF
chmod +x "$TMP/bin/gh"

# repo-metadata fixtures for check (d): allow_auto_merge enabled vs disabled.
printf '{"allow_auto_merge":true}\n'  > "$TMP/repo-aam-true.json"
printf '{"allow_auto_merge":false}\n' > "$TMP/repo-aam-false.json"

cat > "$TMP/protection-full.json" <<'EOF'
{"required_status_checks":{"contexts":["verified-pin","plan-lint","security-review"]}}
EOF
# security-review exists as a CI job but is NOT in the required set.
cat > "$TMP/protection-partial.json" <<'EOF'
{"required_status_checks":{"contexts":["verified-pin","plan-lint"],"checks":[{"context":"verified-pin"},{"context":"plan-lint"}]}}
EOF

make_proj() { # <name> → PROJ, a fixture that fully passes checks (a) and (c)
  PROJ="$TMP/$1"
  mkdir -p "$PROJ/.claude" "$PROJ/specs"
  cat > "$PROJ/.claude/settings.json" <<'EOF'
{"permissions":{"allow":["Bash(supabase db *)","Bash(pnpm eval:*)","Bash(pnpm test*)","mcp__trigger__deploy"]}}
EOF
  cat > "$PROJ/specs/run-command-inventory.txt" <<'EOF'
# command shapes the run will execute
supabase db push
pnpm eval:accuracy
pnpm test

mcp__trigger__deploy
EOF
  cat > "$PROJ/specs/01-architecture.md" <<'EOF'
# Architecture

## Environment contract
| var | source |
|---|---|
| `PREFLIGHT_T_SET` | host env |
| `PREFLIGHT_T_FILE` | derived env file |
EOF
  printf 'PREFLIGHT_T_FILE=fixture-file-value\n' > "$PROJ/.env.local"
}

SENTINEL="s3ntinel-value-9f"
run_gate() { # <proj> [prot-file] [repo-file] → OUT, RC (gh stubbed; one contract var via host env)
  # repo-file defaults to the allow_auto_merge=true fixture so checks (a)-(c) can
  # be exercised without check (d) tripping; pass a false/absent file to probe (d).
  local proj="$1" prot="${2:-}" repo="${3:-$TMP/repo-aam-true.json}"
  OUT="$(PATH="$TMP/bin:$PATH" GH_PROT_FILE="$prot" GH_REPO_FILE="$repo" PREFLIGHT_T_SET="$SENTINEL" \
    bash "$SCRIPT" "$proj" 2>&1)" && RC=0 || RC=$?
}
expect() { # <desc> <exit> [output substring]
  local desc="$1" exp="$2" sub="${3:-}"
  if [ "$RC" -ne "$exp" ]; then bad "$desc (got exit $RC, want $exp)"; return; fi
  if [ -n "$sub" ] && ! printf '%s' "$OUT" | grep -qF "$sub"; then
    bad "$desc (output lacked \"$sub\": ${OUT:0:200})"; return
  fi
  ok "$desc"
}

# 1. Full pass: inventory covered, all three checks required, env names resolve.
make_proj p1
run_gate "$PROJ" "$TMP/protection-full.json"
expect "full pass exits 0" 0 "auto-preflight: PASS"

# 2. Names, never values: the set var's VALUE and the env-file value never
#    appear in any output — the pass path names the var, not what it holds.
if printf '%s' "$OUT" | grep -qF "$SENTINEL"; then
  bad "no env VALUE in output (host-env value leaked)"
else ok "no env VALUE in output (host-env value never echoed)"; fi
if printf '%s' "$OUT" | grep -qF "fixture-file-value"; then
  bad "no env VALUE in output (env-file value leaked)"
else ok "no env VALUE in output (env-file value never echoed)"; fi
if printf '%s' "$OUT" | grep -qF "PREFLIGHT_T_SET"; then
  ok "the pass path reports the var by NAME"
else bad "the pass path reports the var by NAME"; fi

# 3. Uncovered command shape → fail, the shape named.
make_proj p3
echo "vercel deploy --prod" >> "$PROJ/specs/run-command-inventory.txt"
run_gate "$PROJ" "$TMP/protection-full.json"
expect "uncovered command shape fails, named" 1 "vercel deploy --prod"

# 4. Branch protection missing (gh api fails) → fail closed, named.
make_proj p4
run_gate "$PROJ" ""
expect "missing branch protection fails" 1 "no readable branch protection"

# 5. A required check present-but-not-required (security-review exists as a CI
#    job but is absent from the REQUIRED set) → fail, the check named.
make_proj p5
run_gate "$PROJ" "$TMP/protection-partial.json"
expect "present-but-not-required check fails, named" 1 "'security-review' is not a REQUIRED status check"

# 6. A contract env-var name that resolves nowhere → fail, the NAME named.
make_proj p6
echo 'Also needs `PREFLIGHT_T_ABSENT`.' >> "$PROJ/specs/01-architecture.md"
run_gate "$PROJ" "$TMP/protection-full.json"
expect "missing env name fails, named" 1 "PREFLIGHT_T_ABSENT"

# 7. Degraded context: no `gh` on PATH → fail closed, naming gh. PATH is a
#    minimal dir (jq only) so the local checks still run; bash by real path.
mkdir -p "$TMP/nogh"
ln -s "$(command -v jq)" "$TMP/nogh/jq"
make_proj p7
OUT="$(PATH="$TMP/nogh" PREFLIGHT_T_SET="$SENTINEL" \
  "$REAL_BASH" "$SCRIPT" "$PROJ" 2>&1)" && RC=0 || RC=$?
expect "no gh in context fails closed, naming gh" 1 "gh is unavailable"

# 8. Degraded context: no `jq` on PATH → fail closed, naming jq.
mkdir -p "$TMP/nojq"
ln -s "$TMP/bin/gh" "$TMP/nojq/gh"
make_proj p8
OUT="$(PATH="$TMP/nojq" GH_PROT_FILE="$TMP/protection-full.json" PREFLIGHT_T_SET="$SENTINEL" \
  "$REAL_BASH" "$SCRIPT" "$PROJ" 2>&1)" && RC=0 || RC=$?
expect "no jq in context fails closed, naming jq" 1 "jq is unavailable"

# 9. Missing committed inventory → fail closed, named.
make_proj p9
rm "$PROJ/specs/run-command-inventory.txt"
run_gate "$PROJ" "$TMP/protection-full.json"
expect "missing inventory fails closed" 1 "run-command-inventory.txt missing"

# 10. Missing committed allowlist → fail closed, named.
make_proj p10
rm "$PROJ/.claude/settings.json"
run_gate "$PROJ" "$TMP/protection-full.json"
expect "missing settings.json fails closed" 1 "settings.json missing"

# 11. Missing architecture contract → fail closed, named.
make_proj p11
rm "$PROJ/specs/01-architecture.md"
run_gate "$PROJ" "$TMP/protection-full.json"
expect "missing contract fails closed" 1 "01-architecture.md missing"

# 12. A BUNDLED merge in the inventory (gh pr merge chained with another command)
#     → fail closed, the bundled-merge reason named. It forfeits the merge-guard's
#     strict-auto allow and would stall a headless run mid-flight.
make_proj p12
echo 'gh pr merge 5 --auto && gh pr view 5' >> "$PROJ/specs/run-command-inventory.txt"
run_gate "$PROJ" "$TMP/protection-full.json"
expect "bundled merge fails closed, named" 1 "bundled merge"

# 13. A BARE `gh pr merge <ref> --auto` line, with the canonical baseline rule
#     (`Bash(gh pr merge:*)`, the ':*' form the harness uses) present: covered by
#     the normalized matcher AND not flagged by the bundled check → overall exit 0,
#     and the bundled-merge reason is ABSENT. Guards both the ':*' normalization and
#     the bundled check's precision against the bare shape.
make_proj p13
cat > "$PROJ/.claude/settings.json" <<'EOF'
{"permissions":{"allow":["Bash(supabase db *)","Bash(pnpm eval:*)","Bash(pnpm test*)","mcp__trigger__deploy","Bash(gh pr merge:*)","Bash(gh pr view:*)"]}}
EOF
{ echo 'gh pr merge 5 --auto'; echo 'gh pr view 5'; } >> "$PROJ/specs/run-command-inventory.txt"
run_gate "$PROJ" "$TMP/protection-full.json"
expect "bare merge + canonical baseline rule passes" 0 "auto-preflight: PASS"
if printf '%s' "$OUT" | grep -qF "bundled merge"; then
  bad "bare merge must NOT trip the bundled-merge check"
else ok "bare merge does not trip the bundled-merge check"; fi

# 14. Check (d): allow_auto_merge enabled → PASS (part of the full-pass path, but
#     asserted explicitly against the true fixture).
make_proj p14
run_gate "$PROJ" "$TMP/protection-full.json" "$TMP/repo-aam-true.json"
expect "allow_auto_merge=true passes check (d)" 0 "auto-preflight: PASS"

# 15. Check (d): allow_auto_merge disabled → FAIL, naming the setting + attended remedy.
make_proj p15
run_gate "$PROJ" "$TMP/protection-full.json" "$TMP/repo-aam-false.json"
expect "allow_auto_merge=false fails check (d), named" 1 "allow_auto_merge is not enabled"
if printf '%s' "$OUT" | grep -qF "gh api -X PATCH"; then
  ok "check (d) failure names the attended fix (gh api -X PATCH)"
else bad "check (d) failure names the attended fix (gh api -X PATCH)"; fi

# 16. Check (d): the repo api lookup errors (no repo fixture) → fail closed.
make_proj p16
run_gate "$PROJ" "$TMP/protection-full.json" "$TMP/repo-absent.json"
expect "repo api error fails check (d) closed" 1 "cannot confirm allow_auto_merge"

echo "-------------------------------------"
echo "$pass passed, $failc failed"
[ "$failc" -eq 0 ]
