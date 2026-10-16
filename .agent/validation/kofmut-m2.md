# KofMut M2 validation

M2 implements the local mutation cycle on synthetic projects. Base: `b1d8684762ad1d2f94a48d9dcd81270647a6fe52`, branch `kofmut-frontend`. Work is local; no commits, worktrees, subagents, remotes or publications were created. Kof and other projects were not modified.

The supported installation is Kof/compiler/runtime/stdlib **0.6.4**, Linux/JVM with its embedded JDK 25. The installed jar SHA-256 remained `137a838d38757e317545474d55ad6a3ad291fb86d263ae77d9197cf705829c62`. Local Kof documentation, AST records, parser, check command and test harness were consulted; behavior was verified on the installed binary, rather than inferred from the newer source checkout.

## Platform proofs

Before depending on the JVM boundaries, small Kof programs verified ProcessBuilder with String[] argv, cwd, closed stdin, separate output files, waitFor with TimeUnit, process identity and monotonic time. Nested JSON preserved null fields, nullable phases and arrays. POSIX file permission capture and restoration succeeded. The compiler rejected constant `7 / 0` with `ARITH001` and exit 1 in check JSON.

ArrayList argv was rejected at runtime with NoSuchMethodError in 0.6.4; String[] is the verified form. An overloaded Files.createTempFile call emitted incompatible bytecode, so report staging uses the already proven createTempDirectory(Path, String), a file inside it and ATOMIC_MOVE. Moving the sort lambda out of try/finally avoided a compiler lowering failure. These are local calling forms; Kof was not changed. The JSON decoder coerces types, so additional shape records inspect the platform decoded primitive objects before typed binding. No JSON parser was implemented here.

Local artifacts: `.agent/tmp/m2-probes/platform.log`, `json-shapes.log`, `Zero.kf.txt`, plus the real CLI test reports and command stdout/stderr in unique `.agent/tmp/run-<UUID>-*/` directories. Raw logs are intentionally excluded from Git.

## Behavioral evidence

The public observation point is `bin/kof-mut run`, its exit, JSON v1, human output and files observed by synthetic command wrappers. Valid commands invoke the installed Kof compiler and named test runner. Malformed protocol cases are synthetic evidence inputs, not an alternative test runner. Frontend assertions execute the real lexer/parser on their installed classpath.

| Criterion | Observed proof and assertion strength |
| --- | --- |
| Detected mutation | `detected`: baseline passes, one `+ → -`, valid check and completed failed case; one Killed, exit 0. The check cannot merely return a nonzero status to satisfy this proof. |
| Survivor | `survived`: `sum(5, 0)` accepts both results; one Survived, exit 1, file/line/column checked. Treating every test outcome as Killed fails this test. |
| Compiler rejection | `invalid`: baseline passes, `7 * 0 → 7 / 0`, ARITH001 in check evidence, one CompileError, no Killed, exit 3. |
| Baseline prerequisite | Imported undefined source is rejected with filesChecked=1; a separate red test executes one failed case. Both stop with zero candidates and no mutant command observations. A stale report is replaced with the requested UUID. |
| Suite evidence | Two cases in one file count as two executed tests. A real tag filter counts one executed case. An absent tag cannot pass baseline. Malformed JSON, coerced JSON fields, contradictory exits, missing summaries, truncation, all SKIP, zero cases, header mismatch and runner failure never become Killed. |
| Scope | Whole scope is validated before commands. Normalizable duplicates collapse, two paths sort, and missing/test/wrong extension/outside roots/escape/link selections are rejected without command observations. Empty scope returns no_scope/3 without commands. |
| Snapshot and isolation | Baseline and two variants log the exact received source, a new imported file containing its own mutable `1 - 1` expression and the absence of state. First variant is `a - b + helper.zero()`, second is `a + b - helper.zero()`; each starts clean. Originals are compared independently afterward. This distinguishes preserved originals from truly independent variants. |
| Links and permissions | Executable fixture wrappers run directly from copied permissions. Internal data links become regular files with the same contents in baseline and variant; original links remain links. Self cycles, directory cycles, targets outside the project and targets outside declared inputs are rejected. |
| Operators | Exact ordered original/replacement lists cover all fourteen directions. Real compilation/tests detect one mutant from each family. Functions, methods, constructors, fields, lambdas, control blocks, assignments, returns, calls, arrays and conditional expressions are traversed. |
| Token boundaries | Strings, comments, character literals and nested generic closers yield no spurious sites. Repeated and nested operators, unary operands and calls retain distinct tokens. Declared text, aliases, fields and local shadowing prevent inappropriate concatenation mutations. |
| Locations and bytes | Unicode/CRLF frontend expectations use independently counted UTF-16 indices. A real CLI fixture asserts offset 95, line 3, column 64, length 1. cmp compares the complete baseline and variant bytes to explicit expectations and also checks binary bytes 00 ff 0d 0a. |
| Time and descendants | Both individual timeout and a smaller global budget wait until parent and child are active. On completion neither PID is active, evidence says cleanup confirmed, status is Timeout/test. Global budget leaves one Pending with duration zero, reconciles counts, and starts no next check. |
| Report contract | Every parsed report checks versions, UUID, UTC timestamp, nonnegative duration, candidate array size and count reconciliation. Explicit fixture expectations check states, phases, nulls and diagnostics. Human output includes every state per file and survivor locations. Outputs overlapping protected inputs are refused and source bytes remain intact. |
| Process boundary and cleanup | Empty argv entries, spaces, Unicode, newline and shell metacharacters arrive unchanged; stdin is EOF, inherited environment is observed, cwd is disposable and gone on return. Dangling links created by commands do not prevent sandbox removal. |

