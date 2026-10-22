[English](README.md) | [Português](README.pt_BR.md)

# KofMut

KofMut is a mutation testing tool being built for Kof. Its selection, transformation, process execution and reporting logic belongs in Kof, initially running on the JVM on Linux.

**Development status: M1, M1R, M1P, M2, M3 and the bounded executor in M3P are implemented and validated locally.** `run` supports independent reports, concurrent runs, optional evaluation of up to four mutants, cancellation and recovery on Kof 0.6.4. Performance acceptance for the representative SiFuture scope remains pending. M4 retains the detailed public guides. The `0.1.0` value identifies this development source.

## Requirements

- Linux with Bash 4.4 or later and GNU coreutils (`dirname`, `readlink`, `mktemp`, `mkdir`, `rmdir`, `rm`, `cat`, `sort`, `sha256sum` and `b2sum`), GNU findutils (`find`) and `cmp` from GNU diffutils.
- The official **Kof 0.6.4** Linux distribution on `PATH`, including `lib/kof.jar` and its embedded JDK.
- A writable checkout for `build/cache/` and `.agent/tmp/`, and space for disposable copies in the system temporary directory.
- `setsid` from util-linux, the external `kill` command and procfs mounted at `/proc`. Validation also uses `ps`, `cp`, `ln`, `env` and `which`.

Kof 0.6.5 and other versions are rejected until their frontend contracts are verified. The official Kof launcher also requires `sed` and `head`. The launcher discovers the installation with `kof info --json`; it does not download or update Kof.

If another version is selected on your machine, put the supported installation first on `PATH`:

```bash
export PATH="/path/to/kof-0.6.4-linux-x86_64/bin:$PATH"
kof info --json
```

## Run from source

From the checkout root:

```bash
./bin/kof-mut --version
./bin/kof-mut --help
./scripts/check
```

The version command prints `KofMut 0.1.0`, reading `VERSION`. Both version and help return exit code 0. Unsupported commands or arguments return 2. A version or help command is not a quality evaluation.

The Bash bridge pins the real Kof executable and obtains fresh `info --json` on every invocation. With a warm cache it hashes the launcher inputs and the entire installed jar, then uses `exec` to start the compiled `kofmut.launch.RuntimeEntry`. This Kof entry validates the fresh installation evidence, installation paths and image identity, removes its temporary context, sets the application properties and calls `Default.Main.main` in the same JVM. Version, help and other commands use this path. Arguments, working directory, environment, exit codes and signals reach the application directly. Python is not required. The official Kof 0.6.4 script also starts a short `java -version` probe before the installation query: there are two working JVMs plus this probe, and startup measurements include all three Java executions.

`scripts/bootstrap/Launch.kf` runs through `kof run` only when preparation is needed. It validates the installation, checks the captured input hashes, compiles the captured source bytes with `kof build --target jvm --classpath` and publishes the complete image atomically under a file lock. Both JVM entry points and the application specific generated JSON runtime are compiled together. The published image includes SHA-256 checksums of its generated classes; the launcher verifies them before execution. A second cache check under the lock prevents duplicate compilation. Validation and compilation failures return 2 without falling back to an older image.

The cache uses `build/cache/kof-launch-v2/locations/` for installation descriptors and `build/cache/kof-launch-v2/images/` for compiled programs. The preliminary SHA-256 identity includes the mode, checkout root, pinned Kof path and contents, raw fresh JSON, launchers, VERSION, manifest and relevant source contents, in deterministic order with NUL terminated fields. The final SHA-256 identity also includes a BLAKE2b 512 bit hash of the entire installed jar, computed by GNU `b2sum`. Timestamps do not determine validity. Changes in a future evaluated project do not recompile KofMut.

The former `kofmut-launch-v1` command delivery has been replaced by `kofmut-location-v1`, whose NUL terminated fields carry the validated Java and jar paths. Bash reads these fields without parsing JSON or evaluating command text. Each launch passes five internal arguments (root, pinned Kof, mode, context directory and image directory), followed by the original application arguments. No application arguments pass through the `kof run` option parser. Old Python and `kof-bootstrap-v1` cache entries are ignored.

Missing or inconsistent descriptors and incomplete images trigger automatic preparation. To discard the new cache and recover after an abrupt interruption, run `rm -rf -- build/cache/kof-launch-v2` from the checkout root. This also removes unused staging directories and forces preparation on the next invocation. The cache filesystem must support file locks and atomic directory moves. The initial preparation cost and warm startup comparison are recorded in the [M1P validation report](.agent/validation/kofmut-m1p.md); the warm startup target does not apply to the first build.

