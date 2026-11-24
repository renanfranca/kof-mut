# C1 only JVM option for SiFuture mutation commands

Plan: `.agent/execplans/jvm-short-commands.md`. Measured on 2026-11-24.

## Environment

| Item | Value |
| --- | --- |
| Machine | Intel Core i9-14900HX, `nproc` 32 (P cores 0 to 15, E cores 16 to 31), Linux 7.0.0-44-generic |
| Kof | `~/.local/share/kof/kof-0.7.0-linux-x86_64/bin/kof` through `.agent/tmp/perf/with-kof-070`, launcher sha256 `2077c8648748586cde5e57c991256dad0d8acd3bffa4744598661831a5f35ef3` (same as the previous record) |
| SiFuture | `15f8f4a01c2ac17f5bdd15a392d8fe0fdd54dce5`, clean |
| KofMut | `594b1ee28cc1569ecd2a72d6c2a9078ebd51a1c0` plus this plan's uncommitted `scripts/measure-run` (`-dirty` in `environment.tsv`); no change under `src/` |

The IDE and other agent sessions were closed before the session that produced the Milestone 2 data, at the user's request after the first Milestone 1 attempts were too noisy (below).

Before each run, the session waited until the whole machine used under 1.0 busy core over 10 s (`.agent/tmp/perf/wait-quiet`, ignored by Git) and `measure-run` waited for a one minute load under 4. Session driver: `.agent/tmp/perf/c1-session.sh`, log `.agent/tmp/perf/c1-session.log`.

## Machine columns in `scripts/measure-run`

Each run now starts KofMut in the background and an inline `python3 -I` sampler next to it. Once per second the sampler reads `/proc/<pid>/stat` of every process, rebuilds the launcher's descendant set from `ppid`, and splits the `utime + stime` deltas into own and foreign CPU (the sampler itself is excluded). It also reads P and E core frequencies, the `coretemp` package temperature (found by `hwmon` name) and the sum of `core_throttle_count`. Each run directory gains `monitor.tsv` (one row per sample) and `monitor-summary.tsv`. `runs.tsv` gains `foreignCoreMax`, `foreignCoreMean`, `maxTempC`, `throttleDelta`, `pMHzMean` and `eMHzMean` after the existing columns. Run numbers continue across invocations for the same `budgetMs`. A `runs.tsv` whose header predates these columns is refused, so earlier tables are never mixed with the new shape.

`bash -n scripts/measure-run` exits 0. `shellcheck` is not installed on this machine, so that check was not run.

## Milestone 1 examples

Command, with `MEASURE_MAX_LOAD=40` and two `python3 -c 'while True: pass'` loops for the positive run only:

```
.agent/tmp/perf/with-kof-070 scripts/measure-run bin/kof-mut ~/projects/kof-sifuture ~/projects/kof-sifuture/kof-mut.json .agent/tmp/perf/scope-bossshot.json 0 1 <out>
```

Accepted attempt, `.agent/tmp/perf/monitor-check-quiet`, IDE and other sessions closed:

| Example | Run | foreignCoreMax | foreignCoreMean | Samples | Expected |
| --- | ---: | ---: | ---: | --- | --- |
| Positive (two loops) | 1 | 2.71 | 2.39 | 2.19 to 2.71 | max 1.8 to 2.2, mean above 1.5 |
| Negative | 2 | 0.47 | 0.36 | 0.22 to 0.47 | max below 1, `run` 2 |

The negative example and the positive mean meet their expectations. The positive maximum does not: it is two loops plus the background that remains with nothing else open, which the negative run measured at 0.36 on average and 0.47 at most (2.39 minus 0.36 is 2.03). The 1.8 to 2.2 range assumed a background near zero. The sampler did not attribute KofMut's own CPU as foreign: during the positive run the foreign value stayed flat while own CPU swung between 0 and 25 cores.

Discarded attempts, `.agent/tmp/perf/monitor-check`, with the IDE, other agent sessions and a background tool running:

