#!/usr/bin/env bash
#
# Self-test for guard-branch-rules.sh (+ its skill-scoped `hooks:` frontmatter
# wiring in implement-milestone / implement-feature). Builds throwaway git repos
# in a temp dir, feeds the guard synthetic hook stdin JSON, and asserts the
# exit-2 rules: commit-on-default-branch blocked, merge-shaped blocked, all else
# silent. No network, no fixtures.
#
# Run: bash scripts/guard-branch-rules.test.sh

set -uo pipefail
SCRIPT="$(cd "$(dirname "$0")" && pwd)/guard-branch-rules.sh"
SKILLS_DIR="$(cd "$(dirname "$0")/.." && pwd)/skills"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

pass=0 failc=0
ok()  { echo "ok   - $1"; pass=$((pass + 1)); }
bad() { echo "FAIL - $1"; failc=$((failc + 1)); }

# Fresh/aged ISO-8601 UTC timestamps for marker TTL fixtures (GNU or BSD date).
ts_ago() { date -u -d "-$1 hours" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -v-"$1"H +%Y-%m-%dT%H:%M:%SZ; }

json_quote() { # raw string → JSON string literal (house pattern: jq, python3 fallback)
  if command -v jq >/dev/null 2>&1; then printf '%s' "$1" | jq -Rs .
  else printf '%s' "$1" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))'
  fi
}

run_rules() { # <repo> <command text> → OUT (stdout), ERR (stderr), RC
  local repo="$1" cmd="$2" json
  json="$(json_quote "$cmd")"
  OUT="$(printf '{"tool_name":"Bash","tool_input":{"command":%s}}' "$json" \
    | CLAUDE_PROJECT_DIR="$repo" bash "$SCRIPT" 2>"$TMP/err.txt")" && RC=0 || RC=$?
  ERR="$(cat "$TMP/err.txt" 2>/dev/null)"
}

expect_silent() { # <desc> — exit 0, no output on either stream
  if [ "$RC" -eq 0 ] && [ -z "$OUT" ] && [ -z "$ERR" ]; then ok "$1"
  else bad "$1 (rc=$RC, out=${OUT:0:80}, err=${ERR:0:80})"; fi
}
expect_block() { # <desc> <stderr substring> — exit 2, reason on stderr, stdout empty
  local desc="$1" sub="$2"
  if [ "$RC" -ne 2 ]; then bad "$desc (rc=$RC, want 2)"; return; fi
  if [ -n "$OUT" ]; then bad "$desc (stdout not empty: ${OUT:0:80})"; return; fi
  if ! printf '%s' "$ERR" | grep -qF "$sub"; then
    bad "$desc (stderr missing '$sub': ${ERR:0:160})"; return
  fi
  ok "$desc"
}

make_repo() { # <name> → REPO, on branch main with origin/main + origin/HEAD
  REPO="$TMP/$1"
  mkdir -p "$REPO"
  git -C "$REPO" init -q
  git -C "$REPO" checkout -q -b main
  git -C "$REPO" -c user.email=t@keel.test -c user.name=t commit -q --allow-empty -m init
  git -C "$REPO" update-ref refs/remotes/origin/main "$(git -C "$REPO" rev-parse HEAD)"
  git -C "$REPO" symbolic-ref refs/remotes/origin/HEAD refs/remotes/origin/main
  git -C "$REPO" remote add origin "$REPO"
}

# ---- commit rule --------------------------------------------------------------
make_repo r1; R1="$REPO" # sitting on main

run_rules "$R1" 'git commit -m "quick fix"'
expect_block "git commit on the default branch → exit 2 with the branch-first rule" "branch first"
run_rules "$R1" 'git add -A && git commit -m "quick fix"'
expect_block "compound command: commit on the default branch still blocked" "branch first"
run_rules "$R1" 'git status'
expect_silent "non-commit command on the default branch is silent"

git -C "$R1" checkout -q -b feat/work
run_rules "$R1" 'git commit -m "milestone work"'
expect_silent "git commit on a feature branch → exit 0, silent"

# ---- merge rule (build sessions never merge, on ANY branch) --------------------
run_rules "$R1" 'gh pr merge 12'
expect_block "gh pr merge → exit 2 (build sessions never merge)" "never merge"
run_rules "$R1" 'git push origin main'
expect_block "git push to the default branch → exit 2" "never merge"
run_rules "$R1" 'git merge main'
expect_block "git merge <default> → exit 2" "never merge"
run_rules "$R1" 'gh --repo octo/repo pr merge 12'
expect_block "gh --repo <o/r> pr merge (flags before subcommand) → exit 2" "never merge"

