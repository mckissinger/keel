#!/usr/bin/env bash
#
# merge-guard.sh — keel's PreToolUse hook on Bash (wired in hooks/hooks.json).
#
# Reads the hook's stdin JSON (tool_input.command per
# https://code.claude.com/docs/en/hooks), classifies the command, and turns
# merge-shaped commands into harness decisions via hookSpecificOutput:
#
#   not merge-shaped                        → exit 0, no output (allow silently)
#   merge-shaped + gate present + gate PASS → permissionDecision "ask"
#   merge-shaped + gate present + gate FAIL → permissionDecision "deny",
#                                             the gate's stderr reason verbatim
#   merge-shaped + gate/context unresolvable→ permissionDecision "ask",
#                                             naming what was unresolvable
#
# Merge-shaped = `gh pr merge`, `git merge` whose target resolves to the default
# branch, `git push` to the default branch (default branch via origin/HEAD, then
# a main/master probe). A merge-shaped command is NEVER auto-allowed — the floor
# is "ask", per-merge human approval — with ONE exception, the autonomy-mode
# `--auto` path below. The gate is the PROJECT's scripts/check-verified-pin.sh —
# invoked as-is, never re-implemented here.
#
# --- Git context (GIT_CTX) vs project root (ROOT) ----------------------------
#
# A session may run in a LINKED WORKTREE: the Bash call executes in the worktree
# (on the milestone branch) while CLAUDE_PROJECT_DIR still points at the main
# checkout (on the default branch). So BRANCH STATE resolves from the hook input's
# `cwd` — the directory the tool call actually runs in — whenever that is USABLE,
# meaning an existing directory inside a git work tree
# (`git -C <dir> rev-parse --is-inside-work-tree` = true). Fallback order when
# `cwd` is absent or unusable: CLAUDE_PROJECT_DIR, then PWD — today's exact
# resolution, so every non-worktree decision is byte-for-byte unchanged. EVERY git
# read runs against that one resolved GIT_CTX, through the single `gitc` helper:
# default-branch detection, the remotes list, the push classifier's HEAD reads,
# resolve_gh_context's ref-existence probes, decide()'s BASE_REF_R/HEAD_REF_R
# resolution — and the pin gate itself is INVOKED FROM GIT_CTX, so it judges the
# branch state of the checkout the merge command would run in.
#
# MARKER FILES stay rooted at ROOT="${CLAUDE_PROJECT_DIR:-$PWD}" — never a path
# derived from `cwd`. They are project-scoped state written only by a
# human-invoked skill into the project's own .claude/, and worktrees never carry
# them; keeping them ROOT-rooted also means a crafted `cwd` can never point the
# marker reads (or the gate script's own path, likewise taken from ROOT) at an
# attacker-chosen file. The split is exactly: git state from GIT_CTX, marker files
# and the gate script's path from ROOT.
#
# `cwd` is PARSED AS DATA — string-typed, the same discipline as the command text
# — and is only ever passed as a quoted argument to `git -C` / `cd`, never eval'd.
# A `git -C <elsewhere>` inside the GUARDED COMMAND remains an accepted
# classification limit (this guard judges the checkout the command runs IN, not a
# per-invocation -C override); branch protection + required checks stay the
# authority. guard-branch-rules.sh DUPLICATES this hook-input reader (both fields:
# tool_input.command and `cwd`, on both the jq and python3 paths) and this GIT_CTX
# resolution, per the self-contained-hook idiom — keep the two in sync.
#
# --- Autonomy-mode file contract (this guard is the reading owner) -----------
#
# Path:    .claude/keel-autonomy.json  (under CLAUDE_PROJECT_DIR)
# Fields:  level   — "feature" | "run" | "genesis" (any other value → the file
#                    is invalid); all three yield the identical decision table —
#                    only the level token in the emitted reason differs
#          scope   — what the mode covers (feature slug / run scope string)
#          created — when the mode was entered, ISO-8601 UTC (the `...Z` form
#                    `date -u +%Y-%m-%dT%H:%M:%SZ` prints); parsed AS DATA
#          invoker — who triggered it
# The file is UNTRACKED — never committed; a git-tracked copy is treated as a
# spoof and ignored. It is written ONLY by the human-triggered `keel:auto`
# skill (the write path is the authorization trail — an agent can never
# escalate its own autonomy) and cleared at run end. A malformed, unreadable,
# or field-incomplete mode file is treated as NO mode: fail closed to the
# pre-mode decision table.
#
# TTL (24h): the mode file is valid only while `created` is within 24 hours of
# now. An expired file — or a `created` that will not parse as an ISO-8601 UTC
# timestamp, or one dated in the future — is treated EXACTLY as absent (no mode,
# byte-for-byte the pre-mode table); it changes no other row of the matrix.
# Expiry kills a crashed run's leftover file so it cannot arm a later, unrelated
# session after the guard stopped honoring it. The age is computed from `created`
# as parsed data (jq fromdateiso8601 / python3 strptime) — never shelled through
# eval. NO REFRESH PATH: the invoking `keel:auto` skill is this file's only
# writer, and nothing extends a marker's life except a fresh human invocation.
#
# Under a VALID mode file, exactly one row of the decision table changes
# (per decisions/2026-07-05-autonomy-modes-v2.md + decisions/2026-07-genesis-envelope.md — delegation to GitHub's required
# checks, never to agent judgment):
#
#   the canonical `gh pr merge ... --auto` shape + gate PASS → "allow"
#     (GitHub merges when and only when the required checks pass)
#
# Everything else is byte-for-byte today's table: plain `gh pr merge` without
# `--auto` stays "ask" even under a mode; gate FAIL stays "deny"; `git merge` /
# `git push` to the default branch stay "ask"; unresolvable context stays
# "ask"; no mode file → the existing ask-floor. The shape test is a
# whole-command WHITELIST, default-deny to ask: the command must be a single
# line over a safe character set and match exactly
#   gh pr merge <PR-number-or-safe-ref> --auto [--squash|--merge|--rebase]
# (those flags in any order, one positional, no other tokens). Anything
# outside that closed set — quotes, expansions, chaining, clustered short
# flags, the `--` separator, `--admin`, `--delete-branch`, any value-taking,
# unknown, or renamed flag — is not the shape and keeps today's table, so a
# `--auto` inside a quoted string or consumed as another flag's value can
# never count, and gh flag-table drift cannot widen the allow row.
#
# EMISSION CONTRACT (owned here; skills/land-feature and skills/auto carry a
# one-line pointer to this paragraph, never a restatement): because the shape is
# this closed, the auto-lane merge must be ISSUED as a bare, un-chained
# `gh pr merge <pr> --auto [--squash|--merge|--rebase]` in its own Bash call —
# never bundled with `&&`/`||`/`;`/`|`, a `$(...)` substitution, or a trailing
# `echo`/`gh pr view`. A bundled merge fails this whitelist, forfeits the allow
# back to `ask`, and stalls a headless run; scripts/check-auto-preflight.sh
# rejects a bundled merge in the command inventory before launch.
#
# --- Attended-merge marker contract (this guard is a reading owner) ----------
#
# Path:    .claude/keel-attended-merge.json  (under CLAUDE_PROJECT_DIR)
# Fields:  scope   — MUST equal "session" (any other value → the file is invalid)
#          created — when the toggle was set, ISO-8601 UTC (parsed AS DATA)
#          invoker — who set it
# All three are required, non-empty strings; any defect → treated as NO marker,
# fail closed. The file is UNTRACKED — a git-tracked copy is a spoof and ignored,
# same as the autonomy mode file. It is written ONLY by the human-triggered
# `keel:auto-merge` skill (`on` writes it, `off` removes it — the write path is
# the authorization trail; `disable-model-invocation` keeps the model from
# invoking the skill).
#
# TTL (8h): the marker is valid only while `created` is within 8 hours of now.
# An expired marker — or an unparseable / future-dated `created` — is treated
# EXACTLY as absent (no marker, byte-for-byte the pre-marker table). The age is
# computed from `created` as parsed data (never eval'd), the same discipline as
# the mode file's 24h TTL. NO REFRESH PATH: the invoking `keel:auto-merge` skill
# is this marker's only writer; nothing extends its life but a fresh human
# `keel:auto-merge on`.
#
# It is the per-session, attended sibling of the autonomy-mode allow row above.
# Under a valid attended marker AND no active autonomy mode (the mode path takes
# precedence — a valid mode file makes the attended marker ignored here), exactly
# one row changes, mirroring the mode row:
#
#   the canonical `gh pr merge ... --auto` shape + gate PASS → "allow"
#     (the redundant per-merge tap is dropped; GitHub still merges when and only
#      when the required checks pass — decisions/2026-07-04-attended-auto-merge.md)
#
# Everything else is byte-for-byte today's table: plain `gh pr merge` without
# `--auto` stays "ask"; gate FAIL stays "deny"; `git merge` / `git push` to the
# default branch stay "ask"; unresolvable context stays "ask"; no marker → the
# existing ask-floor. The same closed-set shape whitelist (detect_strict_auto)
# and emission discipline as the mode row apply — a bundled/chained `--auto`
# forfeits the allow back to "ask".
#
# Safety invariants: the command text is PARSED as data — never eval'd or
# re-executed. `gh pr view` output is data too: parsed into variables and passed
# only as quoted argv/env, never interpolated into shell as code. Decision JSON
# is encoded by jq (python3 fallback, m1's pattern), never by interpolation.
# The marker text is parsed as data too (json_str, the same string-typed reader
# as the mode file), never eval'd.
#
# --- Committed per-project auto-merge marker contract (this guard is the reading
#     owner; specs/features/per-project-auto-merge.md is the spec) --------------
#
# Path:    .claude/keel-auto-merge.json
# Fields:  scope   — MUST equal "project" (any other value → the file is invalid)
#          created — when the marker was armed, ISO-8601 UTC (parsed AS DATA)
#          invoker — who armed it (the keel:arm-auto-merge skill records this)
# All three are required, non-empty strings; any defect → treated as NO marker,
# fail closed.
#
# ROOT OF TRUST — presence on the DEFAULT BRANCH, not the working tree. The marker
# is honored ONLY as read from the default-branch ref proper,
# `origin/$DEFAULT_BRANCH`, via `git show "origin/$DEFAULT_BRANCH:<path>"` — NEVER
# the working-tree file and NEVER `BASE_REF_R` (the target PR's base branch, which
# under the stacked-PR choreography is a SIBLING milestone branch; reading from it
# would honor a marker an agent planted on a lower stack branch). The default
# branch advances only by a human-merged PR, so presence there IS the
# authorization trail: a locally `Write`-n or branch-only .claude/keel-auto-merge.json
# is ignored. This deliberately INVERTS the untracked attended/mode markers' rule
# (they are spoofable-if-tracked, so honored only untracked); this marker's
# authorization is exactly the git history of the default branch, so it is honored
# only when committed there. A best-effort refresh of the remote ref (mirroring
# check-verified-pin.sh's step -1) precedes the read so a human's disarm on real
# `main` is seen; a clone that never fetches at all is the named residual.
#
# NO TTL — a committed setting does not expire (contrast the attended marker's 8h
# and the mode file's 24h). This is safe BECAUSE the read-from-default-branch root
# of trust means the marker got there through a human-merged PR, not because an
# unexpiring local file is trusted. Its only writer/remover is the human-invoked
# keel:arm-auto-merge skill (disable-model-invocation).
#
# It is the per-project, committed sibling of the mode row and the attended row.
# PRECEDENCE: mode > attended > committed. Under NO active mode AND no valid
# attended marker AND a valid committed marker AND the canonical bare
# `gh pr merge <pr> --auto` shape AND gate PASS, exactly one row changes, mirroring
# the mode/attended rows: → "allow" (the redundant per-merge tap is dropped;
# GitHub still merges only when the required checks pass). Everything else is
# byte-for-byte today's table.
#
# HUMAN-TAP RULE (blocks temporary→permanent escalation): any merge-shaped command
# whose target PR TOUCHES .claude/keel-auto-merge.json is NEVER auto-merged — it is
# forced to "ask", BEFORE and regardless of every allow row (mode/attended/
# committed), so no temporary authority (an 8h attended marker, a 24h mode) can
# auto-land the permanent marker's own arming/disarming PR. The PR's file list is
# computed with the non-truncating `git diff --name-only base...head` (never the
# truncatable `gh pr view --json files`); an indeterminate list fails closed to
# "ask". The residual — forging the local default-branch ref itself (`git
# update-ref`/`git branch -f`, not merge/push/commit-shaped) — is the existing
# markers' own threat model, backstopped by the required-checks floor.
#
# Safety: the marker text is parsed as DATA (json_str, string-typed), never eval'd,
# exactly as the mode/attended markers are.

