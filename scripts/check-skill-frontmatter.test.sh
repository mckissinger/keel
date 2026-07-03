#!/usr/bin/env bash
#
# Self-test for check-skill-frontmatter.sh. Builds throwaway fixture skill dirs
# in a temp root and asserts the lint's exit code (and, where the done-conditions
# call for it, that the offending field is named on stderr). No network, no
# fixtures on disk.
#
# Run: bash scripts/check-skill-frontmatter.test.sh

set -uo pipefail
SCRIPT="$(cd "$(dirname "$0")" && pwd)/check-skill-frontmatter.sh"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

pass=0 failc=0
check() { # desc  expected_exit  [stderr_substring]
  local desc="$1" exp="$2" needle="${3:-}" got err ok=1
  err="$(bash "$SCRIPT" "$ROOT" 2>&1 >/dev/null)" && got=0 || got=$?
  [ "$got" -eq "$exp" ] || ok=0
  if [ -n "$needle" ] && ! printf '%s' "$err" | grep -q -- "$needle"; then ok=0; fi
  if [ "$ok" -eq 1 ]; then
    echo "ok   - $desc"; pass=$((pass + 1))
  else
    echo "FAIL - $desc (got exit $got, want $exp; needle '$needle'; stderr: $err)"
    failc=$((failc + 1))
  fi
}
fresh()   { ROOT="$TMP/$1"; mkdir -p "$ROOT/skills"; }
mkskill() { mkdir -p "$ROOT/skills/$1"; cat > "$ROOT/skills/$1/SKILL.md"; }

# 1. A well-formed skill (name == dir, description + when_to_use present) passes.
fresh c1-clean
mkskill good <<'EOF'
---
name: good
description: A perfectly ordinary one-line description.
when_to_use: When you need the ordinary thing and nothing fancier.
---
# Good
EOF
check "well-formed skill passes" 0

# 2. A skill missing `name` fails, naming `name` on stderr.
fresh c2-no-name
mkskill noname <<'EOF'
---
description: Present.
when_to_use: When present.
---
# No name
EOF
check "missing name fails, names 'name'" 1 "name"

# 3. A skill missing `description` fails, naming `description` on stderr.
fresh c3-no-desc
mkskill nodesc <<'EOF'
---
name: nodesc
when_to_use: When present.
---
# No description
EOF
check "missing description fails, names 'description'" 1 "description"

# 4. A skill missing `when_to_use` fails, naming `when_to_use` on stderr.
fresh c4-no-wtu
mkskill nowtu <<'EOF'
---
name: nowtu
description: Present.
---
# No when_to_use
EOF
check "missing when_to_use fails, names 'when_to_use'" 1 "when_to_use"

# 5. A skill whose `name` value MISMATCHES its directory name fails.
fresh c5-name-mismatch
mkskill realdir <<'EOF'
---
name: someothername
description: Present.
when_to_use: When present.
---
# Mismatch
EOF
check "name != directory fails, names 'name'" 1 "name"

# 6. KEY anti-overreach case: a description that SUMMARIZES a workflow (a long,
#    multi-clause paragraph, complete with a "NOT" disambiguation clause) but
#    carries all three fields present PASSES — proving the lint stays field-
#    presence only and never reaches into M2's semantic territory.
fresh c6-workflow-summary
mkskill busy <<'EOF'
---
name: busy
description: Orchestrate the whole thing end to end — interview the request, restate the goal, fan out the sub-steps in dependency order, compose from the workbench, author the checks, halt at the stop-points, then hand off; defaults to the interleaved cadence but always asks first. NOT for a single small step, and NOT for merging.
when_to_use: After the upstream gate has run, when the whole batch needs driving to done. NOT for one item (that is the atomic verb) and NOT for the review gate that runs after.
---
# Busy
EOF
check "workflow-summary description with all fields PASSES" 0

# 7. A skill using YAML folded block scalars (`>-`, as keel's own `interview`
#    skill does) for description + when_to_use passes — locks the real-repo shape.
fresh c7-block-scalar
mkskill folded <<'EOF'
---
name: folded
description: >-
  Clarify a large or ambiguous request before building. Restates the goal and
  surfaces the open decisions, asking only what cannot be defaulted.
when_to_use: >-
  When a request is large or ambiguous enough that a wrong assumption would
  waste significant build time. Not for small, well-specified tasks.
---
# Folded
EOF
check "block-scalar (>-) description + when_to_use passes" 0

# 8. Frontmatter that does not open with `---` fails (parse check).
fresh c8-no-open
mkskill noopen <<'EOF'
name: noopen
description: Present.
when_to_use: When present.
EOF
check "no opening '---' fails" 1

# 9. Frontmatter with no closing `---` fails (parse check).
fresh c9-no-close
mkskill noclose <<'EOF'
---
name: noclose
description: Present.
when_to_use: When present.
# never closes
EOF
check "no closing '---' fails" 1

# 10. One malformed skill among several well-formed ones still fails the set,
#     naming the offending field.
fresh c10-mixed
mkskill alpha <<'EOF'
---
name: alpha
description: Present.
when_to_use: When present.
---
EOF
mkskill beta <<'EOF'
---
name: beta
when_to_use: When present.
---
EOF
check "one bad skill in a set fails, names 'description'" 1 "description"

# 11. An empty skills/ dir passes (bootstrap window), as does a root with none.
fresh c11-empty
check "empty skills dir passes" 0

ROOT="$TMP/c11b-nodir"; mkdir -p "$ROOT"
check "no skills dir passes" 0

echo "-------------------------------------"
echo "$pass passed, $failc failed"
[ "$failc" -eq 0 ]
