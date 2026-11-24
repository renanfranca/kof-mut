# `fastJvmCommands` configuration option

Plan: `.agent/execplans/fast-jvm-commands.md`. Measured on 2026-11-24, branch `feat/fast-jvm-commands` from `3d3b209`, Kof 0.7.0 through `.agent/tmp/perf/with-kof-070`.

## Delivered behavior

`"fastJvmCommands": true` in `kof-mut.json` puts `-XX:TieredStopAtLevel=1` in `JAVA_TOOL_OPTIONS` of the baseline check, the baseline test and every candidate check and test. An inherited value is kept and the option is appended; an inherited value that already sets `-XX:TieredStopAtLevel=` is left unchanged. Omitted, `null` or `false` leaves the inherited environment. Any other JSON value returns 2 before project commands. Argv, the literal `kof` redirection, stdout, report keys, `schemaVersion: 1` and `VERSION` are unchanged.

Code: `src/main/kof/kofmut/JsonShape.kf` (shape validation), `Inputs.kf` (`fastJvmCommandsEnabled`), `Evidence.kf` (`javaToolOptionsWithFastCompiler`, applied to `builder.environment()` in `executeCommand`), `Run.kf` (four call sites). Docs: `docs/cli.md` and `docs/cli.pt_BR.md`, section "Configure a project".

## Tests, red then green

Three behavior tests in `src/test/kof/kofmut/Run.kf`, tag `fast-jvm`; `src/test/fixtures/mutation-runner` now appends `phase<TAB>${JAVA_TOOL_OPTIONS-<unset>}` to `$KOF_MUT_OBSERVATIONS/java-tool-options` on every invocation.

| Test | Queue | Red before the production edit (`.agent/tmp/fast/red.log`) | Green |
| --- | --- | --- | --- |
| rejects every value other than a JSON boolean | `check-run-a` | value `1` did not exit 2 (the key was ignored and the run proceeded) | pass |
| reaches every project command environment and leaves stdout and report keys unchanged | `check-run-a` | `true-unset: expected -XX:TieredStopAtLevel=1 but saw check <unset>`; the `false` and absent cases already passed | pass |
| keeps literal kof commands redirected and detects every operator family | `check-run-b` | no command stderr log showed the option | pass |

Earlier red attempts failed on defects of the new tests themselves (list concatenation and a nullable literal rejected by Kof, a survivor exit treated as failure, a JSON edit that broke on a trailing newline, a random reportPath suffix compared literally); they were fixed before the recorded red run, and none involved production code.

Focused queues after the change (`.agent/tmp/fast/run-a.log`, `run-b.log`): `check-run-a` 0 failed of 27, `check-run-b` 0 failed of 26, 53 of 53 tests covered. The existing `parallel-config` and `process` tests pass unchanged.

## Full check

`.agent/tmp/perf/with-kof-070 ./scripts/check`, log `.agent/tmp/fast/check.log`, observations `.agent/tmp/check-f646ee61-ae6d-47aa-bafa-1ff04f43f580`: exit 0, about 17 minutes, run after the SiFuture session.

| Queue | Result |
| --- | --- |
| version | exit 0 in 1 s |
| contracts | exit 0 in 12 s |
| cli-a, cli-b | 0 failed of 17 each; exit 0 in 759 s and 748 s |
| run-a | 0 failed of 27; exit 0 in 884 s |
| run-b | 0 failed of 26; exit 0 in 795 s |
| install-a, install-b, install-c | 0 failed of 8, 12 and 11; exit 0 in 1033 s, 920 s and 913 s |

The coverage guard printed no uncovered file.

## Null probe