set -euo pipefail
set -f # no globbing: command text is tokenized as data

ROOT="${CLAUDE_PROJECT_DIR:-$PWD}"
cd "$ROOT" 2>/dev/null || true

# --- hook input --------------------------------------------------------------

CMD="" CMD_PARSED=0 RAW="" HOOK_CWD=""
read_hook_command() { # stdin JSON → CMD (tool_input.command), HOOK_CWD (cwd), CMD_PARSED
  # `cwd` — the directory this tool call runs in — is read on BOTH reader paths,
  # STRING-TYPED (jq select(type)/python3 isinstance, so a wrong-typed field reads
  # as absent) and kept as DATA: it is only ever a quoted `git -C` / `cd`
  # argument, never eval'd. Reader-less: no JSON reader → no `cwd` either.
  local input
  input="$(cat 2>/dev/null || true)"
  if command -v jq >/dev/null 2>&1; then
    CMD="$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null || true)"
    HOOK_CWD="$(printf '%s' "$input" | jq -r '.cwd | select(type=="string")' 2>/dev/null || true)"
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
    HOOK_CWD="$(printf '%s' "$input" | python3 -c '
import json, sys
try:
    d = json.load(sys.stdin)
except Exception:
    sys.exit(0)
w = d.get("cwd")
sys.stdout.write(w if isinstance(w, str) else "")
' 2>/dev/null || true)"
    CMD_PARSED=1
  else
    RAW="$input"
  fi
  return 0
}

