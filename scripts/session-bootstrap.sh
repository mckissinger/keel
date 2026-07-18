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
# TTL (24h): this copy enforces the same 24h freshness bound the guards do —
# a stale / expired / unparseable-`created` mode file produces the no-mode
# baseline banner (never "Autonomy mode ACTIVE"), so a crashed run's leftover
# file cannot arm a later session's context after the guards stopped honoring
# it. `created` is parsed AS DATA — never eval'd. NO REFRESH PATH: keel:auto is
# the file's only writer; nothing extends its life but a fresh human invocation.

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

created_fresh() { # <created-string> <ttl-seconds> → 0 iff parseable AND 0<=age<=ttl
  # DUPLICATED from merge-guard.sh (keep in sync). `created` is DATA — stdin
  # (jq -Rs) or env (python3), never eval'd. Only the strict "%Y-%m-%dT%H:%M:%SZ"
  # ISO-8601 UTC form matching the WHOLE string is fresh (jq round-trips
  # fromdateiso8601|todateiso8601==input for python3-strptime parity); unparseable
  # or future → not fresh; no parser → not fresh (fail closed to the no-mode baseline).
  local created="$1" ttl="$2"
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$created" | jq -e -Rs --argjson ttl "$ttl" '
      . as $in
      | (try (fromdateiso8601 | todateiso8601) catch null) as $r
      | if $r == null or $r != $in then false
        else ($in | fromdateiso8601) as $c | (now - $c) as $a | ($a >= 0 and $a <= $ttl) end
    ' >/dev/null 2>&1
  elif command -v python3 >/dev/null 2>&1; then
    C="$created" TTL="$ttl" python3 -c '
import os, sys, time
from datetime import datetime, timezone
try:
    dt = datetime.strptime(os.environ["C"], "%Y-%m-%dT%H:%M:%SZ").replace(tzinfo=timezone.utc)
    age = time.time() - dt.timestamp()
    sys.exit(0 if 0 <= age <= float(os.environ["TTL"]) else 1)
except Exception:
    sys.exit(1)
' >/dev/null 2>&1
  else
    return 1
  fi
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
  case "$lvl" in feature | run | genesis) ;; *) return 0 ;; esac # feature|run|genesis; any other → no mode
  [ -n "$scope" ] && [ -n "$created" ] && [ -n "$invoker" ] || return 0
  created_fresh "$created" 86400 || return 0 # TTL 24h: expired/unparseable → no mode banner
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
- Marketing: marketing-site (landing page or full marketing site — usually after the app is built)
- Video:     product-video (how-to / onboarding / demo videos from committed, regenerable sources — post-app)
- Logo:      logo (brand mark + versioned logo kit under design/brand/ — SVG-direct, attended art direction; ends on a plan PR)
- Harden:    harden (pre-launch production-readiness audit → grain-mapped remediation slate — post-app)
- Growth:    gtm → spec-campaign → run-growth → measure (positioning → one campaign → one gated operating cycle → metrics + cohort readout; run-growth human-triggered only)
- Cross-cut: debug · status · harvest · demo · test-health
- Autonomy:  keel:auto feature <slug> / keel:auto run [scope] / keel:auto genesis "<idea>" (human-triggered only; enters and exits the autonomy mode)

Standing invariants — these hold no matter what else the session is doing:
- Autonomy mode ACTIVE — level: ${MODE_LEVEL}, scope: ${MODE_SCOPE}. Merge authority is delegated to the server-side required checks via gh pr merge --auto, per decisions/2026-07-autonomy-modes.md — the checks decide, never agent judgment. Ledger every would-be ask to specs/runs/<run-id>/ (recorded deferral; silent deferral stays banned). Stop-points still halt: go-live, live-key swaps, and spend beyond pre-authorized caps stay attended.
- Never commit to main; builds run on branches.
- A milestone's code merges only under the two-part control: a fresh-session verified pin (the verification half) plus the pin gate's drift check (no code changed since the pin). Neither half alone proves the other.
- Never claim an unobservable outcome: a tool result cannot tell you whether a permission prompt appeared — a command reads the same whether it was approved or ran silently — so report only what the tool returned, never that something "merged without a prompt."
- Attended gates end on the five-line summary block: Done / Decision / Recommend / Glance / Next (references/gate-presentation.md defines it).

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
- Marketing: marketing-site (landing page or full marketing site — usually after the app is built)
- Video:     product-video (how-to / onboarding / demo videos from committed, regenerable sources — post-app)
- Logo:      logo (brand mark + versioned logo kit under design/brand/ — SVG-direct, attended art direction; ends on a plan PR)
- Harden:    harden (pre-launch production-readiness audit → grain-mapped remediation slate — post-app)
- Growth:    gtm → spec-campaign → run-growth → measure (positioning → one campaign → one gated operating cycle → metrics + cohort readout; run-growth human-triggered only)
- Cross-cut: debug · status · harvest · demo · test-health
- Autonomy:  keel:auto feature <slug> / keel:auto run [scope] / keel:auto genesis "<idea>" (human-triggered only; enters and exits the autonomy mode)

Standing invariants — these hold no matter what else the session is doing:
- Never merge; the user reviews and merges. Open PRs and stop there. One attended exception: if the user has invoked /keel:auto-merge on this session, an explicitly-instructed, verified-pin-gate-passing gh pr merge <pr> --auto may land without the per-merge tap — you still never merge on your own initiative, and with no marker this line holds exactly as written (decisions/2026-07-04-attended-auto-merge.md).
- Never commit to main; builds run on branches.
- A milestone's code merges only under the two-part control: a fresh-session verified pin (the verification half) plus the pin gate's drift check (no code changed since the pin). Neither half alone proves the other.
- Attended gates stop and ask; they are never silently deferred.
- Attended gates end on the five-line summary block: Done / Decision / Recommend / Glance / Next (references/gate-presentation.md defines it).
- Never claim an unobservable outcome: a tool result cannot tell you whether a permission prompt appeared — a command reads the same whether it was approved or ran silently — so report only what the tool returned, never that something "merged without a prompt."

Specs live under specs/. When work matches a keel verb, invoke that skill rather than improvising the process.
EOF
