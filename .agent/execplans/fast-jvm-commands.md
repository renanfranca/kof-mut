# Add the `fastJvmCommands` configuration option

## Purpose and success

KofMut runs the evaluated project's `checkCommand` and `testCommand` once for the baseline and once per candidate. On Kof projects each of these is a short JVM process. `.agent/validation/jvm-short-commands.md` showed the effect of limiting those JVMs to their fast compiler with `JAVA_TOOL_OPTIONS=-XX:TieredStopAtLevel=1`, measured on SiFuture `15f8f4a` with Kof 0.7.0:
- every mutant id, state and phase stayed the same;
- no limitation was added;
- a run took about 62% of the time, under the `balanced` power profile (Meteor 37.5 s against 60.7 s, BossShot 23.6 s against 38.6 s).

That measurement put the variable in the project configuration through an `env` prefix. The prefix has two costs:
- every project must know a JVM detail;
- an argv that starts with `env` no longer starts with a literal `kof`, so KofMut stops redirecting it to the Kof selected for the invocation (`src/main/kof/kofmut/Evidence.kf`, `executeCommand`).

This plan moves the decision into KofMut as an explicit, optional configuration key. KofMut puts the option in the environment of each project command process. The argv stays untouched.

Success, observable from outside:

1. `"fastJvmCommands": true` in `kof-mut.json` makes every project command see the option in `JAVA_TOOL_OPTIONS`:
   - this covers the baseline check, the baseline test, and every candidate check and test;
   - a value the caller already set is kept, and the option is appended to it;
   - if the caller already set `-XX:TieredStopAtLevel=` explicitly, the value is left unchanged.
2. Omitted, `null` or `false` leaves the commands' environment exactly as inherited, which is today's behavior.
3. Any other JSON value is rejected with exit 2 before any project command, without `reportPath=`, and the project is left untouched. This is the same contract as `maxParallelMutants`.
4. stdout, the report JSON keys and `schemaVersion: 1` are unchanged.
5. On SiFuture, a configuration copy with `"fastJvmCommands": true` reproduces the mutant states of the default configuration and the speed of the earlier `env` measurement.

How to see it working: add `"fastJvmCommands": true` to a copy of SiFuture's configuration and run `scripts/measure-run`. The command stderr logs contain "Picked up JAVA_TOOL_OPTIONS: -XX:TieredStopAtLevel=1", and `runs.tsv` shows the shorter `reportDurationMs`.

## Context and limits

Read before starting:

- `AGENTS.md`:
  - engine logic in Kof under `src/main/kof/kofmut/`;
  - behavioral tests in Kof drive the change;
  - `./scripts/check` is the validation entry point;
  - public docs in English and Brazilian Portuguese, with JSON fields and CLI identifiers not translated;
  - prefer names over comments;
  - logs in `.agent/tmp/`, evidence in `.agent/validation/`.
- `src/main/kof/kofmut/JsonShape.kf`:
  - `ConfigShape` and `validateConfigShape`;
  - the `maxParallelMutants` validation is the pattern to follow: an `Object` field, a type check, and a `throw` with a message naming the key.
- `src/main/kof/kofmut/Inputs.kf`: `RunConfig` and `loadConfig`.
- `src/main/kof/kofmut/Evidence.kf`: `executeCommand` builds `ProcessBuilder(["setsid", ...argv])`, redirects a literal `kof` executable to `System.getProperty("kofmut.kof")`, and starts the process through `RunResources.startCommand`.
- `src/main/kof/kofmut/Run.kf`:
  - `evaluateBaseline` and `evaluateCandidate` call `executeCommand` four ways (baseline check, baseline test, candidate check, candidate test).
- `src/test/kof/kofmut/Run.kf`, tests to mirror:
  - `parallel limit rejects original incompatible JSON values before project commands and internal output`;
  - `parallel configuration accepts supported limits and defaults to one without changing JSON v1`;
  - `configured argv environment cwd and closed stdin reach disposable commands`, with its fixture `src/test/fixtures/mutation-runner`;
  - `all operator families are detected through real compiler and tests`, which runs the real Kof compiler and tests.
- `docs/cli.md` and `docs/cli.pt_BR.md`:
  - section "Configure a project": the example JSON, the field table, and the paragraph that starts "Commands run as argv".
- `.agent/validation/jvm-short-commands.md`: the A and C numbers, the `states.tsv` hashes and the C configuration this plan reproduces.

Facts checked during planning:

