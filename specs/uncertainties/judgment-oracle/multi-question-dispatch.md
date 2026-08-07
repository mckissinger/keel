# Uncertain choice — what the oracle does with a multi-question dispatch

**The choice made:** `agents/oracle.md` instructs the oracle, when a dispatched brief bundles more
than one question, to answer **none** of them — return `uncertain` and state that the dispatch must
be split into single-question consults.

**Viable alternative(s):** (a) answer only the first (or the most load-bearing) question and note
the rest as unanswered; (b) answer each question and return one report per question. Either keeps
the run moving where my choice forces a halt-and-redispatch (an `uncertain` disposition halts the
run attended under the consult contract).

**Why it's uncertain:** the spec fixes "exactly one question per dispatch" and the three-value
disposition set, but is silent on the malformed-dispatch case. Mapping it to `uncertain` is the
conservative reading (a protocol violation never produces forward motion), but a reviewer could
reasonably prefer the answer-first-question alternative — it preserves the consult's value at the
cost of tolerating a malformed brief, and each extra halt burns one of the feature's 5 attended
restarts of momentum. The consequence is real: my choice makes a sloppy orchestrator brief cost an
attended halt rather than a degraded answer.
