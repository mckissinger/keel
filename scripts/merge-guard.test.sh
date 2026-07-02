#!/usr/bin/env bash
#
# Self-test for merge-guard.sh (+ its hooks.json PreToolUse wiring). Builds
# throwaway git repos in a temp dir, feeds the guard synthetic hook stdin JSON,
# and asserts the full decision matrix: non-triggers stay silent, merge-shaped
# commands become ask/deny, the gate's stderr reason passes through verbatim,
# and missing gate/context degrades to ask. gh is a recording stub — no network.
#
# Run: bash scripts/merge-guard.test.sh

set -uo pipefail
SCRIPT="$(cd "$(dirname "$0")" && pwd)/merge-guard.sh"
HOOKS_JSON="$(cd "$(dirname "$0")/.." && pwd)/hooks/hooks.json"
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

STUB_PATH=""
run_guard() { # <repo> <command text> → OUT, RC (harness shape: JSON on stdin)
  local repo="$1" cmd="$2" json
  json="$(json_quote "$cmd")"
  OUT="$(printf '{"tool_name":"Bash","tool_input":{"command":%s}}' "$json" \
    | CLAUDE_PROJECT_DIR="$repo" PATH="${STUB_PATH:+$STUB_PATH:}$PATH" bash "$SCRIPT" 2>/dev/null)" && RC=0 || RC=$?
}

expect_silent() { # <desc> — allow path: exit 0, NO output
  if [ "$RC" -eq 0 ] && [ -z "$OUT" ]; then ok "$1"
  else bad "$1 (rc=$RC, out=${OUT:0:120})"; fi
}
expect_decision() { # <desc> <ask|deny> [reason substring]
  local desc="$1" d="$2" sub="${3:-}"
  if [ "$RC" -ne 0 ] || [ -z "$OUT" ]; then bad "$desc (rc=$RC, no decision output)"; return; fi
  if ! printf '%s' "$OUT" | grep -q "\"permissionDecision\": \"$d\""; then
    bad "$desc (wanted $d, got: ${OUT:0:160})"; return
  fi
  if [ -n "$sub" ] && ! printf '%s' "$OUT" | grep -qF "$sub"; then
    bad "$desc (reason missing '$sub': ${OUT:0:200})"; return
  fi
  ok "$desc"
}

make_repo() { # <name> <default-branch> <symref|nosymref> → REPO, on the default branch
  local name="$1" def="$2" sym="$3"
  REPO="$TMP/$name"
  mkdir -p "$REPO"
  git -C "$REPO" init -q
  git -C "$REPO" checkout -q -b "$def"
  git -C "$REPO" -c user.email=t@keel.test -c user.name=t commit -q --allow-empty -m init
  git -C "$REPO" update-ref "refs/remotes/origin/$def" "$(git -C "$REPO" rev-parse HEAD)"
  if [ "$sym" = "symref" ]; then
    git -C "$REPO" symbolic-ref refs/remotes/origin/HEAD "refs/remotes/origin/$def"
  fi
  git -C "$REPO" remote add origin "$REPO"
}

# ---- R1: main default, on a feature branch, NO gate script -------------------
make_repo r1 main symref; R1="$REPO"
git -C "$R1" checkout -q -b feat/work

# 1. The non-trigger matrix: everything here must allow silently.
run_guard "$R1" 'git status';                       expect_silent "non-git-merge command is silent (git status)"
run_guard "$R1" 'ls -la';                           expect_silent "non-git command is silent (ls -la)"
run_guard "$R1" 'git merge-base main HEAD';         expect_silent "git merge-base does not trigger"
run_guard "$R1" 'git merge --abort';                expect_silent "git merge --abort does not trigger"
run_guard "$R1" 'git merge --continue';             expect_silent "git merge --continue does not trigger"
run_guard "$R1" 'git merge --quit';                 expect_silent "git merge --quit does not trigger"
run_guard "$R1" 'git merge feat/other';             expect_silent "branch-to-branch merge does not trigger"
run_guard "$R1" 'git push origin feat/work';        expect_silent "push to a non-default branch does not trigger"
run_guard "$R1" 'git push -u origin hooks-m2-guards'; expect_silent "push -u to a non-default branch does not trigger"

# 2. Merge-shaped but the project has no gate → plain ask naming the gate.
run_guard "$R1" 'git merge main'
expect_decision "merge-shaped without a gate → ask naming it" ask "check-verified-pin.sh"

# ---- R2: main default, feature branch, PASSING gate that records its call ----
make_repo r2 main symref; R2="$REPO"
git -C "$R2" checkout -q -b feat/work
git -C "$R2" checkout -q -b feat-1 && git -C "$R2" checkout -q feat/work
mkdir -p "$R2/scripts"
cat > "$R2/scripts/check-verified-pin.sh" <<'EOF'
#!/usr/bin/env bash
printf '%s|%s\n' "${BASE_REF:-}" "${1:-}" > "$(dirname "$0")/../gate-call.txt"
exit 0
EOF
chmod +x "$R2/scripts/check-verified-pin.sh"