- **Kof 0.7.0 `json.decode` into a record ignores unknown keys and leaves missing ones `null`.** Probe: a record `Shape(Object a, Object b)` decoded from `{"a": 1, "b": true, "extra": true}` and from `{"a": 1}`. So adding `Object fastJvmCommands` to `ConfigShape` decodes absence as `null`.
- **Backward compatibility is not a concern for this change (user decision).** Older KofMut builds are not considered.

Kof selection: the `kof` on PATH is 0.8.1, which KofMut refuses (JSN006). Run every test and measurement through `.agent/tmp/perf/with-kof-070` (ignored by Git, present locally). It exports these three variables and then runs `exec "$@"`:
- `PATH="$HOME/.local/share/kof/kof-0.7.0-linux-x86_64/bin:$PATH"`
- `KOF_MUT_COMPATIBILITY_OTHER="$HOME/.local/share/kof/kof-0.6.4-linux-x86_64/bin"`
- `LC_ALL=C.UTF-8`

If it is missing, recreate it with exactly that content.

Fixed limits:

- Configuration and report stay `schemaVersion: 1`. Do not change report fields, exit codes or stdout. Leave `VERSION` alone (`0.1.0`).
- The variable is set only in the environment of project command processes. It is not set in KofMut's own JVM, in launcher preparation or in compatibility probes.
- Do not change argv, and do not change the literal `kof` redirection.
- Do not modify Kof. Do not write inside `~/projects/kof-sifuture`. Its configuration copies live under `.agent/tmp/perf/`.
- Out of scope:
  - making the option the default;
  - widening `maxParallelMutants`;
  - the Kof 0.8.x incompatibility;
  - changing SiFuture's own configuration. The record lists the one line SiFuture would add.

Safety boundary: this task is limited to authorized, defensive maintenance of this repository.

## Milestones

### Milestone 1: validate and apply `fastJvmCommands`

Behavior, with examples:

- Absent, `null` or `false`:
  - if the caller exports nothing, every project command sees `JAVA_TOOL_OPTIONS` unset;
  - if the caller exports `JAVA_TOOL_OPTIONS=-Xmx64m`, every command sees exactly `-Xmx64m`;
- `true`:
  - with nothing exported, every command sees `-XX:TieredStopAtLevel=1`;
  - with `-Xmx64m` exported, every command sees `-Xmx64m -XX:TieredStopAtLevel=1`;
  - with `-XX:TieredStopAtLevel=4` exported, every command sees `-XX:TieredStopAtLevel=4` unchanged.
- These values are rejected with exit 2: `1`, `0`, `"true"`, `[]`, `{}`, `1.0`. In each case:
  - stdout has no `reportPath=`;
  - no project command ran;
  - no `.kof-mut` directory exists in the project;
  - the project's sources, bytes and modes are unchanged.

Tests first, in `src/test/kof/kofmut/Run.kf`. Tag each test with exactly one of `check-run-a` or `check-run-b`, so the coverage guard in `scripts/check` counts it.

1. **Rejection.** Mirror `parallel limit rejects original incompatible JSON values before project commands and internal output`, using the values above and the same assertions. It must fail before the change: today KofMut ignores the key, so it exits 0 and runs the commands.
2. **Application.** Extend `src/test/fixtures/mutation-runner`, under the same `KOF_MUT_OBSERVATIONS` condition it already uses, to append one line per invocation to `$KOF_MUT_OBSERVATIONS/java-tool-options`. Each line holds the invocation's phase, then a tab, then `${JAVA_TOOL_OPTIONS-<unset>}`. A run with one candidate then gives at least four lines: baseline check, baseline test, candidate check, candidate test.

   The test runs `./bin/kof-mut run` with `process.run("env", ...)` once for each of these combinations:
   - `false` with nothing exported;
   - `false` with `-Xmx64m`;
   - `true` with nothing exported;
   - `true` with `-Xmx64m`;
   - `true` with `-XX:TieredStopAtLevel=4`;
   - the key absent with `-Xmx64m`.

   To leave the variable unset, use `env -u JAVA_TOOL_OPTIONS`. For each run, assert that:
   - every recorded line has the expected value;
   - there are at least four lines;
   - stdout has the same lines as a run without the key;
   - the decoded report has the same key set as a run without the key.

   With today's code, the `true` cases fail because the variable stays as inherited.