Warm startup met the M1P target: Kof median **0.7129 s**, Python median **0.6738 s** (5.81% above Python, within 10%), across 33 alternating pairs with no compilation. Three empty cache starts took 5.05 s, 5.15 s, 5.17 s. See the [M1P report](.agent/validation/kofmut-m1p.md) for dispersion, raw results and conditions. M3 external measurements and their budget limitation are recorded below.

## Run an evaluation

From the checkout root, with Kof 0.6.4 on PATH:

```bash
./bin/kof-mut run --project fixtures/detected \
  --files fixtures/detected/scope.json --report-dir .agent/tmp/reports
# exit 0: one Killed mutation

./bin/kof-mut run --project fixtures/survived \
  --files fixtures/survived/scope.json --report-dir .agent/tmp/reports
# exit 1: one Survived mutation

./bin/kof-mut run --project fixtures/invalid \
  --files fixtures/invalid/scope.json --report-dir .agent/tmp/reports
# exit 3: no_mutants, one discarded candidate with ARITH001

./bin/kof-mut run --project fixtures/equivalent \
  --files fixtures/equivalent/scope.json --report-dir .agent/tmp/reports
# exit 1: one equivalent boundary mutation survives
```

`--project` and `--files` are required. `--report-dir` is optional and defaults to `<project>/.kof-mut/reports`. These three paths are relative to the caller's cwd. The removed `--report` flag returns exit 2 with migration guidance before any output directories or project commands. `--config` is relative to the project and defaults to `kof-mut.json`. `--run-id UUID` is optional; without it, the tool generates a UUID. Unknown flags, incomplete arguments and invalid inputs return 2.

Each invocation prints exactly one discovery line before the first project command:

```text
reportPath="/absolute/reports/<project-id>/<run-id>-<unique-suffix>/report.json"
```

The value after `reportPath=` is a JSON string, so decode it with a JSON parser, including escaped quotes, Unicode and control characters. The project ID is the full hexadecimal SHA-256 of the project's absolute canonical path, independent of Git. Canonical aliases share an ID; projects with the same name at different paths have different IDs. The filesystem exclusively reserves each execution directory, even for concurrent invocations with the same UUID. There is no shared latest report. The final `report.json` is written temporarily and moved atomically on the same filesystem.

Each fixture contains this configuration shape:

```json
{
  "schemaVersion": 1,
  "sourceRoots": ["src"],
  "testRoots": ["tests"],
  "inputs": ["kof.toml", "src", "tests"],
  "checkCommand": ["kof", "check", "src/math/Calc.kf", "--json"],
  "testCommand": ["kof", "test", "tests"],
  "commandTimeoutMs": 10000,
  "budgetMs": 90000,
  "maxParallelMutants": 1
}
```

`maxParallelMutants` is optional. An absent value, JSON `null` or `1` uses serial evaluation. Original JSON integers `2`, `3` and `4` enable that many simultaneous mutant evaluations. Other values, including `1.0`, `1e0`, strings and out of range integers, return exit 2 before project commands. The configuration and report retain `schemaVersion: 1`; the effective limit appears in the human report. There is no new CLI flag or JSON report field.

One complete baseline check and test run must pass before mutant evaluations start. Each evaluation uses its own snapshot copy and logs. A free slot receives the next candidate immediately. Candidates and discarded candidates retain their selection order in the final report; process start and completion order can vary. More simultaneous evaluations increase CPU and memory use. Use `maxParallelMutants: 1` when commands depend on shared external resources such as a database, a fixed port or files outside the sandbox. Independent source copies do not isolate those resources.

`budgetMs` is required and must be an original JSON integer. `budgetMs: 0` disables the global mutation budget; positive integers keep the bounded policy. Missing, `null`, negative, boolean, string, decimal (including `0.0`), exponential and incompatible values return exit 2 before project commands or input changes. `commandTimeoutMs` remains required and must be a positive original JSON integer, including when `budgetMs: 0`.

The planned sensors use two profiles. Stop uses `budgetMs: 85000` internally and external cancellation at 90 seconds from before the complete CLI invocation, including launcher startup. Partial current results and pending work remain visible; a missing or invalid current report is unavailable evidence. Task closure through `check` and `check:task` uses `budgetMs: 0`, without external cancellation at 90 seconds, and evaluates every candidate unless an error prevents continuation. Each command retains its individual timeout. These are future sensor policies; sensor installation is separate.

