# Validate the C1 only JVM option for SiFuture mutation commands

## Purpose and success

The SiFuture Stop hook (`~/projects/kof-sifuture`) runs `kof-mut run` with `budgetMs: 85000`. The previous plan (`.agent/execplans/stop-budget-performance.md`, record `.agent/validation/stop-budget-performance.md`) showed:
- KofMut's own overhead is under 1% of mutant time.
- Check and test are 99%.
- Four slots run truly in parallel.
- Each command slows down about twice when four run together.

On a quiet machine, BossShot takes about 38 s and Meteor about 67 s.

Each `kof check` or `kof test` is a short JVM process. Measured during planning on 2026-11-24, on copies of SiFuture `15f8f4a` outside the project with Kof 0.7.0:
- `check` uses about 6 cores: 9 to 10 s of CPU in 1.7 s of wall time.
- `test` also uses about 6 cores: 13 to 18 s of CPU in 3 to 3.5 s of wall time.

Most of that CPU goes to the JVM optimizing compiler (C2). C2 never pays off in a process this short.

The JVM reads `JAVA_TOOL_OPTIONS` by itself. With `JAVA_TOOL_OPTIONS=-XX:TieredStopAtLevel=1` (only the fast C1 compiler), the same planning measurement gave:

| Planning observation | Default | C1 only |
| --- | --- | --- |
| CPU of one `check` | 8.5 to 10.8 s | 2.7 to 2.9 s |
| CPU of one `test` | 12.7 to 20.4 s | 4.3 to 5.1 s |
| 4 copies, check then test, wall | 8.5, 9.6, 16.1 s | 4.8, 4.8, 5.0 s |
| 8 copies, check then test, wall | not measured | 6.0, 6.1, 6.2 s |

All 409 tests passed in each copy. These were isolated commands, not KofMut runs. They motivate the plan and do not prove it.

This plan validates the option through complete KofMut runs, without changing Kof, KofMut's engine or SiFuture. Success means:

1. `scripts/measure-run` reports, for each run, how much CPU other processes took during it, so noisy runs are detected instead of guessed.
2. On Meteor and BossShot, the plan checks whether a configuration whose commands are prefixed with `env JAVA_TOOL_OPTIONS=-XX:TieredStopAtLevel=1` gives the same mutant ids, states and phases as the current configuration. It also measures how much faster it is on clean runs.
3. The validation record presents the numbers and the exact two line configuration change SiFuture would make. Whether to recommend the option, document it publicly, and adopt it in SiFuture is decided by the user after reading the numbers, outside this plan.

How to see it working: run `scripts/measure-run` with the default configuration and with the C1 configuration, alternating. Compare `runs.tsv`: same `states.tsv` hashes, lower `reportDurationMs`, and `foreignCoreMax` under 1 on the runs used.

## Context and limits

Read before starting:

- `AGENTS.md`:
  - engine logic in Kof under `src/main/kof/kofmut/`;
  - logs in `.agent/tmp/`, evidence in `.agent/validation/`;
  - public docs in English and Brazilian Portuguese;
  - do not modify Kof;
  - no worktrees or subagents.
- `.agent/validation/stop-budget-performance.md`, sections "Meteor phase breakdown", "Findings" and "Slow runs diagnosis". These are the B0 numbers, state list hashes and noise findings this plan builds on.
- `scripts/measure-run` (arguments `LAUNCHER PROJECT BASE_CONFIG SCOPE BUDGET_MS REPETITIONS OUTPUT_DIR`). It writes a config copy changed only in `budgetMs`, appends one row per run to `<out>/runs.tsv`, and writes `environment.tsv`, `states.tsv`, `report.json` and `timings.tsv` per run.
- `docs/cli.md` "Configure a project" and its translation `docs/cli.pt_BR.md`:
  - commands run as argv;
  - they run with the sandbox cwd and an inherited environment.
