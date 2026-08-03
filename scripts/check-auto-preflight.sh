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
#   (b2) asserts the security-review check is CONTENT, not just a name: some
#       file under .github/workflows/ both declares the check context and
#       matches the review-implementation pattern (default
#       `claude-code-security-review`; PREFLIGHT_SECREVIEW_PATTERN overrides for
#       a different in-Actions implementation). A non-Actions provider has no
#       workflow to scan — PREFLIGHT_SECREVIEW_EXTERNAL=1 attests it explicitly,
#       echoed loudly in the output, never silently;
#   (c) asserts every env-var NAME in the architecture contract (backtick-quoted
#       ALL_CAPS tokens, e.g. `STRIPE_SECRET_KEY`) resolves in the host env
#       store — the process environment or a `NAME=` line in the derived env
#       file. Names only: values are never read into output, never echoed.
#   (d) asserts via `gh api` that the repo has `allow_auto_merge` enabled — the
#       repo setting that lets `gh pr merge --auto` queue a merge instead of
#       falling back to an interactive prompt. Disabled / missing / API-error →
#       a gap: an unattended run's `--auto` would stall on a prompt. The fix is
#       attended (repo Settings → Allow auto-merge, or `gh api -X PATCH`).
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

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="${1:-$(cd "$SCRIPT_DIR/.." && pwd)}"
cd "$ROOT"

# --- config block (a project copy edits these; env overrides for one-offs) ----
INVENTORY_FILE="${PREFLIGHT_INVENTORY:-specs/run-command-inventory.txt}"
SETTINGS_FILE="${PREFLIGHT_SETTINGS:-.claude/settings.json}"
CONTRACT_FILE="${PREFLIGHT_CONTRACT:-specs/01-architecture.md}"
ENV_FILE="${PREFLIGHT_ENV_FILE:-.env.local}"
# Required status-check job names, space-separated — whatever the CI vendor
# calls the verified-pin job, the plan-lint job, and the security-review job.
# A consuming repo more commonly declares its own names in a COMMITTED
# .claude/keel-auto-merge-checks.json (read by check-branch-protection.sh); this
# config-block value and PREFLIGHT_REQUIRED_CHECKS remain the operator-override
# tier above it (decisions/2026-08-03-arm-auto-merge-check-contract.md).
# The editable config-block default is the literal below (a project copy may edit
# it); KEEL_DEFAULT_CHECKS is a SEPARATE immutable sentinel with the same value,
# used only to tell an unmodified config block from an edited one — do not edit it.
REQUIRED_CHECKS="${PREFLIGHT_REQUIRED_CHECKS:-verified-pin plan-lint security-review}"
KEEL_DEFAULT_CHECKS="verified-pin plan-lint security-review"
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
            # Claude Code's `Bash(<prefix>:*)` means "<prefix> then any args" — the
            # ':' is the syntax separator, not a literal in the command. Normalize a
            # trailing ':*' to a '*' glob so a space-delimited shape (e.g.
            # `gh pr merge 5 --auto`) matches `Bash(gh pr merge:*)` here the same way
            # it does in the harness, instead of false-gapping the canonical rule form.
            case "$pat" in *":*") pat="${pat%:*}*" ;; esac
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

# --- (a2) no BUNDLED merge in the inventory ----------------------------------
# The merge-guard auto-allows exactly a BARE `gh pr merge <ref> --auto` (its
# whitelist rejects any chaining outright). A `gh pr merge` bundled with another
# command in one shell call — `gh pr merge 5 && gh pr view 5`, `P=$(gh pr merge …)`
# — forfeits that allow and falls back to `ask`, which stalls a headless run mid-
# flight. Catch it before launch. Pure string scan: needs no jq, so it fires even
# when the allowlist dry-run above could not run.
if [ -f "$INVENTORY_FILE" ]; then
  while IFS= read -r shape; do
    case "$shape" in ''|'#'*) continue ;; esac
    case "$shape" in *"gh pr merge"*) ;; *) continue ;; esac
    case "$shape" in
      *"&&"* | *"||"* | *";"* | *"|"* | *'$('* | *'`'*)
        gap "inventory: bundled merge — '$shape' chains \`gh pr merge\` with another command; emit it BARE (\`gh pr merge <ref> --auto\`) in its own call, or the merge-guard's strict-auto allow forfeits to a prompt and the run stalls"
        ;;
    esac
  done < "$INVENTORY_FILE"
fi

# --- (b) + (b2) + (d) branch protection: delegated to the shared assertion -----
# The merge-relevant subset — the required checks are actually REQUIRED, the
# security-review check is CONTENT (not just a name), and allow_auto_merge is
# enabled — is the SAME assertion keel:arm-auto-merge runs, so it lives in ONE
# script both call and can never drift. check-branch-protection.sh emits its gaps
# to stderr in the same GAP vocabulary and defaults; a non-zero exit is one
# preflight gap here (its own gap lines already named the specifics on stderr).
# Forward THIS preflight's required-check set to the child ONLY when it is a REAL
# override — i.e. PREFLIGHT_REQUIRED_CHECKS is set in the environment, OR a project
# copy has EDITED the config-block default away from keel's built-in string. When
# it equals the unmodified built-in default, forward NOTHING, so the child resolves
# a committed .claude/keel-auto-merge-checks.json itself (precedence operator
# override > committed config > keel default; decisions/2026-08-03-arm-auto-merge-
# check-contract.md). Forwarding the unmodified default as if it were an override
# would MASK a committed config; NOT forwarding an edited config-block value would
# be the fail-open regression the pre-extraction preflight guarded against.
BP="$SCRIPT_DIR/check-branch-protection.sh"
bp_forward=0
[ -n "${PREFLIGHT_REQUIRED_CHECKS+set}" ] && bp_forward=1
[ "$REQUIRED_CHECKS" != "$KEEL_DEFAULT_CHECKS" ] && bp_forward=1
if [ -x "$BP" ]; then
  if [ "$bp_forward" -eq 1 ]; then
    PREFLIGHT_REQUIRED_CHECKS="$REQUIRED_CHECKS" "${BASH:-bash}" "$BP" "$ROOT" >/dev/null || fails=$((fails + 1))
  else
    "${BASH:-bash}" "$BP" "$ROOT" >/dev/null || fails=$((fails + 1))
  fi
else
  gap "branch-protection: $BP is missing or not executable — cannot assert the required-checks / auto-merge posture (fail closed)"
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
  echo "auto-preflight: PASS — inventory covered, required checks required, contract env names resolve, repo allows auto-merge"
  exit 0
fi
echo "auto-preflight: $fails gap(s) — fix attended before launching an auto run; never widen permissions mid-run" >&2
exit 1
