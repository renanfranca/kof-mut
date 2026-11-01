# Parallel check queues

Validation record for running `./scripts/check` suites as parallel queues, executed 2026-10-31. Evidence is under `.agent/tmp/check-parallel/73bea95c-8d8c-4fb5-af66-813c93e89d09/` and the observation directory `.agent/tmp/check-7d7f5cea-10c0-4f99-8c89-839fea76f67f/`. A passing run proves its recorded tree and environment, not later revisions.

## Change

- `scripts/check` runs `version` alone, then `cli`, `run`, `install-a`, `install-b` and `contracts` at the same time, each under `scripts/observe`. Each queue writes `<queue>.out`; the check prints it whole when the queue finishes, followed by `queue <queue>: exit <n> in <s> s`.
- Every `Install.kf` test carries exactly one of `check-install-a` (15 tests) or `check-install-b` (16 tests), balanced longest first by the durations in `.agent/tmp/measure-d847c0f6-a4d9-4ada-972d-dca5a9b211b1/results/results.tsv` (1047 s and 1062 s measured alone).
- After all queues pass, the check reads `kof test: tag '<tag>' (k of N)` from both Install queues and fails with `check queues do not cover Install.kf: <a> + <b> of <N>` unless a + b = N.
- A failing check waits for every queue and exits with the status of the first failing queue in the order cli, run, install-a, install-b, contracts. INT and TERM reach every running queue and the check exits 130 or 143.
- `scripts/observe` is unchanged. Its header race does not apply because `version` runs alone first and creates both headers; 12 observers started together into one directory, three times, produced one header each (`race-*`).

## Results

| Run | Command | Result |
|---|---|---|
| Fake harness (`fake/`, PATH shim `shim/kof`) | pass | exit 0 (`pass.out`, `pass2.out`) |
| Fake harness | install-a reports 14 of 31 | exit 1, `check queues do not cover Install.kf: 14 + 16 of 31` (`coverage.out`) |
| Fake harness | run queue fails | exit 1, all other queues finished and printed (`fail.out`) |
| Fake harness | TERM, then INT to the check during the queues | exit 143 and 130, every queue stopped with the same status (`sig-*.out`) |
| Kof 0.6.8 first, `KOF_MUT_COMPATIBILITY_OTHER` = 0.6.6 | `./scripts/check` | exit 0 in 1037 s (`real-check.out`) |

Real run per queue, compared with the sequential check of the same day (`.agent/validation/check-diagnostics.md`, 2631 s):

| Queue | Tests | Parallel | Sequential |
|---|---|---|---|
| version | | 5 s | 6 s |
| contracts | | 12 s | 7 s |
| cli | 34/34 | 902 s | 587 s |
| run | 47/47 | 954 s | 658 s |
| install-a | 15/15 | 1032 s | 1374 s (whole suite) |
| install-b | 16/16 | 949 s | |
| total | | 1037 s | 2631 s |

- The highest load1 was 13.77 (sequential: 5.25). Load average was 0.10 before the run.
- No queue left a process (`leftover.txt`: six `none`).
- Each queue ran about 45 to 55 percent slower than alone, so the gain is 61 percent, not the 4x of perfect parallelism.

## Gaps

- Signals and failure handling were verified on the fake harness only, not during a real run.
- In the fake TERM and INT runs, `leftover.txt` listed `sleep` processes from the shim, which is a bash script that does not use `exec`; the real `kof` launcher uses `exec` to start Java.
- A test that is missing from one queue and duplicated in the other at the same time leaves the sum unchanged and is not caught.
- One real run only. Timing tests passed under this load, but sensitivity to heavier host load is not measured.
- Kof 0.6.6 was not rerun as the first Kof; the change touches only the check script and test tags.

## Regression with Kof 0.6.4

From 2026-10-31 on, the user chose Kof 0.6.4 (`kof.jar` SHA-256 `137a838d38757e317545474d55ad6a3ad291fb86d263ae77d9197cf705829c62`) as the regression Kof instead of 0.6.6. Same tree as above. Commands ran one after another (`kof-064/summary.txt`, outputs in `kof-064/*.out`):

| Kof first on PATH | Command | Result |
|---|---|---|
| 0.6.4 | `kof test src/test/kof/kofmut/Cli.kf --tag compatibility` | exit 0, 9/9, 285 s |
| 0.6.4 | `kof test src/test/kof/kofmut/Cli.kf --tag launch-arguments` | exit 0, 2/2, 41 s |
| 0.6.4 | `KOF_MUT_COMPATIBILITY_OTHER=<0.6.8 bin> kof test src/test/kof/kofmut/Install.kf --tag compatibility` | exit 0, 7/7, 201 s |
| 0.6.4 | `kof test src/test/kof/kofmut/Install.kf --tag launch-arguments` | exit 0, 1/1, 30 s |
| 0.6.4 | `./scripts/launch contracts` | exit 0, 6 s |
| 0.6.8 | `KOF_MUT_COMPATIBILITY_OTHER=<0.6.4 bin> ./scripts/check` | exit 0, 1043 s |