run_guard "$R2" 'git merge main'
expect_decision "git merge <default> + passing gate → ask" ask "verified-pin gate passed"
if [ "$(cat "$R2/gate-call.txt" 2>/dev/null)" = "origin/main|feat/work" ]; then
  ok "gate invoked with BASE_REF=origin/<default> and HEAD_REF=<current branch>"
else
  bad "gate invocation (got: $(cat "$R2/gate-call.txt" 2>/dev/null))"
fi

run_guard "$R2" 'git merge origin/main'
expect_decision "git merge origin/<default> triggers" ask
run_guard "$R2" 'git -C /somewhere/else merge main'
expect_decision "git -C <path> merge <default> (flags before subcommand) triggers" ask
run_guard "$R2" 'git push origin main'
expect_decision "git push origin <default> triggers" ask
run_guard "$R2" 'git push --force-with-lease origin HEAD:main'
expect_decision "git push <flags> origin HEAD:<default> triggers" ask
run_guard "$R2" 'GIT_TRACE=1 git push origin main'
expect_decision "env-var prefix does not hide a push to <default>" ask
run_guard "$R2" 'git commit -m "wip" && git push origin main'
expect_decision "compound command: the merge-shaped segment still triggers" ask

# ---- R3: FAILING gate — deny with the stderr reason passed through -----------
make_repo r3 main symref; R3="$REPO"
git -C "$R3" checkout -q -b feat/work
mkdir -p "$R3/scripts"
cat > "$R3/scripts/check-verified-pin.sh" <<'EOF'
#!/usr/bin/env bash
echo "verified-pin: FAIL — synthetic-reason-7f3 (pinned sha is not an ancestor)" >&2
exit 1
EOF
chmod +x "$R3/scripts/check-verified-pin.sh"

run_guard "$R3" 'git push origin main'
expect_decision "failing gate → deny with the stderr reason verbatim" deny "synthetic-reason-7f3"

# ---- gh pr merge, via a recording stub (no network) --------------------------
mkdir -p "$TMP/bin-ok" "$TMP/bin-fail"
cat > "$TMP/bin-ok/gh" <<EOF
#!/usr/bin/env bash
printf '%s\n' "\$*" > "$TMP/gh-args.txt"
if [ "\${1:-}" = "pr" ] && [ "\${2:-}" = "view" ]; then
  printf '{"baseRefName":"main","headRefName":"feat-1"}\n'
  exit 0
fi
exit 1
EOF
cat > "$TMP/bin-fail/gh" <<'EOF'
#!/usr/bin/env bash
exit 1
EOF
chmod +x "$TMP/bin-ok/gh" "$TMP/bin-fail/gh"

STUB_PATH="$TMP/bin-ok"
run_guard "$R2" 'gh pr merge 123 --squash'
expect_decision "gh pr merge + resolvable PR context + passing gate → ask" ask "verified-pin gate passed"
if grep -q '^pr view 123 ' "$TMP/gh-args.txt" 2>/dev/null; then
  ok "PR context read via gh pr view <arg> --json (arg extracted past flags)"
else
  bad "gh pr view invocation (got: $(cat "$TMP/gh-args.txt" 2>/dev/null))"
fi
run_guard "$R2" 'gh --repo octo/repo pr merge 123'
expect_decision "gh --repo <o/r> pr merge (flags before subcommand) triggers" ask

STUB_PATH="$TMP/bin-fail"
run_guard "$R2" 'gh pr merge 123'
expect_decision "gh pr view unresolvable → plain ask naming the PR context" ask "PR context"
run_guard "$R2" 'gh pr checks 123'
expect_silent "gh non-merge subcommand does not trigger"
STUB_PATH=""

# ---- R4: master fallback (no origin/HEAD symref → main/master probe) ---------
make_repo r4 master nosymref; R4="$REPO"
git -C "$R4" checkout -q -b topic
run_guard "$R4" 'git push origin master'
expect_decision "master-default repo: push to master triggers (probe fallback)" ask
run_guard "$R4" 'git push origin main'
expect_silent "master-default repo: push to a 'main' branch does not trigger"

# ---- shipped shape ------------------------------------------------------------
if [ -x "$SCRIPT" ]; then ok "merge-guard.sh is executable"
else bad "merge-guard.sh is executable"; fi

if grep -q '"PreToolUse"' "$HOOKS_JSON" && grep -q 'merge-guard.sh' "$HOOKS_JSON" \
   && grep -q '"matcher": "Bash"' "$HOOKS_JSON"; then
  ok "hooks.json wires PreToolUse (matcher Bash) to merge-guard.sh"
else bad "hooks.json wires PreToolUse (matcher Bash) to merge-guard.sh"; fi

if grep -qE 'permissionDecision.*"allow"|--arg d "allow"|emit allow' "$SCRIPT"; then
  bad "merge-guard.sh never emits an explicit allow for merge-shaped commands"
else ok "merge-guard.sh never emits an explicit allow for merge-shaped commands"; fi

echo "-------------------------------------"
echo "$pass passed, $failc failed"
[ "$failc" -eq 0 ]
