# Uncertainty — `arm-auto-merge`'s "no committed marker → behaves as today" left as-is, not rephrased to "of either kind"

**Milestone:** `auto-merge-doctrine` (M3 of `per-project-auto-merge`).

## The choice made

M3's disambiguation done-condition targets `skills/auto-merge/SKILL.md` (the per-session **attended**
marker's skill), whose bare "with no marker, every guard behaves exactly as today" the committed row
falsifies. I amended all three of its instances to "no marker **of either kind** (no attended marker
and no committed per-project marker)".

I **did not** touch `skills/arm-auto-merge/SKILL.md` (the committed marker's skill, shipped in M2),
which says twice "with **no committed marker**, every guard behaves exactly as today"
(`skills/arm-auto-merge/SKILL.md:4`, `:45`).

## Why it's uncertain

M3 carries two conditions that pull against each other for this one file:

- the behavioral grep — "`grep -rn "behaves exactly as today" skills/` shows any surviving instance
  carries the 'of either kind' disambiguation" — read literally, would want `arm-auto-merge`'s
  instances to say "of either kind" too; but
- the confined-diff condition — "the M1/M2 gate scripts, guards, **arming skill** ... have empty
  diffs" — forbids M3 from editing `skills/arm-auto-merge/SKILL.md` at all.

I resolved the tension by reading the grep condition through its own stated intent — "not a bare
'no marker' **the committed row falsifies**." `arm-auto-merge`'s phrasing is predicated on the
committed marker being *absent*, so the committed row cannot falsify it; and "no committed marker" is
not a *bare* "no marker" — it names the specific marker that skill governs. So the instance is immune
to the exact failure M3 targets, and leaving it satisfies the confined-diff condition. Within that
skill's own frame (it controls only the committed marker) the phrasing is accurate.

**Why a reviewer might decide differently:** a strict reading of "any surviving instance carries the
'of either kind' disambiguation" flags `arm-auto-merge:4/:45` as non-conforming, and one could argue
the phrasing is still imprecise at the edge — with **no committed marker but an attended marker
present**, the guards do *not* behave "exactly as today," which "no committed marker" alone does not
convey. The alternative is to amend those two lines to "of either kind" in a **follow-up** that owns
`skills/arm-auto-merge/SKILL.md` (M3 cannot, without breaking its confined-diff condition). I judged
the committed-scoped phrasing accurate-enough within that skill's scope and not worth reopening an
M2-owned surface from M3; a reviewer who weights cross-skill uniformity higher would schedule that
one-line follow-up.
