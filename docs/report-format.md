[English](report-format.md) | [Português](report-format.pt_BR.md) | [KofMut](../README.md)

# JSON v1 report reference

This is the public integration contract of the current source. CLI identifiers, JSON fields, values and case are canonical and are not translated. For invocation/configuration use [CLI](cli.md); for mutation concepts use [operators](operators.md).

## Discover the current report

For example, invoke the [detected fixture](../README.md#run-an-evaluation), optionally supplying a caller generated `--run-id UUID`. After safe destination validation, the tool reserves an exclusive directory and prints exactly one discovery line before the first project command:

```text
reportPath="/absolute/reports/<project-id>/<run-id>-<unique-suffix>/report.json"
```

The characters after `reportPath=` form a JSON string. Decode with a JSON parser, including escaped quotes, Unicode and control characters; stripping quotation marks is insufficient. The path is absolute. `project-id` is the full lowercase hexadecimal SHA-256 of the UTF-8 absolute canonical project path, without an added newline, independent of Git. Canonical aliases share an ID; different locations with the same basename do not. Even simultaneous calls with the same UUID reserve different directories. No shared latest result exists.

An announcement identifies a **reservation**, not a published file. Wait for process completion and require the final file at that exact path. Publication writes UTF-8 JSON to a temporary file and moves it atomically on the same filesystem. A filesystem publication failure returns 2 without a usable final report. Argument errors, unsafe destinations or launcher failure can return 2 without any announcement or JSON. An error after valid destination reservation can publish an `error` report. External interruption does not promise a partial report. Never search for the newest file or substitute an earlier report.

A consumer can implement this procedure without any Python dependency:

```text
Choose expectedRunId and expectedScope for this invocation.
Start run with --run-id expectedRunId; capture stdout, stderr and its exit.
Require exactly one stdout line starting with reportPath=.
JSON-decode the remainder as a string; require an absolute path.
Wait for completion and open the final JSON only at that decoded path.
Validate required fields, types and schemaVersion == 1.
Compare runId to expectedRunId and scope to the normalized requested scope.
Reconcile IDs, arrays, counts, baseline, limitations, status and process exit.
If discovery/publication/validation fails, record unavailable current evidence.
```

For a run rejected during input validation, `scope` can still be empty; treat it as an error and do not accept it as evidence for the requested scope. A tool generated UUID appears in human output and in JSON; an integrator should supply its own UUID to check identity independently. Checking UUID alone is insufficient because the same UUID can be reused across invocations.

## Example

This schematic `detected` report shows every field. Durations, timestamp and absolute log paths are illustrative, not expected timings or portable paths. The source location matches the fixture. Actual runs have their own identity and evidence paths.

```json
{
  "schemaVersion": 1,
  "toolVersion": "0.1.0",
  "kofVersion": "0.6.4",
  "runId": "d7df680d-2304-43a3-9741-4b0ebd61686e",
  "status": "complete",
  "scope": ["src/math/Calc.kf"],
  "baseline": {
    "status": "passed",
    "check": {
      "exitCode": 0,
      "durationMs": 1000,
      "summary": "stdout: /example/kof-mut/.agent/tmp/run-example/baseline-check.stdout; stderr: /example/kof-mut/.agent/tmp/run-example/baseline-check.stderr; process group cleanup confirmed",
      "filesChecked": 1,
      "executedTests": null,
      "failedTests": null
    },
    "test": {
      "exitCode": 0,
      "durationMs": 1000,
      "summary": "0 failed of 1 executed tests; stdout: /example/kof-mut/.agent/tmp/run-example/baseline-test.stdout; stderr: /example/kof-mut/.agent/tmp/run-example/baseline-test.stderr; process group cleanup confirmed",
      "filesChecked": null,
      "executedTests": 1,
      "failedTests": 0
    }
  },
  "counts": {
    "candidates": 1,
    "executed": 1,
    "killed": 1,
    "survived": 0,
    "compileError": 0,
    "timeout": 0,
    "testError": 0,
    "pending": 0
  },
  "mutants": [
    {
      "id": "src/math/Calc.kf:68:-",
      "file": "src/math/Calc.kf",
      "operator": "arithmetic",
      "original": "+",
      "replacement": "-",
      "location": {"line": 4, "column": 38, "offset": 68, "length": 1},
      "status": "Killed",
      "phase": "test",
      "durationMs": 2000,
      "evidence": "1 failed of 1 executed tests; stdout: /example/kof-mut/.agent/tmp/run-example/0-test.stdout; stderr: /example/kof-mut/.agent/tmp/run-example/0-test.stderr; process group cleanup confirmed"
    }
  ],
  "discardedCandidates": [],
  "limitations": [],
  "startedAt": "2026-10-22T12:00:00Z",
  "durationMs": 5000
}
```

## Top level fields

All fields below are required and nonnull. JSON objects are not ordered. Arrays retain the meanings described below. Missing required fields or incompatible types invalidate the report; version 1 does not promise semantics for schema extensions.

| Field | JSON type | Meaning |
| --- | --- | --- |
| `schemaVersion` | integer | `1` |
| `toolVersion` | string | KofMut VERSION, currently `0.1.0` |
| `kofVersion` | string | Frontend version actually selected and verified for this evaluation |
| `runId` | string | Requested or generated UUID |
| `status` | string | Overall state from the status table below |
| `scope` | array of strings | Normalized, deduplicated, sorted production paths relative to project; can be empty |
| `baseline` | object | Baseline state and both phase objects |
| `counts` | object | Eight nonnegative integer counts below |
| `mutants` | array of objects | Nondiscarded evaluation records; empty when none |
| `discardedCandidates` | array of objects | Rejected candidates; empty when none |
| `limitations` | array of strings | Unsupported forms, errors and other explicit reasons preventing completeness; empty when none |
| `startedAt` | string | ISO 8601 UTC instant at application `run` entry, with `Z` |
| `durationMs` | nonnegative integer | Elapsed monotonic milliseconds from `run` entry through evaluation/cleanup to report construction |

Overall duration excludes launcher startup and final publication. It is not a sum of candidate durations, especially with parallel evaluations. No score, approval percentage, project ID, log object or `maxParallelMutants` field is added to JSON v1.

## Baseline and phase evidence

`baseline` always has required `status` (string), `check` (object) and `test` (object). `status` values are `passed`, `failed` or `error`. `passed` requires valid check approval followed by completed tests with executed cases and zero failures. `failed` records a check/test that did not establish this prerequisite, including timeout or invalid evidence; `error` is also the initial value when baseline could not be evaluated. Overall `status` and phase evidence determine the outcome; baseline status alone is not an exit code.

Both `check` and `test` contain **all six fields**, including the inapplicable nulls:

| Field | JSON type | Meaning and null rules |
| --- | --- | --- |
| `exitCode` | integer or null | Child command exit, including a termination exit; null when no command ran |
| `durationMs` | nonnegative integer or null | Phase elapsed milliseconds; null when not started |
| `summary` | string or null | Evidence summary, diagnostics and local log references; null when not started |
| `filesChecked` | integer or null | Check counter `1..2147483647` when valid/coherent check JSON is decoded; null for tests, invalid check evidence, timeout or an unstarted phase |
| `executedTests` | nonnegative integer or null | Cases observed in parsed test evidence; null for check, timeout, unstarted phases or parsing that could not yield counts |
| `failedTests` | nonnegative integer or null | Failed cases in that parsed evidence; same null rules as `executedTests` |

A phase that never started has all six values null. Do not interpret null as zero, and do not accept nonnull test counters as proof of valid protocol: inconsistent parsed output can retain observed counts while reporting invalid evidence. `filesChecked` counts entry files, not imported sources. Command exits are distinct from KofMut's process exit. Failed/invalid baseline prevents mutant evaluation; baseline budget expiry produces overall `incomplete`.

## Mutants and discarded candidates

Every `mutants` item has these required, nonnull fields:

| Field | JSON type | Meaning |
| --- | --- | --- |
| `id` | string | Unique identity within the run, stable across result aggregation; current form is `file:offset:replacement`; treat as opaque |
| `file` | string | Production path relative to project |
| `operator` | string | `boundary`, `equality`, `logical`, `boolean` or `arithmetic` |
| `original` | string | Original token text |
| `replacement` | string | Replacement token text |
| `location` | object | Four integer fields defined below, referring to original source |
| `status` | string | Mutant state from the next table |
| `phase` | string | `parse`, `check` or `test`: recorded evaluation context or next unstarted phase |
| `durationMs` | nonnegative integer | Candidate elapsed time through its recorded result, including preparation and preceding phases; zero for `Pending` |
| `evidence` | string | Textual result/reason, diagnostics and log references when available |

Each `discardedCandidates` item has the same `id`, `file`, `operator`, `original`, `replacement`, `location`, `durationMs` and `evidence` fields and types. Its required `phase` is only `parse` or `check`, and it has **no `status` field**. It is outside `mutants` and outside their counts. Token/parse or coherent check rejection can discard a candidate; invalid evidence cannot. The [operator guide](operators.md#discarded-candidate) defines those rules.

Within each array, results follow original selection order even when processes finish out of order. IDs and log indices do not renumber after discards. After candidate selection, every evaluation is accounted for once in one array, including cancellation/cleanup errors. Completed results remain; unstarted candidates on error use `Pending/parse`, duration zero and the interruption reason in `evidence`. The overall result remains `error/2` when publishable.

## Mutant states

| `status` | Meaning |
| --- | --- |
| `Killed` | Approved check and completed tests with recognized failure evidence |
| `Survived` | Approved check and completed tests without failures |
| `CompileError` | Historical compatibility value; new coherent compiler rejections go to `discardedCandidates` |
| `Timeout` | Check or test was interrupted at its deadline, with phase/cleanup evidence |
| `TestError` | Invalid/insufficient evidence, runner failure, unexpected task failure or cleanup error |
| `Pending` | Evaluation or next phase did not start because budget ended or execution stopped on error; duration zero; `evidence` records nonstart or interruption |

A mutant can be `Pending/check` or `Pending/test` after earlier work; zero duration is the pending representation, not a claim that no earlier work occurred. `Pending/parse` identifies a candidate not started. No `NoCoverage` state exists. A survivor does not automatically imply equivalence, missing coverage or a weak test.

## Counts

All eight fields are required nonnegative integers. `candidates` counts the retained mutant records, not the original total before discards. `executed` is an accounting count, not the number of completed test commands.

| Field | Exact rule |
| --- | --- |
| `candidates` | `mutants.length` |
| `executed` | `candidates - pending` |
| `killed` | Number of `Killed` records |
| `survived` | Number of `Survived` records |
| `compileError` | Number of historical `CompileError` records; zero in new runs |
| `timeout` | Number of `Timeout` records |
| `testError` | Number of `TestError` records |
| `pending` | Number of `Pending` records |

Reconcile `executed = killed + survived + compileError + timeout + testError` and `candidates = executed + pending`. To obtain the selected total after selection, add `discardedCandidates.length` to `candidates`. Discards are not kills. Expected discards allow `complete` when applicable mutants remain; all discarded, with no other limitation, is `no_mutants/3`.

## Locations and evidence

`location` always contains nonnull integers `line` and `column` starting at 1, `offset` starting at 0 and positive `length`. `offset` and `length` index JVM Strings in **UTF-16 code units**, not UTF-8 bytes or Unicode code points. Columns follow the official lexer, also advancing by UTF-16 units. The original token is the source substring `[offset, offset + length)` before replacement. Do not index UTF-8 buffers with these values.

For the tested CRLF source `Bool less(Int x) { var text = "😀" return x < 2 }\r\n`, `<` has `offset: 44`, `line: 1`, `column: 45`, `length: 1`. Its UTF-8 byte offset is 46 because the emoji occupies two UTF-16 units and four UTF-8 bytes. These units also matter when replacement length changes.

`summary`/`evidence` are strings, not nested command JSON or stable machine protocols for log extraction. They can include Kof diagnostic codes/messages, `stdout:`, `stderr:`, `log:` paths and cleanup confirmation/failure. Do not translate or discard diagnostics when retaining evidence. Read the [local logs](cli.md#reports-and-logs) for details; portable consumers should use structured statuses and fields rather than infer approval from summary text.

## Overall status and process exit

| Overall `status` | Exit | Interpretation |
| --- | --- | --- |
| `complete` | `0` | At least one applicable mutant, all `Killed`, no limitations |
| `complete` | `1` | Evaluation complete with at least one `Survived`; quality validation fails |
| `baseline_failed` | `2` | Baseline check/test did not provide valid passing evidence |
| `error` | `2` | Input, frontend, tool, task or cleanup error, when JSON publication is possible |
| `incomplete` | `3` | Budget expiry, inconclusive mutant or unsupported scope/other limitation |
| `no_scope` | `3` | Explicit empty scope; no baseline commands or quality approval |
| `no_mutants` | `3` | No applicable mutants, including all candidates discarded; no quality approval |

`Timeout`, `TestError`, `Pending` and limitations prevent `complete`. Expected discards alone do not. A baseline can pass while the overall run is incomplete or errors. Counts can be zero when baseline or input validation stopped evaluation.

Outside this JSON mapping, version/help return 0 without evaluation; entry/publication errors can return 2 without JSON; SIGINT/SIGTERM during an active command return 130/143 without a promised report. Require agreement between current final JSON and process exit. `complete` establishes execution completion; survivors, equivalence analysis and [historical performance](../README.md#validation-and-next-milestones) remain separate concerns.
