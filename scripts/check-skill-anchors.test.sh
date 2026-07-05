#!/usr/bin/env bash
#
# Self-test for check-skill-anchors.sh. Builds throwaway ROOTs (each with a
# scripts/skill-anchors/ dir + target files) in a temp dir and asserts the
# lint's exit code for present / absent / malformed / missing-file anchors and
# for the empty-and-missing-dir pass paths. Also runs it against THIS repo.
#
# Run: bash scripts/check-skill-anchors.test.sh

set -uo pipefail
SCRIPT="$(cd "$(dirname "$0")" && pwd)/check-skill-anchors.sh"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

pass=0 failc=0
ok()  { echo "ok   - $1"; pass=$((pass + 1)); }
bad() { echo "FAIL - $1"; failc=$((failc + 1)); }

run() { # <root> → OUT, RC
  OUT="$(bash "$SCRIPT" "$1" 2>&1)" && RC=0 || RC=$?
}
expect() { # <desc> <exit> [substr]
  local desc="$1" exp="$2" sub="${3:-}"
  if [ "$RC" -ne "$exp" ]; then bad "$desc (got exit $RC, want $exp; out=${OUT:0:160})"; return; fi
  if [ -n "$sub" ] && ! printf '%s' "$OUT" | grep -qF "$sub"; then
    bad "$desc (output lacked \"$sub\": ${OUT:0:160})"; return
  fi
  ok "$desc"
}

# mkroot <name> → ROOT with an anchors dir and one target file carrying a line.
mkroot() { # <name> <target-rel> <target-content>
  ROOT="$TMP/$1"
  mkdir -p "$ROOT/scripts/skill-anchors" "$ROOT/$(dirname "$2")"
  printf '%s\n' "$3" > "$ROOT/$2"
}

# 1. Present anchor → pass.
mkroot present skills/x/SKILL.md "the load-bearing SEAM sentence lives here"
printf '%s\t%s\n' "skills/x/SKILL.md" "load-bearing SEAM sentence" > "$ROOT/scripts/skill-anchors/f.txt"
run "$ROOT"; expect "present anchor → pass" 0 "PASS"

# 2. Absent anchor → fail, naming the file.
mkroot absent skills/x/SKILL.md "the sentence was reworded and the seam dropped"
printf '%s\t%s\n' "skills/x/SKILL.md" "load-bearing SEAM sentence" > "$ROOT/scripts/skill-anchors/f.txt"
run "$ROOT"; expect "absent anchor → fail, names the file" 1 "skills/x/SKILL.md no longer contains its anchor"

# 3. Malformed line (no TAB) → fail.
mkroot malformed skills/x/SKILL.md "whatever"
printf '%s\n' "skills/x/SKILL.md this-has-no-tab" > "$ROOT/scripts/skill-anchors/f.txt"
run "$ROOT"; expect "malformed line (no TAB) → fail" 1 "no TAB"

# 3b. Malformed line (empty anchor after the TAB) → fail.
mkroot emptyanchor skills/x/SKILL.md "whatever"
printf 'skills/x/SKILL.md\t\n' > "$ROOT/scripts/skill-anchors/f.txt"
run "$ROOT"; expect "empty anchor after TAB → fail" 1 "empty file-path or anchor"

# 4. Named file does not exist → fail.
mkroot nofile skills/x/SKILL.md "whatever"
printf '%s\t%s\n' "skills/does-not-exist/SKILL.md" "anything" > "$ROOT/scripts/skill-anchors/f.txt"
run "$ROOT"; expect "named file missing → fail" 1 "named file does not exist"

# 5. Blank lines and #-comments are skipped (a comment is not a malformed line).
mkroot comments skills/x/SKILL.md "anchor text present"
{ printf '# a comment line\n'; printf '\n'; printf '%s\t%s\n' "skills/x/SKILL.md" "anchor text present"; } \
  > "$ROOT/scripts/skill-anchors/f.txt"
run "$ROOT"; expect "comments + blank lines skipped → pass" 0 "PASS"

# 6. Empty anchors dir → pass (wireable before anchors exist).
ROOT="$TMP/emptydir"; mkdir -p "$ROOT/scripts/skill-anchors"
run "$ROOT"; expect "empty anchors dir → pass" 0 "nothing to check"

# 7. Missing anchors dir → pass.
ROOT="$TMP/nodir"; mkdir -p "$ROOT/scripts"
run "$ROOT"; expect "missing anchors dir → pass" 0 "nothing to check"

# 8. The final line lacking a trailing newline is still read.
mkroot notrailingnl skills/x/SKILL.md "tail anchor here"
printf '%s\t%s' "skills/x/SKILL.md" "tail anchor here" > "$ROOT/scripts/skill-anchors/f.txt" # no \n
run "$ROOT"; expect "final line without trailing newline is read → pass" 0 "PASS"

# 9. This repo: the shipped auto-hardening.txt anchors are all present.
run "$REPO_ROOT"; expect "this repo's anchors all present → pass" 0 "PASS"

# 10. The shipped lint is executable.
if [ -x "$SCRIPT" ]; then ok "check-skill-anchors.sh is executable"
else bad "check-skill-anchors.sh is executable"; fi

echo "-------------------------------------"
echo "$pass passed, $failc failed"
[ "$failc" -eq 0 ]
