[English](README.md) | [Português](README.pt_BR.md)

# KofMut

KofMut is a mutation testing tool being built for Kof. Its selection, transformation, process execution and reporting logic belongs in Kof, initially running on the JVM on Linux.

**Development status: M1, M1R, M1P and the local M2 cycle are implemented.** `run` executes a baseline, isolated mutations and the JSON v1 report on synthetic projects. Broader recovery, concurrent runs and external acceptance on SiFuture belong to M3. The `0.1.0` value identifies this development source.

## Requirements

- Linux with Bash 4.4 or later and GNU coreutils (`dirname`, `readlink`, `mktemp`, `rm`, `cat`, `sort`, `sha256sum` and `b2sum`), GNU findutils (`find`) and `cmp` from GNU diffutils.
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

Warm startup met the M1P target: Kof median **0.7129 s**, Python median **0.6738 s** (5.81% above Python, within 10%), across 33 alternating pairs with no compilation. Three empty cache starts took 5.05 s, 5.15 s, 5.17 s. See the [M1P report](.agent/validation/kofmut-m1p.md) for dispersion, raw results and conditions. The 90 second integration budget remains unproven.

## Run an evaluation

From the checkout root, with Kof 0.6.4 on PATH:

```bash
./bin/kof-mut run --project fixtures/detected \
  --files fixtures/detected/scope.json --report .agent/tmp/detected.json
# exit 0: one Killed mutation

./bin/kof-mut run --project fixtures/survived \
  --files fixtures/survived/scope.json --report .agent/tmp/survived.json
# exit 1: one Survived mutation

./bin/kof-mut run --project fixtures/invalid \
  --files fixtures/invalid/scope.json --report .agent/tmp/invalid.json
# exit 3: one CompileError mutation, ARITH001 diagnostic
```

