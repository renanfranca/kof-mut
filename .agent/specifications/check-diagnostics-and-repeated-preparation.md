# Explainable check failures and fewer repeated preparations

## Status and source

- **Status:** approved specification, 2026-10-30. Not implemented.
- **Source:** user requirements and decisions in the 2026-10-30 planning session (analysis of the supplied plan "Reduzir execuções repetidas na suíte completa do KofMut", follow-up measurements, and the approved behavioral acceptance proposal).
- **Base observed:** branch `multiple-test-invocations`, HEAD `5aeb0c5`.
- **Applies to:** `./scripts/check`, the Kof behavioral test suites under `src/test/kof/kofmut/`, test fixtures under `src/test/fixtures/`, and the minimal production extractions needed for direct contracts.

## Purpose

`./scripts/check` is the single acceptance entry point. It currently fails in ways that cannot be explained afterwards, and it pays repeated full preparations that are not the subject of the test being run. This work MUST:

1. make every integration failure identify the failed condition and keep its evidence;
2. make every check run record machine load and process state, so a slow or failed run can be explained; and
3. reduce repeated real preparations in tests whose guarantee does not require them, without losing any guarantee.

## Measured context

These observations motivate the requirements. They are not acceptance results for this work.

| Observation | Source |
| --- | --- |
| 2026-10-30 full check with Kof 0.6.8 primary and 0.6.6 alternate: exit 1 after 2525.145 s. The CLI suite alone accounts for 2521.280 s, 24 passed and 8 failed. Run, Install and frontend contracts were not reached. | `.agent/validation/kof-068.md`; `.agent/tmp/kof-068/24b180a9-789a-4d11-939f-29eb705b755d/0.6.8-full-check.stdout` |
| Each test run alone, same Kof selection: CLI ≈1040 s, Run ≈989 s, Install ≈2109 s, contracts 9.6 s. All 8 tests that failed on 2026-10-30 passed alone. Only `minst08` and `minst21` failed, both with `readiness missing`. | `.agent/tmp/measure-d847c0f6-a4d9-4ada-972d-dca5a9b211b1/results/` |
| In that measurement, `results.tsv` labels `mcli28` and `mrun08` as failures, but both exited 0 with `PASS`. | `…/results/out/mcli28.txt`, `…/results/out/mrun08.txt` |
| The whole CLI suite in one invocation took 665.509 s, 31 passed and 1 failed (`mcli27`, bare `assertion failed`). No test processes remained afterwards. The 31 s timeout lines printed after the `mcli27` failure belong to `mcli28`, the deliberate blocked-compiler test, which passed. | `.agent/tmp/suite-72515805-f3e1-44f6-897f-bcaf9123eed7/results/` |

Interpretation: on an idle host, the same tests are several times faster and mostly pass. Their results are highly sensitive to host load, and several failures cannot be attributed because their assertions carry no message and their evidence is deleted.

## Scope

In scope:

- assertion messages, evidence retention, synchronization barriers and wait bounds in the integration tests named below;
- a check observer that runs inside every `./scripts/check`;
- conversion of repeated real preparations into refused-compilation checks and direct Kof contracts, keeping at least one real path per guarantee family; and
- the validation records and the bilingual README validation note.

Out of scope, and MUST NOT be introduced:

- a reduced or alternative check profile; `./scripts/check` remains the complete acceptance;
- running suites or tests in parallel to save time;
- changing any production deadline, public CLI, JSON field, exit code, compatibility policy or approval rule;
- automatic retries until success;
- removing a guarantee to save time;
- changes to Kof, the user's real installation, other repositories, commits, worktrees, subagents, remotes or publication.

## Unchanged behavior

The following MUST remain observably identical:

- the production deadlines and their sources:
  - preparation total 90000 ms (`src/main/kof/kofmut/launch/Compatibility.kf:87`);
  - shared process cleanup 2000 ms (`Compatibility.kf:100`);
  - each preparation command ≤30000 ms and bounded by the remaining preparation time (`Compatibility.kf:146-148`);
  - synthetic trial `commandTimeoutMs` 10000 and `budgetMs` 25000 (`src/main/kof/kofmut/CompatibilityProbe.kf:47`);
  - bootstrap compilation `timeout --kill-after=2 30` (`scripts/bootstrap/Launch.kf:79-82`);
  - `kof info` and `sha256sum` `timeout --kill-after=2 10` (`scripts/launch`);