Closure scope includes every production file in the delivery, including earlier sessions, without the session ledger filter or Stop's 25 file cap. Run again on the final content, using the content staged for the commit when validating before commit. New and renamed files use their final paths; normal checks record and verify deletions. No applicable production scope means no mutation evaluation. `complete/1` provides complete evidence with survivors and fails quality validation; an inconclusive evaluation also fails closure. The fixture configuration above has no external sensor deadline.

Choose a report root outside source/test roots and explicitly copied input paths. The root cannot equal the project root or overlap any protected path. Inputs, configuration, scope files, the manifest and Kof sources are protected against report overwrites, including canonical aliases through symbolic links. If configuration cannot be validated, an error report is published only outside the evaluated project. An internal destination is refused with exit 2 and a terminal explanation, without creating output directories or starting project commands.

Scope is an explicit JSON array such as `["src/math/Calc.kf"]`, without globs. Paths are normalized, deduplicated and sorted. Missing files, tests, extensions other than `.kf`, paths outside `sourceRoots`, project escapes and symbolic links in selected paths are rejected before project commands.

Declare required sources, imports, tests, manifests and scripts in `inputs`, including new untracked files. Commands must check and test the selected scope. `.git`, evidence, the default `.kof-mut/reports` namespace and the selected custom report root inside the project are excluded, including with `inputs: ["."]`. Previous reports in these namespaces never enter later snapshots. Internal input links are materialized only when their targets also belong to inputs; external targets and cycles are rejected. The tool captures inputs before baseline and preserves bytes and script permissions. Each variant receives an independent copy of that snapshot. Command side effects do not enter the next variant. Originals and tests are preserved.

Commands use separate argv entries, sandbox cwd, inherited environment and closed stdin. Each process starts in its own group. With positive `budgetMs`, its deadline is the smaller of `commandTimeoutMs` and the remaining global budget, measured with a monotonic clock from entry to `run`, including preparation and baseline. With `budgetMs: 0`, each baseline and mutant command receives its full `commandTimeoutMs`; an individual timeout with confirmed cleanup allows the remaining candidates to continue. On expiry, the group is terminated and `/proc` is checked for active members; zombies are not active processes. No further command starts after the budget. Sandboxes are removed; separate stdout and stderr logs remain per run in the tool checkout's `.agent/tmp/`. A JVM shutdown hook coordinates command start and registration with cancellation. SIGINT and SIGTERM during an active command return 130 and 143, clean that execution's group and sandbox, and preserve simultaneous runs. External interruption does not promise a partial report. Commands that deliberately leave their process group have no cancellation guarantee in this version.

With concurrent mutants, global expiry closes admission and interrupts all active groups. Interrupted phases are `Timeout`; phases still waiting to start are `Pending` with duration zero. Cancellation signals every owned group before waiting, with a shared cleanup deadline of two seconds. Tasks are joined before sandbox removal and publication. An unexpected task or cleanup failure closes admission and returns `error/2` when a report can be published. Every selected candidate appears exactly once in `mutants` or `discardedCandidates`, including when cancellation also fails. Completed results retain their states, IDs, phases and log references. Candidates never started are `Pending/parse` with duration zero and an interruption reason in `evidence`. Cleanup diagnostics remain explicit; publication follows task collection and the cleanup attempt. Publication failure returns 2 without a usable final report.

## Operators and evidence

The official Kof 0.6.4 lexer and parser select and reparse one token replacement. Families: `boundary` (`< ↔ <=`, `> ↔ >=`), `equality` (`== ↔ !=`), `logical` (`&& ↔ ||`), `boolean` (`true ↔ false`) and `arithmetic` (`+ ↔ -`, `* ↔ /`). Symbols in comments, strings, characters and generic delimiters are excluded. Concatenations recognized from literals, declarations and unambiguous local propagation are also excluded. Arithmetic with an uncertain type is validated by the compiler. Explicit `this.field` resolves the class field independently of parameters and locals with the same name; unqualified identifiers follow lexical scope.

Traversal covers functions, methods, constructors, fields, lambdas, conditionals, loops, switch, try/catch/finally, declarations, calls, assignments, array access and returns. Forms that are not traversed yet, such as `record` declarations, produce explicit limitations that prevent `complete`. Line and column start at 1; offset and length use JVM String UTF-16 indices, not UTF-8 bytes. Compiler rejection and missing evidence never count as a detected mutation.

