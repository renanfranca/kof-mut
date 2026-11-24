# Stop budget performance: baseline and per phase timings

Plan: `.agent/execplans/stop-budget-performance.md`. Measured on 2026-11-23.

## Environment

| Item | Value |
| --- | --- |
| Machine | Intel Core i9-14900HX, `nproc` 32, Linux 7.0.0-43-generic, ext4 |
| Kof | `~/.local/share/kof/kof-0.7.0-linux-x86_64/bin/kof` first on PATH; launcher sha256 `2077c8648748586cde5e57c991256dad0d8acd3bffa4744598661831a5f35ef3`, `kof.jar` sha256 `fda317b89bb05ffdb068c2d4ff80be71ecfa5dee821b7b322bfe296acb24ae17` |
| SiFuture | `15f8f4a01c2ac17f5bdd15a392d8fe0fdd54dce5`, clean, config `kof-mut.json` with `maxParallelMutants: 4`, `commandTimeoutMs: 30000` |
| B0 | KofMut `1dffa555bbc347b320177c873af4fed51a9ac37d`, frozen with `git archive` in `.agent/tmp/perf/b0` |
| Instrumented | the same commit plus this plan's uncommitted changes (`-dirty` in `environment.tsv`) |

Kof 0.8.1 is the `kof` on PATH since 2026-11-23 10:20, but KofMut refuses it: since Kof 0.8.0, `json.decode` into a record field typed `Object` or `List<Object>` throws `JSN006: json.decode expected an array but the payload is a number`, and `JsonShape.kf` relies on that pattern. The compatibility probe therefore fails before any evaluation, for B0 and for this tree. E6 used Kof 0.7.0, so every measurement and test below pins 0.7.0 through PATH. Kof was not modified.

Each run started only with a one minute load under 4 (`scripts/measure-run` waits). Evidence: `.agent/tmp/perf/<session>/budget-<budgetMs>-run-<n>-<runId>/` with `environment.tsv`, `stdout`, `stderr`, `report.json`, `states.tsv` and, for the instrumented tree, `timings.tsv`. Commands:

```
scripts/measure-run <launcher> ~/projects/kof-sifuture ~/projects/kof-sifuture/kof-mut.json .agent/tmp/perf/scope-<file>.json 0 3 .agent/tmp/perf/<session>-<file>
scripts/measure-run <launcher> ~/projects/kof-sifuture ~/projects/kof-sifuture/kof-mut.json .agent/tmp/perf/scope-<file>.json 85000 1 .agent/tmp/perf/<session>-<file>
```

## Smaller file

`BossShot.kf`, the first file tried: `complete` with 16 candidates on B0 and `budgetMs: 0`. `SubchiefShot.kf` and `ShipContact.kf` were not needed.

## B0

| File | budgetMs | Run | Exit | Status | reportDurationMs | wallMs | Candidates | Killed | Survived | Timeout | Pending | load1 before/after |
| --- | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| Meteor | 0 | 1 | 0 | complete | 133077 | 134829 | 26 | 26 | 0 | 0 | 0 | 3.99/26.28 |
| Meteor | 0 | 2 | 0 | complete | 129672 | 131294 | 26 | 26 | 0 | 0 | 0 | 3.95/26.58 |
| Meteor | 0 | 3 | 0 | complete | 67256 | 68666 | 26 | 26 | 0 | 0 | 0 | 3.27/15.27 |
| Meteor | 85000 | 1 | 3 | incomplete | 85120 | 86663 | 26 | 21 | 0 | 4 | 1 | 3.63/23.43 |
| BossShot | 0 | 1 | 0 | complete | 74240 | 76260 | 16 | 16 | 0 | 0 | 0 | 3.50/20.94 |
| BossShot | 0 | 2 | 0 | complete | 39444 | 41010 | 16 | 16 | 0 | 0 | 0 | 3.73/15.04 |
| BossShot | 0 | 3 | 0 | complete | 37211 | 38797 | 16 | 16 | 0 | 0 | 0 | 3.87/15.43 |
| BossShot | 85000 | 1 | 0 | complete | 37695 | 39274 | 16 | 16 | 0 | 0 | 0 | 3.88/16.30 |

## Instrumented