No test passes JSON `null`, so it was checked once by hand after the full check: a copy of `fixtures/detected` with `src/test/fixtures/mutation-runner` in `timeout` mode, `"fastJvmCommands": null` and `JAVA_TOOL_OPTIONS=-Xmx64m` exported. The run reached `complete` (exit 1 only because the fixture's single candidate survives, as in the reference run of the application test) and all four commands recorded `-Xmx64m`. The copy was removed afterwards.

## SiFuture measurement

SiFuture `15f8f4a`, power profile `balanced` (`.agent/tmp/perf/fast-power-profile.txt`). Driver `.agent/tmp/perf/fast-session.sh` (the earlier `perf-session.sh` with C replaced by F and without the 85000 runs), log `.agent/tmp/perf/fast-session.log`, evidence `.agent/tmp/perf/fast-session-<meteor|bossshot>/<a|f>/`.

F configuration, `.agent/tmp/perf/fast/kof-mut.json`: SiFuture's `kof-mut.json` plus `"fastJvmCommands": true`, commands unchanged and without an `env` prefix.

Runs alternate A, F. No run was discarded: every `foreignCoreMax` was under 1 and every exit 0. `Survived`, `Timeout`, `TestError`, `Pending` and discards are all 0; `Lim` is the length of `limitations`; `Picked up` counts command stderr logs containing `Picked up JAVA_TOOL_OPTIONS: -XX:TieredStopAtLevel=1`.

| File | Config | Run | Status | reportDurationMs | wallMs | Candidates | Killed | foreignCoreMax | foreignCoreMean | maxTempC | throttleDelta | Lim | Picked up |
| --- | --- | ---: | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| Meteor | A | 1 | complete | 59484 | 61684 | 26 | 26 | 0.66 | 0.31 | 92 | 1960 | 0 | 0 of 54 |
| Meteor | F | 1 | complete | 37430 | 39001 | 26 | 26 | 0.33 | 0.22 | 88 | 0 | 0 | 54 of 54 |
| Meteor | A | 2 | complete | 61083 | 62679 | 26 | 26 | 0.69 | 0.31 | 90 | 1086 | 0 | 0 of 54 |
| Meteor | F | 2 | complete | 37504 | 39076 | 26 | 26 | 0.48 | 0.23 | 84 | 0 | 0 | 54 of 54 |
| Meteor | A | 3 | complete | 59597 | 60966 | 26 | 26 | 0.52 | 0.30 | 92 | 1476 | 0 | 0 of 54 |
| Meteor | F | 3 | complete | 37384 | 39011 | 26 | 26 | 0.36 | 0.22 | 82 | 0 | 0 | 54 of 54 |
| BossShot | A | 1 | complete | 38359 | 39843 | 16 | 16 | 0.79 | 0.32 | 92 | 640 | 0 | 0 of 34 |
| BossShot | F | 1 | complete | 23617 | 25185 | 16 | 16 | 0.36 | 0.22 | 81 | 0 | 0 | 34 of 34 |
| BossShot | A | 2 | complete | 38440 | 39851 | 16 | 16 | 0.70 | 0.33 | 91 | 326 | 0 | 0 of 34 |
| BossShot | F | 2 | complete | 23685 | 25278 | 16 | 16 | 0.50 | 0.23 | 82 | 0 | 0 | 34 of 34 |
| BossShot | A | 3 | complete | 38269 | 39854 | 16 | 16 | 0.53 | 0.29 | 92 | 1086 | 0 | 0 of 34 |
| BossShot | F | 3 | complete | 23397 | 24777 | 16 | 16 | 0.29 | 0.23 | 86 | 12 | 0 | 34 of 34 |

Identity: every `states.tsv` matches the hashes of `.agent/validation/jvm-short-commands.md`, "Identity": Meteor `8ade86979bba9d1ff6ee48aa40b9da4f87a8e3099910a3df9edd7db4279d03ee` (A and F, runs 1 to 3), BossShot `48b239e64e1be1b72602bb9092a8e182e41c3a2a4768a6e21510283a5f762931` (A and F, runs 1 to 3).

Speed, medians of `reportDurationMs`:

| File | A | F | F of A | C of A in the earlier record | Gap |
| --- | ---: | ---: | ---: | ---: | ---: |
| Meteor | 59597 | 37430 | 62.8% | 61.8% | 1.0 points |
| BossShot | 38359 | 23617 | 61.6% | 61.0% | 0.6 points |

SiFuture preserved: `git status --porcelain` empty before and after; manifest `2763a6e02f28579b9d96094d4f918564083752da88eb8c7d9f5ed802c1aea1ff` before and after (`.agent/tmp/perf/fast-sifuture-*`), the same as the earlier record.

## Criteria

| Criterion | Source of the expectation | Command and observation | Result |
| --- | --- | --- | --- |
| Rejection of `1`, `0`, `"true"`, `[]`, `{}`, `1.0` with exit 2, no `reportPath=`, no command, no `.kof-mut`, bytes and modes kept | plan Milestone 1; same contract as `maxParallelMutants` in `docs/cli.md` | `kof test Run.kf --tag check-run-a` | pass |
| Absent, `null`, `false` keep the inherited value; `true` sets, appends or respects an explicit level; at least four commands; stdout and report keys unchanged | plan Milestone 1 examples | same | pass for the six combinations the plan lists; `null` is not one of them, see "Null probe" |
| Real `kof` commands keep their redirection and the option reaches them | plan Milestone 1, `Evidence.kf` `executeCommand` | `kof test Run.kf --tag check-run-b` | pass |
| Docs in both languages at the same places | plan Milestone 2 | field row, null exception sentence and paragraph after "Commands run as argv"; example JSON unchanged; `git diff --check` clean | pass |
| Identity, applied, no new limitation, SiFuture preserved | plan Milestone 3, `jvm-short-commands.md` | tables above | pass |
| Speed recorded | plan Milestone 3 | 62.8% and 61.6%, within 1 point of C | recorded |

## For SiFuture

The one line SiFuture would add to its own `kof-mut.json`, with no other key changing:

```json
"fastJvmCommands": true
```

Adoption in SiFuture is the user's decision and was not made here.
