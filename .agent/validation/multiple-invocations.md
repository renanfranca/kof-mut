# Concatenated test invocations, 2026-10-26

## Scope and identity

KofMut base `a40b20ac37afac302efc2a0dae7702e44720e166`, branch `multiple-test-invocations`, uncommitted implementation. Public schema/configuration/statuses/exits remain v1. SiFuture base `dc96b0366eee67b3417d58dbe14a06c66e6651aa` is used only through disposable copies in that repository. No compiler modification, hooks, permanent SiFuture catalog additions, commits, worktrees, subagents or publication.

Dependency: existing Kof 0.6.6 Linux/JVM, jar SHA-256 `198bb211dbcefe60bd02f703dff991e82ba55c94f805b1b2b863362757289e58`; local research checkout `7c237861a9035d84b1f7ec4cfddd89daef4c6ddd`. Consulted training index, control flow/string/function/class idioms, fake idioms, duplicate state, CLI/testing corpus, language reference statements/expressions/classes, Learn Kof chapter 23 and current `CmdTest.java`. CLI final summaries count files; named PASS/FAIL count cases, and `exit code:` is emitted for the just-completed suite.

## Implementation and separate audits

`Evidence.kf` validates each final summary against the current invocation, resets invocation counters, and preserves aggregate executed/failed cases. Every invocation must have suites and executed cases. Pending suites, absent/duplicate summaries, count contradictions and an aggregate exit inconsistent with failures remain invalid. A later success cannot clear earlier failure. Per-suite exit diagnostics validate the failed suite independently of the final wrapper return.

Tests extend the existing synthetic mutation-runner and public Run suite with tag `multiple-invocations`: six valid shapes, initial failure in either invocation, and fourteen invalid shapes at baseline/variant. Expected results were derived separately from `docs/cli.md` and the report status table: complete/0 Killed, complete/1 Survived, baseline_failed/2 before candidates, incomplete/3 TestError without a kill. Two plus one cases must be three, distinct from file counts.

Discrimination audit: ignoring either invocation fails count/detection assertions; last-result-only fails first detection. Confusing files/cases fails 3-case assertions and two-suites/one-invocation control. Treating any nonzero exit as a kill fails invalid mutant controls. Legitimate baseline failure requires 3 observed cases, 1 failure and a valid failure summary; protocol rejection does not satisfy that assertion. Filtered SKIP retains executed case counts. Raw audit notes are optional supporting evidence under `.agent/tmp/multiple-invocations/`.

## Observations so far

- `kof test src/test/kof/kofmut/Run.kf --tag multiple-invocations` with old production reader: exit 1, all three regression groups failed. The valid 2+1 output produced baseline_failed and no evaluated candidate. `red.log`, 96122 ms.
- Same command after correction, first attempt: exit 1 before behavior could be tested; preparation compilation exceeded its 10000 ms maximum. `green.log`, 58803 ms. This is not a reader failure or passing acceptance.
- Independent temporary proof using exact current records/parser functions and synthetic runner outputs: exit 0, two groups passed, six valid and fourteen invalid shapes; `reader-proof.log`, 8179 ms. Identical test suffix against exact HEAD parser: exit 1, valid-shape group failed and invalid-shape group passed, `reader-old-proof.log`, 8496 ms. This supports the parser behavior only, not the public executable/integration.
- Repeated preparation with default JVM exceeded compilation deadline. JVM process options `ActiveProcessorCount=4`, then `ActiveProcessorCount=2/TieredStopAtLevel=1`, then `ActiveProcessorCount=1/TieredStopAtLevel=1/UseSerialGC` allowed compilation but the real synthetic compatibility evaluation exhausted its unchanged 8500 ms budget. In the two-processor attempt: baseline check 829 ms, baseline test 4112 ms, variant test Timeout, total 8543 ms. Default Kof 0.6.4 also exceeded the compilation deadline. These are diagnostic attempts only; no dependency contents or product limits changed.
- High host load and a Ghostty process using roughly fourteen CPU cores were observed. Causality for the entire slowdown has not been established.