| Example | Run | foreignCoreMax | foreignCoreMean | Note |
| --- | ---: | ---: | ---: | --- |
| Positive | 1 | 11.04 | 5.25 | another session's Maven tests started mid run |
| Negative | 2 | 1.59 | 0.72 | two isolated spikes over a 0.6 to 0.8 background |
| Negative | 3 | 5.40 | 1.61 | |
| Negative | 4 | 3.76 | 1.23 | |

These show the monitor doing its job: they would have passed the old one minute load check.

## C configuration

`.agent/tmp/perf/c1/kof-mut.json`, created from `~/projects/kof-sifuture/kof-mut.json` with `python3 -I`; only the two commands differ (the rest is reformatted JSON):

```json
{
  "schemaVersion": 1,
  "sourceRoots": ["src/main/kof"],
  "testRoots": ["src/test/kof"],
  "inputs": ["kof.toml", "src", "scripts/kof_project.py", "scripts/kof-tests.mjs", "scripts/sensor-arguments.mjs"],
  "checkCommand": ["env", "JAVA_TOOL_OPTIONS=-XX:TieredStopAtLevel=1", "python3", "scripts/kof_project.py", "check", "--target", "jvm", "--json", "--kof", "kof"],
  "testCommand": ["env", "JAVA_TOOL_OPTIONS=-XX:TieredStopAtLevel=1", "node", "scripts/kof-tests.mjs", "--target", "jvm"],
  "commandTimeoutMs": 30000,
  "budgetMs": 0,
  "maxParallelMutants": 4
}
```

The option reached the project JVMs: the command logs of C's Meteor run 1 contain "Picked up JAVA_TOOL_OPTIONS" in 81 files, those of A's run 1 in none.

## A against C

Runs alternate A, C, A, C. No run was discarded: every run's `foreignCoreMax` was under 1 and every exit was 0. Columns `Timeout`, `TestError` and `Pending` are all 0 and `Survived` is 0, so they are left out; `Lim` is the length of the report's `limitations` array.

| File | Config | budgetMs | Run | Status | reportDurationMs | wallMs | Candidates | Killed | foreignCoreMax | foreignCoreMean | maxTempC | throttleDelta | pMHzMean | eMHzMean | Lim |
| --- | --- | ---: | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Meteor | A | 0 | 1 | complete | 59755 | 61893 | 26 | 26 | 0.49 | 0.28 | 91 | 1762 | 3010 | 2757 | 0 |
| Meteor | C | 0 | 1 | complete | 37211 | 38778 | 26 | 26 | 0.44 | 0.22 | 85 | 0 | 2241 | 2125 | 0 |
| Meteor | A | 0 | 2 | complete | 60679 | 62243 | 26 | 26 | 0.86 | 0.30 | 92 | 1350 | 2926 | 2702 | 0 |
| Meteor | C | 0 | 2 | complete | 37496 | 39078 | 26 | 26 | 0.63 | 0.23 | 89 | 0 | 2203 | 2123 | 0 |
| Meteor | A | 0 | 3 | complete | 69360 | 70923 | 26 | 26 | 0.76 | 0.33 | 92 | 846 | 2603 | 2461 | 0 |
| Meteor | C | 0 | 3 | complete | 37499 | 38568 | 26 | 26 | 0.44 | 0.22 | 87 | 0 | 2362 | 2226 | 0 |
| Meteor | A | 85000 | 1 | complete | 70190 | 71748 | 26 | 26 | 0.77 | 0.35 | 89 | 614 | 2556 | 2452 | 0 |
| Meteor | C | 85000 | 1 | complete | 37345 | 38906 | 26 | 26 | 0.31 | 0.20 | 82 | 0 | 2377 | 2148 | 0 |
| BossShot | A | 0 | 1 | complete | 38693 | 40267 | 16 | 16 | 0.54 | 0.29 | 92 | 858 | 2786 | 2661 | 0 |
| BossShot | C | 0 | 1 | complete | 23579 | 25585 | 16 | 16 | 0.49 | 0.23 | 85 | 0 | 2175 | 2213 | 0 |
| BossShot | A | 0 | 2 | complete | 37896 | 39452 | 16 | 16 | 0.69 | 0.30 | 94 | 2182 | 2881 | 2667 | 0 |
| BossShot | C | 0 | 2 | complete | 23540 | 25130 | 16 | 16 | 0.67 | 0.24 | 84 | 0 | 2142 | 2011 | 0 |
| BossShot | A | 0 | 3 | complete | 38627 | 40198 | 16 | 16 | 0.71 | 0.31 | 92 | 718 | 2884 | 2654 | 0 |
| BossShot | C | 0 | 3 | complete | 23684 | 25250 | 16 | 16 | 0.43 | 0.23 | 82 | 0 | 2116 | 1998 | 0 |
| BossShot | A | 85000 | 1 | complete | 39061 | 40421 | 16 | 16 | 0.73 | 0.30 | 91 | 460 | 2816 | 2630 | 0 |
| BossShot | C | 85000 | 1 | complete | 23549 | 25118 | 16 | 16 | 0.36 | 0.22 | 85 | 0 | 2370 | 2224 | 0 |