Check counters must be original JSON integers before typed conversion: `filesChecked` from 1 to 2147483647 and `errorCount` from 0 to 2147483647. Fractional, negative, out of range or incompatible values invalidate the evidence. Baseline requires valid check JSON, coherent exit, `success: true` and zero errors, plus completed Kof suites with executed cases and zero failures. `filesChecked` does not count imports. The `kof test` protocol is interpreted per suite and case, separating filters and SKIP from executed cases. Zero cases, missing summaries, truncated or contradictory output are inconclusive. Wrappers must preserve these 0.6.4 protocols.

| Mutant status | Meaning |
| --- | --- |
| `Killed` | Valid check and completed tests with recognized failure |
| `Survived` | Valid check and completed tests without failures |
| `CompileError` | Legacy status; new runs record coherent compiler rejections in `discardedCandidates` |
| `Timeout` | Deadline terminated check or test, with phase and cleanup recorded |
| `TestError` | Insufficient or invalid evidence, or runner failure |
| `Pending` | Evaluation or a remaining phase did not start because the budget ended or execution stopped on error; the reason is recorded in `evidence` |

For each independent candidate, the tool confirms the original token, applies one replacement, compares the original and modified token streams with the official lexer (accounting for UTF-16 length changes), and reparses with the official parser. Only a candidate that preserves every other token and parses successfully reaches check; only an approved check reaches tests. Lexer/parser rejection, unintended token changes and coherent check rejection are recorded as discarded candidates, with Kof diagnostics and log references. A token comparison failure without a diagnostic uses the fixed message `Variant changes tokens other than the selected token`. Snapshot divergence, unexpected exceptions and infrastructure failures remain tool errors. Invalid or contradictory check evidence remains `TestError` and never authorizes discard.

There is no coverage instrumentation or `NoCoverage` status. Survivors and possible equivalents require human analysis; there is no automatic exclusion or approval percentage.

## JSON v1 report and exits

The UTF-8 JSON is published by atomic rename and contains `schemaVersion`, `toolVersion`, `kofVersion`, `runId`, `status`, `scope`, `baseline`, `counts`, `mutants`, `discardedCandidates`, `limitations`, UTC `startedAt` and `durationMs`. `baseline` contains `status` (`passed`, `failed`, `error`), `check` and `test`, with `exitCode`, `durationMs`, `summary`, `filesChecked`, `executedTests` and `failedTests`; inapplicable values or phases that did not start use JSON null.

`counts` contains nonnegative integers: `candidates`, `executed`, `killed`, `survived`, `compileError`, `timeout`, `testError` and `pending`. Each mutant contains `id`, `file`, `operator`, `original`, `replacement`, `location` (`line`, `column`, `offset`, `length`), `status`, `phase` (`parse`, `check`, `test`), `durationMs` and `evidence`, including log references. `counts.candidates` equals `mutants.length`; `executed` sums every mutant status except `Pending`. `counts.compileError` is retained for compatibility and is zero in new runs. The human report prints the UUID, totals per file, survivor locations and discarded candidates.

`discardedCandidates` is a separate array (empty when none) with `id`, `file`, `operator`, `original`, `replacement`, `location`, `phase` (`parse` or `check`), `durationMs` and `evidence`, using the same formats as mutants. Discards retain their original candidate IDs and distinct logs and do not enter mutant counts. The previous M2 contract emitted `CompileError` and prevented `complete`; the approved correction replaces that behavior while retaining JSON schema version 1.

| Exit | Status and interpretation |
| --- | --- |
| `0` | `complete`, at least one applicable mutant, all `Killed`, no limitations |
| `1` | `complete` with survivors |
| `2` | `error` or `baseline_failed` |
| `3` | `incomplete`, `no_scope` or `no_mutants` |

Expected discards permit `complete/0` with at least one applicable mutant and all `Killed`, or `complete/1` with survivors. If every candidate is discarded, the result is `no_mutants/3`; discards are not evidence of test quality. `Timeout`, `TestError`, `Pending`, budget exhaustion or a limitation prevents `complete`. Consumers must read the path announced by their own invocation and validate `runId`, schema version, scope, counts and exit code. The announcement identifies a reservation; completion requires the final file and consistent contents. Publication failure returns 2 without a usable final report. Previous reports remain intact; a subsequent invocation reserves a fresh directory.

