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

# Fresh/aged ISO-8601 UTC timestamps for marker TTL fixtures (GNU or BSD date).
ts_ago()    { date -u -d "-$1 hours" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -v-"$1"H +%Y-%m-%dT%H:%M:%SZ; }
ts_future() { date -u -d "+$1 hours" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -v+"$1"H +%Y-%m-%dT%H:%M:%SZ; }

json_quote() { # raw string → JSON string literal (house pattern: jq, python3 fallback)
  if command -v jq >/dev/null 2>&1; then printf '%s' "$1" | jq -Rs .
  else printf '%s' "$1" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))'
  fi
}

STUB_PATH=""
run_guard() { # <repo> <command text> → OUT, RC (harness shape: JSON on stdin, NO cwd field)
  local repo="$1" cmd="$2" json
  json="$(json_quote "$cmd")"
  OUT="$(printf '{"tool_name":"Bash","tool_input":{"command":%s}}' "$json" \
    | CLAUDE_PROJECT_DIR="$repo" PATH="${STUB_PATH:+$STUB_PATH:}$PATH" bash "$SCRIPT" 2>/dev/null)" && RC=0 || RC=$?
}

run_guard_cwd() { # <repo(ROOT)> <hook cwd> <command text> → OUT, RC
  # Same harness, but the hook input carries the real PreToolUse `cwd` field —
  # the directory the Bash call runs in, which need not be CLAUDE_PROJECT_DIR.
  local repo="$1" cwd="$2" cmd="$3" json cjson
  json="$(json_quote "$cmd")"
  cjson="$(json_quote "$cwd")"
  OUT="$(printf '{"tool_name":"Bash","cwd":%s,"tool_input":{"command":%s}}' "$cjson" "$json" \
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

# ---- autonomy mode: the --auto allow path + the fail-closed matrix -----------
# Contract under test (documented in merge-guard.sh's header): ONLY a valid
# .claude/keel-autonomy.json + a single plain `gh pr merge ... --auto` + gate
# PASS maps to allow. Every defect — file missing / malformed / unknown level /
# --auto absent or evaded / gate FAIL — yields the pre-mode behavior.

# created is 1h ago — comfortably inside the 24h mode TTL (fixtures below probe
# the 23h/25h boundary explicitly). A hardcoded past date would now read expired.
MODE_JSON="$(printf '{"level":"run","scope":"whole-project","created":"%s","invoker":"human:keel-auto"}' "$(ts_ago 1)")"
write_mode() { # <repo> <json>
  mkdir -p "$1/.claude"
  printf '%s' "$2" > "$1/.claude/keel-autonomy.json"
}

# R5: main default, feature branch, PASSING gate, resolvable PR context (gh stub).
make_repo r5 main symref; R5="$REPO"
git -C "$R5" checkout -q -b feat/work
git -C "$R5" checkout -q -b feat-1 && git -C "$R5" checkout -q feat/work
mkdir -p "$R5/scripts"
printf '#!/usr/bin/env bash\nexit 0\n' > "$R5/scripts/check-verified-pin.sh"
chmod +x "$R5/scripts/check-verified-pin.sh"
STUB_PATH="$TMP/bin-ok"

# Fail-closed row 1: NO mode file — --auto changes nothing, ask-floor holds.
run_guard "$R5" 'gh pr merge 123 --auto --squash'
expect_decision "no mode file: gh pr merge --auto + passing gate → ask (ask-floor)" ask "verified-pin gate passed"

# The one allow row: valid mode + --auto + gate PASS.
write_mode "$R5" "$MODE_JSON"
run_guard "$R5" 'gh pr merge 123 --auto --squash'
expect_decision "valid mode + gh pr merge --auto + passing gate → allow, delegating to required checks" allow "required checks"
run_guard "$R5" 'gh pr merge --auto 123'
expect_decision "flag order does not matter: --auto before the PR arg still allows" allow "required checks"
write_mode "$R5" "$(printf '{"level":"feature","scope":"autonomy-modes","created":"%s","invoker":"human:keel-auto"}' "$(ts_ago 1)")"
run_guard "$R5" 'gh pr merge 123 --auto'
expect_decision "feature-level mode allows and names its level" allow "level: feature"

# genesis-level mode (auto-genesis-m3): identical decision word to run across the
# matrix — only the reason's level token differs. allow / ask / bogus / TTL here;
# gate-FAIL deny in R6 and mode-over-marker precedence in R7 below.
write_mode "$R5" "$(printf '{"level":"genesis","scope":"idea-slug","created":"%s","invoker":"human:keel-auto"}' "$(ts_ago 1)")"
run_guard "$R5" 'gh pr merge 123 --auto'
expect_decision "genesis-level mode + --auto + passing gate → allow, names level: genesis" allow "level: genesis"
run_guard "$R5" 'gh pr merge 123 --squash'
expect_decision "genesis-level mode, no --auto → ask (parity with run)" ask "verified-pin gate passed"
# bogus genesis-adjacent levels → treated absent (whitelist is an EXACT set).
write_mode "$R5" "$(printf '{"level":"genesis ","scope":"x","created":"%s","invoker":"human"}' "$(ts_ago 1)")"
run_guard "$R5" 'gh pr merge 123 --auto'
expect_decision "level \"genesis \" (trailing whitespace) → no mode → ask" ask "verified-pin gate passed"
write_mode "$R5" "$(printf '{"level":"Genesis","scope":"x","created":"%s","invoker":"human"}' "$(ts_ago 1)")"
run_guard "$R5" 'gh pr merge 123 --auto'
expect_decision "level \"Genesis\" (casing variant) → no mode → ask" ask "verified-pin gate passed"
# genesis + expired (>24h) → treated absent, byte-for-byte the no-mode row.
write_mode "$R5" "$(printf '{"level":"genesis","scope":"x","created":"%s","invoker":"human"}' "$(ts_ago 25)")"
run_guard "$R5" 'gh pr merge 123 --auto'
expect_decision "genesis-level + expired created (25h) → treated absent → ask" ask "verified-pin gate passed"
write_mode "$R5" "$MODE_JSON"

# Fail-closed row 2: plain gh pr merge (no --auto) stays ask even under a mode.
run_guard "$R5" 'gh pr merge 123 --squash'
expect_decision "valid mode, no --auto → ask even under mode" ask "verified-pin gate passed"

# Under a mode, the other merge shapes and non-triggers are byte-for-byte today's table.
run_guard "$R5" 'git merge main'
expect_decision "valid mode: git merge <default> stays ask" ask
run_guard "$R5" 'git push origin main'
expect_decision "valid mode: git push <default> stays ask" ask
run_guard "$R5" 'git status'
expect_silent "valid mode: non-merge command stays silent"

# --auto string evasion: none of these may reach allow.
run_guard "$R5" 'gh pr merge 123 --auto --admin'
expect_decision "mode: --admin alongside --auto (branch-protection bypass) → ask" ask
run_guard "$R5" 'gh pr merge 123 --auto=false'
expect_decision "mode: --auto=false is not the delegation shape → ask" ask
run_guard "$R5" 'gh pr merge 123 --subject "ship it --auto"'
expect_decision "mode: --auto inside a quoted string does not count → ask" ask
run_guard "$R5" 'gh pr merge 123 --auto && git push origin main'
expect_decision "mode: chained command never allows → ask" ask
run_guard "$R5" "$(printf 'gh pr merge 123 --auto\ngit push origin main')"
expect_decision "mode: newline-split command never allows → ask" ask
run_guard "$R5" 'gh pr merge 123 `echo --auto`'
expect_decision "mode: expansion-carried --auto never allows → ask" ask

# --auto in a VALUE position: real gh consumes the next token as the flag's
# value, so each of these is a PLAIN merge — none may reach allow.
run_guard "$R5" 'gh pr merge 123 --subject --auto'
expect_decision "mode: --auto as the --subject value → ask" ask "verified-pin gate passed"
run_guard "$R5" 'gh pr merge 123 -t --auto'
expect_decision "mode: --auto as the -t value → ask" ask "verified-pin gate passed"
run_guard "$R5" 'gh pr merge 123 --body --auto'
expect_decision "mode: --auto as the --body value → ask" ask "verified-pin gate passed"
run_guard "$R5" 'gh pr merge 123 -A --auto'
expect_decision "mode: --auto as the -A value → ask" ask "verified-pin gate passed"
run_guard "$R5" 'gh pr merge 123 --body-file --auto'
expect_decision "mode: --auto as the --body-file value → ask" ask "verified-pin gate passed"
run_guard "$R5" 'gh pr merge 123 -F --auto'
expect_decision "mode: --auto as the -F value → ask" ask "verified-pin gate passed"

# The whitelist shape is a CLOSED SET: any token outside it falls to ask —
# clustered short flags, the `--` separator, flags not in the safe set.
run_guard "$R5" 'gh pr merge 123 -s -dt --auto'
expect_decision "mode: clustered short flags (-dt consumes --auto as -t's value) → ask" ask "verified-pin gate passed"
run_guard "$R5" 'gh pr merge -- --auto'
expect_decision "mode: post-`--` --auto is positional, not a flag → ask" ask "verified-pin gate passed"
run_guard "$R5" 'gh pr merge 123 --auto --delete-branch'
expect_decision "mode: --delete-branch is outside the safe set → ask" ask "verified-pin gate passed"

# Positive controls: the genuine delegation shapes still allow.
run_guard "$R5" 'gh pr merge 123 --auto'
expect_decision "mode: genuine flag-position --auto still allows (positive control)" allow "required checks"
run_guard "$R5" 'gh pr merge 123 --auto --rebase'
expect_decision "mode: --auto with a merge-method flag still allows (positive control)" allow "required checks"

# TTL (24h): a mode file aged past 24h → treated absent (ask); one inside the TTL
# → still allows. Full-hour margins (23h/25h) avoid clock-edge flake.
write_mode "$R5" "$(printf '{"level":"run","scope":"x","created":"%s","invoker":"human"}' "$(ts_ago 25)")"
run_guard "$R5" 'gh pr merge 123 --auto'
expect_decision "expired mode file (created 25h ago) → treated absent → ask" ask "verified-pin gate passed"
write_mode "$R5" "$(printf '{"level":"run","scope":"x","created":"%s","invoker":"human"}' "$(ts_ago 23)")"
run_guard "$R5" 'gh pr merge 123 --auto'
expect_decision "fresh mode file (created 23h ago, inside 24h TTL) → allow" allow "required checks"
write_mode "$R5" '{"level":"run","scope":"x","created":"not-a-timestamp","invoker":"human"}'
run_guard "$R5" 'gh pr merge 123 --auto'
expect_decision "mode file with an unparseable created → treated absent → ask" ask "verified-pin gate passed"
write_mode "$R5" "$(printf '{"level":"run","scope":"x","created":"%s","invoker":"human"}' "$(ts_future 5)")"
run_guard "$R5" 'gh pr merge 123 --auto'
expect_decision "mode file with a future-dated created → treated absent → ask" ask "verified-pin gate passed"
write_mode "$R5" "$MODE_JSON" # restore a fresh valid mode for the rows below

# Fail-closed rows 3-5: malformed JSON / unknown level / missing contract field.
write_mode "$R5" '{"level":"run","scope":'
run_guard "$R5" 'gh pr merge 123 --auto'
expect_decision "malformed mode JSON → no mode → ask" ask "verified-pin gate passed"
write_mode "$R5" '{"level":"total","scope":"x","created":"2026-07-02","invoker":"human"}'
run_guard "$R5" 'gh pr merge 123 --auto'
expect_decision "unknown mode level → no mode → ask" ask "verified-pin gate passed"
write_mode "$R5" '{"level":"run","scope":"x","created":"2026-07-02"}'
run_guard "$R5" 'gh pr merge 123 --auto'
expect_decision "mode file missing a contract field (invoker) → no mode → ask" ask "verified-pin gate passed"
write_mode "$R5" '{"level":"run","scope":5,"created":"2026-07-02","invoker":"human"}'
run_guard "$R5" 'gh pr merge 123 --auto'
expect_decision "wrong-typed scope (JSON number) → no mode → ask (jq/python3 parity)" ask "verified-pin gate passed"

# Unresolvable PR context under a valid mode → still ask.
write_mode "$R5" "$MODE_JSON"
STUB_PATH="$TMP/bin-fail"
run_guard "$R5" 'gh pr merge 123 --auto'
expect_decision "valid mode but unresolvable PR context → ask" ask "PR context"
STUB_PATH="$TMP/bin-ok"

# Spoof: a git-TRACKED mode file violates the untracked contract → no mode.
git -C "$R5" add -f .claude/keel-autonomy.json
git -C "$R5" -c user.email=t@keel.test -c user.name=t commit -qm spoof
run_guard "$R5" 'gh pr merge 123 --auto'
expect_decision "git-tracked mode file is a spoof → no mode → ask" ask "verified-pin gate passed"

# Fail-closed row 6: gate FAIL under a valid mode stays deny (R6, failing gate).
make_repo r6 main symref; R6="$REPO"
git -C "$R6" checkout -q -b feat/work
git -C "$R6" checkout -q -b feat-1 && git -C "$R6" checkout -q feat/work
mkdir -p "$R6/scripts"
cat > "$R6/scripts/check-verified-pin.sh" <<'EOF'
#!/usr/bin/env bash
echo "verified-pin: FAIL — synthetic-reason-a2m (pin drift)" >&2
exit 1
EOF
chmod +x "$R6/scripts/check-verified-pin.sh"
write_mode "$R6" "$MODE_JSON"
run_guard "$R6" 'gh pr merge 123 --auto'
expect_decision "valid mode + --auto + FAILING gate → deny with the gate's stderr" deny "synthetic-reason-a2m"
write_mode "$R6" "$(printf '{"level":"genesis","scope":"idea-slug","created":"%s","invoker":"human:keel-auto"}' "$(ts_ago 1)")"
run_guard "$R6" 'gh pr merge 123 --auto'
expect_decision "genesis-level mode + --auto + FAILING gate → deny (parity with run)" deny "synthetic-reason-a2m"
STUB_PATH=""

# ---- attended-merge marker: the per-session --auto unlock --------------------
# Contract (merge-guard.sh header): a valid .claude/keel-attended-merge.json
# (scope="session" + created + invoker) + NO autonomy mode + a bare
# `gh pr merge <pr> --auto` + gate PASS → allow. Plain merge → ask. Gate FAIL →
# deny. Bundled/evaded --auto → ask. Autonomy mode present → attended ignored
# (the mode row governs). Spoof / malformed / wrong-scope → treated absent.

# created 1h ago — inside the 8h attended TTL (the 7h/9h boundary is probed below).
ATT_JSON="$(printf '{"scope":"session","created":"%s","invoker":"human:keel-auto-merge"}' "$(ts_ago 1)")"
write_attended() { # <repo> <json>
  mkdir -p "$1/.claude"
  printf '%s' "$2" > "$1/.claude/keel-attended-merge.json"
}

# R7: main default, feature branch, PASSING gate, resolvable PR context (gh stub).
make_repo r7 main symref; R7="$REPO"
git -C "$R7" checkout -q -b feat/work
git -C "$R7" checkout -q -b feat-1 && git -C "$R7" checkout -q feat/work
mkdir -p "$R7/scripts"
printf '#!/usr/bin/env bash\nexit 0\n' > "$R7/scripts/check-verified-pin.sh"
chmod +x "$R7/scripts/check-verified-pin.sh"
STUB_PATH="$TMP/bin-ok"

# Marker absent → today's ask-floor (regression: unchanged by this milestone).
run_guard "$R7" 'gh pr merge 123 --auto --squash'
expect_decision "no attended marker: --auto + gate pass → ask (ask-floor unchanged)" ask "verified-pin gate passed"

# The one attended allow row: valid marker + bare --auto + gate PASS.
write_attended "$R7" "$ATT_JSON"
run_guard "$R7" 'gh pr merge 123 --auto --squash'
expect_decision "attended marker + gh pr merge --auto + passing gate → allow" allow "attended auto-merge active"
run_guard "$R7" 'gh pr merge --auto 123'
expect_decision "attended: flag order does not matter → allow, delegating to required checks" allow "required checks"
run_guard "$R7" 'gh pr merge 123 --auto --rebase'
expect_decision "attended: --auto with a merge-method flag still allows (positive control)" allow "attended auto-merge active"

# Plain gh pr merge (no --auto) stays ask even under the marker.
run_guard "$R7" 'gh pr merge 123 --squash'
expect_decision "attended marker, no --auto → ask" ask "verified-pin gate passed"

# Bundled / evaded --auto under the marker → ask (only the bare shape unlocks).
run_guard "$R7" 'gh pr merge 123 --auto && echo done'
expect_decision "attended: chained --auto never allows → ask" ask
run_guard "$R7" 'gh pr merge 123 --auto --admin'
expect_decision "attended: --admin alongside --auto → ask" ask
run_guard "$R7" 'gh pr merge 123 --subject "ship it --auto"'
expect_decision "attended: --auto inside a quoted string does not count → ask" ask

# Other merge shapes / non-triggers are byte-for-byte today's table under the marker.
run_guard "$R7" 'git merge main'
expect_decision "attended marker: git merge <default> stays ask" ask
run_guard "$R7" 'git push origin main'
expect_decision "attended marker: git push <default> stays ask" ask
run_guard "$R7" 'git status'
expect_silent "attended marker: non-merge command stays silent"

# TTL (8h): a marker aged past 8h → treated absent (ask); one inside the TTL
# (7h) → still allows. 7h/9h give a full hour of margin around the 8h bound.
write_attended "$R7" "$(printf '{"scope":"session","created":"%s","invoker":"human:keel-auto-merge"}' "$(ts_ago 9)")"
run_guard "$R7" 'gh pr merge 123 --auto'
expect_decision "expired attended marker (created 9h ago) → treated absent → ask" ask "verified-pin gate passed"
write_attended "$R7" "$(printf '{"scope":"session","created":"%s","invoker":"human:keel-auto-merge"}' "$(ts_ago 7)")"
run_guard "$R7" 'gh pr merge 123 --auto'
expect_decision "fresh attended marker (created 7h ago, inside 8h TTL) → allow" allow "attended auto-merge active"
write_attended "$R7" '{"scope":"session","created":"not-a-timestamp","invoker":"human:keel-auto-merge"}'
run_guard "$R7" 'gh pr merge 123 --auto'
expect_decision "attended marker with an unparseable created → treated absent → ask" ask "verified-pin gate passed"
write_attended "$R7" "$(printf '{"scope":"session","created":"%s","invoker":"human:keel-auto-merge"}' "$(ts_future 5)")"
run_guard "$R7" 'gh pr merge 123 --auto'
expect_decision "attended marker with a future-dated created → treated absent → ask" ask "verified-pin gate passed"

# Malformed / partial / wrong-scope / wrong-typed → treated absent → ask.
write_attended "$R7" '{"scope":"session","created":'
run_guard "$R7" 'gh pr merge 123 --auto'
expect_decision "malformed attended marker JSON → treated absent → ask" ask "verified-pin gate passed"
write_attended "$R7" '{"scope":"project","created":"c","invoker":"i"}'
run_guard "$R7" 'gh pr merge 123 --auto'
expect_decision "attended marker scope != session → treated absent → ask" ask "verified-pin gate passed"
write_attended "$R7" '{"scope":"session","created":"c"}'
run_guard "$R7" 'gh pr merge 123 --auto'
expect_decision "attended marker missing invoker → treated absent → ask" ask "verified-pin gate passed"
write_attended "$R7" '{"scope":5,"created":"c","invoker":"i"}'
run_guard "$R7" 'gh pr merge 123 --auto'
expect_decision "attended marker wrong-typed scope (number) → treated absent → ask (jq/python3 parity)" ask "verified-pin gate passed"

# Autonomy precedence: a valid mode file present → the attended marker is IGNORED,
# the mode row governs (still allow here, but with the MODE reason, not attended).
write_attended "$R7" "$ATT_JSON"
write_mode "$R7" "$MODE_JSON"
run_guard "$R7" 'gh pr merge 123 --auto'
expect_decision "attended + valid autonomy mode both active → mode governs (allow, mode reason)" allow "autonomy mode active"
# same precedence with a genesis-level mode: marker ignored, mode row governs and
# names level: genesis (auto-genesis-m3 — precedence rule unchanged by the new level).
write_mode "$R7" "$(printf '{"level":"genesis","scope":"idea-slug","created":"%s","invoker":"human:keel-auto"}' "$(ts_ago 1)")"
run_guard "$R7" 'gh pr merge 123 --auto'
expect_decision "attended + genesis-level mode both active → mode governs (allow, level: genesis)" allow "level: genesis"
rm -f "$R7/.claude/keel-autonomy.json"

# Spoof: a git-TRACKED attended marker violates the untracked contract → absent.
write_attended "$R7" "$ATT_JSON"
git -C "$R7" add -f .claude/keel-attended-merge.json
git -C "$R7" -c user.email=t@keel.test -c user.name=t commit -qm spoof-attended
run_guard "$R7" 'gh pr merge 123 --auto'
expect_decision "git-tracked attended marker is a spoof → treated absent → ask" ask "verified-pin gate passed"

# Gate FAIL under a valid attended marker stays deny (R8, failing gate).
make_repo r8 main symref; R8="$REPO"
git -C "$R8" checkout -q -b feat/work
git -C "$R8" checkout -q -b feat-1 && git -C "$R8" checkout -q feat/work
mkdir -p "$R8/scripts"
cat > "$R8/scripts/check-verified-pin.sh" <<'EOF'
#!/usr/bin/env bash
echo "verified-pin: FAIL — synthetic-reason-att9 (pin drift)" >&2
exit 1
EOF
chmod +x "$R8/scripts/check-verified-pin.sh"
write_attended "$R8" "$ATT_JSON"
run_guard "$R8" 'gh pr merge 123 --auto'
expect_decision "attended marker + --auto + FAILING gate → deny with the gate's stderr" deny "synthetic-reason-att9"
STUB_PATH=""

# ---- accepted classifier bypasses: ASSERTED, not closed ------------------------
# These shapes are out of classification reach BY DESIGN: the guard is a text
# classifier and cannot see through shell reassembly (`sh -c`, `eval`, piped
# `xargs`) — the documented inherent limit; branch protection + required checks
# are the authority, not this hook. This block pins TODAY'S behavior — each shape
# is unclassified and allowed silently — as the ACCEPTED LIMIT, not a target to
# close: a future edit that silently changes classification on these shapes must
# fail here and become a conscious suite edit. R1 has no gate script, so a
# classified merge shape would emit "ask" — silence proves unclassified.
run_guard "$R1" "sh -c 'gh pr merge 5'"
expect_silent "accepted limit: sh -c wrapped merge is unclassified (silent allow)"
run_guard "$R1" "bash -lc 'gh pr merge 5'"
expect_silent "accepted limit: bash -lc wrapped merge is unclassified (silent allow)"
run_guard "$R1" 'eval "gh pr merge 5"'
expect_silent "accepted limit: eval-carried merge is unclassified (silent allow)"
run_guard "$R1" 'echo 5 | xargs gh pr merge'
expect_silent "accepted limit: piped-xargs merge is unclassified (silent allow)"

# ---- linked worktree: git state comes from the hook's cwd (GIT_CTX) ------------
# The structurally-missing class: every case above sets CLAUDE_PROJECT_DIR EQUAL to
# the checkout under test, so the worktree mismatch — the Bash call runs in the
# worktree on a feature branch while CLAUDE_PROJECT_DIR still points at the main
# checkout on the default branch — could never be observed. Asserted at the two
# OBSERVABLE seams: push CLASSIFICATION (which reads HEAD) and, for merge-shaped
# commands, the DECISION PATH — the refs decide() resolves and the directory the
# pin gate runs in. Merge-shape classification itself is HEAD-independent by
# design (`git merge main` names the default branch outright), so it triggers from
# either cwd; only the decision path below can show which checkout was judged.

make_repo r9 main symref; R9="$REPO"                # main checkout, sitting on main
git -C "$R9" checkout -q -b feat-1                  # the PR head branch the gh stub reports
git -C "$R9" checkout -q main
WT9="$TMP/wt9-feature"                              # linked worktree, feature branch
git -C "$R9" worktree add -b wt/milestone "$WT9" >/dev/null 2>&1
mkdir -p "$R9/scripts"
cat > "$R9/scripts/check-verified-pin.sh" <<'EOF'
#!/usr/bin/env bash
printf '%s|%s|%s\n' "${BASE_REF:-}" "${1:-}" "$PWD" > "$(dirname "$0")/../gate-call.txt"
exit 0
EOF
chmod +x "$R9/scripts/check-verified-pin.sh"
NOGIT9="$TMP/not-a-repo-9"; mkdir -p "$NOGIT9"      # a directory outside any work tree
GONE9="$TMP/nonexistent-dir-9"                      # never created

expect_gate_call() { # <desc> <expected "BASE|HEAD|pwd">
  local got; got="$(cat "$R9/gate-call.txt" 2>/dev/null)"
  if [ "$got" = "$2" ]; then ok "$1"
  else bad "$1 (gate call: got '$got', want '$2')"; fi
}

# (i) push CLASSIFICATION resolves the worktree's HEAD: a bare `git push` from the
#     worktree is not a push to the default branch → silent allow; the SAME command
#     with cwd absent falls back to ROOT (on main) and classifies as today → ask.
run_guard_cwd "$R9" "$WT9" 'git push'
expect_silent "worktree cwd: bare git push (implicit feature branch) is not merge-shaped"
run_guard "$R9" 'git push'
expect_decision "no cwd field: bare git push from ROOT on the default branch → ask" ask "verified-pin gate passed"
expect_gate_call "no cwd field: gate judged the ROOT checkout (HEAD=main, run in ROOT)" "origin/main|main|$R9"
run_guard_cwd "$R9" "$WT9" 'git push origin main'
expect_decision "worktree cwd: an EXPLICIT push to the default branch still triggers" ask

# (ii) merge-shaped from the worktree: classification is HEAD-independent, so the
#      DECISION PATH is the seam — decide()'s resolved HEAD_REF_R is the worktree's
#      branch and the pin gate runs IN the worktree, while the gate SCRIPT's path
#      still comes from ROOT.
run_guard_cwd "$R9" "$WT9" 'git merge main'
expect_decision "worktree cwd: git merge <default> → ask (gate consulted)" ask "verified-pin gate passed"
expect_gate_call "worktree cwd: gate got HEAD_REF=<worktree branch> and ran in the worktree" "origin/main|wt/milestone|$WT9"
run_guard "$R9" 'git merge main'
expect_decision "no cwd field: git merge <default> → ask (unchanged)" ask "verified-pin gate passed"
expect_gate_call "no cwd field: gate got HEAD_REF=main and ran in ROOT (today's resolution)" "origin/main|main|$R9"

# (iii)/(iv) An unusable cwd degrades to the ROOT resolution — never to silence.
run_guard_cwd "$R9" "$NOGIT9" 'git merge main'
expect_decision "cwd outside any git work tree → fallback to ROOT → ask" ask "verified-pin gate passed"
expect_gate_call "cwd outside a work tree: gate judged ROOT (HEAD=main, run in ROOT)" "origin/main|main|$R9"
run_guard_cwd "$R9" "$GONE9" 'git push'
expect_decision "nonexistent cwd → fallback to ROOT → bare push classifies as today (ask)" ask "verified-pin gate passed"
run_guard_cwd "$R9" "" 'git push'
expect_decision "empty cwd string → fallback to ROOT → bare push classifies as today (ask)" ask "verified-pin gate passed"

# Markers stay project-rooted while git state follows cwd: the attended marker is
# read from ROOT/.claude even when the merge is judged from the worktree, and a
# marker planted in the WORKTREE's .claude/ is not read at all.
STUB_PATH="$TMP/bin-ok"
write_attended "$R9" "$ATT_JSON"
run_guard_cwd "$R9" "$WT9" 'gh pr merge 123 --auto'
expect_decision "marker at ROOT + worktree cwd → the attended row still fires (marker read from ROOT)" allow "attended auto-merge active"
rm -f "$R9/.claude/keel-attended-merge.json"
write_attended "$WT9" "$ATT_JSON"
run_guard_cwd "$R9" "$WT9" 'gh pr merge 123 --auto'
expect_decision "marker only in the worktree's .claude → not read → ask (markers are ROOT-rooted)" ask "verified-pin gate passed"
rm -rf "$WT9/.claude"
STUB_PATH=""

# ---- committed per-project auto-merge marker --------------------------------
# Contract (merge-guard.sh header): a marker committed to the DEFAULT BRANCH
# (.claude/keel-auto-merge.json, scope="project" + created + invoker), read ONLY
# from origin/<default> (never the working tree, never BASE_REF_R) + NO mode + NO
# attended marker + a bare `gh pr merge <pr> --auto` + gate PASS → allow. Plain →
# ask. Gate FAIL → deny. A PR that TOUCHES the marker → ask (human-tap rule,
# before every allow row). Working-tree-only / not-on-default-branch → absent.
# Precedence: mode > attended > committed.

# A gh stub mapping the PR arg to a head branch so one repo exercises a clean PR
# (123 → feat-clean), a marker-TOUCHING PR (777 → feat-marker), and an
# unrelated-history PR (888 → feat-unrelated, no merge base → indeterminate diff).
mkdir -p "$TMP/bin-committed"
cat > "$TMP/bin-committed/gh" <<EOF
#!/usr/bin/env bash
printf '%s\n' "\$*" > "$TMP/gh-args.txt"
# repo view → the SERVER default branch (read_committed_marker's root of trust; the
# stub answers the bare name, matching production's --jq '.defaultBranchRef.name').
if [ "\${1:-}" = "repo" ] && [ "\${2:-}" = "view" ]; then
  printf '%s\n' "\${STUB_DEFAULT_BRANCH:-main}"
  exit 0
fi
if [ "\${1:-}" = "pr" ] && [ "\${2:-}" = "view" ]; then
  head=feat-clean
  for a in "\$@"; do case "\$a" in 777) head=feat-marker ;; 888) head=feat-unrelated ;; 999) head=feat-arm ;; esac; done
  printf '{"baseRefName":"main","headRefName":"%s"}\n' "\$head"
  exit 0
