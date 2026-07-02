# hooks-m3 — composition walk TRANSCRIPT (executed, attended)

Executed 2026-07-01 in an attended session, against the m3-branch hook scripts in a composed
throwaway keel-managed fixture (a `specs/milestones/` project with `check-verified-pin.sh`, a
pinned drift-free milestone branch `m-demo`, and a plain non-keel dir). Each hook was driven
with the exact PreToolUse/SessionStart stdin the harness sends. All five assertions pass.

**Scope note (honest boundary):** this proves keel's hook **scripts** emit the correct decisions
end-to-end, composed in one fixture. Whether the Claude Code harness *renders* the emitted
`permissionDecision` as an approval prompt is a property of the harness itself, not keel's code —
keel's contract is to emit the correct decision JSON, demonstrated below. Each assertion's
deterministic core is also owned by a committed self-test (named per assertion in the walk plan).

## Results

**(a) gate-PASSING merge → ask.** `git merge main` on the pinned, drift-free `m-demo`:
```json
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask",
 "permissionDecisionReason":"verified-pin gate passed — per-merge human approval"}}
```
Exit 0. The guard runs the project's own `check-verified-pin.sh`, it passes, → ask. It does not
block or fight the landing flow.

**(b) gate-FAILING merge → deny with the gate's reason verbatim.** Same command after committing
code drift past the pin:
```json
{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny",
 "permissionDecisionReason":"verified-pin: FAIL — specs/milestones/m-demo.md — code changed after the pin (956e254); verified code != merged code: feature.txt"}}
```
Exit 0. The deny reason is the gate's own stderr, verbatim; the merge does not proceed.

**(c) pin write untouched by the branch guard.** `git commit -m "verify: pin m-demo ..."` on
branch `m-demo` → exit 0, silent. Control: the same commit on `main` → exit 2 with
"git commit on the default branch (main) is blocked in build sessions — branch first …". The
branch guard blocks commit-to-main but never the on-branch pin write.

**(d) bootstrap + `disable-model-invocation` coexist.** In the keel-managed fixture the
SessionStart bootstrap names each flagged skill AND each carries the flag:
```
kickoff       named: yes | flag present: yes
adopt         named: yes | flag present: yes
land-feature  named: yes | flag present: yes
```
Naming a skill in orientation is not model-invoking it; the live block-vs-allow is the harness's
enforcement of the (verified-present) flag.

**(e) non-keel dir → total silence.** SessionStart bootstrap in the plain dir: 0 bytes, exit 0.
Merge guard on `ls -la` there: exit 0, no output. No keel hook text anywhere.

## Verdict

No composition failure. The guards do not fight the landing flow (a), correctly block on a failing
gate (b), leave the pin write alone (c), coexist with the invocation flags (d), and stay silent
outside keel projects (e). Presented for attended approval; on approval the pin is written.
