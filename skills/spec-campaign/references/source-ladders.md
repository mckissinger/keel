# Source ladders — enrichment rungs, the verification gate, and the rules that bind them

How a campaign's audience slice becomes a list of verified, reachable contacts.
A **source ladder** is the ordered set of enrichment rungs a campaign spec
commits to — tried top-down per prospect, each rung filling what the rungs above
it missed. Ladders are **per-campaign**: data-provider coverage is
audience-dependent (as of 2026-07, no provider covers every niche equally), so
the ladder is named and validated per audience slice, never inherited as a
global default.

## The rung taxonomy

Ordered by typical precision-per-effort; a campaign's ladder picks and orders
its own subset:

1. **Licensed contact databases** — commercial B2B data providers queried by
   firmographic/role filters (as of 2026-07, e.g. Apollo, ZoomInfo, or a
   niche-vertical equivalent — hedged examples; the spec names whichever the
   sample pull validated). Strongest when the slice matches a well-covered
   segment; weakest on local/trade niches.
2. **Public records** — license boards, permit registries, professional
   registries, and similar government or quasi-government rolls. Often the
   *only* authoritative source for licensed trades (an invented example:
   *Fieldnote*'s irrigation-license slice resolves through two state license
   boards, not any commercial database).
3. **Maps/places APIs** — place listings queried by category + geography for
   business name, site, and phone. Good for existence and location; almost
   never a direct source of a named person's address.
4. **The prospect's own website** — crawl/extraction of team, contact, and
   about pages for names and published addresses. High precision, low
   coverage, and bounded by the site actually publishing anything.
5. **Waterfall email-finding** — pattern inference and finder services that
   propose an address for a known name + domain, tried across providers until
   one resolves. The rung that most needs the gate below: everything it
   produces is a guess until verified.

## The mandatory verification gate

**No found address enters a queue unverified.** Every rung's output — even a
licensed database's — passes an address-verification step (as of 2026-07,
SMTP-level verifier services are the common mechanism; any equivalent
satisfies the contract) before it may appear in any queue file. The gate is a
pipeline step, not a suggestion: a ladder without it is malformed.

The **bounce stop-condition is the enforcement backstop**, not a substitute:
the campaign spec's bounce-rate ceiling (mandatory per the doctrine's
compliance floor — `references/growth-operations.md` §7, `${CLAUDE_PLUGIN_ROOT}`,
cited) is what catches a verifier that lied or a list that aged. The gate keeps
bad addresses out; the stop-condition pauses the campaign if they get in
anyway. A campaign relying on the backstop alone is burning its sending domain
to discover its list quality.

## The sample-pull rule

**Before a campaign spec commits to a ladder, a small sample of the audience
is pulled through it — and per-rung resolution is recorded in the spec.**
Coverage is measured, never assumed. The pull is an attended, in-session step
of `spec-campaign` (the one spend that verb incurs): take a small sample of
the audience slice, run it down the candidate ladder, and record in the
campaign spec's source-ladder section what fraction each rung resolved and
what the verification gate then confirmed. A ladder whose sample resolves
poorly is renegotiated in the same sitting — different rungs, a different
slice, or an honest smaller volume — not discovered mid-flight after the
envelope was set against imagined coverage.

## The ToS rule

**Rungs that violate a platform's terms of service are not used.** Scraping a
source whose terms prohibit it, or automating against an interface whose terms
forbid automation, is off the ladder — no exception for "everyone does it."

**Gray-zone rungs are named in the campaign spec as attended risk
acceptances**, per the doctrine's compliance floor (cited above): where a
source's terms are ambiguous or unevenly enforced (as of 2026-07, much
public-web extraction sits here), the campaign spec's compliance section
records the rung, the risk, and the operator's explicit acceptance. The
operator accepts the risk on the record, or the rung stays off the ladder — a
drafting session never makes that call.
