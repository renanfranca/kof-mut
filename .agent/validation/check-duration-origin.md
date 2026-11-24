# Cleanup deadline measured from the blocked command

Plan: `.agent/execplans/check-duration-origin.md`. Measured on 2026-11-24 on Linux 7.0.0-44-generic, ext4, with Kof 0.7.0 first on PATH and Kof 0.6.4 as the compatibility alternate (`.agent/tmp/perf/with-kof-070`). Raw logs: `.agent/tmp/check-duration-origin/`.

## Change

Only `src/test/kof/kofmut/Run.kf` changed. In the `unbounded` variant (`budgetMs` 0, per command `commandTimeoutMs`), three cleanup tests now bound the interval from the earliest `ready-<candidate>-test` file of the blocked candidates to the run's end (`startedAt` plus `durationMs`). The bounds are at least `timeout - 100` and under `timeout + 3500`. The global budget variant keeps its `durationMs < 5500` or `< 8000` bound, and both variants keep `durationMs >= 2500` or `>= 5000`. The test prints `cleanupDeadlineFromBlockedCommandMs=<interval> timeoutMs=<timeout>`. Kof requires a literal `assert` message (PARSE087), so the assertion message names that printed line instead of embedding the value.

| Test | Blocked candidates | Timeout |
| --- | --- | ---: |
| `persistent cleanup failure shares one deadline across concurrent callers and cannot approve` (four-active) | 0, 1, 2, 3 | 2500 |
| `cleanup failure preserves five completed kills while the first candidate is still blocked` (five-kills) | 0 | 5000 |
| `cleanup failure preserves a prior discard survivor and kills with original identities and permits recovery` (discard-survivor) | 5 | 5000 |

## Sources rechecked

- `src/main/kof/kofmut/RunResources.kf`: a command's deadline is `commandTimeoutMs` from the clock read just before `builder.start()`, unless a global budget leaves less. Cleanup then shares one 2000 ms deadline from `cleanupStart` in `awaitGroupsWithinSharedCleanupDeadline` and `terminateGroups`. Intended `unbounded` cost from the command's start is therefore timeout plus at most about 2000 ms plus report construction. A restarted deadline adds another full 2000 ms with `ineffectiveSignals`.
- `docs/report-format.md`: `startedAt` is the ISO 8601 UTC instant at `run` entry; `durationMs` is elapsed monotonic milliseconds from `run` entry to report construction. Their sum is a wall clock estimate of the run's end; a wall clock step during a run would skew it, which none of the recorded runs showed.
- `src/test/fixtures/parallel-runner`: a blocked command writes `$log/ready-$candidate-$phase` only after its descendant is alive, so the file's modification time is a few ms after KofMut started the command and its timeout clock. The measured interval is slightly short, which cannot hide a 2000 ms restart. Modification times have sub millisecond resolution here, so the fixture clock fallback in the plan's risks was not needed.

## Planning table

From the failing check kept by the previous plan in `.agent/tmp/m3f/observations/`:

| Test | Variant | `durationMs` | Old bound | Run start to first ready file | First ready file to run end |
| --- | --- | ---: | --- | ---: | ---: |
| four-active | budget 2500 | 4965 | `< 5500` pass | 1413 | 3552 |
| four-active | timeout 2500 | 6149 | `< 5500` fail | 1167 | 4982 |
| five-kills | budget 5000 | 7042 | `< 8000` pass | 1044 | 5998 |
| five-kills | timeout 5000 | 8540 | `< 8000` fail | 1595 | 6945 |
| discard-survivor | budget 5000 | 7046 | `< 8000` pass | 1553 | 5493 |
| discard-survivor | timeout 5000 | 8460 | `< 8000` fail | 1472 | 6988 |

## Old bound reproduced under load

`.agent/tmp/perf/with-kof-070 ./scripts/check` on the unchanged tree (`855a2d2`): exit 1 in 15m43s, observations `.agent/tmp/check-795a02fa-2377-4d5b-9e4a-82075e0430da`, log `red-check.log`. Queue `run-a` failed 2 of 25: four-active and discard-survivor. The kept evidence shows only the `unbounded` variants over the old bound:

