#!/usr/bin/env bash
#
# check-skill-frontmatter.sh — keel's skill frontmatter lint: a deterministic
# STRUCTURAL check that every skill carries the frontmatter fields the router and
# every eval depend on. Structure cannot silently regress once this is CI-gated.
#
# For every skills/*/SKILL.md it asserts, FAILING when any is absent:
#   (a) frontmatter parses — the file opens with a `---` line and has a closing
#       `---` line;
#   (b) `name:` present in the frontmatter AND equal to the skill's directory
#       name (keel skill names are the grain verbs, so name-equals-directory IS
#       the grain check — there is no separate grain-token grep);
#   (c) `description:` present and non-empty;
#   (d) `when_to_use:` present and non-empty — the trigger field keel skills
#       actually carry.
# The three fields are read ONLY from within the first `---`…`---` frontmatter
# block (a `description:` in body prose is never counted). Values are the text
# after the first colon, surrounding whitespace trimmed.
#
# CRITICAL SCOPING — this lint is FIELD-PRESENCE ONLY. It never inspects whether
# a description or when_to_use disambiguates from a sibling verb or summarizes a
# workflow: no grep for "NOT", no semantic judgment. Those are empirical
# questions the boundary evals (M2) measure — a token-grep would be a weak proxy
# for the real thing. So a long workflow-summary description with all three
# fields present PASSES here.
#
# Conservative by design: structure fails, judgment doesn't. An empty or missing
# skills/ dir passes (bootstrap-compatible: the lint can be wired before the
# first skill exists).
#
# Usage: scripts/check-skill-frontmatter.sh [ROOT]   (ROOT defaults to repo root)
# Exit 0 = clean. Non-zero = a malformed skill, with the reason on stderr.

set -euo pipefail

ROOT="${1:-$(cd "$(dirname "$0")/.." && pwd)}"
cd "$ROOT"

fails=0
fail() { echo "check-skill-frontmatter: FAIL — $1" >&2; fails=$((fails + 1)); }

shopt -s nullglob
skills=(skills/*/SKILL.md)
shopt -u nullglob

if [ ${#skills[@]} -eq 0 ]; then
  echo "check-skill-frontmatter: no skills under skills/*/SKILL.md — pass (bootstrap window)"
  exit 0
fi

# Print the frontmatter body (the lines between the opening and closing `---`).
# Exit 2 = file does not open with `---`; exit 3 = no closing `---`.
frontmatter() { # <file>
  awk '
    NR == 1                  { if ($0 != "---") { bad = 1; exit }; open = 1; next }
    open && $0 == "---"      { closed = 1; exit }
    open                     { print }
    END                      { if (bad) exit 2; if (!closed) exit 3 }
  ' "$1"
}

# Print the trimmed scalar value of <field> from a frontmatter body on stdin —
# everything after the first colon, surrounding whitespace stripped. Empty output
# means the key is absent or its same-line value is empty.
field_value() { # <field>   (frontmatter body on stdin)
  awk -v f="$1" '
    $0 ~ "^" f ":" {
      sub("^" f ":[[:space:]]*", "")
      sub(/[[:space:]]+$/, "")
      print
      exit
    }
  '
}

for skill in "${skills[@]}"; do
  dir="$(dirname "$skill")"
  name_expected="$(basename "$dir")"

  # (a) Frontmatter parses. (Capture the real exit code — 2 = no opening `---`,
  #     3 = no closing `---` — via the `&& … || rc=$?` idiom, since `$?` after an
  #     `if ! cmd` reflects the negated result, not cmd's own exit code.)
  fm="$(frontmatter "$skill")" && rc=0 || rc=$?
  if [ "$rc" -ne 0 ]; then
    if [ "$rc" -eq 2 ]; then
      fail "$skill — frontmatter does not open with a '---' line"
    else
      fail "$skill — frontmatter has no closing '---' line"
    fi
    continue
  fi

  # (b) name present and equal to the directory name.
  if ! printf '%s\n' "$fm" | grep -qE '^name:'; then
    fail "$skill — missing 'name' field in frontmatter"
  else
    name_val="$(printf '%s\n' "$fm" | field_value name)"
    if [ -z "$name_val" ]; then
      fail "$skill — 'name' field is empty"
    elif [ "$name_val" != "$name_expected" ]; then
      fail "$skill — 'name' is '$name_val' but the skill directory is '$name_expected' (name must equal directory)"
    fi
  fi

  # (c) description present and non-empty.
  if ! printf '%s\n' "$fm" | grep -qE '^description:'; then
    fail "$skill — missing 'description' field in frontmatter"
  else
    desc_val="$(printf '%s\n' "$fm" | field_value description)"
    if [ -z "$desc_val" ]; then
      fail "$skill — 'description' field is present but empty"
    fi
  fi

  # (d) when_to_use present and non-empty.
  if ! printf '%s\n' "$fm" | grep -qE '^when_to_use:'; then
    fail "$skill — missing 'when_to_use' field in frontmatter"
  else
    wtu_val="$(printf '%s\n' "$fm" | field_value when_to_use)"
    if [ -z "$wtu_val" ]; then
      fail "$skill — 'when_to_use' field is present but empty"
    fi
  fi
done

if [ "$fails" -eq 0 ]; then
  echo "check-skill-frontmatter: PASS — ${#skills[@]} skill file(s) well-formed"
  exit 0
fi
echo "check-skill-frontmatter: $fails malformed skill finding(s)" >&2
exit 1