3. **Real Kof commands.** Run the real compiler fixture of `all operator families are detected through real compiler and tests` once more with `"fastJvmCommands": true`, with checkCommand and testCommand left starting with literal `kof`. Assert that:
   - the result is the same, `complete` with the same counts as the existing test;
   - at least one command stderr log under the run's log directory contains `Picked up JAVA_TOOL_OPTIONS: -XX:TieredStopAtLevel=1`.

   The redirection of a literal `kof` stays covered by the existing tests, because argv is not touched.

Edits:

- `JsonShape.kf`:
  - add `Object fastJvmCommands` to `ConfigShape`;
  - in `validateConfigShape`, reject any non `null` value whose class is not `java.lang.Boolean`, with the message `fastJvmCommands must be a JSON boolean`.
- `Inputs.kf`: add the field to `RunConfig`, as `Object` or `Bool?` (whichever decodes `null` and absence the same way), and expose one `Bool` meaning "enabled".
- `Evidence.kf`: `executeCommand` receives whether the option is enabled. When it is, it sets `JAVA_TOOL_OPTIONS` on `builder.environment()` following the rules above, before `startCommand`. The rule "append unless `-XX:TieredStopAtLevel=` is already present" lives in one named function.
- `Run.kf`: pass the flag at the four call sites.

Validation:

- `.agent/tmp/perf/with-kof-070 kof test src/test/kof/kofmut/Run.kf --tag check-run-a` and `--tag check-run-b`: `0 failed`.
- Record that each new test failed before its production edit, and on which assertion.

Acceptance: the examples above observed through the tests. The existing `parallel-config` and `process` tests pass unchanged.

### Milestone 2: documentation in both languages

Edits, the same content at the same places in `docs/cli.md` and `docs/cli.pt_BR.md`:

- In the field table, a row for `fastJvmCommands`: an optional JSON boolean; omitted, `null` or `false` leaves the inherited environment; `true` adds `-XX:TieredStopAtLevel=1` to `JAVA_TOOL_OPTIONS` of every project command, appended to an existing value and skipped when that value already sets `-XX:TieredStopAtLevel=`.
- After the paragraph "Commands run as argv...", one short paragraph:
  - the option suits JVM commands that each run for seconds, which spend much of their CPU on the JVM optimizing compiler;
  - it does not change argv, so a literal `kof` executable keeps its redirection;
  - KofMut's own JVM is not affected;
  - verify that mutant states are unchanged before relying on it;
  - the JVM prints a "Picked up JAVA_TOOL_OPTIONS" notice on each command's stderr.
- Write in plain words, with no measured numbers in the public docs.

Acceptance:
- Both files carry matching content at the same places.
- The JSON example, if one changed, still parses: `python3 -I -c 'import json,sys; json.loads(sys.argv[1])' '<example>'`.
- `git diff --check` is clean.

### Milestone 3: SiFuture measurement

Behavior: evidence that the option reproduces the earlier `env` result through the new key.

- Create `.agent/tmp/perf/fast/kof-mut.json`. It is `~/projects/kof-sifuture/kof-mut.json` plus `"fastJvmCommands": true`, with the commands unchanged and no `env` prefix.
- Confirm that the power profile is `balanced` (`powerprofilesctl get`) and record it. The earlier record's A and C were measured under `balanced`.
- For Meteor and BossShot (`.agent/tmp/perf/scope-meteor.json`, `.agent/tmp/perf/scope-bossshot.json`):
  - alternate A (the original configuration) and F (the new copy), one run at a time, with `scripts/measure-run bin/kof-mut ~/projects/kof-sifuture <config> <scope> 0 1 .agent/tmp/perf/fast-session-<file>/<a|f>` through `with-kof-070`;
  - wait for `.agent/tmp/perf/wait-quiet 1.0` before each run;
  - stop when each configuration has three runs with `foreignCoreMax` under 1, at most seven attempts each.

  `.agent/tmp/perf/perf-session.sh` is a working driver to adapt.
- Record SiFuture's `git status --porcelain` and its manifest (`find src kof.toml scripts -type f -print0 | sort -z | xargs -0 sha256sum | sha256sum`, run inside SiFuture) before and after.

Acceptance, with sources:

- **Identity.** Every clean run of A and F has the `states.tsv` sha256 from `.agent/validation/jvm-short-commands.md`, "Identity": Meteor `8ade86979bba9d1ff6ee48aa40b9da4f87a8e3099910a3df9edd7db4279d03ee`, BossShot `48b239e64e1be1b72602bb9092a8e182e41c3a2a4768a6e21510283a5f762931`. If SiFuture is no longer at `15f8f4a`, compare A against F only and record the new hashes.
- **Applied.** F's command stderr logs contain the "Picked up JAVA_TOOL_OPTIONS: -XX:TieredStopAtLevel=1" notice. A's do not.
- **No new limitation.** F has no `Timeout` or `TestError`, and the same `limitations` as A.
- **Speed, recorded.** Record the median `reportDurationMs` of F as a percentage of A for each file, next to the earlier C result (61.8% Meteor, 61.0% BossShot). A gap of more than 10 percentage points from C is a finding to explain, not a failure.
- **SiFuture preserved.** Status and manifest identical before and after.