# --- git context (see the GIT_CTX contract in the header) ----------------------

GIT_CTX="$ROOT"
resolve_git_ctx() { # first USABLE of hook `cwd` → CLAUDE_PROJECT_DIR → PWD
  # Usable = an existing directory inside a git work tree. Nothing usable → ROOT,
  # so the git reads resolve (and fail) exactly as they do today.
  local d
  for d in "$HOOK_CWD" "${CLAUDE_PROJECT_DIR:-}" "$PWD"; do
    [ -n "$d" ] && [ -d "$d" ] || continue
    if [ "$(git -C "$d" rev-parse --is-inside-work-tree 2>/dev/null || true)" = "true" ]; then
      GIT_CTX="$d"
      return 0
    fi
  done
  GIT_CTX="$ROOT"
  return 0
}

gitc() { # the ONE git-read mechanism: every branch-state read runs in GIT_CTX
  # Marker reads deliberately do NOT go through here — they stay at ROOT.
  git -C "$GIT_CTX" "$@"
}

# --- decision output ---------------------------------------------------------

emit() { # <allow|deny|ask> <reason> — JSON-encoded, never interpolated
  local d="$1" r="$2"
  if command -v jq >/dev/null 2>&1; then
    jq -n --arg d "$d" --arg r "$r" \
      '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: $d, permissionDecisionReason: $r}}'
  elif command -v python3 >/dev/null 2>&1; then
    PD="$d" PR="$r" python3 -c '
import json, os
print(json.dumps({"hookSpecificOutput": {"hookEventName": "PreToolUse",
  "permissionDecision": os.environ["PD"],
  "permissionDecisionReason": os.environ["PR"]}}))'
  else
    # No JSON encoder at all: a static, uninterpolated "ask" (never allow).
    printf '%s\n' '{"hookSpecificOutput": {"hookEventName": "PreToolUse", "permissionDecision": "ask", "permissionDecisionReason": "keel merge-guard: no jq or python3 available to encode a decision - defaulting to ask"}}'
  fi
  return 0
}

