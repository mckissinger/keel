# Security probes — the application-security dimension (supply chain and the AI surface included)

The probe list for the security sweep subagent. Organized by the **OWASP Top
10:2025** categories — the grounding for this dimension — with **OWASP ASVS 5.0**
named as the deeper per-area source when a probe needs requirement-level detail
(seventeen chapters; consult the matching chapter, don't transcribe it). Every probe
is phrased to be **checkable with evidence** (`file:line` or command + output
excerpt) and **dispatches through the stack profile** — the Q1–Q2 surface inventory
scopes what to sweep; the environment contract names the services; a probe this
stack cannot express is recorded **"n/a + why."** Tool and mechanism names below
(a lockfile, an npm-audit-class scanner, a CSP header) are examples of the probe
class on stacks that have them, never requirements.

## A01 — Broken access control (and tenancy)

- **Every Q2 surface names its access rule.** Walk the surface inventory: for each
  route/endpoint/command, who may reach it, and where is that enforced? A surface
  with no discoverable enforcement point is a finding.
- **Enforcement lives at the data layer where the stack has one.** Where the stack
  offers data-layer enforcement (row-level security, schema-level policies),
  tenancy/ownership rules are enforced *there*, not only in handler code — a
  handler-only check leaves every future surface a bypass. Cite the policy per core
  entity, or the finding is the absent policy.
- **The IDs in URLs/params are authorized, not just parsed.** Object references
  reachable by ID are checked against the caller's rights (the IDOR class). Probe
  the detail/utility surfaces — the ones no milestone's diff flagged.
- **Server-side request targets are constrained** (SSRF folds into A01 in the 2025
  list): any place the server fetches a user-influenced URL names its allowlist or
  is a finding.

## A02 — Security misconfiguration

- **Response headers** (gated on Q8.1 has-UI / a browser-facing surface): a
  content-security policy, frame/clickjacking protection, content-type sniffing off,
  transport security enforced — read the deployed surface's actual headers (Q10)
  where reachable, the framework config otherwise.
- **Debug surfaces are off in production**: debug/verbose flags, stack traces in
  error responses, framework debug pages, exposed introspection endpoints.
- **Defaults are changed**: default credentials, sample routes, permissive CORS
  ("*" with credentials is a finding), open storage buckets or public datastores
  the contract doesn't intend public.

## A03 — Software supply chain (the folded section)

This section rides the security subagent — it is a named part of this dimension,
not a fourth fan-out. The 2025–26 ecosystem attacks (self-replicating package
worms, compromises of top-download packages) made these baseline:

- **The lockfile is committed and CI installs from it** (an `npm ci`-equivalent —
  the exact-lockfile install, not a floating resolve). A gitignored lockfile or a
  CI install that re-resolves is a finding.
- **Install-script posture is deliberate**: does the ecosystem run package install
  scripts, and has the project decided (disabled, or allowlisted with a reason)?
  Undecided is the finding; either decision recorded is clean.
- **A release-cooldown / quarantine posture exists where the ecosystem supports
  it** (a minimum-release-age rule blocks the compromised-version window most 2025–26
  attacks lived in). Where the ecosystem has no such mechanism: n/a + why.
- **Audit tooling is wired, not occasional**: a dependency-vulnerability scan runs
  in CI (an npm-audit-class or OSV-class scanner on this stack). Running a scan
  *now* is attended — the user's go-ahead, normal permission flow.
- **Direct dependencies are alive**: flag unmaintained/archived direct dependencies
  on load-bearing paths.

## A04 — Cryptographic failures

- **Transport is encrypted end-to-end** (the deployed surface redirects/upgrades;
  internal service calls per the contract).
- **Secrets and credentials at rest**: passwords hashed with a current
  memory-hard/adaptive scheme (not a bare fast hash), tokens/keys stored per the
  environment contract — and never in the repo: probe tracked files and history
  for secret-shaped material. **Values are never read to prove this** — the
  name-check command asserts presence; the repo probe greps for *shapes*, quoting
  nothing secret-shaped into the report.
- **No homegrown crypto** on an invariant path.

## A05 — Injection

- **Every system boundary that interpolates input names its escape/parameterization
  mechanism**: datastore queries parameterized (no string-built queries on any
  path), shell/exec calls absent or argument-vectored, template/HTML output escaped
  by default with any raw-output escape hatches enumerated and justified. keel's
  posture holds: validate at **system boundaries** (Q2 surfaces, external inputs) —
  the probe never mandates speculative internal validation.

## A06 — Insecure design

- **The hard invariants recorded in `specs/01-architecture.md` each have an
  enforcement point and a committed test.** This is the cross-check between the
  spec's stated invariants and the code's actual guarantees — an invariant with no
  test is a finding even if the code looks right.
- **Abuse paths on the money/data surfaces**: what does the worst-case authenticated
  user do — bulk-export another tenant's data, replay a paid action, exhaust a
  quota? Name the top three by stakes and check each has a control.

## A07 — Authentication failures

- **Session handling**: cookies/tokens carry the secure attributes the platform
  offers (secure, http-only, same-site or equivalent), sessions expire and are
  revocable, logout actually invalidates.
- **Auth endpoints are rate-limited** (login, signup, reset — the brute-force
  class).
- **Password/credential policy delegates to the provider where one is contracted**
  (the environment contract's auth service) — a contracted provider with local
  overrides weakening it is a finding.

## A08 — Software and data integrity failures

- **CI/CD integrity**: pinned action/tool versions (never `@latest` for
  network-resolved setup actions — keel's own provision rule), protected default
  branch with the required checks actually required.
- **Deserialization/eval of untrusted data is absent or justified.**
- **Webhooks verify signatures** where the contracted services sign them.

## A09 — Security logging and alerting failures

- **The security-relevant events are logged**: auth failures, permission denials,
  and invariant violations produce a log line someone could find. (Whether
  *operational* observability would surface an incident is
  `probes-operations.md`'s — this probe is the security-event subset.)
- **Logs don't leak**: no secrets, tokens, or bulk PII in log output paths.

## A10 — Mishandling of exceptional conditions

Owned by `probes-reliability.md` (fail-open vs fail-closed is a reliability probe
with security consequences); the security subagent checks only the one
security-shaped case: **an error path that skips an authorization or validation
step** (the catch-and-continue bypass).

## The AI surface — gated on Q7

Run this section only when the profile's Q7 answer names an external/AI model call;
"n/a — no external calls" skips it entirely. Grounded in the **OWASP Top 10 for LLM
Applications 2025**:

- **Prompt injection posture**: where untrusted content (user input, fetched
  documents, third-party data) reaches a model prompt, the design treats it as
  data — named separation between instructions and content, and the high-impact
  actions a model can trigger are enumerated with a human or policy gate on each.
- **Model output is untrusted at every executing boundary**: LLM output that
  reaches HTML, a query, a shell, or a tool call passes the same
  escape/parameterization controls as any external input (the improper-output-
  handling class).
- **Consumption is bounded**: the capped-key doctrine keel already runs (a
  spend-capped provider key, per the environment contract) is verified live here —
  the cap exists, and per-request bounds (token/size/rate limits) exist on
  user-triggerable model calls (the unbounded-consumption class).