- In the full check, the queues gave cli 34/34 in 909 s, run 47/47 in 960 s, install-a 15/15 in 1041 s and install-b 16/16 in 956 s.
- `version` and `contracts` took 0 s and 1 s because their prepared images from the previous run were reused.
- Observation directory: `.agent/tmp/check-b8675a9a-3a5f-4d93-aa71-fad4b2d9f736/`, with no leftover process and the highest load1 at 15.46.

## Seven queues, not adopted as measured

Each suite was split into queues: `cli-a`/`cli-b`, `run-a`/`run-b`, `install-a`/`install-b`/`install-c`, plus `contracts`. Every test in the three files carries one `check-<queue>` tag, and the coverage guard covers all three files. The fake harness controls passed (`seven/`: pass 0; one short queue per file 1 with the coverage message; failing queue 1 after all queues; TERM 143, INT 130).

Real run: Kof 0.6.4 first on PATH (the user's default, `seven/kof-default.json`), `KOF_MUT_COMPATIBILITY_OTHER` = 0.6.8, host turbo mode enabled by the user. `./scripts/check` exited 1 in 786 s. The highest load1 was 22.55, and no queue left a process. Observation directory: `.agent/tmp/check-e1b5a6cb-17e3-4ec7-90cb-b9356e24a4ad/`.

| Queue | Result | Time |
|---|---|---|
| cli-a | 17/17 | 555 s |
| cli-b | 17/17 | 512 s |
| run-a | 23/24 | 572 s |
| run-b | 23/23 | 539 s |
| install-a | 9/10 | 780 s |
| install-b | 11/11 | 657 s |
| install-c | 10/10 | 670 s |

Two failures, both from test timing under load. Neither is a production fault:

- **`Run.kf`, "individual timeout and global budget stop active descendants…": `descendant and parent must have started`.** The individual mode gives the fixture runner a 3000 ms command timeout, and its parent and child did not both write the ready marker before the timeout.
- **`Install.kf`, "INT and TERM stop installer children…": `behavior failed`.** The independent evaluation timed out in its baseline check (exit 137 after 120073 ms; report `incomplete`). The test holds that baseline until it has finished four interrupted installer updates and their four recovery installs. The fixture gives the check a 120000 ms command timeout, and under this load those cycles took longer than that. Alone, the whole test took 45 s.

The README edit happened a few seconds after this run started. Neither failure involves README contents.

### Rerun with more slack in two tests

At the user's choice, two test-only timing values were raised: the individual command timeout in that `Run.kf` test went from 3000 to 6000 ms, and the command timeout of the shared installed evaluation fixture (`startInstalledEvaluationPath` in `Install.kf`) went from 120000 to 300000 ms. No production deadline changed.

The same run (0.6.4 first, 0.6.8 as the alternate) exited 1 in 759 s, with the highest load1 at 22.51 and no leftover process. Observation directory: `.agent/tmp/check-f51f370d-a141-46e0-ae75-f4f8f542a0c3/`.

- All queues passed except `install-a` (9/10). The `Run.kf` test passed.
- The Install test failed again, this time with `baseline_failed`: `Invalid check JSON: unexpected end of JSON` after 132851 ms.
- **Cause:** the fixture `src/test/fixtures/m3-runner` holds the baseline with a child `sleep 120`. When the release came after 132 s, that child had already exited, and `kill -KILL "$child"` failed under `set -e`, with stderr `kill: (1339407) - No such process`.

So the fixture itself requires the release within 120 s, whatever the command timeout. The test was not rerun.

### Fixture child sleep and a contract defect

With the user's approval, the child in `src/test/fixtures/m3-runner` now sleeps 600 s instead of 120 s. Release still kills it, so passing tests take the same time. No test matches the old text.

That run (0.6.4 first, 0.6.8 as the alternate) exited 1 in 791 s, with the highest load1 at 25.75 and no leftover process. Observation directory: `.agent/tmp/check-52ef2f1f-7364-47c3-8530-07570e73e4fc/`.

- All seven test queues passed, including the Install test from above.
- The `contracts` queue failed: `expected: another identity is not approved`.
- **Cause:** a defect in the contract written during the check diagnostics work. It built the other identity as `"0" + identity.substring(1)`. The identity includes the temporary fixture path, so it changes per run, and about 1 run in 16 it already starts with `0`. In those runs the "other" identity equals the original.
- **Fix:** use `1` when the identity starts with `0`. `./scripts/launch contracts` then passed, 19 PASS lines.

### Final seven queue run, adopted

Kof 0.6.4 was first on PATH, with `KOF_MUT_COMPATIBILITY_OTHER` = 0.6.8 and the user's turbo mode enabled. `./scripts/check` exited 0 in 795 s (`seven-final/`).

| Queue | Result | Time |
|---|---|---|
| version | passed | 0 s |
| contracts | 19 PASS | 1 s |
| cli-a | 17/17 | 562 s |
| cli-b | 17/17 | 523 s |
| run-a | 24/24 | 583 s |
| run-b | 23/23 | 524 s |
| install-a | 10/10 | 794 s |
| install-b | 11/11 | 664 s |
| install-c | 10/10 | 683 s |

- Observation directory: `.agent/tmp/check-6718ed0c-1702-4dc7-ad2d-28561b86c31f/`, with no leftover process and the highest load1 at 27.48.
- Compared with five queues: 795 s against about 1040 s, under turbo mode, so the two figures are not directly comparable.
- This is the first full check with 0.6.4 as the main Kof.
- `install-a` is now the slowest queue by about 110 s.
- Each change after the first failed run fixed a separate cause and was checked by a new run, not by repeating an unchanged tree.

## Deadlines that no longer decide passing tests

Principle: in a passing test, no deadline decides the outcome except the deadline under test, and only the deliberate hang runs inside that window. Evidence: `.agent/tmp/deterministic-timeouts/`. The load harness `load.sh` runs N busy loops around a command.

### Causes found

- **Run timeout test.** In `timeout` mode, `src/test/fixtures/mutation-runner` simulated only the hanging mutant test. Baseline check, baseline test and the mutant check ran real Kof (one JVM each) inside the measured windows: the individual timeout and the global budget, which starts before the baseline. Under load, the mutant check exceeded the timeout, so the mutant test never started.
- **Install evaluations held through installer work.** The test holds the evaluation until it writes `release`, while it runs installer builds that have no bound (`shell.runWith`). Two finite values raced with that work: the evaluated command timeout (120 s) and the `m3-runner` child `sleep 120`.

### Changes, replacing the earlier slack

- **`mutation-runner` in `timeout` mode** answers check and test synthetically. Only the candidate containing `7 / 0` gets an `ARITH001` rejection, which keeps `global-discard` meaningful. Real `ARITH001` discards stay covered by "a coherent compiler rejection is discarded…" and "compiler rejection permits a later detected mutant…". The individual timeout is back to 3000 ms.
- **`Install.kf`:**
  - `commandTimeoutBeyondAnyInstallerWorkMs()` = 3600000 ms is used by `startInstalledEvaluationPath` and by "failed preparation preserves A…" (previously 120000 ms). It is a safety value; the evaluations end through the test's `finally`.
  - `stopRunnerGroupLeftActive(log)` kills the runner process group in those `finally` blocks, mirroring the existing idiom in `Run.kf`.
- **`m3-runner`:** the child runs `sleep infinity`. It dies by release, by kof-mut cleanup (asserted in `Run.kf` `assertStopped`) or by the test's `finally`. It does not die with its parent, because that would hide a cleanup failure.

### Runs (each once, Kof 0.6.4 first)

| Tree | Load | Command | Result |
|---|---|---|---|
| before (timeout 6000 ms) | 96 busy loops, load1 up to 49.6 | `kof test Run.kf --tag timeout` | exit 1, `descendant and parent must have started` (`control-before.out`) |
| after (timeout 3000 ms) | 96 busy loops, load1 up to 64.8 | `kof test Run.kf --tag timeout` | exit 0, 1/1, no leftover (`run-after-load.out`) |
| after | 96 busy loops, load1 about 100 | `kof test Install.kf --tag update` | exit 1, 5/9 passed in 1737 s (`install-update-load.out`) |
| after | none added; the run started while load1 was still decaying from 47 | `KOF_MUT_COMPATIBILITY_OTHER=<0.6.8 bin> ./scripts/check` | exit 1 in 790 s (`check.out`) |

- **Install under load: inconclusive for this change.**
  - Three evaluations never reached the hold. The product's compatibility probe failed first: its real `kof test` exceeded the production 10000 ms command timeout in `CompatibilityProbe.kf` ("synthetic mutation exit"). That is the product correctly refusing an environment it cannot verify in time; production deadlines were not changed.
  - The fourth failure was the test's own 30 s `installReady` bound ("readiness missing: …/concurrent-B").
- **Full check.** Every queue passed except `run-b`. Observation directory: `.agent/tmp/check-b3de23be-1db2-41fc-a07d-ad69333b1be8/`, no leftover after any stage.
  - All Install queues passed, including the four held evaluations (install-a 10/10, install-b 11/11, install-c 10/10).
  - `run-b` failed 1 of 23: "run detects a changed arithmetic result with compiler and suite evidence". Its baseline `kof test` (real Kof) timed out at 10127 ms against `commandTimeoutMs` 10000 in `fixtures/detected/kof-mut.json`.
  - This is the same class of race in another test: a real Kof JVM against a fixture deadline that the test does not verify. The same 10000 ms value appears in `fixtures/equivalent`, `fixtures/survived` and `fixtures/invalid`, and in `fixtureConfig(…, 10000, …)` calls that use the real runner. Not changed yet.