json_str() { # <json> <key> → prints the value ONLY if it is a string, or nothing
  # Both encoder paths enforce the string type (jq select(type)/python3
  # isinstance): a wrong-typed field reads the same — absent — under either.
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

# --- marker freshness (TTL; see the contracts in the header) ------------------

created_fresh() { # <created-string> <ttl-seconds> → 0 iff parseable AND 0<=age<=ttl
  # `created` is DATA: passed on stdin (jq -Rs) or via env (python3), never
  # interpolated into code, never eval'd. jq first, python3 fallback — the same
  # reader ordering as json_str, held to the SAME accept/reject set: only the
  # strict "%Y-%m-%dT%H:%M:%SZ" ISO-8601 UTC form matching the WHOLE string is
  # fresh. jq slurps the whole value (-Rs) and round-trips it
  # (fromdateiso8601 | todateiso8601 == input) so a valid-prefix-plus-trailing-
  # junk string is rejected exactly as python3's strptime rejects it — no reader
  # is the lenient one. Future-dated (`age < 0`) is rejected too, so a crafted
  # timestamp cannot extend a marker's life past its TTL. No parser → not fresh.
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

# --- autonomy mode (see the mode-file contract in the header) -----------------

MODE_ACTIVE=0 MODE_LEVEL=""

read_mode_file() { # .claude/keel-autonomy.json → MODE_ACTIVE/MODE_LEVEL; any defect → no mode
  MODE_ACTIVE=0 MODE_LEVEL=""
  local f="$ROOT/.claude/keel-autonomy.json" content lvl scope created invoker
  [ -f "$f" ] && [ -r "$f" ] || return 0
  # Contract: the file is untracked. A git-tracked copy is a spoof (someone
  # committed a mode) → treated as no mode.
  if git -C "$ROOT" ls-files --error-unmatch -- .claude/keel-autonomy.json >/dev/null 2>&1; then
    return 0
  fi
  content="$(cat "$f" 2>/dev/null)" || return 0
  lvl="$(json_str "$content" level)"
  scope="$(json_str "$content" scope)"
  created="$(json_str "$content" created)"
  invoker="$(json_str "$content" invoker)"
  case "$lvl" in feature | run | genesis) ;; *) return 0 ;; esac # unknown level → no mode
  # All contract fields must be present, non-empty strings — a partial file
  # (or malformed JSON, which parses to nothing) fails closed.
  [ -n "$scope" ] && [ -n "$created" ] && [ -n "$invoker" ] || return 0
  # TTL (24h): an expired / unparseable / future `created` → treated absent.
  created_fresh "$created" 86400 || return 0
  MODE_ACTIVE=1 MODE_LEVEL="$lvl"
  return 0
}

