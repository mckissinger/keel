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
# Exit 2 blocks the tool call and feeds stderr back to Claude (PreToolUse exit-code
# semantics per https://code.claude.com/docs/en/hooks).
#
# The merge-shape classifier is DUPLICATED from merge-guard.sh on purpose —
# m1's precedent keeps hook scripts self-contained (no sibling sourcing, so each
# survives plugin-cache path churn and reads standalone). Keep the two in sync.
# Safety: command text is PARSED as data — never eval'd or re-executed.

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

# --- main ---------------------------------------------------------------------

read_hook_command
if [ "$CMD_PARSED" -ne 1 ]; then exit 0; fi # no jq/python3: this backstop degrades open
if [ -z "$CMD" ]; then exit 0; fi           # not a Bash command payload

DEFAULT_BRANCH="$(detect_default_branch)"
REMOTES="$(git remote 2>/dev/null | tr '\n' ' ' || true)"
if [ -z "${REMOTES// /}" ]; then REMOTES="origin"; fi

classify_cmd "$CMD"

if [ -n "$SHAPE" ]; then
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