Evidence: `.agent/tmp/perf/c1-session-<meteor|bossshot>/<a|c>/budget-<budgetMs>-run-<n>-<runId>/`, with `runs.tsv` beside each config directory.

## Identity

| File | Runs | sha256 of `states.tsv` | Previous record |
| --- | --- | --- | --- |
| Meteor | A 1 to 3, C 1 to 3 | `8ade86979bba9d1ff6ee48aa40b9da4f87a8e3099910a3df9edd7db4279d03ee` | same |
| BossShot | A 1 to 3, C 1 to 3 | `48b239e64e1be1b72602bb9092a8e182e41c3a2a4768a6e21510283a5f762931` | same |

The `budgetMs: 85000` runs produce the same hashes too. Since SiFuture is still at `15f8f4a`, the expected hashes come from `.agent/validation/stop-budget-performance.md`, "Identity lists", and the hashes above match them: 26 and 16 candidates, all Killed, same phases.

## Per command medians

Over the mutant rows of `timings.tsv` from the three clean `budgetMs: 0` runs of each configuration (the baseline row is excluded):

| File | Config | checkMs | testMs | reportDurationMs |
| --- | --- | ---: | ---: | ---: |
| Meteor | A | 2983 | 5438 | 60679 |
| Meteor | C | 1462 | 3172 | 37496 |
| BossShot | A | 2905 | 5400 | 38627 |
| BossShot | C | 1475 | 3183 | 23579 |

## Criteria

| Criterion | Source of the expectation | Observed | Result |
| --- | --- | --- | --- |
| `bash -n scripts/measure-run` | plan Validation 1 | exit 0 | pass |
| `shellcheck` | plan Validation 1 | not installed | not run |
| Positive example | plan Milestone 1 | max 2.71, mean 2.39 | mean pass; max outside 1.8 to 2.2 by the measured background |
| Negative example | plan Milestone 1 | max 0.47, `run` 2 | pass |
| Old `runs.tsv` rows untouched | plan Milestone 1 | new header refuses old tables; no earlier table was written | pass |
| Identity | previous record, "Identity lists" | hashes equal across A, C and the previous record | pass |
| No new limitation | plan Milestone 2 | C: no `Timeout`, no `TestError`, `limitations` empty, as in A | pass |
| Speed | plan Milestone 2, clean runs only | Meteor C 61.8% of A, BossShot C 61.0% | recorded |
| Stop budget | plan Milestone 2 | Meteor C `complete` with 0 `Pending` and 0 `Timeout` in 37.3 s; A also `complete` in 70.2 s on this quiet machine | met |
| SiFuture preserved | plan Milestone 2 | `git status --porcelain` empty before and after; manifest `2763a6e02f28579b9d96094d4f918564083752da88eb8c7d9f5ed802c1aea1ff` before and after (`.agent/tmp/perf/c1-sifuture-*`) | pass |

