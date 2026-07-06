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
