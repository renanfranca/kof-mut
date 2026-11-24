# Measure cleanup deadlines from the blocked command, so `./scripts/check` passes under load

## Purpose and success

`./scripts/check` is the repository's validation entry point and must exit 0. On `main` (`855a2d2`) it fails under its own load. Its seven `kof test` queues and the contracts queue run at the same time. Three tests in queue `run-a` fail on a duration upper bound:

- `persistent cleanup failure shares one deadline across concurrent callers and cannot approve` (`src/test/kof/kofmut/Run.kf`, bound `report.durationMs < 5500`);
- `cleanup failure preserves five completed kills while the first candidate is still blocked` (bound `< 8000`);
- `cleanup failure preserves a prior discard survivor and kills with original identities and permits recovery` (bound `< 8000`).

Run alone, `kof test src/test/kof/kofmut/Run.kf --tag check-run-a` passes 25 of 25. Two of the three also failed before the last merge (`.agent/validation/stop-budget-performance.md`, "Fixture race correction").

Each test runs twice. With `unbounded` false, a global `budgetMs` (2500 or 5000) applies. With `unbounded` true, `budgetMs` is 0 and the per command `commandTimeoutMs` (2500 or 5000) applies instead. Planning read the evidence that the failing check kept in `.agent/tmp/m3f/observations/`.

Every failure is in the `unbounded` variant:

| Test | Variant | `durationMs` | Bound | Run start to first ready file | First ready file to run end |
| --- | --- | ---: | --- | ---: | ---: |
| four-active | budget 2500 | 4965 | `< 5500` pass | 1413 | 3552 |
| four-active | timeout 2500 | 6149 | `< 5500` fail | 1167 | 4982 |
| five-kills | budget 5000 | 7042 | `< 8000` pass | 1044 | 5998 |
| five-kills | timeout 5000 | 8540 | `< 8000` fail | 1595 | 6945 |
| discard-survivor | budget 5000 | 7046 | `< 8000` pass | 1553 | 5493 |
| discard-survivor | timeout 5000 | 8460 | `< 8000` fail | 1472 | 6988 |

How the times were computed:
- Run end is `startedAt` plus `durationMs`.
- "First ready file" is the modification time of the earliest `ready-<candidate>-test` file. The `parallel-runner` fixture writes that file when the blocked command starts.

Cause:
- A global budget counts from the start of the run, so measuring `report.durationMs` from the run's start is correct for that variant.
- A command timeout counts from the moment that command starts. Before that, the run must start up, run the baseline and run the candidate checks. Under load, that took 1.0 to 1.6 s.
- So in the `unbounded` variant, `durationMs` adds a load dependent prefix to the quantity under test.

Measured from the first ready file, the `unbounded` runs take timeout plus 1945 to 2482 ms. That matches the intended behavior: the command timeout, then one shared 2 s cleanup deadline (`awaitGroupsWithinSharedCleanupDeadline` and `terminateGroups` in `src/main/kof/kofmut/RunResources.kf`).

The defect these bounds guard against is a cleanup that restarts its 2 s deadline. The test's own message for that is "cleanup retries restarted the shared deadline". With signals that cannot kill the group (`ineffectiveSignals`), a restart costs at least one more full 2 s. That gives at least timeout plus 4000 ms from the blocked command's start.

Success:
- In the `unbounded` variant, each of the three tests bounds the interval from the blocked command's start to the run's end. It no longer bounds `durationMs` from the run's start.
- The upper bound still fails when the cleanup deadline is doubled.
- `./scripts/check` exits 0 twice in a row.

No production code changes.

## Context and limits

Read before starting:

- `AGENTS.md`: behavioral tests in Kof; `./scripts/check` is the entry point; logs in `.agent/tmp/`; evidence in `.agent/validation/`; no comments where a named function or variable can say it; no worktrees or subagents.
- `scripts/check`: queues `cli-a`, `cli-b`, `run-a`, `run-b`, `install-a`, `install-b`, `install-c` and `contracts` run in parallel. The coverage guard requires every test to carry exactly one `check-<queue>` tag of its file.
- `src/test/kof/kofmut/Run.kf`:
  - the three tests, starting at the `persistent cleanup failure` test;
  - the helpers `readyEvent`, `cleanupReport`, `keepBudgetEvidence`, `waitFinished` and `startRunPath`.