## Findings

- Identity: the C1 only option changes no mutant id, state or phase on Meteor or BossShot, and adds no `Timeout`, `TestError` or limitation.
- Speed, clean runs only: C takes 61.8% of A's `reportDurationMs` on Meteor (37.5 s against 60.7 s) and 61.0% on BossShot (23.6 s against 38.6 s). Per command, `checkMs` falls to about 49 to 51% and `testMs` to about 58 to 59%. Planning predicted about 50% for the whole run; the run gains less because the test phase gains less than the check phase.
- Machine side effect: every A run triggered core throttling (`throttleDelta` 460 to 2182, package up to 94 °C) and none of the C runs did (0, at most 89 °C).
- Stop budget: with `budgetMs: 85000`, Meteor C finishes `complete` with 0 `Pending` in 37.3 s. On this quiet machine A also finished, in 70.2 s, unlike the previous record's 85000 runs (1 and 6 `Pending`) taken with more load, so the A side of that comparison depends on machine conditions.
- Noise: the IDE, other agent sessions and background tools add 0.6 to 1 core with spikes; with them closed the background is about 0.3 core. The old one minute load check did not detect the difference.
- Caveat for adopters: only an argv whose first entry is literally `kof` is redirected to the Kof selected for the invocation (`src/main/kof/kofmut/Evidence.kf:22`, `docs/cli.md` "Configure a project"). A command that starts with `env` loses that redirection. SiFuture's commands start with `python3` and `node`, so they are unaffected.

The change SiFuture would make in its own `kof-mut.json`, two lines, without any other key changing:

```diff
   "checkCommand": [
+    "env", "JAVA_TOOL_OPTIONS=-XX:TieredStopAtLevel=1",
     "python3", "scripts/kof_project.py", "check",
     "--target", "jvm", "--json", "--kof", "kof"
   ],
   "testCommand": [
+    "env", "JAVA_TOOL_OPTIONS=-XX:TieredStopAtLevel=1",
     "node", "scripts/kof-tests.mjs", "--target", "jvm"
   ],
```

Whether to recommend this, document it publicly and adopt it in SiFuture is the user's decision and is not made here.

## Performance power profile

Measured on 2026-11-24 after `powerprofilesctl set performance` (platform profile and energy performance preference `performance`; the session above ran under `balanced`). Same Kof, SiFuture `15f8f4a`, KofMut `8dfd35f`, A and C configurations and session driver (`.agent/tmp/perf/perf-session.sh`, log `perf-session.log`, evidence `.agent/tmp/perf/perf-session-<file>/<a|c>/`). Runs with `foreignCoreMax` of 1 or more were kept and excluded: Meteor A runs 1, 2, 4 and 5, BossShot A run 2.

| File | Config | Clean `budgetMs: 0` runs (reportDurationMs) | Median | Median under `balanced` | Change | 85000 run |
| --- | --- | --- | ---: | ---: | ---: | --- |
| Meteor | A | 54144, 54372, 54404 | 54372 | 60679 | -10.4% | complete, 54560 |
| Meteor | C | 31326, 31549, 31585 | 31549 | 37496 | -15.9% | complete, 31764 |
| BossShot | A | 34455, 34622, 34578 | 34578 | 38627 | -10.5% | complete, 34362 |
| BossShot | C | 20058, 20021, 19909 | 20021 | 23579 | -15.1% | complete, 19813 |

- Identity: all 12 Meteor and 9 BossShot `states.tsv` files, discarded runs included, have the hashes of "Identity" above.
- Under `performance`, C takes 58% of A on both files. C under `performance` takes 52% of A under `balanced`.
- Every run, C included, reached 94 to 100 °C and throttled (`throttleDelta` 494 to 3314); P cores averaged 3.4 to 3.5 GHz for A and 2.6 to 2.8 GHz for C. Under `balanced`, C did not throttle.
- SiFuture preserved: status empty and manifest identical before and after (`perf-sifuture-*`).