`--project`, `--files` and `--report` are required and relative to the caller's cwd. `--config` is relative to the project and defaults to `kof-mut.json`. `--run-id UUID` is optional; without it, the tool generates a UUID. Unknown flags, incomplete arguments and invalid inputs return 2.

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
  "budgetMs": 90000
}
```

Choose a report destination outside source/test roots and explicitly copied input paths. Configuration, scope files and Kof sources are protected against report overwrites.

Scope is an explicit JSON array such as `["src/math/Calc.kf"]`, without globs. Paths are normalized, deduplicated and sorted. Missing files, tests, extensions other than `.kf`, paths outside `sourceRoots`, project escapes and symbolic links in selected paths are rejected before project commands.

Declare required sources, imports, tests, manifests and scripts in `inputs`, including new untracked files. Commands must check and test the selected scope. `.git`, mutator reports and evidence are excluded. Internal input links are materialized only when their targets also belong to inputs; external targets and cycles are rejected. The tool captures inputs before baseline and preserves bytes and script permissions. Each variant receives an independent copy of that snapshot. Command side effects do not enter the next variant. Originals and tests are preserved.

Commands use separate argv entries, sandbox cwd, inherited environment and closed stdin. Each process starts in its own group. Its deadline is the smaller of `commandTimeoutMs` and the remaining global budget, measured with a monotonic clock from entry to `run`, including preparation and baseline. On expiry, the group is terminated and `/proc` is checked for active members; zombies are not active processes. No further command starts after the budget. Sandboxes are removed; separate stdout and stderr logs remain per run in the tool checkout's `.agent/tmp/`. Commands that deliberately leave their process group have no cancellation guarantee in this version.

## Operators and evidence

The official Kof 0.6.4 lexer and parser select and reparse one token replacement. Families: `boundary` (`< ↔ <=`, `> ↔ >=`), `equality` (`== ↔ !=`), `logical` (`&& ↔ ||`), `boolean` (`true ↔ false`) and `arithmetic` (`+ ↔ -`, `* ↔ /`). Symbols in comments, strings, characters and generic delimiters are excluded. Concatenations recognized from literals, declarations and unambiguous local propagation are also excluded. Arithmetic with an uncertain type is validated by the compiler.

Traversal covers functions, methods, constructors, fields, lambdas, conditionals, loops, switch, try/catch/finally, declarations, calls, assignments, array access and returns. Forms that are not traversed yet, such as `record` declarations, produce explicit limitations that prevent `complete`. Line and column start at 1; offset and length use JVM String UTF-16 indices, not UTF-8 bytes. Compiler rejection and missing evidence never count as a detected mutation.

Baseline requires valid check JSON, coherent exit, `success: true`, `filesChecked > 0` and zero errors, plus completed Kof suites with executed cases and zero failures. `filesChecked` does not count imports. The `kof test` protocol is interpreted per suite and case, separating filters and SKIP from executed cases. Zero cases, missing summaries, truncated or contradictory output are inconclusive. Wrappers must preserve these 0.6.4 protocols.

| Mutant status | Meaning |
| --- | --- |
| `Killed` | Valid check and completed tests with recognized failure |
| `Survived` | Valid check and completed tests without failures |
| `CompileError` | Compiler rejected the variant with a diagnostic |
| `Timeout` | Deadline terminated check or test, with phase and cleanup recorded |
| `TestError` | Insufficient or invalid evidence, or runner failure |
| `Pending` | Evaluation or a remaining phase did not start because the budget ended |

There is no coverage instrumentation or `NoCoverage` status. Survivors and possible equivalents require human analysis; there is no automatic exclusion or approval percentage.

## JSON v1 report and exits

The UTF-8 JSON is published by atomic rename and contains `schemaVersion`, `toolVersion`, `kofVersion`, `runId`, `status`, `scope`, `baseline`, `counts`, `mutants`, `limitations`, UTC `startedAt` and `durationMs`. `baseline` contains `status` (`passed`, `failed`, `error`), `check` and `test`, with `exitCode`, `durationMs`, `summary`, `filesChecked`, `executedTests` and `failedTests`; inapplicable values or phases that did not start use JSON null.

`counts` contains nonnegative integers: `candidates`, `executed`, `killed`, `survived`, `compileError`, `timeout`, `testError` and `pending`. Each mutant contains `id`, `file`, `operator`, `original`, `replacement`, `location` (`line`, `column`, `offset`, `length`), `status`, `phase` (`parse`, `check`, `test`), `durationMs` and `evidence`, including log references. Candidates and statuses reconcile; `executed` sums every status except `Pending`. The human report prints the UUID, totals per file and survivor locations.

| Exit | Status and interpretation |
| --- | --- |
| `0` | `complete`, at least one candidate, all `Killed`, no limitations |
| `1` | `complete` with survivors |
| `2` | `error` or `baseline_failed` |
| `3` | `incomplete`, `no_scope` or `no_mutants` |

`CompileError`, `Timeout`, `TestError`, `Pending` or a limitation prevents `complete`. A previous report is never read as the current result; use `--run-id` to verify an automated evaluation's identity. Publication failure returns 2 and must be treated as an error even if an old report remains at the destination.

## Validation and next milestones

`./scripts/check` preserves the 21 launcher contracts, runs Kof tests through the real CLI and compiles the frontend assertion program with the installed jar on its classpath. Kof 0.6.4 `test` does not accept `--classpath`; frontend proofs use the official whole program `assert` style without a new test harness.

M3 expands concurrency and recovery and measures external acceptance on SiFuture within the same 90 seconds. M2 synthetic results do not establish that cost. M4 completes the detailed public guides. See [the plan](EXECPLAN.md), [M2 validation](.agent/validation/kofmut-m2.md) and the historical [M1R](.agent/validation/kofmut-m1r.md) and [M1P](.agent/validation/kofmut-m1p.md) reports.

## License

KofMut uses **GPL-3.0-only**. See [LICENSE](LICENSE) and [NOTICE](NOTICE). The Kof jar and embedded JDK remain in the user's installation and are not bundled in this source checkout.
