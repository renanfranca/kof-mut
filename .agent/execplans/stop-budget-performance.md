# Measure where KofMut spends its time on SiFuture

## Purpose and success

KofMut is meant to be the mutation tier of the SiFuture Stop hook (`~/projects/kof-sifuture`). That hook runs `kof-mut run` with `budgetMs: 85000` inside a 90 second ceiling. Today a mutant costs about 8.5 s at the median on SiFuture, and `Meteor.kf` (41 candidates) took 6m03s with `maxParallelMutants: 4` (`~/projects/kof-sifuture/.agent/validation/sensor-debt-payoff.md`, row E6). Almost every real change would end `incomplete` with mutants left `Pending`.

This plan is the first of a series. It changes no engine behavior. It produces:

1. a repeatable measurement of KofMut on SiFuture, the baseline every later plan compares against;
2. an internal per phase timing record, which shows how much of each mutant's time goes to the global lock, copying, validation, check, test, command release and removal.

The next plan is chosen from these numbers, not from estimates.

How to see it working: run `scripts/measure-run` against `Meteor.kf`. It writes a TSV row per run and a sorted list of mutant ids and states. Each run's evidence directory contains a `timings.tsv` with one row per candidate plus the baseline. The report JSON and stdout are unchanged.

Planning observations on 2026-11-23, load average around 2 on 32 cores, SiFuture at its current commit. They motivate the measurement and do not replace it:

- `python3 scripts/kof_project.py check --target jvm --json --kof kof` took 1.72 s wall.
- `node scripts/kof-tests.mjs --target jvm` ran 409 tests in 2.95 s wall, compile included.
- So the project commands cost about 4.7 s per mutant. 41 mutants over 4 slots would take about 48 s if the slots ran fully in parallel. E6 measured 6 min, which suggests most of the time is spent inside KofMut, not in the project. This plan confirms or refutes that.
- 24 of the 30 SiFuture test modules mention `Meteor`, so choosing tests by import graph would select almost the whole suite.

## Context and limits

Read these before starting:

- `AGENTS.md`: engine logic stays in Kof under `src/main/kof/kofmut/`; behavioral tests in Kof drive changes; `./scripts/check` is the validation entry point; logs go in `.agent/tmp/`; evidence goes in `.agent/validation/`; no worktrees or subagents.
- `.agent/reviews/improvement-review-2026-11-13.md` items 4, 6 and 7.
- `docs/cli.md` (configuration table, timeouts and cancellation, prepared run, reports and logs) and `docs/report-format.md`.
- `~/projects/kof-sifuture/scripts/mutation-step.mjs`: the consumer of the report and exit codes.

Where time may go, per the code:

- `src/main/kof/kofmut/Run.kf`, `evaluateTask` and `evaluateCandidate`: each candidate copies every input into `variant-N` (`resources.prepare`). It writes the mutated file and validates tokens (`validateVariantTokens`), both while holding `resources.lock`. It then runs `checkCommand` and, if check passes, `testCommand`. Finally it deletes the variant (`resources.removeVariant`), under the lock.
- `src/main/kof/kofmut/RunResources.kf`: `prepare`, `startCommand`, `releaseCommand`, `stopCommands` and `removeVariant` all take the same `ReentrantLock`. `releaseCommand` runs `terminateGroups` with the lock held, even after a normal exit. `terminateGroups` spawns `kill -KILL -- -PGID`, waits up to a shared 2 s and polls `processGroupActive` every 10 ms.
- `src/main/kof/kofmut/Evidence.kf`: `executeCommand` starts commands under `setsid` and calls `releaseCommand` in `finally`. `processGroupActive` reads every `/proc/<pid>/stat`.

Fixed limits:

- No change to report fields, `schemaVersion: 1`, exit codes 0 to 3, the single `reportPath=` line, stdout lines, `runId`, `scope` or any mutant state. The timing record is internal evidence in the run's log directory, not part of the report.
- No change to locking, cleanup or scheduling behavior. The instrumentation only reads clocks.
- Do not modify Kof. Do not write anything inside `~/projects/kof-sifuture`. Scope files, configuration copies and reports used for measurement live under this repository's `.agent/tmp/perf/`.