fi
exit 1
EOF
chmod +x "$TMP/bin-committed/gh"

# created 1h ago — committed markers carry NO TTL, but `created` is a required,
# non-empty field, so use a real timestamp.
COMMIT_JSON="$(printf '{"scope":"project","created":"%s","invoker":"human:keel-arm-auto-merge"}' "$(ts_ago 1)")"
arm_committed() { # <repo> <json> — commit the marker onto refs/heads/main so origin/main carries it
  local repo="$1" json="$2" cur
  cur="$(git -C "$repo" rev-parse --abbrev-ref HEAD)"
  git -C "$repo" checkout -q main
  mkdir -p "$repo/.claude"
  printf '%s' "$json" > "$repo/.claude/keel-auto-merge.json"
  git -C "$repo" add -f .claude/keel-auto-merge.json
  git -C "$repo" -c user.email=t@keel.test -c user.name=t commit -qm "arm committed auto-merge"
  git -C "$repo" update-ref refs/remotes/origin/main "$(git -C "$repo" rev-parse HEAD)"
  git -C "$repo" checkout -q "$cur" # the marker file leaves the working tree — honor must come from origin/main
}

# R10: main default; a clean feature branch, a marker-touching branch, an orphan
# branch; marker armed on main; passing gate. Gate script is created LAST so the
# orphan's `git clean` never removes it.
make_repo r10 main symref; R10="$REPO"
git -C "$R10" checkout -q -b feat-clean
echo code > "$R10/src.txt"; git -C "$R10" add -f src.txt
git -C "$R10" -c user.email=t@keel.test -c user.name=t commit -qm "feat-clean work"
git -C "$R10" checkout -q -b feat-marker main
mkdir -p "$R10/.claude"; printf '%s' "$COMMIT_JSON" > "$R10/.claude/keel-auto-merge.json"
git -C "$R10" add -f .claude/keel-auto-merge.json
git -C "$R10" -c user.email=t@keel.test -c user.name=t commit -qm "arm via PR (marker-touching)"
git -C "$R10" checkout -q --orphan feat-unrelated
git -C "$R10" rm -rf --cached . >/dev/null 2>&1 || true
git -C "$R10" clean -fdq 2>/dev/null || true
echo x > "$R10/orphan.txt"; git -C "$R10" add -f orphan.txt
git -C "$R10" -c user.email=t@keel.test -c user.name=t commit -qm orphan
git -C "$R10" checkout -q feat-clean
arm_committed "$R10" "$COMMIT_JSON"
mkdir -p "$R10/scripts"; printf '#!/usr/bin/env bash\nexit 0\n' > "$R10/scripts/check-verified-pin.sh"; chmod +x "$R10/scripts/check-verified-pin.sh"
STUB_PATH="$TMP/bin-committed"

