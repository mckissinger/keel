#!/usr/bin/env bash
#
# check-neutral.sh — guards keel's OWN stack-neutral corpus against retained
# framework/command language and editing scars.
#
# keel is a stack-neutral methodology plugin; its methodology docs must not name
# a specific framework, library, or command as if it were required. This guard
# scans the corpus (skills, references, agents, workflows, README) for a denylist
# of UNAMBIGUOUS leaks — a stale command name, a hardcoded framework path, a
# retained project name, an anonymization scar. It does NOT ban framework names
# used as hedged examples ("e.g. Supabase"); those are legitimate and stay.
#
# Design-track prose is intentionally web/CSS-specific (app-design-directions,
# interaction-craft, motion-cookbook), so this guard deliberately checks only the
# hard leaks/scars that must be zero EVERYWHERE — never generic web terms.
#
# Usage: scripts/check-neutral.sh [ROOT]     (ROOT defaults to the repo root)
# Exit 0 = clean. Non-zero = a leak class was found, printed to stderr.

set -uo pipefail

ROOT="${1:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

# Scan the methodology corpus only. scripts/ is excluded on purpose — this guard
# and its self-test legitimately contain the banned strings as test data.
targets=()
for d in skills references agents workflows; do [ -d "$d" ] && targets+=("$d"); done
[ -f README.md ] && targets+=("README.md")
if [ ${#targets[@]} -eq 0 ]; then
  echo "check-neutral: nothing to scan under $ROOT — pass"
  exit 0
fi

fails=0
flag() { # pattern  human-reason
  local hits
  hits="$(grep -rniE --include='*.md' --include='*.js' "$1" "${targets[@]}" 2>/dev/null || true)"
  if [ -n "$hits" ]; then
    echo "check-neutral: FAIL — $2" >&2
    printf '%s\n' "$hits" | sed 's/^/  /' >&2
    fails=$((fails + 1))
  fi
}

# Stale command name — keel has no /goal; the build verbs are implement-milestone / implement-feature.
flag '/goal\b'                                   'stale /goal command — use implement-milestone / implement-feature'
# Framework-specific mechanics that must route through the stack profile, not a hardcode.
flag 'src/app/'                                   'hardcoded Next.js path — detect surfaces via the stack profile (Q1/Q2)'
flag '\bRLS\b'                                    'Postgres-specific "RLS" — say "invariant" / "row security" generically'
flag 'server action'                              'Next.js term "server action" — say "state-changing action"'
# Retained war-story project names — genericize to "an earlier run".
flag 'meridian|\bWave-[0-9]'                       'retained project name — genericize to "an earlier run"'
# Editing scars from the anonymization pass.
flag 'a an earlier|[[:space:]]run run[[:space:]]|harness harness|\bthe the\b' 'doubled-word / anonymization scar'

# --- Design-neutrality: the SHARED NEUTRAL CORPUS must name no web hardcode. ------
# The build/verify spine is framework-neutral by profile, so these exact spine paths
# must never name a web-only design token/library (@theme, Lucide, Recharts) as if it
# were THE way — those belong behind the stack profile's design verbs. This is a
# DEDICATED SCOPED grep over just the spine paths below, NOT the blanket `flag` above,
# precisely because the design-track files (skills/app-design-directions/**,
# references/motion-cookbook.md) use these same names as LEGITIMATE web examples and
# must stay exempt — they are deliberately left out of `spine` and never scanned here.
spine=(
  references/milestones-and-verification.md
  references/profile-interface.md
  skills/implement-milestone
  skills/spec-feature
  skills/spec-change
  skills/verify-milestone
)
scope=()
for p in "${spine[@]}"; do [ -e "$p" ] && scope+=("$p"); done
if [ ${#scope[@]} -gt 0 ]; then
  spine_hits="$(grep -rniE --include='*.md' --include='*.js' \
    '@theme|\bLucide\b|\bRecharts\b' "${scope[@]}" 2>/dev/null || true)"
  if [ -n "$spine_hits" ]; then
    echo "check-neutral: FAIL — web hardcode (@theme/Lucide/Recharts) in the shared neutral corpus; route design tokens/libraries through the stack profile's design verbs (web-specific names stay in the design-track files only)" >&2
    printf '%s\n' "$spine_hits" | sed 's/^/  /' >&2
    fails=$((fails + 1))
  fi
fi

if [ "$fails" -eq 0 ]; then
  echo "check-neutral: PASS — no retained stack/command language"
  exit 0
fi
echo "check-neutral: $fails leak class(es) found" >&2
exit 1
