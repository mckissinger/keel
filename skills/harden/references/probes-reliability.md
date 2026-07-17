# Reliability + data-safety probes — the second dimension

The probe list for the reliability sweep subagent. Same discipline as the security
probes: every probe checkable with evidence (`file:line` or command + output
excerpt), dispatched through the stack profile (Q1–Q2 scope the surfaces; the
environment contract names the services; Q9 names the migration scheme), and a probe
this stack cannot express is recorded **"n/a + why."**

## Error handling at system boundaries

- **Every Q2 surface has a defined failure shape**: an API surface returns a
  structured error (not a stack trace, not a hang); a UI surface renders its error
  state (the one the feature specs enumerated); a CLI surface exits nonzero with a
  message. Probe the boundaries — keel's posture holds here too: **only validate at
  system boundaries**; this probe never mandates speculative internal try/catch,
  and "add error handling for scenarios that cannot happen" is exactly the
  preference-noise the report must not carry.
- **Exceptional conditions fail closed** (the OWASP A10:2025 class): when a check
  errors — an auth lookup that throws, a policy fetch that times out — does the
  code path deny or allow? Walk the guard-shaped code paths; a catch that continues
  past a failed check is a finding (the security-shaped case is cross-referenced
  from `probes-security.md`).
- **Partial failure is handled where the contract makes it possible**: a
  multi-write action against a datastore without a transaction (or with one that
  spans only half the writes) leaves torn state — probe the state-changing actions
  (Q4) whose effects span more than one write.

## Timeouts and rate limits

- **Every outbound call to a contracted service names a timeout.** An unbounded
  outbound call is a finding — the hang propagates to the user (and keel's own Q12
  rule — never wait open-endedly — is the same doctrine at the substrate).
- **Retries are bounded and idempotent-only**: a retry on a non-idempotent action
  (a payment, a send) is a finding; a retry with no backoff/cap is a finding.
- **Inbound rate limiting exists on the abuse-prone surfaces**: auth endpoints
  (owned by the security probes), plus anything expensive or state-changing a
  single caller could hammer — enumerated from the Q2 inventory by cost.

## Backups and restore

- **The datastore's backup posture is recorded and real**: what is backed up, on
  what schedule, retained how long — read from the contracted service's actual
  configuration (a cheap read-only status command, attended if it needs a login),
  never assumed from the provider's defaults.
- **A backup never restore-tested is a finding.** The probe is for *evidence of a
  restore path*: a documented restore procedure, or better a recorded restore
  exercise. "Backups exist" without a known restore path is accepted-risk material
  at best — surface it for triage, don't wave it through.
- **Point-in-time needs are matched to the product**: if the product's data-loss
  tolerance (from `00-product.md`'s stakes) is minutes, daily snapshots are a
  finding.

## Migrations

- **The scheme matches the profile's Q9 answer**: collision-free versioning,
  forward-only discipline, shared-object statements idempotent — drift between the
  recorded scheme and the migration directory is a finding.
- **The rollback story is stated**: forward-only is a legitimate answer *when
  recorded* (roll forward with a fixing migration); no stated answer is the
  finding. A destructive migration (drop/rename on a populated table) with no
  expand-contract staging is flagged at the stakes of the data involved.

## PII and data scope

- **A PII inventory exists and matches reality**: what personal data the system
  actually stores (walk the schema/core entities), where it lives, and whether
  `00-product.md`'s stated scope covers it. Data collected that no feature needs is
  a finding (scope creep in the schema).
- **Retention and deletion are answerable**: can the product delete a user's data
  when asked — is there a path, and does it reach the backups' retention story?
  No path is a finding; "manual, documented" is a recordable answer.
- **PII stays out of logs and error reports** (cross-referenced with the security
  probes' log-leak check) and out of URLs/query strings.