- approval by content identity and behavioral checks, never by a literal version;
- the order of check stages (version, CLI, Run, Install, frontend contracts), stopping at the first failing stage, and the exit status of each outcome.

## Stop rule

If diagnosis shows that a failure is caused by production behavior rather than by the tests or the test supervisor, work on that failure MUST stop. The executor MUST report the retained evidence to the user and obtain authorization before any production fix. Until then the failure MUST remain recorded as pending.

## Requirements

### R1. Integration failures name the failed condition

- In `src/test/kof/kofmut/Cli.kf` and `src/test/kof/kofmut/Install.kf`, every `assert` in the following tests MUST carry a message naming the checked condition:
  - tests tagged `compatibility` or `launch-arguments`;
  - the eight tests that failed on 2026-10-30 (CLI tests 5, 7, 11, 17, 19, 25, 29 and 31 in declaration order);
  - `mcli27` ("INT and TERM discard an emitted candidate…"), `minst08` and `minst21`.
- Messages MUST be string literals, because Kof 0.6.6 rejects calculated assert messages with PARSE087 (`EXECPLAN.md`, M6 record). Calculated diagnostics MUST go through the existing helpers `cliAssertEvidence` (`Cli.kf`) and `installAssertEvidence` (`Install.kf`), which print evidence and use a literal message.
- Assertion conditions MUST NOT change. Only their identification changes.

### R2. A failing test keeps its disposable directory

- When a test fails, whether through a failed assertion or an exception, its disposable directory under `.agent/tmp/` MUST be preserved and its absolute path MUST be printed in the test output.
- When the test passes, the directory MUST be removed, as it is today.
- This replaces the unconditional `finally { assert(Directory(project).delete()) }` cleanup in the tests covered by R1. Other tests MAY adopt the same mechanism.

### R3. Test waits are never shorter than the production bound

- A test MUST NOT fail an operation that the product still allows to be running. Each wait that observes a product operation MUST use the production bound for that operation, measured with a monotonic clock (`System.nanoTime()`) from the start of the observed invocation, plus the shared 2000 ms cleanup when termination is observed. A full preparation observed from invocation start is therefore bounded by 92000 ms.
- Known waits below their bound that MUST be corrected:
  - `installReady` in `Install.kf` (30000 ms readiness). Readiness is written by the configured project runner (`src/test/fixtures/m3-runner:19`, configured at `Install.kf:44-48`) during the baseline check, which follows compatibility preparation. It is the failing condition of `minst08` and `minst21`.
  - The integrity test (`Cli.kf`, "contents changing during preparation…"): 30000 ms readiness, then 30000 ms completion after release.
  - The INT/TERM test (`Cli.kf`, `mcli27`): 30000 ms readiness, and 5000 ms termination after the signal.
- Every other wait in the R1 tests MUST be reviewed. A wait MAY change only when a cited production bound exceeds it. Waits on operations without a production bound MUST stay unchanged unless a justification is recorded.
- Existing lower-bound assertions that prove a deadline is honored (for example `commandElapsed >= 29000` in `mcli28`) MUST remain.
- The reference pattern is the timeout test in `Cli.kf` ("a preparation command timeout refuses evaluation…"): monotonic start before spawn, readiness bounded by the preparation total, and a total assertion `< 92000`.

### R4. Barriers, not sleeps, prove that a phase started

- In the R1 tests, a phase transition (compiler emitted, preparation reached a stage, evaluation started) MUST be proven by a readiness barrier written by the fixture, such as the `KOF_MUT_TEST_READY` files of `controlled-toolchain/kof`.
- `Thread.sleep` MAY remain only as a polling interval. Any remaining fixed sleep used as evidence MUST be replaced by a barrier or carry a recorded justification. One example is the 100 ms sleep before the "no late approval" assertion in `mcli27`.

### R5. Every check records load and process state

- `./scripts/check` MUST create a fresh directory `.agent/tmp/check-<id>/` and record in it:
  - samples at an interval of 2 s or less, each with a timestamp, `/proc/loadavg`, and the count, CPU, RSS and thread totals of the check's own process tree;
  - the start, end and exit status of each stage (version, CLI, Run, Install, frontend contracts); and
  - at the end, the list of the check's processes still alive.
