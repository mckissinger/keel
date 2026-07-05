#!/usr/bin/env bash
#
# guard-branch-rules.sh — keel's skill-scoped PreToolUse hook on Bash, declared
# in the `hooks:` frontmatter of skills/implement-milestone/SKILL.md and
# skills/implement-feature/SKILL.md (active only while a build skill runs).
#
# Build sessions have two hard branch rules; this makes them mechanism, even in
# local-only projects with no branch protection:
#   `git commit` while on the default branch → exit 2 (branch first)
#   merge-shaped command                     → exit 2 (build sessions never merge)
#   everything else                          → exit 0, silent
#
# ONE exception, the attended-merge marker (contract below): a per-session,
# human-set marker + no active autonomy mode + a bare `gh pr merge <pr> --auto`
# (the canonical detect_strict_auto shape) → exit 0, DEFERRING the gate decision
# to merge-guard.sh, which fires on the same Bash call. Every other merge-shaped
# command, and `git commit` on the default branch, still → exit 2. No marker →
# the exit-2 matrix is byte-for-byte today's.
#
# Exit 2 blocks the tool call and feeds stderr back to Claude (PreToolUse exit-code
# semantics per https://code.claude.com/docs/en/hooks).
#
# The merge-shape classifier is DUPLICATED from merge-guard.sh on purpose —
# m1's precedent keeps hook scripts self-contained (no sibling sourcing, so each
# survives plugin-cache path churn and reads standalone). Keep the two in sync.
# The marker readers (json_str, created_fresh, read_mode_file,
# read_attended_marker) and the detect_strict_auto whitelist are likewise
# DUPLICATED from merge-guard.sh (the marker's reading owner) — same
# self-contained idiom; the cross-script parity is asserted by
# scripts/attended-marker-parity.test.sh. The mode file's `level` whitelist is
# likewise identical to the owner's: "feature" | "run" | "genesis" are the only
# valid values; any other → no mode (fail closed).
# Marker TTLs (enforced identically here): the autonomy mode file is valid only
# while `created` is within 24h, the attended marker within 8h; an expired,
# unparseable, or future-dated `created` is treated EXACTLY as absent, so the
# exit-2 matrix stays byte-for-byte today's. The TTL age is computed from
# `created` as parsed data — never eval'd. NO REFRESH PATH: each file's invoking
# skill (`keel:auto` / `keel:auto-merge`) is its only writer; nothing extends a
# marker's life except a fresh human invocation.
# Safety: command text and marker text are PARSED as data — never eval'd or
# re-executed.

set -euo pipefail
set -f # no globbing: command text is tokenized as data

ROOT="${CLAUDE_PROJECT_DIR:-$PWD}"
cd "$ROOT" 2>/dev/null || true

# --- hook input --------------------------------------------------------------

CMD="" CMD_PARSED=0
read_hook_command() { # stdin JSON → CMD (tool_input.command), CMD_PARSED
  local input
  input="$(cat 2>/dev/null || true)"
  if command -v jq >/dev/null 2>&1; then
    CMD="$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null || true)"
    CMD_PARSED=1
  elif command -v python3 >/dev/null 2>&1; then
    CMD="$(printf '%s' "$input" | python3 -c '
import json, sys
try:
    d = json.load(sys.stdin)
except Exception:
    sys.exit(0)
c = (d.get("tool_input") or {}).get("command") or ""
sys.stdout.write(c if isinstance(c, str) else "")
' 2>/dev/null || true)"
    CMD_PARSED=1
  fi
  return 0
}

# --- default branch ----------------------------------------------------------

detect_default_branch() { # origin/HEAD → main/master probe → "main"
  local ref b
  if ref="$(git symbolic-ref --quiet refs/remotes/origin/HEAD 2>/dev/null)"; then
    printf '%s\n' "${ref#refs/remotes/origin/}"
    return 0
  fi
  for b in main master; do
    if git show-ref --verify --quiet "refs/heads/$b" 2>/dev/null \
      || git show-ref --verify --quiet "refs/remotes/origin/$b" 2>/dev/null; then
      printf '%s\n' "$b"
      return 0
    fi
  done
  printf 'main\n'
  return 0
}