# ---- non-triggers (same classifier as merge-guard) -----------------------------
run_rules "$R1" 'git merge --abort';        expect_silent "git merge --abort does not trigger"
run_rules "$R1" 'git merge-base main HEAD'; expect_silent "git merge-base does not trigger"
run_rules "$R1" 'git merge feat/other';     expect_silent "branch-to-branch merge does not trigger"
run_rules "$R1" 'git push origin feat/work'; expect_silent "push to a non-default branch does not trigger"
run_rules "$R1" 'ls -la';                   expect_silent "non-git command does not trigger"

# ---- attended-merge marker: the per-session --auto defer ---------------------
# Contract (guard-branch-rules.sh header): a valid .claude/keel-attended-merge.json
# (scope="session" + created + invoker) + NO autonomy mode + a bare
# `gh pr merge <pr> --auto` → exit 0 (defer the gate decision to merge-guard.sh).
# Plain merge, git commit on the default branch, other merge shapes, and a
# bundled/evaded --auto → exit 2. A valid autonomy mode present suppresses the
# defer (mode precedence). No marker → the exit-2 matrix is unchanged.

# created within TTL (attended 8h / mode 24h); the boundary is probed below. A
# hardcoded past date would now read expired and flip these defer rows.
ATT_JSON="$(printf '{"scope":"session","created":"%s","invoker":"human:keel-auto-merge"}' "$(ts_ago 1)")"
MODE_JSON="$(printf '{"level":"run","scope":"whole-project","created":"%s","invoker":"human:keel-auto"}' "$(ts_ago 1)")"
write_attended() { mkdir -p "$1/.claude"; printf '%s' "$2" > "$1/.claude/keel-attended-merge.json"; }
write_mode()     { mkdir -p "$1/.claude"; printf '%s' "$2" > "$1/.claude/keel-autonomy.json"; }

make_repo r2; R2="$REPO"              # sitting on main
git -C "$R2" checkout -q -b feat/work # a build branch

# Marker absent → the exit-2 matrix is unchanged (regression).
run_rules "$R2" 'gh pr merge 123 --auto'
expect_block "no attended marker: gh pr merge --auto → exit 2 (unchanged)" "never merge"

# Valid marker + bare --auto → exit 0, deferring to merge-guard.sh (silent).
write_attended "$R2" "$ATT_JSON"
run_rules "$R2" 'gh pr merge 123 --auto'
expect_silent "attended marker + bare gh pr merge --auto → exit 0 (defer to merge-guard)"
run_rules "$R2" 'gh pr merge 123 --auto --squash'
expect_silent "attended marker + bare --auto with a merge-method flag → exit 0 (defer)"
run_rules "$R2" 'gh pr merge --auto 123'
expect_silent "attended marker + --auto before the PR arg → exit 0 (defer)"

# TTL (8h): an expired attended marker (9h) → treated absent → exit 2; a fresh
# one inside the TTL (7h) → still defers (exit 0). Full-hour margins.
write_attended "$R2" "$(printf '{"scope":"session","created":"%s","invoker":"human:keel-auto-merge"}' "$(ts_ago 9)")"
run_rules "$R2" 'gh pr merge 123 --auto'
expect_block "expired attended marker (9h) + bare --auto → exit 2 (treated absent)" "never merge"
write_attended "$R2" "$(printf '{"scope":"session","created":"%s","invoker":"human:keel-auto-merge"}' "$(ts_ago 7)")"
run_rules "$R2" 'gh pr merge 123 --auto'
expect_silent "fresh attended marker (7h, inside 8h TTL) + bare --auto → exit 0 (defer)"
write_attended "$R2" '{"scope":"session","created":"not-a-timestamp","invoker":"human:keel-auto-merge"}'
run_rules "$R2" 'gh pr merge 123 --auto'
expect_block "attended marker with an unparseable created → treated absent → exit 2" "never merge"
write_attended "$R2" "$ATT_JSON" # restore a fresh valid marker for the rows below

# TTL (24h): an EXPIRED mode file no longer suppresses the attended defer — it is
# treated absent, so a fresh attended marker + bare --auto defers (exit 0), where
# a fresh mode file would have forced exit 2 (mode precedence, tested below).
write_mode "$R2" "$(printf '{"level":"run","scope":"x","created":"%s","invoker":"human"}' "$(ts_ago 25)")"
run_rules "$R2" 'gh pr merge 123 --auto'
expect_silent "expired mode file (25h) does not suppress the attended defer → exit 0"
rm -f "$R2/.claude/keel-autonomy.json"