Later plans this one feeds, for orientation only. None of this is in scope here:

- Take independent work (copy, token validation, normal release, variant removal) out of the global lock.
- Skip `kill` and polling when a finished command's group is already empty, keeping the `/proc` scan as evidence.
- Widen `maxParallelMutants` beyond 4, as a versioned contract change, only if still needed.
- A schemata prototype using `config.env`, and a proposal for what Kof would need: compile once and run many, per-test coverage, a test name filter, stop at the first failure and JSON test output.

## Definitions

- **Slot**: one of the `maxParallelMutants` concurrent candidate evaluations.
- **Global lock**: `RunResources.lock`.
- **B0**: a frozen copy of KofMut at the commit this plan starts from, before the instrumentation. Later plans reuse it for before measurements.
- **Measurement session**: for each chosen file, three runs with `budgetMs: 0` and one with `budgetMs: 85000`, with load recorded before and after each run.

## Milestones

### Milestone 1: B0 and the measurement script

Behavior: one command measures a KofMut build on a SiFuture file and leaves comparable evidence.

Edits:

1. Freeze B0 before changing code: `mkdir -p .agent/tmp/perf/b0 && git archive HEAD | tar -x -C .agent/tmp/perf/b0`. Record the commit id. Its first run builds its own preparation cache. Run it once and discard that result as a warmup.
2. Add `scripts/measure-run` (Bash, `set -euo pipefail`). Arguments: KofMut launcher, project, base config, scope file, `budgetMs`, repetitions, output directory. For each run it must:
   - write a config copy changed only in `budgetMs`, rewriting the JSON with `node -e` or `python3 -c`, never editing the original;
   - record `uptime`, `nproc`, the SiFuture commit, the KofMut commit and the resolved `kof` path with its `sha256sum`;
   - run `<launcher> run --project <project> --files <scope> --config <copy> --report-dir <out>/reports --run-id <uuid>` and record wall time and exit code;
   - append a TSV row: `file, budgetMs, run, exit, status, reportDurationMs, wallMs, candidates, killed, survived, timeout, testError, pending, discarded, load1Before, load1After`, read from the report at the announced `reportPath`;
   - save a sorted `id<TAB>status<TAB>phase` list per run;
   - never write inside the project.
3. Choose the smaller file. Try, in order, `src/main/kof/sifuture/game/BossShot.kf`, `SubchiefShot.kf` and `ShipContact.kf` with B0 and `budgetMs: 0`. Take the first that reaches `complete` with 8 to 20 candidates. If none does, record the results and pick the closest file with `complete`.

Validation:

- `scripts/measure-run .agent/tmp/perf/b0/bin/kof-mut ~/projects/kof-sifuture ~/projects/kof-sifuture/kof-mut.json .agent/tmp/perf/scope-meteor.json 0 3 .agent/tmp/perf/b0-meteor`, the same with `85000 1`, and both for the smaller file.

Acceptance:

- B0 Meteor with `budgetMs: 0`: 41 candidates, 37 Killed, 4 Survived, 0 Timeout. The same id/status list in all three runs. If the numbers differ from E6, record the difference; do not adjust.
- B0 Meteor with `budgetMs: 85000`: the number of `Pending` mutants is recorded. That is the number later plans must bring to zero.
- SiFuture preserved: `git -C ~/projects/kof-sifuture status --porcelain` is identical before and after. A manifest from `find src kof.toml scripts -type f -print0 | sort -z | xargs -0 sha256sum`, run inside SiFuture, is identical before and after.

### Milestone 2: per phase timing record

Behavior: every run writes `timings.tsv` into its existing evidence directory (`logs` in `MutationRun`, under `.agent/tmp/run-<runId>-*`, or the `kofmut.logs` directory). It has one row for the baseline and one per evaluated candidate, with columns `index, lockWaitMs, prepareMs, validateMs, checkMs, checkReleaseMs, testMs, testReleaseMs, removeMs, totalMs`. Phases that did not run hold an empty value. The report and stdout are unchanged.

Edits:

- `src/main/kof/kofmut/RunResources.kf`: one helper that acquires the lock and adds the measured wait to a per slot accumulator. Every current `lock.lock()` call that a slot can reach goes through it. Locking order and scope stay the same.
- `src/main/kof/kofmut/Evidence.kf`: `executeCommand` measures the command (start until `waitFor` returns) separately from `releaseCommand`, and returns both durations to the caller without changing `CommandResult` fields used by evidence. Add a field only if it does not reach the report.
- `src/main/kof/kofmut/Run.kf`: measure prepare, validate, check, check release, test, test release and remove around the existing calls, and write the rows once after `evaluateCandidates` returns. Write them in candidate index order, even when completion order differs. A failure to write `timings.tsv` must not change the run's status or exit code. Record it as a limitation only if the evidence directory itself is unusable, which is already the case today.
- Name every measured span with a self-explanatory variable or function; do not add comments, per `AGENTS.md`.

Tests (failing first), in `src/test/kof/kofmut/Run.kf`, tagged `check-run-a` or `check-run-b` so the coverage guard of `scripts/check` counts them:

- A parallel run (`maxParallelMutants: 4`, reuse `prepareParallel`) whose evidence directory holds `timings.tsv`. It has a header and exactly one row per candidate in `report.mutants` and `report.discardedCandidates`, plus one baseline row, in index order. Every present value is a nonnegative integer, and `totalMs` is at least the sum of the phases that ran in that row. For example, with six candidates and no discards, the file has seven data rows with indexes `baseline, 0..5`.
- The same run's report has exactly the fields it has today (compare the key sets of the decoded JSON with a run from an existing test fixture, not with expected values derived from production code), and stdout has the same lines.
- A discarded candidate (reuse the comment collision fixture from `comment collisions are discarded before check and later candidates remain isolated`) has a row with `validateMs` present and `checkMs` empty.

Validation:

- `kof test src/test/kof/kofmut/Run.kf --tag check-run-a` and `--tag check-run-b`: `0 failed`.
- A measurement session with the instrumented tree (`./bin/kof-mut`) on Meteor and the smaller file. Its id/status lists equal B0 (`diff` empty).

Acceptance:

- The breakdown for Meteor shows, as medians over all candidates of the three `budgetMs: 0` runs: lock wait, prepare, validate, check, check release, test, test release and remove, each in ms and as a share of `totalMs`.
- The instrumented tree's median `reportDurationMs` is within 5% of B0's under comparable load. A larger gap means the instrumentation itself costs time; record that.

## Progress

- [x] Milestone 1: B0 frozen at `1dffa555bbc347b320177c873af4fed51a9ac37d` (`.agent/tmp/perf/b0`), `scripts/measure-run` added, `BossShot.kf` chosen (first candidate, 16 candidates, `complete`), B0 sessions recorded in `.agent/tmp/perf/b0-meteor` and `.agent/tmp/perf/b0-bossshot`. Meteor at the current SiFuture commit has 26 candidates, all Killed, not the 41/37/4 of E6; recorded, not adjusted.
- [x] Milestone 2: timing record with tests, instrumented session recorded, breakdown written
  - [x] Two behavior tests tagged `timings` and `check-run-b` failed first on the missing `timings.tsv`, then passed.
  - [x] Instrumentation in place: `RunResources.acquire` replaces every `lock.lock()` of the run, `executeCommand` returns `runNanos` and `releaseNanos`, `Run.kf` writes `timings.tsv` once. The per candidate records are preallocated by the scheduler so recording them takes no extra lock.
  - [x] Instrumented session in `.agent/tmp/perf/instrumented-meteor` and `.agent/tmp/perf/instrumented-bossshot`; id/status lists equal B0; breakdown and findings in `.agent/validation/stop-budget-performance.md`.
  - [ ] Median `reportDurationMs` within 5% of B0: not met (Meteor +13.7%). Runs are bimodal on both trees and instrumented phases are under 1% of time; recorded, not attributed to instrumentation.
