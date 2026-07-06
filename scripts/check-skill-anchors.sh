#!/usr/bin/env bash
#
# check-skill-anchors.sh — the prose-anchor lint.
#
# Some skill/agent prose carries load-bearing SENTENCES a behavioral contract
# depends on (a seam another skill reads, a mandate a milestone pins). This lint
# makes those sentences machine-checkable so a later reword can't silently drop
# one: for each scripts/skill-anchors/<feature>.txt it asserts every declared
# anchor STRING is present verbatim in its named file.
#
# Anchor-file format — one entry per line:  <file-path><TAB><literal-anchor>
#   * the FIRST tab splits path from anchor (an anchor may contain spaces)
#   * blank lines and lines starting with '#' are skipped
#   * <literal-anchor> is matched as a FIXED string (grep -F), not a regex
#   * a line prefixed '!' is a NEGATIVE anchor: it asserts the fixed string is
#     ABSENT from its named file (the committed form of "this claim was removed
#     and must stay removed"). The named file must still exist — a missing file
#     is an error, not a vacuous pass.
#
# Anchor sets are FILE-PER-FEATURE: a later feature adds its own
# scripts/skill-anchors/<feature>.txt and never edits an existing one (the §4
# no-shared-file collision rule). An empty or missing anchors dir → pass, so the
# lint can be wired into CI before any anchors exist.
#
# Usage: scripts/check-skill-anchors.sh [ROOT]   (ROOT defaults to the repo root)
# Exit 0 = all anchors present (or none to check). Non-zero = a missing/broken
# anchor or a malformed anchor line, each named on stderr.

set -uo pipefail

ROOT="${1:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

DIR="scripts/skill-anchors"
fails=0
fail() { echo "check-skill-anchors: FAIL — $1" >&2; fails=$((fails + 1)); }

if [ ! -d "$DIR" ]; then
  echo "check-skill-anchors: no $DIR/ — nothing to check, pass"
  exit 0
fi

shopt -s nullglob
anchor_files=("$DIR"/*.txt)
if [ ${#anchor_files[@]} -eq 0 ]; then
  echo "check-skill-anchors: $DIR/ has no anchor files — nothing to check, pass"
  exit 0
fi

checked=0
for af in "${anchor_files[@]}"; do
  lineno=0
  # `|| [ -n "$line" ]` so a final line without a trailing newline is still read.
  while IFS= read -r line || [ -n "$line" ]; do
    lineno=$((lineno + 1))
    case "$line" in '' | '#'*) continue ;; esac
    negated=0
    case "$line" in '!'*) negated=1; line="${line#!}" ;; esac
    case "$line" in
      *$'\t'*) : ;;
      *) fail "$af:$lineno — malformed line (no TAB between file-path and anchor): $line"; continue ;;
    esac
    path="${line%%$'\t'*}"
    anchor="${line#*$'\t'}"
    if [ -z "$path" ] || [ -z "$anchor" ]; then
      fail "$af:$lineno — malformed line (empty file-path or anchor): $line"; continue
    fi
    if [ ! -f "$path" ]; then
      fail "$af:$lineno — named file does not exist: $path"; continue
    fi
    checked=$((checked + 1))
    if [ "$negated" -eq 1 ]; then
      if grep -qF -- "$anchor" "$path"; then
        fail "$path contains a BANNED string (negative anchor declared in $af:$lineno): $anchor"
      fi
    elif ! grep -qF -- "$anchor" "$path"; then
      fail "$path no longer contains its anchor (declared in $af:$lineno): $anchor"
    fi
  done < "$af"
done

if [ "$fails" -eq 0 ]; then
  echo "check-skill-anchors: PASS — $checked anchor(s) present across ${#anchor_files[@]} feature file(s)"
  exit 0
fi
echo "check-skill-anchors: $fails missing/broken anchor(s)" >&2
exit 1
