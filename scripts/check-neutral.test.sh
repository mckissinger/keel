#!/usr/bin/env bash
#
# Self-test for check-neutral.sh. Builds throwaway corpora in a temp dir and
# asserts the guard's exit code for each. No network, no fixtures.
#
# Run: bash scripts/check-neutral.test.sh

set -uo pipefail
SCRIPT="$(cd "$(dirname "$0")" && pwd)/check-neutral.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

pass=0 failc=0
check() { # desc  expected_exit
  local desc="$1" exp="$2" got
  bash "$SCRIPT" "$ROOT" >/dev/null 2>&1 && got=0 || got=$?
  if [ "$got" -eq "$exp" ]; then
    echo "ok   - $desc"; pass=$((pass + 1))
  else
    echo "FAIL - $desc (got exit $got, want $exp)"; failc=$((failc + 1))
  fi
}
fresh() { ROOT="$TMP/$1"; mkdir -p "$ROOT/skills/x" "$ROOT/references" "$ROOT/workflows"; }

# 1. A clean corpus passes.
fresh c1-clean
echo "# activate a surface, drive a state-changing action; verify via implement-milestone" > "$ROOT/skills/x/SKILL.md"
check "clean corpus passes" 0

# 2. A hedged framework example is NOT a leak (we keep those).
fresh c2-hedged
echo "default what's defaultable (e.g. Supabase for the database, Vercel for hosting)." > "$ROOT/skills/x/SKILL.md"
check "hedged framework example passes" 0

# 3. Stale /goal command fails.
fresh c3-goal
echo "after a multi-milestone /goal run, sweep the milestones" > "$ROOT/references/rules.md"
check "stale /goal command fails" 1

# 4. Hardcoded Next.js path fails.
fresh c4-srcapp
echo 'if the milestone touches a route (`src/app/**`) block it' > "$ROOT/workflows/w.js"
check "hardcoded src/app path fails" 1

# 5. RLS fails.
fresh c5-rls
echo "the sweep can close schema/RLS/unit checks" > "$ROOT/skills/x/SKILL.md"
check "Postgres RLS term fails" 1

# 6. "server action" fails.
fresh c6-sa
echo "any milestone that adds a route or server action needs the walk" > "$ROOT/references/rules.md"
check "server action term fails" 1

# 7. Retained project name fails.
fresh c7-name
echo "Meridian's /location route shipped as a stub" > "$ROOT/references/rules.md"
check "retained project name fails" 1

# 8. Numbered wave name fails, but generic 'by wave' is fine.
fresh c8-wave
echo "spec a Wave-2 of features and build concurrently" > "$ROOT/skills/x/SKILL.md"
check "numbered Wave-2 name fails" 1

fresh c8b-wave-ok
echo "by wave: spec a wave of independent features, build concurrently" > "$ROOT/skills/x/SKILL.md"
check "generic 'by wave' passes" 0

# 9. Anonymization scar fails.
fresh c9-scar
echo "a an earlier run run asserted it while main was unprotected" > "$ROOT/skills/x/SKILL.md"
check "doubled-word scar fails" 1

echo "-------------------------------------"
echo "$pass passed, $failc failed"
[ "$failc" -eq 0 ]