is_default_ref() { # <token> — does it name the default branch?
  local t="$1" r
  if [ -z "$t" ]; then return 1; fi
  t="${t#refs/heads/}"
  t="${t#refs/remotes/}"
  if [ "$t" = "$DEFAULT_BRANCH" ]; then return 0; fi
  for r in $REMOTES; do
    if [ "$t" = "$r/$DEFAULT_BRANCH" ]; then return 0; fi
  done
  return 1
}

# --- classification (parse only; never executed) ------------------------------

SHAPE="" GH_PR_ARG="" GIT_COMMIT=0
TOKS=()
N=0 I=0

classify_gh() { # after `gh`: skip flags (value-taking ones skip their value)
  local w w1="" w2="" w3=""
  while [ "$I" -lt "$N" ]; do
    w="${TOKS[$I]}"
    case "$w" in
      --repo | -R | --hostname | -t | --subject | -b | --body | -A | --author-email | --match-head-commit)
        I=$((I + 2))
        continue
        ;;
      -*)
        I=$((I + 1))
        continue
        ;;
    esac
    if [ -z "$w1" ]; then w1="$w"; elif [ -z "$w2" ]; then w2="$w"; elif [ -z "$w3" ]; then w3="$w"; fi
    I=$((I + 1))
  done
  if [ "$w1" = "pr" ] && [ "$w2" = "merge" ]; then
    SHAPE="gh-pr-merge"
    GH_PR_ARG="$w3"
  fi
  return 0
}

classify_git_merge() {
  local w
  while [ "$I" -lt "$N" ]; do
    w="${TOKS[$I]}"
    case "$w" in
      --abort | --continue | --quit) # sequencer control, not a merge
        SHAPE=""
        return 0
        ;;
      -m | --message | -F | --file | -s | --strategy | -X | --strategy-option | --into-name)
        I=$((I + 2))
        continue
        ;;
      -*)
        I=$((I + 1))
        continue
        ;;
    esac
    if is_default_ref "$w"; then SHAPE="git-merge"; fi
    I=$((I + 1))
  done
  return 0
}

classify_git_push() {
  local w pos=0 spec dst cur
  while [ "$I" -lt "$N" ]; do
    w="${TOKS[$I]}"
    case "$w" in
      -o | --push-option | --receive-pack | --repo | --exec)
        I=$((I + 2))
        continue
        ;;
      -*)
        I=$((I + 1))
        continue
        ;;
    esac
    pos=$((pos + 1))
    if [ "$pos" -ge 2 ]; then # refspecs (first positional is the remote)
      spec="${w#+}"
      dst="${spec##*:}"
      dst="${dst#refs/heads/}"
      if [ "$dst" = "HEAD" ]; then
        dst="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
      fi
      if [ -n "$dst" ] && [ "$dst" = "$DEFAULT_BRANCH" ]; then
        SHAPE="git-push"
        return 0
      fi
    fi
    I=$((I + 1))
  done
  if [ "$pos" -le 1 ]; then # bare `git push` [remote]: implicit current branch
    cur="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
    if [ -n "$cur" ] && [ "$cur" = "$DEFAULT_BRANCH" ]; then SHAPE="git-push"; fi
  fi
  return 0
}

classify_git() { # after `git`: skip global flags, then dispatch on the subcommand
  local w sub
  while [ "$I" -lt "$N" ]; do
    w="${TOKS[$I]}"
    case "$w" in
      -C | -c | --git-dir | --work-tree | --namespace | --exec-path)
        I=$((I + 2))
        continue
        ;;
      -*)
        I=$((I + 1))
        continue
        ;;
      *) break ;;
    esac
  done
  if [ "$I" -ge "$N" ]; then return 0; fi
  sub="${TOKS[$I]}"
  I=$((I + 1))
  case "$sub" in # `merge-base` etc. fall through: exact match only
    merge) classify_git_merge ;;
    push) classify_git_push ;;
    commit) GIT_COMMIT=1 ;;
  esac
  return 0
}