# The one committed allow row: valid marker on main + clean PR + bare --auto + gate PASS.
run_guard "$R10" 'gh pr merge 123 --auto'
expect_decision "committed marker on main + clean PR + --auto + gate pass → allow" allow "committed per-project auto-merge active"
run_guard "$R10" 'gh pr merge --auto 123'
expect_decision "committed: flag order does not matter → allow (delegates to required checks)" allow "required checks"
run_guard "$R10" 'gh pr merge 123 --auto --rebase'
expect_decision "committed: --auto with a merge-method flag still allows (positive control)" allow "committed per-project auto-merge active"

# Plain gh pr merge (no --auto) stays ask under the committed marker.
run_guard "$R10" 'gh pr merge 123 --squash'
expect_decision "committed marker, no --auto → ask" ask "verified-pin gate passed"
# Bundled / chained --auto → ask (only the bare shape unlocks).
run_guard "$R10" 'gh pr merge 123 --auto && echo done'
expect_decision "committed: chained --auto never allows → ask" ask

# HUMAN-TAP RULE: a marker-touching PR → ask even with a valid marker + passing gate.
run_guard "$R10" 'gh pr merge 777 --auto'
expect_decision "committed + marker-touching PR → ask (human-tap, before every allow row)" ask "human merge tap"
# Indeterminate file list (no merge base) → ask, fail closed.
run_guard "$R10" 'gh pr merge 888 --auto'
expect_decision "committed + indeterminate PR diff (no merge base) → ask (fail closed)" ask

