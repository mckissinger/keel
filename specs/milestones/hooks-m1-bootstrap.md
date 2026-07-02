# Milestone — hooks-m1-bootstrap: hooks infra + keel-gated SessionStart

**Goal:** keel ships a hooks layer, and sessions in keel-managed projects self-activate via a
SessionStart bootstrap (re-injected after compaction) that costs nothing anywhere else.

**Feature:** `specs/features/enforcement-hooks.md`. **No-UI** → two-dimension
done-conditions. **Depends on:** nothing. **Parallelizable:** no (m2/m3 build on this).

## Done-conditions

### Logic / invariants
- [auto] `hooks/hooks.json` exists and is registered from `.claude-plugin/plugin.json`; it
  declares SessionStart with matchers covering session start/resume **and** `compact`
  (post-compaction re-injection — PostCompact cannot inject context), all pointing at
  `scripts/session-bootstrap.sh` via `${CLAUDE_PLUGIN_ROOT}`.
- [auto] `scripts/session-bootstrap.sh`: probes the cwd for keel markers — a
  `specs/milestones/` or `specs/stack-profile.md` or a CLAUDE.md mentioning the verified-pin
  process — and on **no** marker exits 0 with **no output**. On a marker, emits a bootstrap
  of **under 1k tokens**: the grain ladder (which verb for which grain) and the standing
  invariants (never merge, never commit to main, pin gates the merge, builds run on
  branches), phrased as orientation, not instruction dump.
- [auto] The script is executable, `dirname`-relative (survives plugin-cache path churn), and
  emits valid hook output per the hooks schema (JSON where the event requires it).
- [auto] `scripts/check-neutral.sh` scans `hooks/**` and `scripts/session-bootstrap.sh`
  alongside its current globs; its self-test gains a case proving a denylisted hardcode in a
  hook file is caught.

### Behavioral completeness
- [auto] `scripts/session-bootstrap.test.sh` (house idiom: throwaway dirs, assert
  exit/output): no-marker dir → empty output; marker dir → bootstrap emitted and under the
  token budget (assert by byte/word bound); compact matcher present in hooks.json (grep).
- [auto] `claude plugin validate --strict .` passes with the hooks registration.
- [runtime] In a live session in a keel-managed fixture dir, the bootstrap appears in
  context at session start (deterministic core: the emit path, covered by
  `session-bootstrap.test.sh`; the live check is activation-only).
- [auto] Both existing script self-tests still pass; `README.md` "What's in the plugin"
  mentions the hooks layer in one line.

## verification
verifier subagent against this file (hooks.json schema + registration greps, script probes
run via the committed self-test, neutrality extension proven by its new self-test case) +
`claude plugin validate --strict .`. The [runtime] activation check runs in the live
composition walk of `hooks-m3` if not closed here. No hard invariant loosened → no
`/security-review` (m2 carries it instead).