# --- attended-merge marker (see the marker contract in the header) ------------

ATTENDED_ACTIVE=0

read_attended_marker() { # .claude/keel-attended-merge.json → ATTENDED_ACTIVE; any defect → no marker
  ATTENDED_ACTIVE=0
  local f="$ROOT/.claude/keel-attended-merge.json" content scope created invoker
  [ -f "$f" ] && [ -r "$f" ] || return 0
  # Contract: the file is untracked. A git-tracked copy is a spoof → treated as
  # no marker (parity with read_mode_file).
  if git -C "$ROOT" ls-files --error-unmatch -- .claude/keel-attended-merge.json >/dev/null 2>&1; then
    return 0
  fi
  content="$(cat "$f" 2>/dev/null)" || return 0
  scope="$(json_str "$content" scope)"
  created="$(json_str "$content" created)"
  invoker="$(json_str "$content" invoker)"
  # scope MUST be the literal "session"; created and invoker present, non-empty
  # strings. A partial file, a wrong scope, or malformed JSON fails closed.
  [ "$scope" = "session" ] || return 0
  [ -n "$created" ] && [ -n "$invoker" ] || return 0
  # TTL (8h): an expired / unparseable / future `created` → treated absent.
  created_fresh "$created" 28800 || return 0
  ATTENDED_ACTIVE=1
  return 0
}

# --- committed per-project auto-merge marker (see the contract in the header) --

COMMITTED_ACTIVE=0

read_committed_marker() { # committed .claude/keel-auto-merge.json on the default branch → COMMITTED_ACTIVE
  COMMITTED_ACTIVE=0
  local content scope created invoker
  # Root of trust: the marker is honored ONLY as read from the default-branch ref
  # (origin/$DEFAULT_BRANCH), NEVER the working tree and NEVER BASE_REF_R (a sibling
  # branch under a stack). Best-effort refresh first (mirrors check-verified-pin.sh
  # step -1): a failed fetch warns and proceeds with the local image — never fatal.
  gitc fetch origin "+refs/heads/$DEFAULT_BRANCH:refs/remotes/origin/$DEFAULT_BRANCH" >/dev/null 2>&1 \
    || echo "keel merge-guard: WARN — could not refresh 'origin/$DEFAULT_BRANCH' for the committed auto-merge marker; proceeding with the local ref" >&2
  content="$(gitc show "origin/$DEFAULT_BRANCH:.claude/keel-auto-merge.json" 2>/dev/null)" || return 0
  [ -n "$content" ] || return 0
  scope="$(json_str "$content" scope)"
  created="$(json_str "$content" created)"
  invoker="$(json_str "$content" invoker)"
  # scope MUST be the literal "project"; created and invoker present, non-empty.
  # A partial file, a wrong scope, or malformed JSON fails closed. NO TTL — a
  # committed setting does not expire; its safety is presence on the default
  # branch (human-merged), not freshness.
  [ "$scope" = "project" ] || return 0
  [ -n "$created" ] && [ -n "$invoker" ] || return 0
  COMMITTED_ACTIVE=1
  return 0
}