- The observer MUST NOT change the check's exit status, stage order or stop-at-first-failure behavior. A failing suite still makes the check return its failure, and later stages still do not run.
- The observer MUST stop when the check ends, including on failure and on INT or TERM. Samples already written MUST be kept. The check's existing INT and TERM exit statuses (130 and 143) MUST be preserved.
- At the end, the check MUST print the observation directory path.
- `scripts/check` currently ends with `exec ./scripts/launch contracts`, which prevents finalization. It MUST be restructured so that the observer can finalize while preserving that stage's exit status.
- The observer is development tooling, outside the product engine. It MAY be a shell script under `scripts/`, consistent with the existing scripts. It MUST be covered by a behavioral Kof test on a short synthetic command. That test MUST show that:
  - a command exiting 7 yields 7;
  - at least one sample is written;
  - the observer stops with the command; and
  - no observer process remains alive.
- The observer records load. It MUST NOT be presented as proving the cause of a slow run.

### R6. Invalidation is proven with refused compilation

- A test whose guarantee is "this content change is detected and requires preparation" MUST prove it with the existing refused compilation of `src/test/fixtures/controlled-toolchain/kof` (`KOF_MUT_TEST_COMPILE=refuse`) instead of a real rebuild for every change.
- Expected observation, after a change with preserved timestamps and a call under refusal:
  - the launcher exits 2;
  - stdout is empty;
  - stderr shows the refused preparation; and
  - the build log is unchanged, because the fixture refuses before logging `build`.

  The plausible incorrect behavior, reusing the previous image, would print `KofMut 0.1.0` with exit 0, so the two are distinguishable.
- After restoring the original bytes, a call under refusal MUST succeed and reuse the previous image without compiling. This proves the restore and prevents contamination between cases.
- Each case MUST start from a known valid image, and cases MUST NOT depend on test order.
- Candidates, to be confirmed against the measured call counts: `mcli15`, `mcli14`, and the invalidation parts of `mcli17` and `mcli31`, plus Install tests with the same pattern.
- R6 MUST NOT be applied to `minst12`. Its cost comes from nine `install.sh` cycles, most of which reuse classes, not from compilations. Its rules are candidates for R8 instead.

### R7. Each family keeps a real rebuild and recovery

At least one real preparation and recovery MUST remain for each family:

- **bootstrap inputs:** a changed input produces a real build, and `--version` exits 0;
- **compatibility approval:** a real rebuild with real Killed and Survived synthetic trials;
- **installed image:** a real `install.sh` producing a new identity.

### R8. Direct contracts for identity, approval and descriptor rules

- Content identity, approval and descriptor rules MUST gain direct behavioral contracts in Kof, executed by `./scripts/launch contracts` in the same compilation and JVM as the existing frontend contracts. They cover:
  - **content identity:** sources, launchers, jar and JDK files; changes with version and timestamps preserved; added and removed files;
  - **approval:** incompatible identity, missing or invalid evidence, and a class inventory that is altered, incomplete or has extra files;
  - **descriptors:** contradictory fields, incompatible paths, truncated delivery.
- Contracts MUST use small synthetic files in temporary directories created by the contract. They MUST NOT write under `build/cache` or `state/kof-mut`. Approval-like fixtures MUST NOT authorize any evaluation through the real launcher.
- Production code MAY be extracted only as far as needed to call these decisions directly. The launcher MUST keep calling the same decisions. There MUST be no test flags, artificial approvals or alternative execution paths.
- Extractions change the runtime source identity. That consequence, including the need to update installed packages, MUST be recorded, and the bilingual installation guide MUST be revised if its guidance no longer holds.

### R9. Real proofs that remain

These guarantees MUST keep at least one real integration proof:

- initial approval and reuse;
- refusal of a frontend with incorrect behavior despite successful compilation;
- Killed and Survived;
- Kof change without checkout;
- integrity before loading classes;
- concurrency, signals and leases;
- preservation of evaluated inputs;
- the 30 s and 90 s deadlines and the confirmed evaluation beyond 90 s (`mcli28`, `mcli32`, `minst03`, `minst04`).

## Acceptance

Each criterion lists its source, example and verification. Planned evidence MUST be recorded separately from observed results.