# Plain gh pr merge (no --auto) under the marker → exit 2.
run_rules "$R2" 'gh pr merge 123'
expect_block "attended marker + plain gh pr merge (no --auto) → exit 2" "never merge"

# Bundled / evaded --auto under the marker → exit 2 (only the bare shape defers).
run_rules "$R2" 'gh pr merge 123 --auto && echo done'
expect_block "attended marker + chained --auto → exit 2 (only the bare shape defers)" "never merge"
run_rules "$R2" 'gh pr merge 123 --auto --admin'
expect_block "attended marker + --admin alongside --auto → exit 2" "never merge"

# Other merge shapes under the marker → exit 2 (only gh pr merge --auto defers).
run_rules "$R2" 'git push origin main'
expect_block "attended marker + git push <default> → exit 2" "never merge"
run_rules "$R2" 'git merge main'
expect_block "attended marker + git merge <default> → exit 2" "never merge"

# git commit on the default branch under the marker → exit 2 (branch-first intact).
git -C "$R2" checkout -q main
write_attended "$R2" "$ATT_JSON"
run_rules "$R2" 'git commit -m "wip"'
expect_block "attended marker + git commit on the default branch → exit 2 (branch first)" "branch first"
git -C "$R2" checkout -q feat/work

# Autonomy precedence: a valid mode file present suppresses the attended defer →
# exit 2 (turning autonomy mode on removes the attended unlock in build scope).
write_attended "$R2" "$ATT_JSON"
write_mode "$R2" "$MODE_JSON"
run_rules "$R2" 'gh pr merge 123 --auto'
expect_block "attended marker + valid autonomy mode both active → exit 2 (mode precedence suppresses the defer)" "never merge"
rm -f "$R2/.claude/keel-autonomy.json"

# Malformed marker → treated absent → exit 2.
write_attended "$R2" '{"scope":"session","created":'
run_rules "$R2" 'gh pr merge 123 --auto'
expect_block "malformed attended marker → treated absent → exit 2" "never merge"
write_attended "$R2" '{"scope":"project","created":"c","invoker":"i"}'
run_rules "$R2" 'gh pr merge 123 --auto'
expect_block "attended marker scope != session → treated absent → exit 2" "never merge"

# Spoof: a git-TRACKED attended marker violates the untracked contract → absent.
write_attended "$R2" "$ATT_JSON"
git -C "$R2" add -f .claude/keel-attended-merge.json
git -C "$R2" -c user.email=t@keel.test -c user.name=t commit -qm spoof-attended
run_rules "$R2" 'gh pr merge 123 --auto'
expect_block "git-tracked attended marker is a spoof → treated absent → exit 2" "never merge"

# ---- shipped shape --------------------------------------------------------------
if [ -x "$SCRIPT" ]; then ok "guard-branch-rules.sh is executable"
else bad "guard-branch-rules.sh is executable"; fi

# TTL contract tripwire: the header must document both TTLs (24h/8h), the
# expired≡absent rule, and the no-refresh rule (parity with merge-guard.sh).
if grep -qF '24h' "$SCRIPT" && grep -qF '8h' "$SCRIPT" \
   && grep -qiF 'as absent' "$SCRIPT" \
   && grep -qiF 'NO REFRESH PATH' "$SCRIPT" \
   && grep -qiF 'fresh human invocation' "$SCRIPT"; then
  ok "TTL contract is documented in the branch-guard header (24h/8h, expired≡absent, no-refresh)"
else bad "TTL contract is documented in the branch-guard header (24h/8h, expired≡absent, no-refresh)"; fi

for skill in implement-milestone implement-feature; do
  f="$SKILLS_DIR/$skill/SKILL.md"
  fm="$(awk '/^---$/{c++; next} c==1' "$f" 2>/dev/null)" # frontmatter body only
  if printf '%s' "$fm" | grep -q 'hooks:' \
     && printf '%s' "$fm" | grep -q 'PreToolUse:' \
     && printf '%s' "$fm" | grep -q 'guard-branch-rules.sh'; then
    ok "$skill/SKILL.md declares the skill-scoped PreToolUse hook"
  else
    bad "$skill/SKILL.md declares the skill-scoped PreToolUse hook"
  fi
done

echo "-------------------------------------"
echo "$pass passed, $failc failed"
[ "$failc" -eq 0 ]