AUTO_MERGE=0

detect_strict_auto() { # WHITELIST: does $CMD exactly match the canonical delegation shape?
  AUTO_MERGE=0
  # The shape is a CLOSED SET — default deny to ask:
  #   gh pr merge <PR-number-or-safe-ref> --auto [--squash|--merge|--rebase]
  # (flags in any order; exactly one positional; NOTHING else). Any token
  # outside the set — clustered short flags, the `--` separator, value-taking
  # flags, unknown or renamed flags, `--admin`, `--delete-branch` — is not
  # the shape. Enumerating bad flags is structurally fragile (flag clustering
  # and gh's flag table drift); the closed set makes value-position
  # consumption fall to today's ask/deny table by construction, with no
  # knowledge of gh's flag table needed.
  #
  # Preconditions first: single line, then a safe byte whitelist (quotes,
  # expansions, chaining, redirection, globs, escapes all fall out here).
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
      --squash | --merge | --rebase) : ;; # the merge-method flags, allowed
      -*) return 0 ;; # ANY other dash token (`--` itself included) → not the shape
      *)
        [ -z "$pos" ] || return 0 # a second positional → not the shape
        printf '%s' "$t" | LC_ALL=C grep -qE '^[0-9]+$|^[A-Za-z0-9][A-Za-z0-9._/-]*$' \
          || return 0 # a PR number or a conservative branch-name charset only
        pos="$t"
        ;;
    esac
    i=$((i + 1))
  done
  [ -n "$pos" ] && [ "$auto" -eq 1 ] || return 0
  AUTO_MERGE=1
  return 0
}

# --- default branch ----------------------------------------------------------