| ID | Criterion | Example (context → action → result) | Verification and evidence |
| --- | --- | --- | --- |
| A1 | R1 | `mcli27` signal termination exceeds its bound → output shows `FAIL …` with a literal message naming that check, not `assertion failed`. | Audit list of the R1 asserts. Negative control in a disposable copy: invert one `mcli27` condition and observe the named message. `Cli.kf --tag compatibility` passes on 0.6.6, proving that the messages compile. |
| A2 | R2 | A forced failure in a disposable copy → the directory exists and its path is printed. A green run → the directory is removed. | Both runs recorded, including one failure raised as an exception. |
| A3 | R3 | Cold installed evaluation whose preparation takes 45 s → `installReady` no longer fails at 30 s, and the test passes. Preparation beyond 92 s still fails, with the elapsed time in the message. | Table of changed waits (before → after → production source line). `minst08` and `minst21` pass alone. `git diff` shows no change to the production deadline lines. If either test still fails with the corrected bound, the stop rule applies. |
| A4 | R4 | `mcli27` sends signals only after the fixture readiness file exists. | Audit list of sleeps in the R1 tests, with a justification or barrier for each fixed sleep. |
| A5 | R5 | `./scripts/check` prints `.agent/tmp/check-<id>/` containing samples, stage timings and the remaining process list, with an exit status equal to the previous behavior. INT during the check returns 130 and keeps the samples. | Output of the observer's Kof test. One real check run with its observation directory. |
| A6 | R6 | `mcli15`: a changed input with preserved timestamp, called under refusal → exit 2, empty stdout, unchanged build log. After restore → exit 0, `KofMut 0.1.0`, no build. | Converted tests pass. Counts in A9. |
| A7 | R7 | One test per family performs a real rebuild and recovery. | Named in the guarantee map (A8). |
| A8 | R8, R9 | Every assertion removed from a converted test maps to a direct contract or to a real integration that observes the same result. | Guarantee map in the validation record: guarantee → test before → test after. Negative controls, each a temporary patch in a disposable copy, MUST fail both a direct contract and at least one integration: (a) approve by version and timestamp only; (b) ignore the class inventory; (c) approve on successful compilation only. |
| A9 | Reduction | Every converted test performs fewer real `build` calls than its baseline. For example, `mcli15` baseline is 10. | Repeat the `measure-d847c0f6` method (PATH shim, one unique tag per test in a disposable copy, one test per invocation, same Kof selection) for the converted tests only. Compare with `results.tsv`. Duration is recorded without a target. Gains MUST NOT be attributed to removed checks. Calls through Kof copies (`mcli31`) and through the 0.6.6 alternate bypass the shim, and this limitation MUST be recorded. |
| A10 | Overall | `./scripts/check` with 0.6.8 first on PATH and `KOF_MUT_COMPATIBILITY_OTHER` pointing at 0.6.6 → exit 0, all stages reached, observation directory written. | Required on 0.6.6: `Cli.kf --tag compatibility`, `Cli.kf --tag launch-arguments`, `Install.kf --tag compatibility` (with 0.6.8 as the alternate), `Install.kf --tag launch-arguments` and `./scripts/launch contracts`, all green. Record outputs, exit codes and observer data. |

Executor obligations before delivery:

1. Recheck each expectation against its cited source, separately from checking that the tests demonstrate it.
2. Record, for each criterion, the command or procedure, the observed result, and the assertion or artifact location. A green suite alone does not establish every criterion.
3. Record failed checks, coverage gaps and unverified criteria. No criterion with an open gap may be presented as satisfied.
4. Record results in `EXECPLAN.md` and in a validation record under `.agent/validation/`, with logs under `.agent/tmp/`. Update the "Validation" section of `README.md` and `README.pt_BR.md` to mention the check observation directory.

## Rejected alternatives

- **Running suites in parallel.** It could cut wall time on the 32-core host, but it increases contention, which the measurements link to deadline failures. Rejected for this work.
- **Raising production deadlines or adding retries.** This would hide the failures instead of explaining them. Excluded by the project rules.
- **A reduced check profile.** `./scripts/check` remains the full acceptance.
- **A time target for the reduction.** Durations vary with host load. Success is measured by real build counts, and time is only recorded.
- **Refused compilation for `minst12`.** Its cost is installation cycles, not compilation, so it is addressed through direct contracts.
