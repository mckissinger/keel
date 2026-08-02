# Uncertain choice — (b2) scopes to the literal check name `security-review`

**Choice made:** preflight sub-check (b2) fires only when the literal name `security-review` appears
in the required set (`REQUIRED_CHECKS` / `PREFLIGHT_REQUIRED_CHECKS`). A project that renames its
review check (e.g. `sec-scan` via the override) skips (b2) entirely — asserted by test case 20.

**Viable alternative:** track the rename — e.g. a `PREFLIGHT_SECREVIEW_CHECK` variable naming which
required check is the review check, so (b2) follows it. Rejected for this milestone because the spec's
condition says "for the `security-review` check name in the required set," and because the rename
knob (`PREFLIGHT_REQUIRED_CHECKS`) is already the strictly larger bypass — an operator who renames
the check can already drop it — so following the rename adds surface without closing a gap (b2)
could otherwise close.

**Why it's uncertain:** a reviewer could reasonably want the content assertion to survive a rename
(the rename-skips-content behavior is a small silent hole inside an already-open override), and could
judge the extra variable worth it. The current shape is simpler and spec-literal; the alternative is
stricter. Recorded for adjudication.
