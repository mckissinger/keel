# Uncertain choice — the human-tap check lives inside the gate-PASS block, so a gate-FAILING marker-touching PR is `deny`, not `ask`

**Choice made:** in `scripts/merge-guard.sh` `decide()`, the marker human-tap
(`pr_touches_marker` → `ask`) is the **first branch inside the gate-pass block**
(`scripts/merge-guard.sh:757`). Consequence: a merge-shaped command whose target PR touches
`.claude/keel-auto-merge.json` resolves to **`ask`** when the verified-pin gate passes, but to
**`deny`** (with the gate-failure reason) when the gate fails — the tap is never reached on a failing
gate.

**Viable alternative:** hoist the `pr_touches_marker` check **above** the gate invocation
(`scripts/merge-guard.sh:756`), so every marker-touching PR returns a uniform `ask` regardless of gate
outcome.

**Why it's uncertain:** the milestone spec says the tap fires "before and regardless of the
mode/attended/committed **allow rows**" — and the allow rows exist only inside the gate-pass block, so
placing the tap at the top of that block satisfies the spec literally. But the spec never states what
a **gate-FAILING** marker-touching PR should return, so the choice was mine. Both outcomes block
auto-merge (deny is strictly stronger than ask), and keeping the tap inside the gate-pass block
surfaces the more informative gate-failure reason on a failing PR rather than a generic tap message —
that's why I chose it. A reasonable reviewer could prefer the uniform-`ask` alternative for a single,
predictable "marker PRs always take a human tap" contract that doesn't depend on gate state. No safety
difference either way (neither outcome auto-merges); the difference is which reason the human sees and
whether the rule reads as "always ask" vs "ask on pass, deny on fail."