- `src/test/fixtures/parallel-runner`: a blocked command writes `$log/ready-$candidate-$phase` after its descendant is alive. That is a few ms after KofMut starts the command and its timeout clock, so the interval measured from it is slightly shorter than the true one. That direction cannot hide a restarted deadline, which adds 2000 ms.
- `docs/report-format.md`: `startedAt` is the ISO 8601 UTC instant at `run` entry, and `durationMs` is the run's duration. Reports carry nanosecond `startedAt`, for example `2026-11-23T19:24:42.069452488Z`.

Kof selection: the `kof` on PATH is 0.8.1, which KofMut refuses (JSN006). Run every test command through `.agent/tmp/perf/with-kof-070` (ignored by Git, present locally). It exports these three variables and then runs `exec "$@"`:
- `PATH="$HOME/.local/share/kof/kof-0.7.0-linux-x86_64/bin:$PATH"`
- `KOF_MUT_COMPATIBILITY_OTHER="$HOME/.local/share/kof/kof-0.6.4-linux-x86_64/bin"`
- `LC_ALL=C.UTF-8`

If it is missing, recreate it with exactly that content.

Fixed limits:

- No change under `src/main/`, to the report, exit codes, stdout or configuration.
- In the `unbounded` false variant, keep every assertion of the three tests as it is, including `durationMs >= budget` and `durationMs < budget + 3000`.
- Keep every other assertion of the `unbounded` true variant, including its lower bound `durationMs >= timeout` and the `child.waitFor` limits with their messages.
- Do not modify Kof. Do not change `scripts/check` queues or tags.
- Out of scope: the Kof 0.8.x incompatibility, and the `fastJvmCommands` option. That option is the next plan; it needs this check green.

## Milestones

### Milestone 1: deadline interval from the blocked command's start

Behavior: in the `unbounded` variant, each of the three tests asserts that the time from the earliest `ready-*-test` file of the blocked candidates to the run's end (`startedAt` plus `durationMs`) is at least `timeout` minus 100 ms and under `timeout + 3500`.

Why these bounds:
- Intended behavior measures timeout plus 1945 to 2482 ms under load.
- A restarted deadline gives at least timeout plus 4000.
- 3500 leaves about 1000 ms for load and still sits 500 ms below the defect.
- The 100 ms below the timeout absorbs the fixture writing its ready file slightly after the timeout clock starts.

Edits, in `src/test/kof/kofmut/Run.kf` only:

- Add a helper that returns the epoch milliseconds of the earliest `ready-<candidate>-test` file for the given candidates. It reads the modification time through `java.nio.file.Files`, which the file already imports. Add another helper that returns the run's end in epoch milliseconds from a `RunReport`'s `startedAt` and `durationMs`, parsing `startedAt` with `java.time.Instant`. Name them so that they say what they return, without comments.
- In each of the three tests:
  - keep the `report.durationMs` upper bound only when `unbounded` is false;
  - when it is true, assert the new interval bound instead. The blocked candidates are 0 to 3 for four-active, 0 for five-kills and 5 for discard-survivor;
  - keep `report.durationMs >= timeout` in both variants.
- Write the failure message of the new assertion so that it says "cleanup deadline measured from the blocked command" and includes the measured interval.

Validation:

- First check that the old bound fails in a scenario where the new bound must pass. Under load, run the queue the way `scripts/check` does: start the seven queues and contracts together with `.agent/tmp/perf/with-kof-070 ./scripts/check`. Record that at least one `unbounded` variant fails on the old bound, using the kept evidence. If none fails because the machine was quiet, record that and continue.
- `.agent/tmp/perf/with-kof-070 kof test src/test/kof/kofmut/Run.kf --tag check-run-a`: `0 failed of 25 tests`.
- Guard proof, a temporary experiment that is never committed:
  1. In `src/main/kof/kofmut/RunResources.kf`, change both `2000` literals of the shared cleanup deadline (`awaitGroupsWithinSharedCleanupDeadline` and `terminateGroups`) to `4000`. That reproduces the cost of one restarted deadline.
  2. Run the three tests (`kof test src/test/kof/kofmut/Run.kf --tag check-run-a`) and record which assertions fail.
  3. Expected: every `unbounded` variant fails, either on the new interval assertion or earlier on its `child.waitFor` message "cleanup restarted its shared deadline". The `unbounded` false variants fail on their unchanged `durationMs` bound.
  4. Revert with `git checkout -- src/main/kof/kofmut/RunResources.kf`. Confirm `git diff --stat -- src/main` is empty.

  If an `unbounded` variant passes with the doubled deadline, the new bound does not guard the defect. Stop and report.

