#!/usr/bin/env bash
#
# session-bootstrap.sh — keel's SessionStart hook (startup/resume/clear/compact).
#
# Probes the session's project directory for keel markers and, only when the
# project is keel-managed, emits a short orientation (the grain ladder + the
# standing invariants) so every session — including a freshly compacted one —
# knows keel's verbs exist. In any other project it exits 0 with no output,
# costing nothing.
#
# Output contract: for SessionStart, plain stdout on exit 0 is added to
# Claude's context (per https://code.claude.com/docs/en/hooks — no JSON
# envelope required for context-only hooks). The `compact` matcher is the
# documented re-injection path after compaction; PostCompact cannot inject.
#
# Self-contained on purpose: it references no sibling files, so it survives
# plugin-cache path churn with no dirname gymnastics beyond this comment.

set -euo pipefail

# The harness sets CLAUDE_PROJECT_DIR for hook processes; fall back to cwd.
ROOT="${CLAUDE_PROJECT_DIR:-$PWD}"

is_keel_managed() {
  [ -d "$ROOT/specs/milestones" ] && return 0
  [ -f "$ROOT/specs/stack-profile.md" ] && return 0
  if [ -f "$ROOT/CLAUDE.md" ] && grep -qiE 'verified[- ]pin' "$ROOT/CLAUDE.md"; then
    return 0
  fi
  return 1
}

# Not a keel-managed project → stay silent.
is_keel_managed || exit 0

# --- autonomy mode -------------------------------------------------------------
# The mode-file contract lives in scripts/merge-guard.sh (the reading owner):
# .claude/keel-autonomy.json, fields level/scope/created/invoker, untracked,
# written only by the human-triggered keel:auto skill, cleared at run end.
# This hook applies the same validation: any defect → no mode → today's text.

MODE_ACTIVE=0 MODE_LEVEL="" MODE_SCOPE=""

mode_json_str() { # <json> <key> → the value ONLY if a string (jq → python3 → nothing)
  # Both encoder paths enforce the string type — a wrong-typed field reads
  # the same, absent, under either (parity with merge-guard.sh's json_str).
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$1" | jq -r --arg k "$2" '.[$k] | select(type=="string")' 2>/dev/null || true
  elif command -v python3 >/dev/null 2>&1; then
    printf '%s' "$1" | K="$2" python3 -c '
import json, os, sys
try:
    d = json.load(sys.stdin)
except Exception:
    sys.exit(0)
v = d.get(os.environ["K"])
if isinstance(v, str):
    sys.stdout.write(v)
' 2>/dev/null || true
  fi
  return 0
}

read_mode_file() {
  local f="$ROOT/.claude/keel-autonomy.json" content lvl scope created invoker
  [ -f "$f" ] && [ -r "$f" ] || return 0
  # Contract: untracked. A git-tracked copy is a spoof → treated as no mode.
  if git -C "$ROOT" ls-files --error-unmatch -- .claude/keel-autonomy.json >/dev/null 2>&1; then
    return 0
  fi
  content="$(cat "$f" 2>/dev/null)" || return 0
  lvl="$(mode_json_str "$content" level)"
  scope="$(mode_json_str "$content" scope)"
  created="$(mode_json_str "$content" created)"
  invoker="$(mode_json_str "$content" invoker)"
  case "$lvl" in feature | run) ;; *) return 0 ;; esac
  [ -n "$scope" ] && [ -n "$created" ] && [ -n "$invoker" ] || return 0
  MODE_ACTIVE=1
  MODE_LEVEL="$lvl"
  # scope is echoed into session context: constrain it to a safe charset and
  # length so a crafted file cannot smuggle arbitrary prose through this hook.
  MODE_SCOPE="$(printf '%s' "$scope" | LC_ALL=C tr -cd 'A-Za-z0-9 ._/:#@=-' | cut -c1-120)"
  [ -n "$MODE_SCOPE" ] || MODE_SCOPE="$lvl"
  return 0
}

read_mode_file

if [ "$MODE_ACTIVE" -eq 1 ]; then
  cat <<EOF
keel is active: this project is keel-managed (spec markers found). Orientation:

Grain ladder — pick the verb that matches the size of the work:
- App:       kickoff (greenfield) / adopt (brownfield) → interview → spec-foundation → app-design-directions (only when there's a UI) → provision
- Feature:   spec-feature → implement-feature → land-feature → review-feature
- Milestone: implement-milestone → verify-milestone
- Change:    spec-change (a sub-feature tweak → one milestone, then the milestone verbs)
- Chore:     punch-list (a batch of tiny changes → one verified chore PR)
- Cross-cut: debug

Standing invariants — these hold no matter what else the session is doing:
- Autonomy mode ACTIVE — level: ${MODE_LEVEL}, scope: ${MODE_SCOPE}. Merge authority is delegated to the server-side required checks via gh pr merge --auto, per decisions/2026-07-autonomy-modes.md — the checks decide, never agent judgment. Ledger every would-be ask to specs/runs/<run-id>/ (recorded deferral; silent deferral stays banned). Stop-points still halt: go-live, live-key swaps, and spend beyond pre-authorized caps stay attended.
- Never commit to main; builds run on branches.
- A milestone's code merges only with a fresh-session verified pin (verified code == merged code).

Specs live under specs/. When work matches a keel verb, invoke that skill rather than improvising the process.
EOF
  exit 0
fi

cat <<'EOF'
keel is active: this project is keel-managed (spec markers found). Orientation:

Grain ladder — pick the verb that matches the size of the work:
- App:       kickoff (greenfield) / adopt (brownfield) → interview → spec-foundation → app-design-directions (only when there's a UI) → provision
- Feature:   spec-feature → implement-feature → land-feature → review-feature
- Milestone: implement-milestone → verify-milestone
- Change:    spec-change (a sub-feature tweak → one milestone, then the milestone verbs)
- Chore:     punch-list (a batch of tiny changes → one verified chore PR)
- Cross-cut: debug

Standing invariants — these hold no matter what else the session is doing:
- Never merge; the user reviews and merges. Open PRs and stop there.
- Never commit to main; builds run on branches.
- A milestone's code merges only with a fresh-session verified pin (verified code == merged code).
- Attended gates stop and ask; they are never silently deferred.

Specs live under specs/. When work matches a keel verb, invoke that skill rather than improvising the process.
EOF