- `src/main/kof/kofmut/Evidence.kf:22`: only an argv whose first entry is literally `kof` is redirected to the concrete Kof selected for the invocation. A command starting with `env` loses that redirection. SiFuture's commands start with `python3` and `node`, so they are unaffected. The validation record must state this caveat.
- `~/projects/kof-sifuture/kof-mut.json`: `checkCommand` is `python3 scripts/kof_project.py check --target jvm --json --kof kof`, `testCommand` is `node scripts/kof-tests.mjs --target jvm`, with `maxParallelMutants: 4`, `commandTimeoutMs: 30000` and `budgetMs: 0`.

Kof selection: the `kof` on PATH is 0.8.1, which KofMut refuses (JSN006, see "Decisions" in the previous plan). Run every measurement through `.agent/tmp/perf/with-kof-070` (ignored by Git, present locally). It exports these three variables and then runs `exec "$@"`:
- `PATH="$HOME/.local/share/kof/kof-0.7.0-linux-x86_64/bin:$PATH"`
- `KOF_MUT_COMPATIBILITY_OTHER="$HOME/.local/share/kof/kof-0.6.4-linux-x86_64/bin"`
- `LC_ALL=C.UTF-8`

If it is missing, recreate it with exactly that content.

Fixed limits:

- No change to `src/`, to the report, `schemaVersion`, exit codes, stdout, configuration keys or `maxParallelMutants` range.
- Do not modify Kof. Do not write inside `~/projects/kof-sifuture`. Configuration copies live under `.agent/tmp/perf/`.
- KofMut does not set `JAVA_TOOL_OPTIONS` itself. The option belongs to the evaluated project's commands, explicitly in its configuration.
- Out of scope: public documentation of the option (decided after this plan), widening `maxParallelMutants` beyond 4 (a versioned contract change), and skipping the check phase.

Safety boundary: this task is limited to authorized, defensive maintenance of this repository.

## Definitions

- **Default configuration (A)**: `~/projects/kof-sifuture/kof-mut.json`, used as is as `BASE_CONFIG`.
- **C1 configuration (C)**: `.agent/tmp/perf/c1/kof-mut.json`. It equals A except that `checkCommand` and `testCommand` each start with `"env", "JAVA_TOOL_OPTIONS=-XX:TieredStopAtLevel=1"`.
- **Foreign CPU**: CPU time used during a run by processes that are not the launcher or its descendants and are not the monitor itself.
- **Clean run**: a run whose `foreignCoreMax` is below 1.

## Milestones

### Milestone 1: foreign CPU in `scripts/measure-run`

Behavior: each run records machine conditions while it runs. `runs.tsv` gains, after the existing columns:
- `foreignCoreMax` and `foreignCoreMean`: foreign CPU seconds per wall second, as the maximum and the mean over one second samples;
- `maxTempC`;
- `throttleDelta`: the sum of `core_throttle_count` increments across CPUs;
- `pMHzMean` and `eMHzMean`.

Each run directory gains `monitor.tsv` with one row per sample. Run numbers continue across invocations into the same output directory, so alternating invocations do not repeat `run` 1.

Edits:

- `scripts/measure-run`:
  - start a sampler (inline `python3 -I` is acceptable) after launching KofMut in the background with its pid known. Stop it when KofMut exits.
  - Sample every second:
    - per process `utime + stime` deltas from `/proc/<pid>/stat`, with the descendant set of the launcher pid rebuilt from `ppid` on each sample;
    - P and E core frequency means from `/sys/devices/cpu_core/cpus` and `/sys/devices/cpu_atom/cpus`. When those files are absent, leave the columns empty;
    - package temperature from the `hwmon` whose `name` is `coretemp`, found by name, never by a fixed index;
    - throttle counters.
  - A descendant reparented to init after its parent exits counts as foreign; a missed process can only raise `foreignCoreMax`, which errs on the safe side.
  - The first run number is one more than the number of existing data rows for the same `budgetMs` in `runs.tsv`.
  - Existing columns and their order stay as they are, so the earlier record still reads the same.

Validation (manual, there is no shell test harness; record the command and output):