# Other merge shapes / non-triggers byte-for-byte today's table under the committed marker.
run_guard "$R10" 'git merge main'
expect_decision "committed marker: git merge <default> stays ask" ask
run_guard "$R10" 'git push origin main'
expect_decision "committed marker: git push <default> stays ask" ask
run_guard "$R10" 'git status'
expect_silent "committed marker: non-merge command stays silent"

# PRECEDENCE mode > attended > committed. Add an attended marker → attended governs.
write_attended "$R10" "$ATT_JSON"
run_guard "$R10" 'gh pr merge 123 --auto'
expect_decision "committed + attended both active → attended governs (allow, attended reason)" allow "attended auto-merge active"
# Add a mode → mode governs over both.
write_mode "$R10" "$MODE_JSON"
run_guard "$R10" 'gh pr merge 123 --auto'
expect_decision "committed + attended + mode all active → mode governs (allow, mode reason)" allow "autonomy mode active"
# The human-tap rule fires even under an active mode: a marker-touching PR → ask.
run_guard "$R10" 'gh pr merge 777 --auto'
expect_decision "marker-touching PR under an active mode → ask (human-tap before every allow row)" ask "human merge tap"
rm -f "$R10/.claude/keel-autonomy.json" "$R10/.claude/keel-attended-merge.json"