detect_default_branch() { # origin/HEAD → main/master probe → "main" (read in GIT_CTX)
  local ref b
  if ref="$(gitc symbolic-ref --quiet refs/remotes/origin/HEAD 2>/dev/null)"; then
    printf '%s\n' "${ref#refs/remotes/origin/}"
    return 0
  fi
  for b in main master; do
    if gitc show-ref --verify --quiet "refs/heads/$b" 2>/dev/null \
      || gitc show-ref --verify --quiet "refs/remotes/origin/$b" 2>/dev/null; then
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
# Classification sees only the literal command text and strips a single outer
# quote layer per token. Like any text-level hook it cannot see through shell
# reassembly (`git "me""rge"`, `m=merge; git $m`, aliases, `sh -c`, `eval`,
# piped `xargs`) — that is the documented inherent limit, asserted as the
# accepted set by merge-guard.test.sh's bypass block; this guard is
# defense-in-depth under branch protection + required checks (the authority),
# the skill-scoped branch guard, and human merge approval.

SHAPE="" GH_PR_ARG=""
TOKS=()
N=0 I=0

classify_gh() { # after `gh`: skip flags (value-taking ones skip their value)
  local w w1="" w2="" w3=""
  while [ "$I" -lt "$N" ]; do
    w="${TOKS[$I]}"
    case "$w" in
      --repo | -R | --hostname | -t | --subject | -b | --body | -F | --body-file | -A | --author-email | --match-head-commit)
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
        dst="$(gitc rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
      fi
      if [ -n "$dst" ] && [ "$dst" = "$DEFAULT_BRANCH" ]; then
        SHAPE="git-push"
        return 0
      fi
    fi
    I=$((I + 1))
  done
  if [ "$pos" -le 1 ]; then # bare `git push` [remote]: implicit current branch
    cur="$(gitc rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
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

classify_cmd() { # <command text> → SHAPE, GH_PR_ARG (+ GIT_COMMIT)
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

# --- decision ----------------------------------------------------------------

BASE_REF_R="" HEAD_REF_R=""

resolve_gh_context() { # gh pr view → BASE_REF_R / HEAD_REF_R, as locally resolvable refs
  command -v gh >/dev/null 2>&1 || return 1
  local json b h
  if [ -n "$GH_PR_ARG" ]; then
    json="$(gh pr view "$GH_PR_ARG" --json baseRefName,headRefName 2>/dev/null)" || return 1
  else
    json="$(gh pr view --json baseRefName,headRefName 2>/dev/null)" || return 1
  fi
  b="$(json_str "$json" baseRefName)" # DATA: quoted argv/env only from here on
  h="$(json_str "$json" headRefName)"
  if [ -z "$b" ] || [ -z "$h" ]; then return 1; fi
  if gitc rev-parse --verify --quiet "refs/remotes/origin/$b^{commit}" >/dev/null 2>&1; then
    BASE_REF_R="origin/$b"
  elif gitc rev-parse --verify --quiet "refs/heads/$b^{commit}" >/dev/null 2>&1; then
    BASE_REF_R="refs/heads/$b"
  else
    return 1
  fi
  if gitc rev-parse --verify --quiet "refs/remotes/origin/$h^{commit}" >/dev/null 2>&1; then
    HEAD_REF_R="origin/$h"
  elif gitc rev-parse --verify --quiet "refs/heads/$h^{commit}" >/dev/null 2>&1; then
    HEAD_REF_R="refs/heads/$h"
  else
    return 1
  fi
  return 0
}

pr_touches_marker() { # 0 = the PR touches the marker OR the file list is indeterminate (fail closed); 1 = definitely does not
  # The PR's own change set is base...head (three-dot: symmetric-difference from
  # the merge base, the same diff shape check-verified-pin.sh uses). Non-truncating
  # by construction — NOT `gh pr view --json files`, which truncates on large PRs
  # and would let a padded marker-touching PR evade this control. Any diff error
  # (unresolvable refs, no merge base) → fail closed (return 0 → the caller emits ask).
  local files
  files="$(gitc diff --name-only "$BASE_REF_R"..."$HEAD_REF_R" 2>/dev/null)" || return 0
  printf '%s\n' "$files" | grep -qxF '.claude/keel-auto-merge.json' && return 0
  return 1
}

decide() { # merge-shaped: ask/deny — plus the one mode-gated row in the header contract
  # The gate SCRIPT's path comes from ROOT (a project asset, like the markers);
  # it is INVOKED FROM GIT_CTX so it judges the checkout the command runs in.
  local gate="$ROOT/scripts/check-verified-pin.sh" err reason d_auto
  if [ ! -f "$gate" ]; then
    emit ask "merge-shaped command — unresolvable: this project has no scripts/check-verified-pin.sh gate to consult; per-merge human approval required"
    return 0
  fi
  if [ "$SHAPE" = "gh-pr-merge" ]; then
    if ! resolve_gh_context; then
      emit ask "merge-shaped command (gh pr merge) — unresolvable: PR context (gh pr view --json baseRefName,headRefName failed, or its base/head refs are not present locally); per-merge human approval required"
      return 0
    fi
  else
    if gitc rev-parse --verify --quiet "refs/remotes/origin/$DEFAULT_BRANCH^{commit}" >/dev/null 2>&1; then
      BASE_REF_R="origin/$DEFAULT_BRANCH"
    elif gitc rev-parse --verify --quiet "refs/heads/$DEFAULT_BRANCH^{commit}" >/dev/null 2>&1; then
      BASE_REF_R="refs/heads/$DEFAULT_BRANCH"
    fi
    HEAD_REF_R="$(gitc rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
    if [ -z "$BASE_REF_R" ] || [ -z "$HEAD_REF_R" ]; then
      emit ask "merge-shaped command — unresolvable: local merge context (default-branch ref '$DEFAULT_BRANCH' or the current branch); per-merge human approval required"
      return 0
    fi
  fi
  err="$(mktemp)"
  if (cd "$GIT_CTX" && BASE_REF="$BASE_REF_R" "$gate" "$HEAD_REF_R") >/dev/null 2>"$err"; then
    if [ "$SHAPE" = "gh-pr-merge" ] && pr_touches_marker; then
      # Human-tap rule (header contract): a PR arming or disarming the committed
      # marker is never auto-merged — forced to ask BEFORE and regardless of every
      # allow row, so no temporary authority can auto-land the permanent marker.
      emit ask "this PR touches the committed auto-merge marker (.claude/keel-auto-merge.json) — arming or disarming per-project auto-merge always takes a human merge tap; no marker or mode auto-merges its own change (specs/features/per-project-auto-merge.md)"
    elif [ "$MODE_ACTIVE" -eq 1 ] && [ "$AUTO_MERGE" -eq 1 ] && [ "$SHAPE" = "gh-pr-merge" ]; then
      # The one row a valid mode changes (header contract). The decision word
      # is bound through a variable so the self-test's static scan — a
      # tripwire against a bare unconditional allow literal — stays live.
      d_auto="allow"
      emit "$d_auto" "autonomy mode active (level: $MODE_LEVEL) — gh pr merge --auto on a gate-passing PR delegates the merge to the server-side required checks (decisions/2026-07-05-autonomy-modes-v2.md + decisions/2026-07-genesis-envelope.md); GitHub merges when and only when the required checks pass"
    elif [ "$MODE_ACTIVE" -eq 0 ] && [ "$ATTENDED_ACTIVE" -eq 1 ] && [ "$AUTO_MERGE" -eq 1 ] && [ "$SHAPE" = "gh-pr-merge" ]; then
      # The attended sibling of the mode row (header contract): a per-session,
      # human-set marker drops the redundant per-merge tap on the same bare
      # `--auto` + gate-pass shape. Autonomy mode takes precedence (guarded by
      # MODE_ACTIVE=0 above). Same variable-bound decision word, so the
      # no-bare-`allow`-literal tripwire stays live.
      d_auto="allow"
      emit "$d_auto" "attended auto-merge active — an instructed gh pr merge --auto on a gate-passing PR delegates the merge to the server-side required checks (decisions/2026-07-04-attended-auto-merge.md); the per-merge tap is dropped for this session, GitHub merges when and only when the required checks pass"
    elif [ "$MODE_ACTIVE" -eq 0 ] && [ "$ATTENDED_ACTIVE" -eq 0 ] && [ "$COMMITTED_ACTIVE" -eq 1 ] && [ "$AUTO_MERGE" -eq 1 ] && [ "$SHAPE" = "gh-pr-merge" ]; then
      # The committed per-project sibling of the mode/attended rows (header
      # contract): a marker committed to the default branch — a standing human
      # authorization — drops the per-merge tap on the same bare `--auto` + gate-pass
      # shape, for every session in the repo. Precedence mode > attended > committed
      # is enforced by the MODE_ACTIVE=0 && ATTENDED_ACTIVE=0 guard; the human-tap
      # rule above has already excluded a marker-touching PR. Same variable-bound
      # decision word, so the no-bare-`allow`-literal tripwire stays live.
      d_auto="allow"
      emit "$d_auto" "committed per-project auto-merge active — a marker committed to the default branch is a standing human authorization; an instructed gh pr merge --auto on a gate-passing PR delegates the merge to the server-side required checks (specs/features/per-project-auto-merge.md); GitHub merges when and only when the required checks pass"
    else
      emit ask "verified-pin gate passed — per-merge human approval"
    fi
  else
    reason="$(cat "$err" 2>/dev/null || true)"
    if [ -z "$reason" ]; then reason="verified-pin gate failed with no reason on stderr"; fi
    emit deny "$reason"
  fi
  rm -f "$err"
  return 0
}

# --- main ---------------------------------------------------------------------

GIT_COMMIT=0 # set by the classifier; unused here (guard-branch-rules.sh consumes it)

read_hook_command
if [ "$CMD_PARSED" -ne 1 ]; then
  # No jq AND no python3: we cannot extract the command. Never auto-allow a
  # possibly merge-shaped one — crude data-only scan of the raw input, static ask.
  if printf '%s' "$RAW" | grep -qiE '\bmerge\b|\bpush\b'; then
    emit ask "keel merge-guard: cannot parse the hook input (neither jq nor python3 is available) and the raw input mentions merge/push — defaulting to ask; merge-shaped commands are never auto-allowed"
  fi
  exit 0
fi
if [ -z "$CMD" ]; then exit 0; fi # not a Bash command payload

resolve_git_ctx # branch state comes from the checkout the command runs in
DEFAULT_BRANCH="$(detect_default_branch)"
REMOTES="$(gitc remote 2>/dev/null | tr '\n' ' ' || true)"
if [ -z "${REMOTES// /}" ]; then REMOTES="origin"; fi

classify_cmd "$CMD"
if [ -z "$SHAPE" ]; then exit 0; fi # not merge-shaped → allow silently

read_mode_file       # no/invalid mode file → MODE_ACTIVE=0 → today's table exactly
read_attended_marker # no/invalid marker → ATTENDED_ACTIVE=0; ignored when a mode is active
detect_strict_auto   # only a single plain `gh pr merge ... --auto` sets AUTO_MERGE
# The committed marker is consulted only when it could actually decide the row —
# no active mode, no valid attended marker (precedence: mode > attended > committed).
# This also skips its best-effort fetch under a mode/attended run.
if [ "$MODE_ACTIVE" -eq 0 ] && [ "$ATTENDED_ACTIVE" -eq 0 ]; then
  read_committed_marker # no/invalid marker on the default branch → COMMITTED_ACTIVE=0
fi

decide
exit 0