## Validation and next milestones

`./scripts/check` preserves the 21 launcher contracts, runs Kof tests through the real CLI and compiles the frontend assertion program with the installed jar on its classpath. Kof 0.6.4 `test` does not accept `--classpath`; frontend proofs use the official whole program `assert` style without a new test harness.

M3F passed 21 launcher contracts, 44 mutation cycle tests and 15 frontend groups in both the main checkout and a clean copy with spaces and no Python on PATH. All 49 validation inputs match by SHA-256. Tests cover zero and positive budgets, individual deadlines, cancellation, isolation, error evidence and recovery.

The historical M3P.3 result preservation correction passed 21 launcher contracts, 41 mutation cycle tests and 15 frontend groups in both the checkout and a clean copy with spaces and no Python on PATH. All 49 validation inputs match by SHA-256. Regression reports retain every selected candidate when cancellation also fails, including prior kills, a coherent discard and a survivor.

Historical M3P validation at `438c775` passed 21 launcher contracts, 39 mutation cycle tests and 15 frontend groups, including a clean copy with spaces and no Python on PATH. The measurements below describe that revision and do not establish performance of the result preservation correction. SiFuture revision `82111142c85f98b970ccd65fbf044e492d017729` retained all 114 canonical JVM cases. A temporary check adapter detected an error in an imported source. Original content and permissions remained intact.

| SiFuture scope | maxParallelMutants | External seconds | Result |
| --- | --- | --- | --- |
| `Meteor.kf`, three warm runs | 1 | 85.740–85.793 | `incomplete/3`, 16–17 completed candidates |
| `Meteor.kf`, three warm runs | 4 | 85.749–85.834 | `incomplete/3`, 36 completed, four `Timeout`, one `Pending` |
| `Meteor.kf`, empty launcher cache | 4 | 90.365 | External deadline reached, exit 143, no final JSON |
| `Background.kf` | 1 | 10.987 | `complete/0`, one `Killed` |
| `Background.kf` | 4 | 10.688 | `complete/0`, one `Killed` |
| `Background.kf` + `Meteor.kf` | 4 | 85.826 | `incomplete/3`, 35 completed, four `Timeout`, three `Pending` |

These historical measurements retain `commandTimeoutMs: 10000`, `budgetMs: 85000` internally and an external deadline at 90 seconds before the complete CLI invocation. The cold time includes termination after that deadline. Every published Meteor report reconciles 41 candidates; the joint report reconciles 42. Completed candidates are `Killed` or `Survived`. The interrupted cold run has no final report, so its candidate reconciliation is unavailable. Serial interrupted runs are not used to calculate a speedup factor.

The historical performance target for Meteor and joint scope is deferred and unmet. Warm parallel Meteor peaks at 2.24–2.31 GiB sampled summed RSS, compared with 0.68–0.70 GiB serial. RSS includes shared pages and is not exact exclusive physical memory. The full commands cost more per candidate under concurrency; the specific internal cause has not been profiled. Sensors remain inactive and M4 retains detailed public guides. See [the plan](EXECPLAN.md), [M3P evidence, CPU/RSS method and per sample counts](.agent/validation/kofmut-m3p.md), historical [M3 measurements](.agent/validation/kofmut-m3.md), [M2 validation](.agent/validation/kofmut-m2.md), [M1R](.agent/validation/kofmut-m1r.md) and [M1P](.agent/validation/kofmut-m1p.md).

The first complete M3F observation evaluated `Background.kf` + `Meteor.kf` with `commandTimeoutMs: 10000`, `budgetMs: 0` and `maxParallelMutants: 4`, without an external deadline. It took **96.456 seconds** from before the full CLI invocation and returned **complete/1**: 42 evaluated candidates, 29 `Killed`, 13 `Survived`, no discards, `Timeout`, `TestError`, `Pending` or limitations. Baseline ran all 114 canonical cases; the original and disposable project were preserved. This satisfies complete execution and fails quality validation because survivors remain. See the [M3F evidence and findings](.agent/validation/kofmut-m3p.md) and [per candidate results and durations](.agent/validation/kofmut-m3f-candidates.tsv). Further optimization is deferred; the historical Meteor target within 90 seconds remains unmet. Sensors remain inactive.

## License

KofMut uses **GPL-3.0-only**. See [LICENSE](LICENSE) and [NOTICE](NOTICE). The Kof jar and embedded JDK remain in the user's installation and are not bundled in this source checkout.