# Invalid committed markers on the default branch → treated absent → ask floor.
arm_committed "$R10" '{"scope":"session","created":"2026-08-02T00:00:00Z","invoker":"i"}'
run_guard "$R10" 'gh pr merge 123 --auto'
expect_decision "committed marker scope != project → treated absent → ask" ask "verified-pin gate passed"
arm_committed "$R10" '{"scope":"project","created":"2026-08-02T00:00:00Z"}'
run_guard "$R10" 'gh pr merge 123 --auto'
expect_decision "committed marker missing invoker → treated absent → ask" ask "verified-pin gate passed"
arm_committed "$R10" '{"scope":"project","created":'
run_guard "$R10" 'gh pr merge 123 --auto'
expect_decision "malformed committed marker JSON → treated absent → ask" ask "verified-pin gate passed"
arm_committed "$R10" '{"scope":5,"created":"2026-08-02T00:00:00Z","invoker":"i"}'
run_guard "$R10" 'gh pr merge 123 --auto'
expect_decision "committed marker wrong-typed scope (number) → treated absent → ask (jq/python3 parity)" ask "verified-pin gate passed"

# R11: gate FAIL under a valid committed marker → deny (gate FAIL beats committed).
make_repo r11 main symref; R11="$REPO"
git -C "$R11" checkout -q -b feat-clean
echo code > "$R11/src.txt"; git -C "$R11" add -f src.txt
git -C "$R11" -c user.email=t@keel.test -c user.name=t commit -qm "feat-clean work"
arm_committed "$R11" "$COMMIT_JSON"
mkdir -p "$R11/scripts"
cat > "$R11/scripts/check-verified-pin.sh" <<'EOF'
#!/usr/bin/env bash
echo "verified-pin: FAIL — synthetic-reason-cm3 (pin drift)" >&2
exit 1
EOF
chmod +x "$R11/scripts/check-verified-pin.sh"
run_guard "$R11" 'gh pr merge 123 --auto'
expect_decision "committed marker + --auto + FAILING gate → deny with the gate's stderr" deny "synthetic-reason-cm3"

