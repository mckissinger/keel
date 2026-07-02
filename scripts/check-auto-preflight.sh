#!/usr/bin/env bash
#
# check-auto-preflight.sh — the hard entry gate for an unattended (auto-mode) run.
#
# A headless auto run aborts after repeated classifier blocks (3 consecutive /
# 20 total), so an undrained permission prompt or missing credential kills the
# run instead of pausing it. This preflight makes that checkable BEFORE launch:
#
#   (a) dry-runs the run's committed COMMAND INVENTORY (one command shape per
#       line; `#` comments and blank lines skipped) against the committed
#       `.claude/settings.json` allowlist, reporting any shape no allow rule
#       covers;
#   (b) asserts via `gh api` that branch protection exists on the default
#       branch and that its REQUIRED status checks include every job named in
#       the config block below (job names are config, not a CI-vendor hardcode);
#   (c) asserts every env-var NAME in the architecture contract (backtick-quoted
#       ALL_CAPS tokens, e.g. `STRIPE_SECRET_KEY`) resolves in the host env
#       store — the process environment or a `NAME=` line in the derived env
#       file. Names only: values are never read into output, never echoed.
#
# Exit 0 = ready for an auto run. Non-zero = one or more gaps, each named on
# stderr. Fails closed: a missing input file, unparsable settings, or missing
# `gh`/`jq` is a gap, never a silent pass. A preflight failure is fixed
# attended — never worked around by widening permissions mid-run.
#
# This is the canonical implementation. Provision copies it into a project
# like the pin gate; it is never re-authored from prose (the prose owner is
# skills/provision/SKILL.md's auto-provision envelope section).
#
# Usage: scripts/check-auto-preflight.sh [ROOT]   (ROOT defaults to the repo root)

set -uo pipefail

ROOT="${1:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

# --- config block (a project copy edits these; env overrides for one-offs) ----
INVENTORY_FILE="${PREFLIGHT_INVENTORY:-specs/run-command-inventory.txt}"
SETTINGS_FILE="${PREFLIGHT_SETTINGS:-.claude/settings.json}"
CONTRACT_FILE="${PREFLIGHT_CONTRACT:-specs/01-architecture.md}"
ENV_FILE="${PREFLIGHT_ENV_FILE:-.env.local}"
# Required status-check job names, space-separated — whatever the CI vendor
# calls the verified-pin job, the plan-lint job, and the security-review job.
REQUIRED_CHECKS="${PREFLIGHT_REQUIRED_CHECKS:-verified-pin plan-lint security-review}"
# ------------------------------------------------------------------------------

fails=0
gap() { echo "auto-preflight: GAP — $1" >&2; fails=$((fails + 1)); }

HAVE_JQ=0; command -v jq >/dev/null 2>&1 && HAVE_JQ=1
HAVE_GH=0; command -v gh >/dev/null 2>&1 && HAVE_GH=1
[ "$HAVE_JQ" -eq 1 ] || gap "dependency: jq is unavailable — cannot parse the allowlist or protection JSON (fail closed)"
[ "$HAVE_GH" -eq 1 ] || gap "dependency: gh is unavailable — cannot verify branch protection (fail closed)"