| File | budgetMs | Run | Exit | Status | reportDurationMs | wallMs | Candidates | Killed | Survived | Timeout | Pending | load1 before/after |
| --- | ---: | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| Meteor | 0 | 1 | 0 | complete | 147462 | 149555 | 26 | 26 | 0 | 0 | 0 | 3.97/24.70 |
| Meteor | 0 | 2 | 0 | complete | 147357 | 149262 | 26 | 26 | 0 | 0 | 0 | 3.79/24.09 |
| Meteor | 0 | 3 | 0 | complete | 157399 | 159121 | 26 | 26 | 0 | 0 | 0 | 3.83/26.18 |
| Meteor | 85000 | 1 | 3 | incomplete | 85138 | 86786 | 26 | 16 | 0 | 4 | 6 | 3.69/20.21 |
| BossShot | 0 | 1 | 0 | complete | 74842 | 76646 | 16 | 16 | 0 | 0 | 0 | 3.87/20.81 |
| BossShot | 0 | 2 | 0 | complete | 76480 | 78039 | 16 | 16 | 0 | 0 | 0 | 3.67/20.97 |
| BossShot | 0 | 3 | 0 | complete | 38796 | 40356 | 16 | 16 | 0 | 0 | 0 | 3.33/13.49 |
| BossShot | 85000 | 1 | 0 | complete | 38984 | 40588 | 16 | 16 | 0 | 0 | 0 | 3.91/11.82 |

Durations are bimodal on both trees: BossShot runs take either about 38 s or about 75 s, Meteor about 67 s or 130 to 157 s, with the same starting load. The cause was not identified.

## Identity lists

All three `budgetMs: 0` runs of each file produce the same sorted `id/status/phase` list, on B0 and on the instrumented tree (`diff` empty for all six instrumented runs against B0 run 1).

| File | sha256 of `states.tsv` | Example path |
| --- | --- | --- |
| Meteor | `8ade86979bba9d1ff6ee48aa40b9da4f87a8e3099910a3df9edd7db4279d03ee` | `.agent/tmp/perf/b0-meteor/budget-0-run-1-2b8553be-30c8-4f2a-a39c-fa59131d03a4/states.tsv` |
| BossShot | `48b239e64e1be1b72602bb9092a8e182e41c3a2a4768a6e21510283a5f762931` | `.agent/tmp/perf/b0-bossshot/budget-0-run-1-362913b0-90bf-4882-80eb-310d72410b91/states.tsv` |

## Meteor phase breakdown

78 candidate rows from the three instrumented `budgetMs: 0` runs (`python3 .agent/tmp/perf/breakdown.py .agent/tmp/perf/instrumented-meteor`). Share is the phase sum over the `totalMs` sum (1618270 ms).

| Phase | Median ms | Share of totalMs |
| --- | ---: | ---: |
| lock wait | 0 | 0.1% |
| prepare | 3 | 0.0% |
| validate | 2 | 0.0% |
| check | 7685.5 | 36.9% |
| check release | 55 | 0.3% |
| test | 12848.5 | 62.5% |
| test release | 41.5 | 0.2% |
| remove | 2 | 0.0% |
| total | 20720.5 | 100% |

BossShot gives the same picture: check 34.0%, test 65.4%, overhead 0.6%, median total 17009 ms.

Speed of four slots, as the sum of candidate `totalMs` over `reportDurationMs` minus the baseline row's `totalMs` (this denominator still includes scanning and report writing, so the value is slightly low):

| Run | Sum of candidate totalMs | Engine time after baseline | Speedup |
| --- | ---: | ---: | ---: |
| Meteor 1 | 523458 | 137607 | 3.80 |
| Meteor 2 | 519096 | 136846 | 3.79 |
| Meteor 3 | 575716 | 150778 | 3.82 |
| BossShot 1 | 278207 | 70033 | 3.97 |
| BossShot 2 | 284476 | 71338 | 3.99 |
| BossShot 3 | 133457 | 33770 | 3.95 |

## Findings

- KofMut overhead (lock wait plus release plus prepare plus remove) is 0.7% of mutant time on Meteor and 0.6% on BossShot. Project commands (check plus test) are 99.4%. The lock wait inside these spans is 0.1%.
- Four slots deliver a 3.8 to 4.0 speedup, so the slots do run in parallel.
- This refutes the planning estimate that most time is spent inside KofMut. Each command is just much slower under KofMut than alone: a Meteor check takes 7.7 s and a test 12.8 s at the median with four mutants running, against 1.72 s and 2.95 s measured alone while planning. Four concurrent Kof JVMs contend for the machine (load reaches 24 to 26 on 32 cores).
- The numbers favor the plans that reduce project command work (compile once and run many, or select fewer tests) over taking work out of the global lock or skipping release polling, which together can save at most about 1% of mutant time.
- Meteor at the current SiFuture commit has 26 candidates and 0 survivors, not E6's 41 candidates, 37 Killed and 4 Survived. With `budgetMs: 85000`, B0 left 1 mutant `Pending` and 4 `Timeout`; the instrumented run left 6 `Pending` and 4 `Timeout`. The Timeout mutants are those stopped by the global budget. The difference in Pending follows the slower instrumented session (147 s against 130 s at the median), not the instrumentation itself.