# R12: the marker in the WORKING TREE but NOT on the default branch → absent → ask.
make_repo r12 main symref; R12="$REPO"
git -C "$R12" checkout -q -b feat-clean
echo code > "$R12/src.txt"; git -C "$R12" add -f src.txt
git -C "$R12" -c user.email=t@keel.test -c user.name=t commit -qm "feat-clean work"
mkdir -p "$R12/scripts"; printf '#!/usr/bin/env bash\nexit 0\n' > "$R12/scripts/check-verified-pin.sh"; chmod +x "$R12/scripts/check-verified-pin.sh"
mkdir -p "$R12/.claude"; printf '%s' "$COMMIT_JSON" > "$R12/.claude/keel-auto-merge.json" # working tree only, never on main
run_guard "$R12" 'gh pr merge 123 --auto'
expect_decision "committed marker in the working tree but NOT on the default branch → absent → ask (root of trust)" ask "verified-pin gate passed"

# ---- security-review regression: the four self-arm / tap-evasion paths ---------
# Each proves a control the pre-pin review found MISSING now holds. All use the
# committed gh stub (repo view → server default branch "main"; pr view → head).
ATT_JSON_CM="$(printf '{"scope":"session","created":"%s","invoker":"human:keel-auto-merge"}' "$(ts_ago 1)")"

