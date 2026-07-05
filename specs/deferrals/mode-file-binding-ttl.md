# mode-file trigger-binding + expiry on the merge guard

**Expiry half (b) RESOLVED 2026-07-05 by `auto-hardening-m1-guards`.** The `created` TTL now
ships in all three committed readers — `scripts/merge-guard.sh`, `scripts/guard-branch-rules.sh`,
and `scripts/session-bootstrap.sh`: a mode file is honored only while `created` is within **24h**
of now, and the attended marker (`.claude/keel-attended-merge.json`) only within **8h**; an
expired, unparseable, or future-dated `created` is treated EXACTLY as absent (fail closed), with
the age computed from `created` as parsed data (jq `fromdateiso8601` / python3 `strptime`), never
eval'd. **These two TTL values supersede this deferral's original "older than the session start"
sketch** — a fixed 24h/8h bound needs no per-session harness signal, so it shipped first exactly
as the note below anticipated. **The run-binding half (a)/(c) remains deferred** with its original
rationale (see the Gate section). Regression coverage: the guards' `.test.sh` suites (expired /
fresh / unparseable / future fixtures), `attended-marker-parity.test.sh` (an expired-marker
fixture, jq + python3), and `session-bootstrap.test.sh` (25h expired → no-mode baseline; 23h fresh
→ mode orientation).

**Parked 2026-07-02.** Harden `scripts/merge-guard.sh`'s `read_mode_file` (and
`session-bootstrap.sh`'s copy) so the autonomy mode file is trusted on more than mere
existence + field-validity. Surfaced by the `auto-m5-composition` pre-pin `/security-review`
of the composed allow path (PR #64); the fix touches m2's already-merged merge gate, so it
is a follow-up change, not part of the autonomy-modes feature.

**The gap.** The guard honors any untracked `.claude/keel-autonomy.json` with four
non-empty string fields and `level ∈ {feature,run}`. Nothing binds the file to the
human-triggered `keel:auto` invocation, and `created` is validated as a string but never
compared to now. Two consequences:

- **Cross-context / direct write:** an agent can write the file directly (a plain,
  non-merge-shaped write no hook intercepts), and a later orchestrating session's guard
  reads it and flips `gh pr merge --auto` from `ask` to `allow`. `disable-model-invocation`
  stops the model invoking the *skill*, not writing the skill's *output file*.
- **Crash persistence:** a mode file left by a crashed run (the `skills/auto/SKILL.md:33`
  "clear on every exit path" is prose, not a mechanical invariant) silently converts a
  later, unrelated, **attended** session's `--auto` merges from `ask` to `allow`.

**Why it is accepted for now (not a feature blocker).** Per
`decisions/2026-07-autonomy-modes.md` §(e), the mode unlocks only the `--auto` *handoff*;
the merge itself is gated server-side by the required checks (verified-pin + plan-lint +
blanket security-review). A forged or stale mode file cannot merge unpinned/unsafe code so
long as branch protection is in place — the mode file is not the merge authority. The m2
security review cleared the "agent writes the mode file" path on exactly this basis. So the
residual is a *surprise-behavior* and defense-in-depth gap, not an authorization bypass of
the merge gate.

**The change when built.** Bind the file to the run and to freshness the guard checks:
(a) a `run_id` field the guard cross-checks against a per-session marker the harness sets;
and/or ~~(b) a short `created` TTL — reject a mode file older than the session start (kills
crash-persistence with no harness dependency)~~ **— DONE (24h/8h, see the resolution banner);**
and consider (c) gating the *write* (an HMAC/nonce the harness issues only to a human-triggered
skill invocation), since untracked-ness proves nothing about authorship. Regression tests: a
stale-`created` file → no mode; a `run_id` mismatch → no mode; parity across the jq and python3
field readers and across both `merge-guard.sh` and `session-bootstrap.sh`.

**Gate (run-binding half (a)/(c) only).** Needs a decision on the run-binding mechanism, which
depends on what per-session signal the harness can expose to a PreToolUse hook (a `run_id` in the
hook env, or the session start time) — untested platform interaction. The TTL half (b) needed no
such signal and **has shipped** (`auto-hardening-m1-guards`). The remaining run-binding /
write-gating work stays a future `spec-change` against the guards once the harness signal is
confirmed; until then the delegation-to-required-checks backstop plus the new TTL hold the line
(a leftover file now self-expires within 24h/8h even if a crash skips the skill's cleanup).