- [ ] Final validation passed and findings recorded
  - [x] Findings recorded in `.agent/validation/stop-budget-performance.md`, linked from `.agent/README.md`.
  - [ ] Focused `check-run-a` and `check-run-b`: failed (4 and 5 parallel tests without `LC_ALL`); B0 under the same conditions failed 4 and 2.
  - [ ] `./scripts/check` with `PATH=<0.7.0>/bin`, `KOF_MUT_COMPATIBILITY_OTHER=<0.6.4>/bin`, `LC_ALL=C.UTF-8`: exit 1 in 1300 s, 2 failures in `run-a` and 2 in `run-b`, all parallel or budget tests; other queues and the coverage guard passed. Delivery is blocked until the check is green.

## Lessons learned

- A `kof test` started from a background shell may not see a PATH exported in that shell; the tests then select the default Kof. `.agent/tmp/perf/with-kof-070` exports PATH, `KOF_MUT_COMPATIBILITY_OTHER` and `LC_ALL` and prints the selected Kof before running the command.
- The `parallel-runner` fixture intermittently reports `rmdir: failed to remove '.../counter-lock': No such file or directory` under load, on B0 as well; the affected candidate becomes `TestError` and parallel tests fail.

## Decisions

- **Kof 0.7.0 for every measurement and test in this plan.** On 2026-11-23 the `kof` on PATH became 0.8.1. Since Kof 0.8.0, `json.decode` into a record field typed `Object` or `List<Object>` fails with `JSN006: json.decode expected an array but the payload is a number` (reproduced outside KofMut; 0.7.0 decodes the same payloads). `JsonShape.kf` uses that pattern, so KofMut's compatibility probe refuses 0.8.x before any evaluation, at B0 and at the current tree alike. E6 was measured with Kof 0.7.0. Alternatives were fixing KofMut for 0.8.x (an engine change outside this plan) or modifying Kof (forbidden). Selected: prefix PATH with `~/.local/share/kof/kof-0.7.0-linux-x86_64/bin` for measurements, focused tests and `./scripts/check`; Kof itself is untouched. Consequence: results describe KofMut on Kof 0.7.0. Restoring compatibility with Kof 0.8.x needs its own plan or a Kof fix.

## Risks

- **Noisy measurements.** Mitigation: start each run only with a one minute load under 4, record load before and after, use three runs and the median. If two sessions differ by more than 2 in load, measure B0 again.
- **SiFuture or Kof changing during the work.** Mitigation: every row records the SiFuture commit and the `kof` sha256. If either changes, measure B0 again before comparing.
- **Instrumentation changing behavior.** Mitigation: the existing `parallel`, `budget`, `cleanup`, `timeout` and `m3` tests stay green without editing their assertions, and the instrumented id/status lists must equal B0.

## Validation

1. Focused: `kof test src/test/kof/kofmut/Run.kf --tag check-run-a` and `--tag check-run-b`, both `0 failed`.
2. Full: `./scripts/check` exits 0. It takes about 800 s. Every queue exits 0, and the coverage guard reports every test covered.
3. Measurement: the sessions above, with the SiFuture preservation checks.
4. Record everything in `.agent/validation/stop-budget-performance.md`:
   - environment (machine, `nproc`, Kof path and sha256, SiFuture and KofMut commits);
   - the B0 table and the instrumented table;
   - the paths and sha256 of the id/status lists;
   - the Meteor phase breakdown;
   - a short findings section.
   Link the record from "Current entry points" in `.agent/README.md`.
5. Findings section, required content:
   - which share of mutant time KofMut overhead (lock wait plus release plus prepare plus remove) takes, against project commands (check plus test);
   - the measured speedup of 4 slots, computed as the sum of per candidate `totalMs` divided by the engine time after baseline;
   - one sentence on which later plan the numbers favor.
   Say it plainly if the numbers refute the planning estimate.

Executor obligations before delivery:

- For each acceptance criterion, recheck that the expectation matches its source (E6 row, `docs/report-format.md`, the named tests), separately from whether the test or measurement shows it.
- Record the command, the observed result and the artifact path for each criterion. A green `./scripts/check` alone does not prove the measurement criteria.
- List failed checks and unverified criteria explicitly before delivery.