- `bash -n scripts/measure-run`, and `shellcheck scripts/measure-run` if installed.
- Positive example: start two busy loops (`python3 -c 'while True: pass' &` twice). Then run `.agent/tmp/perf/with-kof-070 scripts/measure-run bin/kof-mut ~/projects/kof-sifuture ~/projects/kof-sifuture/kof-mut.json .agent/tmp/perf/scope-bossshot.json 0 1 .agent/tmp/perf/monitor-check` with `MEASURE_MAX_LOAD=40` so the wait does not block, then kill the loops. Expected: `foreignCoreMax` between 1.8 and 2.2 and `foreignCoreMean` above 1.5.
- Negative example: the same without the loops and with the IDE and other heavy programs closed. Expected: `foreignCoreMax` below 1, and the run's `run` column equals 2.

Acceptance: both examples observed. Old rows in `.agent/tmp/perf/*/runs.tsv` are not rewritten.

### Milestone 2: A against C on Meteor and BossShot

Behavior: evidence that decides whether the C1 option is safe and worth recommending.

Edits: create `.agent/tmp/perf/c1/kof-mut.json` from A with `python3 -I`, prefixing both commands. Record its content in the validation record.

Session, Meteor then BossShot, scope files `.agent/tmp/perf/scope-meteor.json` and `.agent/tmp/perf/scope-bossshot.json`:

- Alternate A and C one run at a time (`REPETITIONS` 1), A first, until each has three clean `budgetMs: 0` runs:
  - output `.agent/tmp/perf/c1-session-<file>/a` for A and `.agent/tmp/perf/c1-session-<file>/c` for C;
  - launcher `bin/kof-mut`, through `with-kof-070`.
- Then one `budgetMs: 85000` run each, A then C.
- Discard and repeat runs with `foreignCoreMax` of 1 or more, at most four extra attempts per configuration and file. Record discarded runs, never delete them.
- Before and after, record SiFuture's `git status --porcelain` and the manifest `find src kof.toml scripts -type f -print0 | sort -z | xargs -0 sha256sum | sha256sum`, run inside SiFuture.

Acceptance, each with its source:

- Identity: for each file, every clean `budgetMs: 0` run of A and C has the same `states.tsv` sha256. If SiFuture is still at `15f8f4a`, that sha256 equals the previous record:
  - Meteor `8ade86979bba9d1ff6ee48aa40b9da4f87a8e3099910a3df9edd7db4279d03ee`, 26 candidates all Killed;
  - BossShot `48b239e64e1be1b72602bb9092a8e182e41c3a2a4768a6e21510283a5f762931`, 16 candidates all Killed.

  Source: `.agent/validation/stop-budget-performance.md`, "Identity lists". The A against C comparison is a real check, because a C1 failure would show up as `TestError`, `Timeout` or a changed phase on some mutant.
- No new limitation: C's reports have no `Timeout` and no `TestError` with `budgetMs: 0`. Their `limitations` arrays have the same entries as A's.
- Speed, measured and not judged: for each file, report the medians of `reportDurationMs` over clean runs for A and C, and C as a percentage of A. Also report the medians of `checkMs` and `testMs` from `timings.tsv`. No speed threshold applies; planning predicts about 50%.
- Stop budget: record the status, `Pending` and `Timeout` counts of each `budgetMs: 85000` run. The goal is Meteor C `complete` with 0 `Pending`. Record the result even if it is not met.
- SiFuture preserved: status and manifest identical before and after.

## Progress

- [x] Milestone 1: foreign CPU columns and `monitor.tsv` in `scripts/measure-run`, positive and negative examples recorded
  - `scripts/measure-run` writes the six machine columns, `monitor.tsv` and `monitor-summary.tsv`, continues run numbers per `budgetMs`, and refuses to append to a `runs.tsv` whose header predates the new columns. `bash -n` exits 0; `shellcheck` is not installed.
  - First attempts (`.agent/tmp/perf/monitor-check`) were taken with the IDE and other agent sessions open and are recorded as discarded. After the user closed them (`.agent/tmp/perf/monitor-check-quiet`): negative `run` 2 with `foreignCoreMax` 0.47 (pass); positive mean 2.39 (pass) and max 2.71, outside 1.8 to 2.2 by the measured background of about 0.36 (deviation recorded, not a monitor fault).