classify_tokens() {
  N=${#TOKS[@]}
  I=0
  local head
  while [ "$I" -lt "$N" ]; do
    head="${TOKS[$I]}"
    case "$head" in
      [A-Za-z_]*=*) # leading VAR=val assignments
        I=$((I + 1))
        continue
        ;;
      command | exec | env | nohup) # transparent wrappers
        I=$((I + 1))
        continue
        ;;
    esac
    break
  done
  if [ "$I" -ge "$N" ]; then return 0; fi
  head="${TOKS[$I]}"
  head="${head##*/}" # /usr/bin/git → git
  I=$((I + 1))
  case "$head" in
    gh) classify_gh ;;
    git) classify_git ;;
  esac
  return 0
}

classify_cmd() { # <command text> → SHAPE, GH_PR_ARG, GIT_COMMIT
  SHAPE="" GH_PR_ARG=""
  local line t
  while IFS= read -r line; do
    if [ -z "${line//[[:space:]]/}" ]; then continue; fi
    TOKS=()
    for t in $line; do # noglob is on; whitespace tokenization of DATA
      t="${t#\"}"
      t="${t%\"}"
      t="${t#\'}"
      t="${t%\'}"
      if [ -n "$t" ]; then TOKS[${#TOKS[@]}]="$t"; fi
    done
    classify_tokens
    if [ -n "$SHAPE" ]; then return 0; fi
  done < <(printf '%s\n' "$1" | tr '|;&' '\n\n\n') # each pipeline/list segment scanned
  return 0
}

# --- marker readers (DUPLICATED from merge-guard.sh — keep in sync) ------------
# The attended-merge marker's reading owner is merge-guard.sh; its full contract
# lives there. This build guard reads the same file with the same validation so
# the two agree on the same Bash call (parity asserted by
# scripts/attended-marker-parity.test.sh). The mode file is read too, only to
# enforce autonomy precedence: a valid autonomy mode makes the attended marker
# ignored here (turning autonomy mode on suppresses the attended defer).

json_str() { # <json> <key> → prints the value ONLY if it is a string, or nothing
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
  # or future (`age < 0`) → not fresh; no parser → not fresh (fail closed).
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

MODE_ACTIVE=0
read_mode_file() { # .claude/keel-autonomy.json → MODE_ACTIVE; any defect → no mode
  MODE_ACTIVE=0
  local f="$ROOT/.claude/keel-autonomy.json" content lvl scope created invoker
  [ -f "$f" ] && [ -r "$f" ] || return 0
  if git -C "$ROOT" ls-files --error-unmatch -- .claude/keel-autonomy.json >/dev/null 2>&1; then
    return 0
  fi
  content="$(cat "$f" 2>/dev/null)" || return 0
  lvl="$(json_str "$content" level)"
  scope="$(json_str "$content" scope)"
  created="$(json_str "$content" created)"
  invoker="$(json_str "$content" invoker)"
  case "$lvl" in feature | run | genesis) ;; *) return 0 ;; esac # feature|run|genesis; any other → no mode
  [ -n "$scope" ] && [ -n "$created" ] && [ -n "$invoker" ] || return 0
  created_fresh "$created" 86400 || return 0 # TTL 24h: expired/unparseable → no mode
  MODE_ACTIVE=1
  return 0
}

ATTENDED_ACTIVE=0
read_attended_marker() { # .claude/keel-attended-merge.json → ATTENDED_ACTIVE; any defect → no marker
  ATTENDED_ACTIVE=0
  local f="$ROOT/.claude/keel-attended-merge.json" content scope created invoker
  [ -f "$f" ] && [ -r "$f" ] || return 0
  if git -C "$ROOT" ls-files --error-unmatch -- .claude/keel-attended-merge.json >/dev/null 2>&1; then
    return 0
  fi
  content="$(cat "$f" 2>/dev/null)" || return 0
  scope="$(json_str "$content" scope)"
  created="$(json_str "$content" created)"
  invoker="$(json_str "$content" invoker)"
  [ "$scope" = "session" ] || return 0
  [ -n "$created" ] && [ -n "$invoker" ] || return 0
  created_fresh "$created" 28800 || return 0 # TTL 8h: expired/unparseable → no marker
  ATTENDED_ACTIVE=1
  return 0
}

AUTO_MERGE=0
detect_strict_auto() { # WHITELIST: does $CMD exactly match the canonical delegation shape?
  # A CLOSED SET, default-deny (mirrors merge-guard.sh):
  #   gh pr merge <PR-number-or-safe-ref> --auto [--squash|--merge|--rebase]
  # flags in any order; exactly one positional; NOTHING else. Chaining, quotes,
  # expansions, clustered short flags, the `--` separator, value-taking/unknown
  # flags all fall out and keep the exit-2 refusal by construction.
  AUTO_MERGE=0
  case "$CMD" in *$'\n'* | *$'\r'*) return 0 ;; esac
  if printf '%s' "$CMD" | LC_ALL=C grep -q '[^A-Za-z0-9 ._/:#@=-]'; then
    return 0
  fi
  local -a w=()
  local t i=3 pos="" auto=0
  for t in $CMD; do w[${#w[@]}]="$t"; done # noglob on; safe charset only
  [ "${#w[@]}" -ge 3 ] || return 0
  [ "${w[0]}" = "gh" ] && [ "${w[1]}" = "pr" ] && [ "${w[2]}" = "merge" ] || return 0
  while [ "$i" -lt "${#w[@]}" ]; do
    t="${w[$i]}"
    case "$t" in
      --auto) auto=1 ;;
      --squash | --merge | --rebase) : ;;
      -*) return 0 ;;
      *)
        [ -z "$pos" ] || return 0
        printf '%s' "$t" | LC_ALL=C grep -qE '^[0-9]+$|^[A-Za-z0-9][A-Za-z0-9._/-]*$' \
          || return 0
        pos="$t"
        ;;
    esac
    i=$((i + 1))
  done
  [ -n "$pos" ] && [ "$auto" -eq 1 ] || return 0
  AUTO_MERGE=1
  return 0
}