| Test | Variant | `durationMs` | Old bound | Ready file to run end |
| --- | --- | ---: | --- | ---: |
| four-active | timeout 2500 | 5520 | `< 5500` fail | 4707 |
| five-kills | timeout 5000 | 7917 | `< 8000` pass | 7002 |
| discard-survivor | timeout 5000 | 8799 | `< 8000` fail | 6961 |

## Focused run

`.agent/tmp/perf/with-kof-070 kof test src/test/kof/kofmut/Run.kf --tag check-run-a`: `0 failed of 25 tests`, exit 0 (`run-a-alone.log`). Intervals 4685 (timeout 2500), 7014 and 6999 (timeout 5000).

## Guard proof

Temporary, never committed. Both `2000` literals of the shared cleanup deadline in `src/main/kof/kofmut/RunResources.kf` were changed to `4000` (`guard-proof.diff`), reproducing the cost of one restarted deadline. Command each time: `.agent/tmp/perf/with-kof-070 kof test src/test/kof/kofmut/Run.kf --tag check-run-a`.

1. Unchanged tests (`guard-proof.log`): 3 failed of 25. Each test failed in its `unbounded` false variant on the `child.waitFor` messages "cleanup retries restarted the shared deadline" and "cleanup restarted its shared deadline". Because each test iterates `listOf(false, true)`, the `unbounded` variant did not run.
2. Tests temporarily reduced to `listOf(true)` (`guard-proof-unbounded.log`): 3 failed of 25, each `unbounded` variant on the same `child.waitFor` messages.
3. Also with those `waitFor` limits temporarily widened to 20000 ms (`guard-proof-interval.log`): 3 failed of 25, each on "cleanup deadline measured from the blocked command". Intervals 6706 (timeout 2500, +4206), 9007 and 8995 (timeout 5000, +4007 and +3995), all above `timeout + 3500`.

Revert: `git checkout -- src/main/kof/kofmut/RunResources.kf` and `Run.kf` restored byte for byte from its green copy. `git diff --stat -- src/main` printed nothing afterwards.

The margin is real but narrow: a doubled deadline measured +3995 to +4206, 495 to 706 ms above the bound, while intended behavior measured up to +2264.

## Full check, twice in a row

`.agent/tmp/perf/with-kof-070 ./scripts/check`, one after the other.

| Queue | Check 1 | Check 2 |
| --- | --- | --- |
| version | exit 0 in 1 s | exit 0 in 1 s |
| contracts | exit 0 in 1 s | exit 0 in 2 s |
| cli-b | exit 0 in 697 s | exit 0 in 744 s |
| cli-a | exit 0 in 702 s | exit 0 in 764 s |
| run-b | exit 0 in 723 s | exit 0 in 770 s |
| run-a | exit 0 in 807 s | exit 0 in 857 s |
| install-c | exit 0 in 872 s | exit 0 in 909 s |
| install-b | exit 0 in 875 s | exit 0 in 913 s |
| install-a | exit 0 in 984 s | exit 0 in 1030 s |
| Exit, wall time | 0, 16m25s | 0, 17m11s |
| Observations | `.agent/tmp/check-c6e5199a-84ce-4037-842d-484b02339632` | `.agent/tmp/check-7caebc28-22fb-43fb-8d96-6ea84a90133b` |

The coverage guard passed in both (no "check queues do not cover" line, exit 0). `unbounded` variants:

| Test | Check | `durationMs` | Ready file to run end | Over timeout |
| --- | --- | ---: | ---: | ---: |
| four-active | 1 | 5431 | 4698 | 2198 |
| five-kills | 1 | 7786 | 7015 | 2015 |
| discard-survivor | 1 | 8779 | 6998 | 1998 |
| four-active | 2 | 5566 | 4764 | 2264 |
| five-kills | 2 | 7878 | 7006 | 2006 |
| discard-survivor | 2 | 8396 | 7021 | 2021 |

Every interval stays under `timeout + 3500`. Under the old bounds, check 1 would have failed discard-survivor (8779) and check 2 four-active (5566) and discard-survivor (8396).

## Separate findings

None. No other test failed in these runs.
