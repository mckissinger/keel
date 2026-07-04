#!/usr/bin/env bash
#
# attended-marker-parity.test.sh — cross-script parity for the attended-merge
# marker. merge-guard.sh (the marker's reading owner) and guard-branch-rules.sh
# duplicate the marker reader per the self-contained-hook idiom; this asserts the
# two NEVER diverge: given the SAME fixture marker they reach the SAME conclusion
# on a bare `gh pr merge <pr> --auto`, and they agree across BOTH field readers
# (jq, and a jq-hidden python3-only PATH).
#
# "Same conclusion" is the unlock decision each script owns:
#   merge-guard.sh:        allow (marker honored)  vs  ask   (marker absent)
#   guard-branch-rules.sh: exit 0 / silent (defer) vs  exit 2 (refuse)
# A valid marker → both UNLOCK. A spoof / malformed marker → both GATE.
#
# Run: bash scripts/attended-marker-parity.test.sh

set -uo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
MG="$HERE/merge-guard.sh"
BG="$HERE/guard-branch-rules.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

pass=0 failc=0
ok()  { echo "ok   - $1"; pass=$((pass + 1)); }
bad() { echo "FAIL - $1"; failc=$((failc + 1)); }

json_quote() { # raw string → JSON string literal (jq, python3 fallback)
  if command -v jq >/dev/null 2>&1; then printf '%s' "$1" | jq -Rs .
  else printf '%s' "$1" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))'; fi
}

# --- a jq-hidden sandbox PATH that forces the python3 reader -------------------
# Symlink a curated set of REAL tools (resolved from the current PATH) into a
# sandbox dir, deliberately OMITTING jq, so `command -v jq` fails and both
# scripts fall to their python3 field reader. gh (a recording stub) lives here
# too so merge-guard can resolve PR context under the sandbox.
SANDBOX="$TMP/sandbox-bin"
mkdir -p "$SANDBOX"
for tool in bash sh env git grep cat tr rm mktemp dirname sed awk cut python3; do
  p="$(command -v "$tool" 2>/dev/null || true)"
  [ -n "$p" ] && ln -sf "$p" "$SANDBOX/$tool"
done
PY_OK=1
command -v python3 >/dev/null 2>&1 || PY_OK=0

# gh stub: resolvable PR context (no network). Shared by both PATH modes.
STUBDIR="$TMP/stub-bin"
mkdir -p "$STUBDIR"
cat > "$STUBDIR/gh" <<'EOF'
#!/usr/bin/env bash
if [ "${1:-}" = "pr" ] && [ "${2:-}" = "view" ]; then
  printf '{"baseRefName":"main","headRefName":"feat-1"}\n'
  exit 0
fi
exit 1
EOF
chmod +x "$STUBDIR/gh"
ln -sf "$STUBDIR/gh" "$SANDBOX/gh"

make_repo() { # <name> → REPO on a feature branch, PASSING gate, PR head branch present
  local name="$1"
  REPO="$TMP/$name"
  mkdir -p "$REPO/scripts"
  git -C "$REPO" init -q
  git -C "$REPO" checkout -q -b main
  git -C "$REPO" -c user.email=t@keel.test -c user.name=t commit -q --allow-empty -m init
  git -C "$REPO" update-ref refs/remotes/origin/main "$(git -C "$REPO" rev-parse HEAD)"
  git -C "$REPO" symbolic-ref refs/remotes/origin/HEAD refs/remotes/origin/main
  git -C "$REPO" remote add origin "$REPO"
  git -C "$REPO" checkout -q -b feat/work
  git -C "$REPO" checkout -q -b feat-1 && git -C "$REPO" checkout -q feat/work
  printf '#!/usr/bin/env bash\nexit 0\n' > "$REPO/scripts/check-verified-pin.sh"
  chmod +x "$REPO/scripts/check-verified-pin.sh"
}

CMD='gh pr merge 123 --auto'

mg_conclusion() { # <repo> <PATH> → "unlock" | "gate" | "other"
  local repo="$1" path="$2" json out
  json="$(json_quote "$CMD")"
  out="$(printf '{"tool_name":"Bash","tool_input":{"command":%s}}' "$json" \
    | CLAUDE_PROJECT_DIR="$repo" PATH="$path" bash "$MG" 2>/dev/null || true)"
  if printf '%s' "$out" | grep -q '"permissionDecision": "allow"'; then echo unlock
  elif printf '%s' "$out" | grep -q '"permissionDecision": "ask"'; then echo gate
  else echo "other:${out:0:60}"; fi
}

bg_conclusion() { # <repo> <PATH> → "unlock" | "gate" | "other"
  local repo="$1" path="$2" json out rc
  json="$(json_quote "$CMD")"
  out="$(printf '{"tool_name":"Bash","tool_input":{"command":%s}}' "$json" \
    | CLAUDE_PROJECT_DIR="$repo" PATH="$path" bash "$BG" 2>/dev/null)" && rc=0 || rc=$?
  if [ "$rc" -eq 0 ] && [ -z "$out" ]; then echo unlock
  elif [ "$rc" -eq 2 ]; then echo gate
  else echo "other:rc=$rc"; fi
}

write_attended() { mkdir -p "$1/.claude"; printf '%s' "$2" > "$1/.claude/keel-attended-merge.json"; }

VALID='{"scope":"session","created":"2026-07-04T12:00:00Z","invoker":"human:keel-auto-merge"}'

# Fixtures: name | expected-conclusion | JSON payload | tracked?(yes/no)
run_fixture() { # <name> <expected> <payload> <tracked>
  local name="$1" want="$2" payload="$3" tracked="$4"
  local reponame="r-${name}"
  make_repo "$reponame"
  local repo="$REPO"
  write_attended "$repo" "$payload"
  if [ "$tracked" = "yes" ]; then
    git -C "$repo" add -f .claude/keel-attended-merge.json
    git -C "$repo" -c user.email=t@keel.test -c user.name=t commit -qm "tracked-$name"
  fi

  local modes=("jq:$STUBDIR:$PATH")
  [ "$PY_OK" -eq 1 ] && modes+=("python3:$SANDBOX")

  local mode label path mg bg
  for mode in "${modes[@]}"; do
    label="${mode%%:*}"; path="${mode#*:}"
    mg="$(mg_conclusion "$repo" "$path")"
    bg="$(bg_conclusion "$repo" "$path")"
    if [ "$mg" = "$want" ] && [ "$bg" = "$want" ]; then
      ok "$name [$label reader]: both scripts conclude '$want' (mg=$mg, bg=$bg)"
    else
      bad "$name [$label reader]: want '$want' from both — got mg=$mg, bg=$bg"
    fi
  done
}

# A valid untracked marker → both UNLOCK.
run_fixture "valid"      unlock "$VALID"                                          no
# A git-tracked marker (spoof) → both GATE (untracked contract).
run_fixture "tracked"    gate   "$VALID"                                          yes
# Malformed JSON → both GATE.
run_fixture "malformed"  gate   '{"scope":"session","created":'                   no
# Wrong scope → both GATE.
run_fixture "wrongscope" gate   '{"scope":"project","created":"c","invoker":"i"}' no

if [ "$PY_OK" -ne 1 ]; then
  echo "note: python3 not found — the python3-reader parity leg was skipped"
fi

echo "-------------------------------------"
echo "$pass passed, $failc failed"
[ "$failc" -eq 0 ]