# --- main ---------------------------------------------------------------------

read_hook_command
if [ "$CMD_PARSED" -ne 1 ]; then exit 0; fi # no jq/python3: this backstop degrades open
if [ -z "$CMD" ]; then exit 0; fi           # not a Bash command payload

DEFAULT_BRANCH="$(detect_default_branch)"
REMOTES="$(git remote 2>/dev/null | tr '\n' ' ' || true)"
if [ -z "${REMOTES// /}" ]; then REMOTES="origin"; fi

classify_cmd "$CMD"

if [ -n "$SHAPE" ]; then
  # The one exception: a per-session attended marker + no active autonomy mode +
  # a bare `gh pr merge <pr> --auto` (the canonical detect_strict_auto shape) →
  # defer the gate decision to merge-guard.sh (which fires on the same Bash
  # call). Autonomy mode takes precedence — a valid mode suppresses this defer.
  read_mode_file
  read_attended_marker
  detect_strict_auto
  if [ "$MODE_ACTIVE" -eq 0 ] && [ "$ATTENDED_ACTIVE" -eq 1 ] \
     && [ "$AUTO_MERGE" -eq 1 ] && [ "$SHAPE" = "gh-pr-merge" ]; then
    exit 0 # merge-guard.sh owns the gate-pass/-fail decision on this same call
  fi
  echo "keel: build sessions never merge — merging is the user's decision, driven through land-feature with per-merge approval. Open the PR and stop there." >&2
  exit 2
fi

if [ "$GIT_COMMIT" -eq 1 ]; then
  CUR="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
  if [ -n "$CUR" ] && [ "$CUR" = "$DEFAULT_BRANCH" ]; then
    echo "keel: git commit on the default branch ($DEFAULT_BRANCH) is blocked in build sessions — branch first (git checkout -b <milestone-slug>), then commit. Builds run on branches; the default branch only advances by the user's reviewed merges." >&2
    exit 2
  fi
fi

exit 0