# (Finding 1) origin/HEAD is agent-repointable, so it must NOT be the root of trust.
# main carries NO marker; a side branch `evil` does, and refs/remotes/origin/HEAD is
# repointed at it. gh repo view still reports main → marker absent → ask. (The old
# origin/HEAD-based read would have armed here.)
make_repo r13a main symref; R13A="$REPO"
git -C "$R13A" checkout -q -b feat-clean
echo code > "$R13A/src.txt"; git -C "$R13A" add -f src.txt
git -C "$R13A" -c user.email=t@keel.test -c user.name=t commit -qm "feat-clean work"
git -C "$R13A" checkout -q -b evil main
mkdir -p "$R13A/.claude"; printf '%s' "$COMMIT_JSON" > "$R13A/.claude/keel-auto-merge.json"
git -C "$R13A" add -f .claude/keel-auto-merge.json
git -C "$R13A" -c user.email=t@keel.test -c user.name=t commit -qm "plant marker on evil"
git -C "$R13A" update-ref refs/remotes/origin/evil "$(git -C "$R13A" rev-parse evil)"
git -C "$R13A" symbolic-ref refs/remotes/origin/HEAD refs/remotes/origin/evil # the repoint
git -C "$R13A" checkout -q feat-clean
mkdir -p "$R13A/scripts"; printf '#!/usr/bin/env bash\nexit 0\n' > "$R13A/scripts/check-verified-pin.sh"; chmod +x "$R13A/scripts/check-verified-pin.sh"
STUB_PATH="$TMP/bin-committed"
run_guard "$R13A" 'gh pr merge 123 --auto'
expect_decision "finding 1: origin/HEAD repointed at a marker branch → still absent (gh reports main) → ask" ask "verified-pin gate passed"

# (Finding 2a) A FORGED local refs/remotes/origin/main carrying the marker, while
# refs/heads/main (the real origin content) has none. The MANDATORY fetch overwrites
# the forged tracking ref with real main → absent → ask.
make_repo r13b main symref; R13B="$REPO"
git -C "$R13B" checkout -q -b feat-clean
echo code > "$R13B/src.txt"; git -C "$R13B" add -f src.txt
git -C "$R13B" -c user.email=t@keel.test -c user.name=t commit -qm "feat-clean work"
git -C "$R13B" checkout -q -b forge main
mkdir -p "$R13B/.claude"; printf '%s' "$COMMIT_JSON" > "$R13B/.claude/keel-auto-merge.json"
git -C "$R13B" add -f .claude/keel-auto-merge.json
git -C "$R13B" -c user.email=t@keel.test -c user.name=t commit -qm "forged marker commit"
git -C "$R13B" update-ref refs/remotes/origin/main "$(git -C "$R13B" rev-parse forge)" # forge the tracking ref
git -C "$R13B" checkout -q feat-clean
mkdir -p "$R13B/scripts"; printf '#!/usr/bin/env bash\nexit 0\n' > "$R13B/scripts/check-verified-pin.sh"; chmod +x "$R13B/scripts/check-verified-pin.sh"
run_guard "$R13B" 'gh pr merge 123 --auto'
expect_decision "finding 2a: forged origin/main tracking ref → overwritten by mandatory fetch → absent → ask" ask "verified-pin gate passed"

# (Finding 2b) Same forge, but origin is UNREACHABLE. The mandatory fetch fails →
# NO fallback to the forged local ref → never allow. (Both the marker read and
# pr_touches_marker fail closed under an unreachable origin.)
make_repo r13c main symref; R13C="$REPO"
git -C "$R13C" checkout -q -b feat-clean
echo code > "$R13C/src.txt"; git -C "$R13C" add -f src.txt
git -C "$R13C" -c user.email=t@keel.test -c user.name=t commit -qm "feat-clean work"
git -C "$R13C" checkout -q -b forge main
mkdir -p "$R13C/.claude"; printf '%s' "$COMMIT_JSON" > "$R13C/.claude/keel-auto-merge.json"
git -C "$R13C" add -f .claude/keel-auto-merge.json
git -C "$R13C" -c user.email=t@keel.test -c user.name=t commit -qm "forged marker commit"
git -C "$R13C" update-ref refs/remotes/origin/main "$(git -C "$R13C" rev-parse forge)"
git -C "$R13C" checkout -q feat-clean
git -C "$R13C" remote set-url origin "$TMP/nonexistent-origin-r13c" # unreachable
mkdir -p "$R13C/scripts"; printf '#!/usr/bin/env bash\nexit 0\n' > "$R13C/scripts/check-verified-pin.sh"; chmod +x "$R13C/scripts/check-verified-pin.sh"
run_guard "$R13C" 'gh pr merge 123 --auto'
expect_decision "finding 2b: forged ref + UNREACHABLE origin → fetch fails, no local fallback → ask (never allow)" ask