Observed focused and intermediate runs are saved under `.agent/tmp/m2-probes/`: `first-red.log`, `invalid-red.log`, `operators-red.log`, `control-red.log`, `text-red.log`, `evidence-red.log`, `timeout-red.log`, `links-red.log`, `report-focused-red.log`, `process-red.log`, with corresponding green results. Red failures came before the associated behavior; fixture mistakes in independently counted offsets and dangling link removal were corrected separately from production behavior.

## Assertion and structural review

Two intentionally incorrect implementations were exercised only in disposable copies. Mapping every completed test result to Killed made the survivor contract fail (exit 1 from the test runner). Reusing a variant with its previous mutation and state made the isolation contract fail, observing two Killed where the explicit contract requires one Killed and one Survived. Logs: `.agent/tmp/m2-probes/audit-false-kill.log` and `audit-cumulative.log`. This tests the assertions against plausible wrong implementations, beyond observing a green suite.

The structural review classified three design risks: early report publication before cleanup, a materialized copy appearing authoritative despite an existing byte snapshot, and duplicated global/per-file counting rules. Evaluation now returns to one cleanup boundary before publication; analysis and each variant are materialized from captured memory bytes, with transformations reading the fresh variant; one count function supplies both report views. The per-run object remains scoped to one invocation. Explicit frontend traversal and protocol status strings were retained within their versioned boundary; no forwarding classes or test-only production seams were introduced.

## Final verification

Observed final results:

- `PATH=<Kof 0.6.4 bin>:$PATH ./scripts/check`: exit 0, 21 launcher cases, 17 mutation cycle cases, 14 frontend proof groups. Log: `.agent/tmp/m2-probes/check-consolidated.log`.
- After structural refactoring, `kof test src/test/kof/kofmut/Run.kf`: exit 0, 17 cases (144441 ms reported); `./scripts/launch contracts`: exit 0, 14 frontend proof groups. Logs: `run-refactor.log` and `frontend-final.log` in the same local evidence directory.
- The final strengthened isolation case (`kof test .../Run.kf --tag isolation`): exit 0. Its unselected imported file contains a mutable operator, and every command must observe the original bytes. Log: `isolation-final.log`.
- Documented fixture commands `./bin/kof-mut run --project fixtures/<name> --files fixtures/<name>/scope.json --report .agent/tmp/<name>.json`: `detected` exit 0/one Killed; `survived` exit 1/one Survived at line 4, column 38; `invalid` exit 3/one CompileError with ARITH001. Baseline passed in all three. Exact exits: `.agent/tmp/m2-probes/fixtures.tsv`.
- Clean copy at `.agent/tmp/m2-clean/checkout with spaces`, initially without `.git`, build or logs: full `./scripts/check` exit 0 using only `.agent/tmp/m2-clean/tools` on PATH. Neither python nor python3 was found. Kof info reported 0.6.4. All 21 launcher cases (247482 ms), 17 cycle cases (137761 ms) and 14 frontend proofs passed. Logs: `check-clean.log`, `no-python-info.log`. The final 41 source/fixture/script/VERSION/manifest/README files match the checkout by SHA-256 content comparison.
- `git diff --check`, Bash syntax checks and local documentation link checks: exit 0. The final source manifest is [kofmut-m2.sha256](kofmut-m2.sha256).

The startup performance measurements in the historical M1P report were not re-established as a new M2 benchmark. The 21 launcher contracts, including its direct cached path and absence of Python, are preserved. M2 claims local synthetic acceptance, not SiFuture acceptance.

## Limits and recovery

Only Kof 0.6.4 on Linux/JVM is supported. Unknown AST forms remain explicit limitations; records are an exercised example. No coverage, equivalent mutation inference, incremental selection or parallel mutant execution is provided. Process groups cover inherited group members; deliberately detached processes have no cancellation guarantee in this milestone. Command output that fails the supported evidence protocol remains inconclusive.

M3 retains broader concurrent run/recovery tests, the equivalent fixture and external SiFuture measurements within the unchanged 90 second budget. M2 synthetic results do not establish external integration cost. M4 retains the complete CLI/operator/report guides in both languages.

To recover from interrupted local builds, remove only `build/cache/kof-launch-v2/` and retry. Mutation logs remain local under `.agent/tmp/`; command sandboxes are disposable system temporary directories. A publication failure returns 2; callers must not interpret an existing older report as the current run. Protected input destinations are refused before project commands.
