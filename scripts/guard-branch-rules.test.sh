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

# ---- shipped shape --------------------------------------------------------------
if [ -x "$SCRIPT" ]; then ok "guard-branch-rules.sh is executable"
else bad "guard-branch-rules.sh is executable"; fi

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