# (Finding 3) A stale local PR-head ref hides a marker just pushed onto the PR.
# main has NO marker; a TEMPORARY attended authority is active; the PR head `feat-arm`
# on origin ADDS the marker, but refs/remotes/origin/feat-arm is stale (pre-marker).
# The mandatory head fetch refreshes → marker seen → human-tap ask (not attended allow).
make_repo r13d main symref; R13D="$REPO"
git -C "$R13D" checkout -q -b feat-arm main
echo x > "$R13D/f.txt"; git -C "$R13D" add -f f.txt
git -C "$R13D" -c user.email=t@keel.test -c user.name=t commit -qm "feat-arm (pre-marker)"
git -C "$R13D" update-ref refs/remotes/origin/feat-arm "$(git -C "$R13D" rev-parse feat-arm)" # STALE tracking ref
mkdir -p "$R13D/.claude"; printf '%s' "$COMMIT_JSON" > "$R13D/.claude/keel-auto-merge.json"
git -C "$R13D" add -f .claude/keel-auto-merge.json
git -C "$R13D" -c user.email=t@keel.test -c user.name=t commit -qm "arm via PR: add marker (server advance)"
git -C "$R13D" checkout -q main
mkdir -p "$R13D/scripts"; printf '#!/usr/bin/env bash\nexit 0\n' > "$R13D/scripts/check-verified-pin.sh"; chmod +x "$R13D/scripts/check-verified-pin.sh"
write_attended "$R13D" "$ATT_JSON_CM"
run_guard "$R13D" 'gh pr merge 999 --auto'
expect_decision "finding 3: stale head hides a just-pushed marker → mandatory fetch reveals it → human-tap ask" ask "human merge tap"

# (Finding 4) diff.relative=true + a subdirectory GIT_CTX would drop the out-of-prefix
# marker from the file list. With diff.relative pinned OFF the marker is still seen.
# main armed (valid marker); PR 777 (feat-marker) touches the marker; hook cwd = a subdir.
make_repo r13e main symref; R13E="$REPO"
git -C "$R13E" checkout -q -b feat-clean
echo code > "$R13E/src.txt"; git -C "$R13E" add -f src.txt
git -C "$R13E" -c user.email=t@keel.test -c user.name=t commit -qm "feat-clean work"
git -C "$R13E" checkout -q -b feat-marker main
mkdir -p "$R13E/.claude"; printf '%s' "$COMMIT_JSON" > "$R13E/.claude/keel-auto-merge.json"
git -C "$R13E" add -f .claude/keel-auto-merge.json
git -C "$R13E" -c user.email=t@keel.test -c user.name=t commit -qm "arm via PR (marker-touching)"
git -C "$R13E" checkout -q feat-clean
arm_committed "$R13E" "$COMMIT_JSON"
mkdir -p "$R13E/scripts"; printf '#!/usr/bin/env bash\nexit 0\n' > "$R13E/scripts/check-verified-pin.sh"; chmod +x "$R13E/scripts/check-verified-pin.sh"
git -C "$R13E" config diff.relative true # the finding-4 lever
mkdir -p "$R13E/sub"
run_guard_cwd "$R13E" "$R13E/sub" 'gh pr merge 777 --auto'
expect_decision "finding 4: diff.relative=true + subdir GIT_CTX → pinned off → marker still seen → human-tap ask" ask "human merge tap"
STUB_PATH=""

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

if grep -q 'keel-autonomy.json' "$SCRIPT" && grep -qi 'fail closed' "$SCRIPT" \
   && grep -q 'keel:auto' "$SCRIPT"; then
  ok "mode-file contract is documented in the guard header (path, writer, fail-closed)"
else bad "mode-file contract is documented in the guard header (path, writer, fail-closed)"; fi

if grep -q 'keel-attended-merge.json' "$SCRIPT" && grep -q 'keel:auto-merge' "$SCRIPT" \
   && grep -qi 'precedence\|ignored when' "$SCRIPT"; then
  ok "attended-marker contract is documented in the guard header (path, writer, autonomy precedence)"
else bad "attended-marker contract is documented in the guard header (path, writer, autonomy precedence)"; fi

# Accepted-limits header tripwire (m2): the classification comment must name the
# reassembly shapes the bypass block asserts — including eval — and the authority
# sentence must name branch protection + required checks. Pins the prose to the
# asserted behavior so neither drifts alone.
if grep -qF 'sh -c' "$SCRIPT" && grep -qF '`eval`' "$SCRIPT" \
   && grep -qF 'xargs' "$SCRIPT" \
   && grep -qF 'branch protection + required checks' "$SCRIPT"; then
  ok "accepted-limits paragraph names sh -c/eval/xargs and the branch-protection + required-checks authority"
else bad "accepted-limits paragraph names sh -c/eval/xargs and the branch-protection + required-checks authority"; fi

# TTL contract tripwire: both TTLs (24h/8h), the expired≡absent rule, and the
# no-refresh rule must stay documented in the header (parity with the milestone).
if grep -qF 'TTL (24h)' "$SCRIPT" && grep -qF 'TTL (8h)' "$SCRIPT" \
   && grep -qiF 'as absent' "$SCRIPT" \
   && grep -qiF 'NO REFRESH PATH' "$SCRIPT" \
   && grep -qiF 'fresh human invocation' "$SCRIPT"; then
  ok "TTL contract is documented in the guard header (24h/8h, expired≡absent, no-refresh)"
else bad "TTL contract is documented in the guard header (24h/8h, expired≡absent, no-refresh)"; fi

echo "-------------------------------------"
echo "$pass passed, $failc failed"
[ "$failc" -eq 0 ]