## Criteria

| Criterion | Command | Observed | Status |
| --- | --- | --- | --- |
| B0 Meteor `budgetMs: 0`: 41 candidates, 37 Killed, 4 Survived, same list three times | B0 session | 26 candidates, 26 Killed, same list three times | Different from E6, recorded, not adjusted |
| B0 Meteor `budgetMs: 85000`: Pending recorded | B0 session | 1 Pending, 4 Timeout | Recorded |
| SiFuture preserved | `git status --porcelain` and the `find ... sha256sum` manifest before and after | identical (manifest sha256 `2763a6e02f28579b9d96094d4f918564083752da88eb8c7d9f5ed802c1aea1ff`) | Passed |
| `timings.tsv` rows, order and values; report keys and stdout unchanged; discarded candidate row | `kof test src/test/kof/kofmut/Run.kf --tag timings` | 2 passed | Passed |
| Instrumented id/status lists equal B0 | `diff` | empty for all six runs | Passed |
| Meteor breakdown | `breakdown.py` | table above | Passed |
| Instrumented median `reportDurationMs` within 5% of B0 | sessions above | Meteor 147462 against 129672 (+13.7%); BossShot 74842 against 39444 | Not met; the bimodal noise is larger than the gap, and instrumentation phases measure under 1% of time, so the gap cannot be attributed to instrumentation |
| Focused `check-run-a` and `check-run-b` `0 failed` | `kof test ... --tag check-run-a`, `--tag check-run-b` | 4 and 5 failures without `LC_ALL`; B0 under the same conditions: 4 and 2 | Failed, also on B0 |
| `./scripts/check` exits 0 | `PATH=<0.7.0>/bin:$PATH KOF_MUT_COMPATIBILITY_OTHER=<0.6.4>/bin LC_ALL=C.UTF-8 ./scripts/check` | exit 1 in 1300 s; `run-a` 2 failures, `run-b` 2 failures, the other queues and the coverage guard passed | Failed |

The failing tests are parallel and budget tests: `persistent cleanup failure shares one deadline across concurrent callers and cannot approve`, `cleanup failure preserves a prior discard survivor and kills with original identities and permits recovery`, `individual deadlines leave siblings and the queue running while the global budget stops all active phases` (`readiness missing` after 15 s) and `zero budget continues baseline and queued candidates beyond a bounded run deadline`. Across these runs, the `parallel-runner` fixture also reports `rmdir: failed to remove '.../counter-lock': No such file or directory`, which turns a candidate into `TestError`; it appears on B0 too. The full check took 1300 s against the 803 s recorded with Kof 0.7.0 in `kof-070-revalidation.md`. Check observations: `.agent/tmp/check-c67d4fc9-21e8-402a-a8ff-d6c0622167b2`.

## Fixture race correction

The `counter-lock` error came from the system `mkdir`, uutils coreutils 0.10.0 (`/usr/bin/mkdir` resolves to `/usr/lib/cargo/bin/coreutils/mkdir`). It is not atomic: two concurrent `mkdir` calls on the same path both succeeded 473 times in 400 rounds, while GNU `mkdir` (`/usr/bin/gnumkdir`) succeeded exactly 400 times. The `parallel-runner` fixture used `mkdir` as a lock, so two runners could enter its counter section together. It now uses `flock` from util-linux on `$log/counter-lock`. The kernel also releases that lock when a runner is killed.

| Check | Observed |
| --- | --- |
| Stress with 8 concurrent runners, 150 rounds each, group kill after each exit, old fixture | 62 of 1200 runs failed, final count 39 instead of 0, maximum 41 with only 8 runners |
| The same with the `flock` fixture, twice | 0 of 1200 runs failed both times, final count 0, maximum 8 and 6 |
| `./scripts/check` with the Kof 0.7.0 recipe | exit 1 in 1119 s; `run-b` and every other queue passed, no `counter-lock` error; `run-a` failed 3 cleanup failure tests (`persistent cleanup failure shares one deadline...`, `cleanup failure preserves five completed kills...`, `cleanup failure preserves a prior discard survivor...`) |
| `kof test src/test/kof/kofmut/Run.kf --tag check-run-a` alone, same recipe | `0 failed of 25 tests` in 442 s |

The remaining failures exceed duration bounds under the full check's load, with the expected states and limitations. `four-active` took 6149 ms in the full check against a `durationMs < 5500` bound, and 5115 ms with `run-a` alone. Two of these three tests also failed on B0. Check observations: `.agent/tmp/check-b3e05365-5a5a-47b0-8c25-9014f7cf7988`.