- [x] Milestone 2: A against C sessions on Meteor and BossShot, identity, limitations, speed and stop budget recorded
  - All 16 runs clean, none discarded. Identity hashes equal across A, C and the previous record; no `Timeout`, `TestError` or limitation. C is 61.8% of A on Meteor and 61.0% on BossShot. Meteor C with `budgetMs: 85000` is `complete` with 0 `Pending`. SiFuture status and manifest unchanged.
- [x] Final validation and record: `.agent/validation/jvm-short-commands.md`, linked from `.agent/README.md`.

## Decisions

- **The option lives in the project configuration, not in KofMut.** Alternatives:
  - KofMut exports `JAVA_TOOL_OPTIONS` to its commands. This hides a JVM policy inside a tool that does not own the project's runtime, and it also changes projects that did not ask for it.
  - The hook exports it to the whole `kof-mut` process. KofMut's own JVM would then also run C1 only, which is not measured here.

  Consequence: SiFuture adopts it with a two line change in its own repository, and other projects opt in explicitly.
- **`./scripts/check` is not part of this plan's final validation.** This plan changes no Kof source, test or fixture under `src/`. `scripts/check` does not exercise `scripts/measure-run` or the docs. Its known duration failures under load (record "Fixture race correction") are not affected by this work. If the executor changes anything under `src/`, this decision no longer holds: `./scripts/check` must then exit 0 before delivery.
- **No speed threshold and no public documentation in this plan.** The user chose to decide on recommending and documenting the option after seeing the numbers. A later change adds the paragraph to `docs/cli.md` and `docs/cli.pt_BR.md`, including the caveat that an argv starting with `env` loses the literal `kof` redirection.

## Risks

- **C1 slows a long compute test.** Mitigation: the identity check and no `Timeout` under `commandTimeoutMs: 30000`. Per command `testMs` medians are compared.
- **Noise.** Mitigation: alternating runs, `foreignCoreMax` below 1, three clean runs each. Close the IDE before the session.
- **SiFuture or Kof changing mid session.** Mitigation: `environment.tsv` records both per run. If either changes, restart the session.
- **The JVM notice "Picked up JAVA_TOOL_OPTIONS" on stderr.** KofMut stores stderr as a log file and does not parse it (`Evidence.kf`). The `check --json` stdout stayed valid in planning. Identity and no new limitation confirm it in full runs.

## Validation

Final validation, all must pass before delivery:

1. `bash -n scripts/measure-run` exits 0, and `shellcheck scripts/measure-run` reports nothing new if available.
2. Milestone 1 positive and negative examples observed as specified.
3. Milestone 2: SiFuture preservation passes. Identity and no new limitation are checked and recorded; a failure there is a valid outcome to record, not a reason to change anything. Speed and stop budget are recorded.
4. `git diff --check` is clean and `git status --porcelain` shows only `scripts/measure-run`, the new validation record, `.agent/README.md` and this plan.

Record everything in `.agent/validation/jvm-short-commands.md`, linked from "Current entry points" in `.agent/README.md`:
- environment: Kof path and sha256, SiFuture and KofMut commits, `nproc`;
- the C configuration;
- the Milestone 1 examples;
- A and C tables with the new columns, including discarded runs;
- `states.tsv` hashes;
- the `checkMs` and `testMs` medians;
- the 85000 runs;
- SiFuture preservation;
- a findings section with the identity result, C as a percentage of A per file, the stop budget outcome, and the exact JSON change SiFuture would make in `kof-mut.json`, without recommending or rejecting it.

Executor obligations before delivery:

- For each criterion, recheck that the expectation matches its source (the previous record, `docs/cli.md`, `Evidence.kf`), separately from whether the measurement shows it.
- Record the command, the observed result and the artifact path for each criterion.
- List failed checks and unverified criteria explicitly. Report speed only from clean runs.