- Focused command repeated with final Run.kf/runner inputs: exit 1, three groups failed during preparation; `focused-final.log`, 73336 ms. Default-JVM compilation completed in this attempt, then the compatibility killed probe returned incomplete with one Timeout: baseline check 1148 ms, baseline test 5191 ms, variant test 2031 ms, total 8536 ms. The reader accepted the baseline single-suite evidence. The public multiple-invocation behaviors still were not reached.
- Real SiFuture disposable Background copy: normal wrapper test command passed 115 cases (1 + 114), zero failures, exit 0. Manual recipe returned 2 during compilation preparation, no reportPath. Inspection rejected absent current evidence. All 190 copied file hashes/modes remained equal, configuration SHA-256 `2e24df1360b021bbf30d4cf4f7fdcdcf1cec202d601a45b018c61b65d8fda9bd`. SiFuture records retain the actual run UUID `8b9c3e97-3fe2-4e31-85c1-4d9de2f63cbd`; there is no final mutation report to cite. No SiFuture sources were copied into this repository.
- Diagnostic 0.6.4 jar identity verified separately: SHA-256 `137a838d38757e317545474d55ad6a3ad291fb86d263ae77d9197cf705829c62`. No dependency bytes were altered. Local Kof source checkout remains clean.

## Full validation result and limits

`./scripts/check` returned **1** at the CLI suite: 18 passed, 13 failed of 31, 1308389 ms. Because scripts/check stops on failure, the complete Run.kf suite, Install.kf and frontend contracts were not reached. Several failures explicitly show compilation deadline or compatibility preparation refusal. Other assertions do not print an individual detailed cause; they are not all attributed to host load without further evidence. Full raw output: `.agent/tmp/multiple-invocations/check.log`.

```text
13 failed of 31 tests
exit code: 1
0 passed, 1 failed
time: 1308389ms total, slowest src/test/kof/kofmut/Cli.kf (1308389ms)
```

The test/public-code inputs were frozen throughout this check. After it ended, the EN/PT report reference was qualified with “With valid test evidence” to distinguish accepted aggregate counts from retained partial counts on invalid output. This documentation clarification does not change execution inputs. Final `git diff --check`, input preservation and manifest checks pass; a passing full check is still pending.

The isolated comparison remains narrower:

```text
PASS reader independently reconciles valid invocation shapes
PASS reader independently rejects invalid trailing evidence
0 failed of 2 tests
```

The identical assertions against HEAD's old reader produce:

```text
FAIL reader independently reconciles valid invocation shapes: assertion failed
PASS reader independently rejects invalid trailing evidence
1 failed of 2 tests
```

This establishes the parser behavior for the synthetic protocol shapes, not completed public application compatibility or real integration. The six valid shapes include detection in the first or last invocation, survival, two suites within one invocation with/without failure, and filtered SKIP. Fourteen invalid shapes are rejected even after an initially valid invocation.

The relevant production mechanism is:

```kof
executed = executed + cases
failures = failures + failed
```

After validating each final summary, only invocation state resets:

```kof
invocations++
invocationSuites = 0
invocationFailedSuites = 0
invocationExecuted = 0
```

See [Evidence.kf](../../src/main/kof/kofmut/Evidence.kf#L124) and the [new behavioral regressions](../../src/test/kof/kofmut/Run.kf). This preserves earlier failures while the next summary is checked against new suites. The official [CLI training](/home/renanfranca/projects/kof/training/tooling/cli.md) describes named PASS/FAIL and tag filtering; [Learn Kof chapter 23](/home/renanfranca/projects/kof/learn/23-testing.md) states “Each test runs **in isolation** (one failing does not interrupt the others).” Current CmdTest.java and actual Kof outputs confirm the file/case distinction used in these expectations. The [weak proof guidance](/home/renanfranca/projects/kof/training/anti-patterns/weak-green-proof.md) motivates exact count/status/exit assertions and the old-reader control, rather than treating exit 0 alone as acceptance.

## Pending acceptance

Passing focused public regression/full check, real SiFuture 115-case Background/detected/survived/failing-baseline runs and removal of the SiFuture guide limitation remain pending. The integration helper extracts the existing approved Bash run/inspection recipes unchanged and checks native exits, UUID/current report/scope/counts/config/input hashes. No passing end-to-end claim is made yet. Historical acceptance remains unchanged.


## Delivery checkpoint

The correction is implemented and parser behavior demonstrated; the approved plan is **not complete**. No passing public or real mutation result is claimed for the correction. Continue with the same commands after preparation can complete under its existing limits; use a new SiFuture attempt directory (`python3 .agent/tmp/multiple-invocations/prove_integration.py .agent/tmp/multiple-invocations/attempt-2`) so no earlier artifact is replaced. Do not widen timeouts/budgets, skip compatibility, omit suites or substitute an older report to obtain approval. The host load observation is a lead, not an established diagnosis for every failed assertion.

Delivery identity is base SHA plus `.agent/validation/multiple-invocations.sha256`. Original plan bytes remain a prefix; prior validation files, source Kof checkout and dependency bytes are preserved. The new record is indexed in `.agent/README.md`. No commit or publication was created.
