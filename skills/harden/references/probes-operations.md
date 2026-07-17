# Operations + launch-readiness probes — the third dimension

The probe list for the operations sweep subagent. Same discipline as the sibling
references: evidence-backed probes, dispatched through the stack profile (Q10 names
the deployed surface; the environment contract names the services), **"n/a + why"**
where the stack can't express one. A local-only project (no deployed surface) marks
the deploy/observability probes n/a per its recorded subtraction and keeps the
deferrals drain.

## Observability — would an incident actually surface?

- **Error tracking exists on the load-bearing surfaces**: an unhandled error on a
  Q2 surface lands somewhere a human will see (an error-tracking service from the
  environment contract, or a stated log-based equivalent) — not only in a container
  log nobody reads. Cite the wiring, or the finding is its absence.
- **Alerting has at least one wired path**: something pages or notifies when the
  product is down or erroring at rate — a status monitor on the deployed surface
  (Q10), a service alert, an uptime check. "We'd notice eventually" is the finding.
- **Log retention is known**: where logs go, how long they live, and that the
  answer comes from the service's actual configuration, not its defaults assumed.

## Environment separation — test vs live

- **Live keys never enter the dev environment** — the environment contract's own
  rule, verified: the contracted services run test/sandbox mode pre-launch, and the
  key *names* in dev resolve to test-mode credentials. Presence is asserted by name
  only via the profile's recorded name-check command; values are never read.
- **The go-live swap is a recorded, attended event**: the deferrals ledger carries
  the live-key / domain / prod-migration checkpoints (seeded at kickoff), and
  nothing autonomous crosses them — confirm the entries still exist and still match
  the contract's current service list.
- **Production config diverges deliberately**: env-var names present in production
  but absent from the contract (or vice versa) are drift findings — the contract is
  the source of truth.

## Deploy and rollback

- **The path to undo a bad deploy is known and recorded**: the host's
  rollback/promote-previous mechanism named, or the stated equivalent (revert +
  redeploy through the pipeline). Unknown is the finding.
- **The deploy gate matches keel's process**: branch protection live with the
  required checks actually *required* (the provision preflight's own assertion —
  re-verify it here; it can drift after kickoff), previews as the verification
  surface, `main` auto-deploying only what merged through the gates.
- **A deploy-time failure is distinguishable from an app failure**: build-time env
  (the production build's variables) resolves per the contract — the Q6 dev/prod
  divergence applied to configuration.

## The deferrals-ledger drain — launch readiness proper

- **Enumerate every open `specs/deferrals/` item whose closing condition falls at
  or before launch.** Each is a finding in the report until it is closed or
  explicitly re-accepted at triage — a deferral silently aged past its trigger is
  exactly the class this verb exists to catch. (The ledger's rules and the run
  preflight's drain stay owned where they are; this probe reads and reports.)
- **The launch checklist is derivable**: after triage, the report's accepted-risk
  and still-open sections should read as the go/no-go list — if a reader can't
  derive "what must happen before real users" from it, the report isn't done.