# --- (a) command inventory vs the committed allowlist -------------------------
if [ "$HAVE_JQ" -eq 1 ]; then
  if [ ! -f "$INVENTORY_FILE" ]; then
    gap "inventory: $INVENTORY_FILE missing — commit the run's command shapes before an auto run (fail closed)"
  elif [ ! -f "$SETTINGS_FILE" ]; then
    gap "allowlist: $SETTINGS_FILE missing — no committed allowlist to dry-run against (fail closed)"
  elif ! jq -e . "$SETTINGS_FILE" >/dev/null 2>&1; then
    gap "allowlist: $SETTINGS_FILE is not parsable JSON (fail closed)"
  else
    rules=()
    while IFS= read -r r; do [ -n "$r" ] && rules+=("$r"); done \
      < <(jq -r '.permissions.allow // [] | .[]' "$SETTINGS_FILE" 2>/dev/null)
    while IFS= read -r shape; do
      case "$shape" in ''|'#'*) continue ;; esac
      covered=0
      for r in ${rules[@]+"${rules[@]}"}; do
        case "$r" in
          "Bash("*")")
            pat="${r#Bash(}"; pat="${pat%)}"
            case "$shape" in $pat) covered=1 ;; esac
            ;;
          *)
            [ "$shape" = "$r" ] && covered=1 # non-Bash tool entry: exact name
            ;;
        esac
        [ "$covered" -eq 1 ] && break
      done
      [ "$covered" -eq 1 ] \
        || gap "inventory: no allow rule in $SETTINGS_FILE covers the command shape: $shape"
    done < "$INVENTORY_FILE"
  fi
fi

# --- (b) branch protection: the required checks are actually REQUIRED ---------
if [ "$HAVE_GH" -eq 1 ] && [ "$HAVE_JQ" -eq 1 ]; then
  default_branch="main"
  if command -v git >/dev/null 2>&1; then
    if ref="$(git symbolic-ref --quiet refs/remotes/origin/HEAD 2>/dev/null)"; then
      default_branch="${ref#refs/remotes/origin/}"
    else
      for b in main master; do
        if git show-ref --verify --quiet "refs/heads/$b" 2>/dev/null \
          || git show-ref --verify --quiet "refs/remotes/origin/$b" 2>/dev/null; then
          default_branch="$b"; break
        fi
      done
    fi
  fi
  if prot="$(gh api "repos/{owner}/{repo}/branches/$default_branch/protection" 2>/dev/null)"; then
    contexts="$(printf '%s' "$prot" | jq -r \
      '[(.required_status_checks.contexts // []), ((.required_status_checks.checks // []) | map(.context))] | add | .[]?' \
      2>/dev/null || true)"
    for want in $REQUIRED_CHECKS; do
      found=0
      while IFS= read -r have; do
        [ "$have" = "$want" ] && found=1
      done <<EOF
$contexts
EOF
      [ "$found" -eq 1 ] \
        || gap "protection: check '$want' is not a REQUIRED status check in branch protection on '$default_branch' (a check that exists but is not required does not gate the merge)"
    done
  else
    gap "protection: no readable branch protection on '$default_branch' (gh api .../protection failed — configure it attended before an auto run)"
  fi
fi

# --- (c) contract env-var names resolve — names only, never values ------------
env_file_has() { # <NAME> — a NAME= line exists; the value is never read out
  [ -f "$ENV_FILE" ] || return 1
  while IFS= read -r l; do
    case "$l" in "$1="*|"export $1="*) return 0 ;; esac
  done < "$ENV_FILE"
  return 1
}
if [ ! -f "$CONTRACT_FILE" ]; then
  gap "contract: $CONTRACT_FILE missing — no environment contract to check env-var names against (fail closed)"
else
  seen=" "
  re='`([A-Z][A-Z0-9_]{3,})`'
  while IFS= read -r line; do
    while [[ "$line" =~ $re ]]; do
      name="${BASH_REMATCH[1]}"
      line="${line#*\`$name\`}"
      case "$seen" in *" $name "*) continue ;; esac
      seen="$seen$name "
      if [ -n "${!name+x}" ] || env_file_has "$name"; then
        echo "auto-preflight: env $name — present (name check only)"
      else
        gap "env: $name (named in $CONTRACT_FILE) does not resolve in the host env or $ENV_FILE — provision it attended (names only; values are never read)"
      fi
    done
  done < "$CONTRACT_FILE"
fi

if [ "$fails" -eq 0 ]; then
  echo "auto-preflight: PASS — inventory covered, required checks required, contract env names resolve"
  exit 0
fi
echo "auto-preflight: $fails gap(s) — fix attended before launching an auto run; never widen permissions mid-run" >&2
exit 1