## Progress

- [x] Milestone 1 (2026-11-24): three tests tagged `fast-jvm` red then green; `check-run-a` 27 of 27 and `check-run-b` 26 of 26 pass. Production edits in `JsonShape.kf`, `Inputs.kf`, `Evidence.kf`, `Run.kf`.
- [x] Milestone 2 (2026-11-24): field row, null exception sentence and usage paragraph in both CLI docs; `git diff --check` clean. The example JSON was left unchanged.
- [x] Milestone 3 (2026-11-24): three clean runs per configuration and file, none discarded; identity, applied, no new limitation and SiFuture preservation pass; F takes 62.8% (Meteor) and 61.6% (BossShot) of A.
- [x] Final validation and record (2026-11-24): `./scripts/check` exit 0; record in `.agent/validation/fast-jvm-commands.md`, linked from `.agent/README.md`. JSON `null` has no automated test and was checked once by hand (recorded there).

## Decisions

- **Option in KofMut, applied through the process environment.** Alternatives:
  - an `env` prefix in each project's commands: it loses the literal `kof` redirection and puts a JVM detail in every project;
  - exporting the variable to the whole `kof-mut` process: it would also change KofMut's own JVM, which was never measured.

  The environment of `ProcessBuilder` changes only the project command processes and leaves argv alone.
- **Optional key, `schemaVersion` stays 1, `VERSION` unchanged, no stdout change.** The user ruled out backward compatibility concerns, so no versioning or confirmation line is added. Applying the option is observable in the command stderr logs. Releasing a new `VERSION` is a separate decision.
- **Respect an explicit `-XX:TieredStopAtLevel=` already in `JAVA_TOOL_OPTIONS`.** A caller who sets it chose a level on purpose. Otherwise the option is appended, so the JVM honors every other caller flag.

## Risks

- **A long compute test slows down without the optimizing compiler and reaches `commandTimeoutMs`.** Mitigation: the option is opt in, and the docs say to verify states first. On SiFuture, the identity and no new limitation checks cover it.
- **The "Picked up JAVA_TOOL_OPTIONS" notice on stderr.** KofMut stores stderr as a log file and does not parse it. Wrapper scripts that parse the JVM's stderr themselves could be affected. The docs mention the notice.
- **Load noise in Milestone 3.** Mitigation: alternate the configurations, require `foreignCoreMax` under 1, close the IDE.

## Validation

Final validation, all must pass before delivery:

1. `.agent/tmp/perf/with-kof-070 kof test src/test/kof/kofmut/Run.kf --tag check-run-a` and `--tag check-run-b`: `0 failed`.
2. `.agent/tmp/perf/with-kof-070 ./scripts/check` exits 0, with every queue and the coverage guard green. It takes about 17 minutes. `main` passed it twice in a row before this plan (`.agent/validation/check-duration-origin.md`).
3. Milestone 3: identity, applied, no new limitation and SiFuture preservation pass, and speed is recorded.
4. `git diff --check` is clean. `git status --porcelain` shows only the four production files, `src/test/kof/kofmut/Run.kf`, `src/test/fixtures/mutation-runner`, the two docs, `.agent/validation/fast-jvm-commands.md`, `.agent/README.md` and this plan.

Record in `.agent/validation/fast-jvm-commands.md`, linked from "Current entry points" in `.agent/README.md`:
- the red then green evidence of each test;
- the check run (exit code, queue lines, observations directory);
- the F configuration;
- the A and F tables from `runs.tsv`, discarded runs included;
- the hashes and the speed comparison with C;
- SiFuture preservation;
- the one line SiFuture would add to its `kof-mut.json`: `"fastJvmCommands": true`.

Executor obligations before delivery:

- For each criterion, recheck that the expectation matches its source, separately from whether the test or measurement shows it. The sources are this plan's examples, `docs/cli.md`, `Evidence.kf` and `.agent/validation/jvm-short-commands.md`.
- Record the command, the observed result and the evidence path for each criterion.
- List failed checks and unverified criteria explicitly before delivery.