Acceptance:

- The three tests pass alone.
- The guard proof shows each `unbounded` variant rejecting the doubled deadline.
- `src/main` is unchanged.

### Milestone 2: full check under its own load

Behavior: `./scripts/check` exits 0 with every queue and the coverage guard green, twice in a row.

Validation:

- `.agent/tmp/perf/with-kof-070 ./scripts/check`, twice, one after the other, with the IDE and other heavy programs closed. Each takes about 15 to 20 minutes. Record for each run:
  - the exit code;
  - every `queue <name>: exit <status> in <seconds> s` line;
  - the check observations directory;
  - from the kept evidence, the new interval of each of the three tests in both runs.
- If a run fails on any other test, record its name and assertion, and do not change that test in this plan. Stop and report it as a separate finding.

Acceptance: two consecutive exit 0 runs. The recorded intervals stay under timeout plus 3500.

## Progress

- [x] Milestone 1: interval helpers and bounds in the three tests, guard proof recorded, `src/main` unchanged (2026-11-24; old bound reproduced failing under load, `run-a` alone 0 failed of 25, guard proof rejects the doubled deadline in every `unbounded` variant)
- [x] Milestone 2: two consecutive `./scripts/check` exit 0 runs recorded (2026-11-24; 16m25s and 17m11s, intervals timeout plus 1998 to 2264 ms)
- [x] Validation record written and linked (`.agent/validation/check-duration-origin.md`, from `.agent/README.md`)

## Lessons learned

- Kof requires a literal `assert` message (PARSE087). The interval is printed as `cleanupDeadlineFromBlockedCommandMs=<interval> timeoutMs=<timeout>` and the message points to it.
- Each test iterates `listOf(false, true)`, so in the guard proof the `false` variant fails first and the `unbounded` variant never runs. Proving the `unbounded` bound needed temporary `listOf(true)` runs, once with the original `waitFor` limits and once with them widened, so the new interval assertion itself is shown rejecting a doubled deadline.

## Decisions

- **Bound the command timeout variant from the blocked command's start, not widen `durationMs`.**
  - Widening the `durationMs` bound to cover the observed 8540 ms would leave about 1 s between the load prefix and the restarted deadline defect. Under heavier load, that 1 s disappears.
  - Measuring from the ready file removes the prefix, which is up to 1.6 s observed. What remains is the quantity the tests are about.

  Consequence: the global budget variant keeps its run start bound, because there the run start is the right origin.
- **3500 ms over the timeout.** This sits between the observed maximum (2482) and the defect's minimum (4000). It is checked by the guard proof rather than assumed.

## Risks

- **The new bound is too loose to catch a restart.** Mitigation: the guard proof with a doubled deadline. Treat it as a stop condition.
- **The `ready` file modification time is coarse.** On ext4 it has nanosecond resolution. If the executor observes whole second values, use the fixture's own clock instead: have `parallel-runner` write `date +%s%3N` into `$event/readyAt` just before the ready file. Record this as a decision.
- **Other duration bounds fail under load too.** They are recorded as separate findings, not fixed here.

## Validation

Final validation, all must pass before delivery:

1. `.agent/tmp/perf/with-kof-070 kof test src/test/kof/kofmut/Run.kf --tag check-run-a`: `0 failed of 25 tests`.
2. Guard proof recorded, and `git diff --stat -- src/main` empty afterwards.
3. `.agent/tmp/perf/with-kof-070 ./scripts/check` exits 0 in two consecutive runs.
4. `git diff --check` is clean. `git status --porcelain` shows only `src/test/kof/kofmut/Run.kf`, the fixture if the risk above applied, `.agent/validation/check-duration-origin.md`, `.agent/README.md` and this plan.

Record in `.agent/validation/check-duration-origin.md`, linked from "Current entry points" in `.agent/README.md`:
- the planning table above, with its source directory;
- the guard proof (edit, command, failing assertions, revert);
- both full checks with queue lines and intervals;
- any separate findings.

Executor obligations before delivery:

- Recheck each expectation against its source, separately from whether the test shows it:
  - the timing model from `RunResources.kf`;
  - the `startedAt` and `durationMs` meaning from `docs/report-format.md`;
  - when the ready file is written, from `parallel-runner`.
- Record the command, the observed result and the evidence path for each criterion.
- List failed checks and unverified criteria explicitly before delivery.
