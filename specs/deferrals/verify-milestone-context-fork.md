# `context: fork` on verify-milestone

**Parked 2026-07-01.** Add `context: fork` to `skills/verify-milestone/SKILL.md` so a
hand-run `/keel:verify-milestone <slug>` executes isolated from the build conversation —
making the fresh-session invariant structural instead of prose (SKILL.md's "fresh session"
rule) for the one path that isn't already dispatched fresh.

**Gate:** untested platform interactions — whether a forked skill retains the skill's
`allowed-tools` grants (added in the packaging chore), and what agent the fork lands in (it
must be able to write + commit the pin, so NOT the read-only verifier agent; possibly a
dedicated verify-runner agent). Resolve by live test after the enforcement-hooks feature
lands (hooks + fork composition should be tested together).
