[English](cli.md) | [Português](cli.pt_BR.md) | [KofMut](../README.md)

# CLI guide

Use the [requirements and four runnable examples](../README.md#requirements) first. This guide is the reference for invocation, project configuration, isolation and recovery. For result vocabulary read [operators](operators.md); for integration use [JSON v1](report-format.md).

## Commands and paths

From the KofMut checkout:

```bash
./bin/kof-mut --version
./bin/kof-mut --help
./bin/kof-mut run --project "my project" --files "my project/scope.json" \
  --config kof-mut.json --report-dir "mutation reports" \
  --run-id d7df680d-2304-43a3-9741-4b0ebd61686e
```

The last command illustrates paths for your own configured project. The ready to run [fixtures](../README.md#run-an-evaluation) return 0, 1, 3 and 1 for `detected`, `survived`, `invalid` and `equivalent` respectively. Capture the exit of each invocation even when it is nonzero; with `set -e`, put `run` in a conditional when you need to inspect its result.

| Command or option | Contract |
| --- | --- |
| `--version` | Print `KofMut <VERSION>` and return 0; current source is `0.1.0` |
| No arguments, `--help` or `-h` | Print usage and return 0; not an evaluation |
| `run` | Evaluate explicit production scope using the project's configured commands |
| `--project PATH` | Required; project root, resolved canonically from caller cwd |
| `--files JSON` | Required; scope JSON file, resolved from caller cwd |
| `--config JSON` | Optional; default `kof-mut.json`, relative to project unless absolute |
| `--report-dir DIRECTORY` | Optional; default `<project>/.kof-mut/reports`, otherwise relative to caller cwd |
| `--run-id UUID` | Optional; UUID string in `8-4-4-4-12` hexadecimal form; generated when omitted |

Flags take separate arguments. Unknown commands or flags, repeated flags, missing values, empty values and invalid inputs return 2. `run --help` is not a supported command. Quote paths containing spaces. Scope paths themselves are relative to the project, regardless of caller cwd. The whole selected file is evaluated, not only changed lines; KofMut does not use Git to choose files.

## Local installation and management

Run the installer from a writable checkout with your Linux/JVM Kof distribution selected on PATH:

```bash
./install.sh
./install.sh --prefix "$HOME/tools/kofmut"
./install.sh --help
```

Choose either the default installation or the custom prefix example. The default prefix is `$HOME/.local`; a relative `--prefix PATH` is resolved from the caller's cwd. No `sudo`, downloads or Kof updates are performed. Empty or repeated arguments, unknown flags, paths overlapping this checkout and prefixes containing the JVM classpath separator `:` return 2 before changing an existing installation. Existing foreign commands, symbolic links in managed directories and invalid ownership metadata are refused. Shell profiles are preserved. If `bin` is absent from PATH, the installer prints the executable's location; for the default prefix use `export PATH="$HOME/.local/bin:$PATH"`.

When `--prefix` is omitted, HOME must be present, nonempty and absolute before the default path is constructed. Absent, empty or relative HOME returns 2 with `HOME must be a non-empty absolute path when --prefix is omitted`, without installing into cwd or a fallback location. An explicit `--prefix PATH` uses that path independently of HOME, including paths relative to cwd. `./install.sh --help` returns 0 even with invalid HOME and does not install anything.

| Path relative to the prefix | Contents |
| --- | --- |
| `bin/kof-mut` | Managed public command |
| `share/kof-mut/current` | Atomic reference to the active release |
| `share/kof-mut/releases/<id>` | Compiled classes, generated runtime, runtime sources, bootstrap, VERSION, public documentation, LICENSE, NOTICE and image metadata |
| `state/kof-mut/compatibility/` | Generated images and approvals, bootstrap, locks and preparation evidence |
| `state/kof-mut/owner.json` | Ownership inventory for published releases |
| `state/kof-mut/manage.lock`, `state/kof-mut/usage.lock` | Persistent coordination files |
| `state/kof-mut/logs/run-<runId>-<unique-suffix>` | Installed evaluation logs |

The payload includes `src/main/kof/` and the scripts needed for recompilation, without development tests, Git metadata, checkout cache, history, Kof jar or JDK. Operational compatibility checks are part of runtime sources. Historical links in the copied README refer to checkout files. The package can be read only; preparation uses `state/kof-mut/compatibility/`, evaluation logs use state and reports obey `--report-dir`. Before the first state write, a preflight refuses overlap with evaluated inputs.

The current internal receipt has `schemaVersion: 2`: `buildDependency` records the Kof/Java version and paths/contents used to build the package; `runtimeSources` lists relative paths and SHA-256 hashes for sources and scripts needed for recompilation; `files` inventories the package. `buildDependency` is build provenance and does not need to remain installed. Legacy receipts with `schemaVersion: 1`, `dependency` and `files` remain recognized for ownership, updates and uninstall; they are not rewritten. Perform one initial update with `./install.sh` in the same prefix to enable automatic Kof adoption. After that, selecting another compatible Kof on PATH requires neither the checkout, a KofMut reinstall nor the old Kof installation. `prefix`, `id`, `inputs` and `files` retain their meanings. `runtimeSources` and `files` are arrays of `{ "path": "relative/path", "hash": "<SHA-256>" }` objects. `buildDependency` retains the former `dependency` shape: `version`, `javaVersion`, `kof`, `java`, `jar` and `contents`; `contents` contains `{path, hash}` objects naming absolute build dependency paths.

Reinstall from an updated checkout using the same prefix to update. Sources, installer, documentation and the build dependency determine package identity. A healthy matching image, including one created by repair, is reused. Stable changes only to documentation or `install.sh` reuse compiled application classes while producing the matching package. Preparation occurs on the destination filesystem and runs real version/help probes before atomic activation. Installers serialize publication. Failed or interrupted preparation leaves the previous active image usable; INT/TERM stop installer children and return 130/143, including cancellation during child startup. Each invocation resolves its concrete release at startup, and previous images remain available while older invocations finish. The filesystem must support file locks and atomic moves. Each evaluation binds the concrete Kof paths selected at startup; future evaluations may adopt another Kof. To relocate the application, install into a fresh prefix; existing receipts continue to name their original prefix.

The installer captures the participating input paths and content hashes before preparing the application. Copied VERSION, launcher, license, notices and documentation must match those inputs and the selected compilation. After image probes, it checks the complete input file set and contents again before publishing, registering ownership or activating. Detected changes return 2 with `checkout changed during installation; retry`, preserving the previous active release and ownership receipt. This includes added/removed sources or documents and changed bytes with unchanged timestamps. Stabilize the checkout and retry. No checkout components are read again to compose the prepared image after the final check.

To repair damaged application files, rerun `./install.sh` with the same prefix and compatible Kof. Repair publishes a complete image while retaining the damaged version; modified files are preserved at uninstall. Reinstallation can use a new identifier when an unowned directory occupies an image path. Missing coordination files, corrupt ownership receipts or foreign commands do not authorize repair by overwriting them: keep them for inspection and install into a fresh prefix. Abrupt termination can leave unactivated preparation or unregistered directories; these are never used as an active image or deleted merely because of their names.

```bash
kof-mut uninstall
```

Only the installed entry offers `uninstall`; source execution retains its original commands. Help, `-h` and no arguments describe installed management. Uninstall takes exclusive access and returns 2 without removal if an installed invocation or installation management is active. Updates are permitted while evaluations run. Successful uninstall returns 0 and removes only entries whose ownership is established and unchanged files listed in their image inventories. It preserves projects, configurations, reports, logs, Kof, unknown files and directories, and modified application files. The state directory and coordination files remain so concurrent operations cannot acquire different lock inodes. An interrupted or invalid management operation must not be treated as successful uninstall.

## Migrate from `--report`

The former `--report FILE` option has been removed. It returns 2 with `--report was removed; use --report-dir DIRECTORY` before creating report directories or running project commands.

Use `--report-dir DIRECTORY` for a report root, then decode the current invocation's `reportPath=` JSON string. Do not replace it with a hardcoded `DIRECTORY/report.json`: each run reserves its own subdirectory. A filename previously supplied to `--report` is not a report root to reuse blindly. See [discovery and publication](report-format.md#discover-the-current-report).

## Configure a project

The `fixtures/detected/kof-mut.json` layout is a concrete starting point, with the optional parallel limit shown explicitly:

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

Adapt paths and commands to your project. There are no implied defaults for required configuration fields.

| Field | Type and meaning |
| --- | --- |
| `schemaVersion` | Required original JSON integer `1` |
| `sourceRoots` | Required nonempty array of relative production directory paths |
| `testRoots` | Required nonempty array of relative test directory paths; files under them cannot be selected |
| `inputs` | Required nonempty array of relative file/directory paths to copy, including everything commands need |
| `checkCommand` | Required nonempty string array, executable followed by separate argv entries; must emit the official `kof check --json` protocol |
| `testCommand` | Required nonempty string array; must emit the supported named `kof test` suite protocol |
| `commandTimeoutMs` | Required original JSON integer, `1..9223372036854775807`; timeout for each command |
| `budgetMs` | Required original JSON integer, `0..9223372036854775807`; zero removes the global mutation budget |
| `maxParallelMutants` | Optional original JSON integer `1..4`; omitted or JSON `null` means `1` |

Numbers must retain integer form before typed decoding. Decimals (including `0.0` and `1.0`), exponentials such as `1e0`, strings, booleans, overflowing integers and incompatible types are invalid. Missing/null `budgetMs`, negative budgets and missing/null/nonpositive `commandTimeoutMs` return 2 before project commands or changes to inputs. The optional null exception applies only to `maxParallelMutants`. Configuration and report both remain `schemaVersion: 1`.

Commands run as argv with sandbox cwd, inherited environment and closed stdin. KofMut does not insert a target or join arguments into a shell command. Declare every script and dependency needed inside the copy in `inputs`, including new untracked sources and imports. Commands must check and test the selected scope. The JVM is KofMut's runtime; the evaluated project uses the target selected by its own commands.

Exit 0 alone is insufficient evidence. Baseline check needs valid/coherent JSON, `success: true`, zero errors and exit 0; baseline tests need completed suites, executed cases and zero failures. Check counters must be original integers: `filesChecked` in `1..2147483647` and `errorCount` in `0..2147483647`; `filesChecked` counts entry files, not imports. A coherent rejection has `success: false`, exit 1 and a positive error count matching ERROR diagnostics. Wrappers must preserve these protocols. Zero tests, SKIP without executed cases, missing summaries, truncation and contradictory output never approve a baseline or kill a mutant. See [baseline fields and states](report-format.md#baseline-and-phase-evidence).

## Select scope and inputs

A scope file such as `fixtures/detected/scope.json` contains:

```json
["src/math/Calc.kf"]
```

Entries have no globs. Paths are normalized, deduplicated and sorted. Every entry must exist, end in `.kf`, be under `sourceRoots`, outside `testRoots` and included in `inputs`. Absolute paths, project escapes, selected symbolic links or links in selected path components are rejected before project commands. An empty array produces `no_scope/3` without baseline commands or quality approval.

Input capture preserves bytes, relative paths and script permissions before baseline. Internal input links are materialized only when their targets also belong to inputs; external targets and cycles are rejected. `.git`, `.agent/tmp`, `build/cache/kof-launch-v2`, `build/cache/compatibility`, default `.kof-mut/reports` and the chosen custom report root inside the project are excluded, including with `inputs: ["."]`. Earlier reports do not enter later snapshots.

Choose a report root outside production/test roots and explicit inputs. It cannot equal the project root or overlap protected sources, tests, manifest, config or scope, including canonical aliases through links. With `inputs: ["."]`, a safe internal report namespace is excluded from the copy. If config cannot be validated, only an external safe destination can receive an error report; an internal destination returns 2 with a terminal explanation and no created report directories or project commands.

## Evaluation and isolation

One complete baseline check and test precedes candidate selection. A failed or invalid baseline blocks mutant commands. Every candidate starts from an independent copy of the same captured input snapshot; a previous command's source changes or side effects inside its copy cannot enter the next variant. Tests are copied and never mutated. Sandboxes are removed before final publication.

Copies isolate files, not external resources. Commands inherit credentials and environment like any local invocation. Databases, fixed ports and paths outside the sandbox remain shared when the project commands use them. Use `maxParallelMutants: 1` for such dependencies.

With limits `2`, `3` or `4`, baseline still runs once. A free slot immediately receives the next candidate. Final mutants and discards preserve selection order within each array; command start/completion order can vary. Parallel evaluation consumes more CPU and memory. The effective limit appears as `maxParallelMutants=N` in human output; JSON v1 has no parallel limit field.

## Timeouts and cancellation

For `budgetMs > 0`, the global monotonic budget starts at entry to `run` and includes input capture, baseline and mutant work. It does not include launcher startup before application entry. Each command receives the smaller of `commandTimeoutMs` and the remaining global budget. On expiry, admission closes and active groups are interrupted; no later command starts. Interrupted phases become `Timeout`; work whose next phase never started becomes `Pending` with duration zero.

For `budgetMs: 0`, there is no global budget. Every baseline/mutant command still has its positive individual timeout. A command timeout with confirmed cleanup allows remaining candidates to continue; that run is inconclusive. Zero does not mean infinite command time or quality approval.

Each command starts with `setsid` in its own process group. Cleanup signals owned groups and checks `/proc` for active members; zombies are not active. Cancellation signals all groups before waiting with a shared cleanup deadline of two seconds, joins tasks, then removes sandboxes. An unexpected task or cleanup failure closes admission and produces `error/2` when publishable. Completed states, IDs and evidence are retained, and unstarted candidates become `Pending/parse` with the error reason. Cleanup failure remains explicit; it is not confirmed termination.

SIGINT/SIGTERM during an active command return 130/143 and clean that invocation's groups/sandbox while preserving concurrent invocations. External interruption does not promise a partial report. Commands that deliberately leave their process group have no cancellation guarantee in this version.

## Reports and logs

The [report reference](report-format.md#discover-the-current-report) defines exclusive reservation, canonical project identity, current `reportPath`, atomic publication and validation. Publication failure returns 2 without a usable final report. Never fall back to a previous report.

In source mode, separate stdout/stderr command logs remain under the KofMut checkout's `.agent/tmp/run-<runId>-<unique-suffix>/`. Installed mode uses `<prefix>/state/kof-mut/logs/run-<runId>-<unique-suffix>/` and refuses overlap with project inputs before writing. They are referenced in baseline `summary` and mutant/discard `evidence`. Parse rejection can add `<index>-parse.log`; command logs use `baseline-check`, `baseline-test`, `<index>-check` and `<index>-test` prefixes with `.stdout`/`.stderr`. Indices retain original selection positions after discards. These paths are local evidence, not a portable embedded log archive. Preserve referenced logs when moving reports for review.

## Launcher and cache

Each invocation resolves the real `kof` executable on PATH and queries `kof info --json`. The bootstrap requires a Linux distribution with its embedded JDK and coherent declared component versions, without downloading or updating dependencies. Help, `-h`, no arguments and `--version` do not prepare compatibility or compile the engine. If necessary, the launcher compiles only a minimal bootstrap. Calls with a valid bootstrap use Java directly, without indirect compilation through `kof run`.

Before the first evaluation with a new combination, KofMut captures the contents of the executable, jar, Java, JDK components and KofMut sources/checks. It compiles a candidate, checks official lexer/parser contracts, positions and operators, and evaluates synthetic projects with killed and surviving mutants. Verification requires coherent reports and compilation/test evidence. Contents are checked again before atomic approval publication. Declared version, path and timestamps are insufficient. The public report remains `schemaVersion: 1`; `kofVersion` identifies the frontend actually used.

Preparation writes only to stderr:

```text
kof-mut: Kof <version> detected; preparing application...
kof-mut: checking compatibility...
kof-mut: ready; starting evaluation.
```

A prepared `run` uses one KofMut work JVM for installed preflight, full content and approval validation, and evaluation. Official Kof discovery and the configured check/test processes remain separate. An internal `kofmut-prepared-v1` index is a candidate location, never proof of compatibility: the launcher checks paths and the entire class inventory before loading it, and the JVM repeats full fingerprints and approval validation. Missing, malformed or stale generated candidates use normal preparation with the same captured Kof and original deadline. Each invocation still runs its own baseline and mutants in independent copies.

A call reusing valid approval repeats none of those messages, compilation or behavioral checks. The stdout protocol and `reportPath` stay unchanged. Configured commands retain their arguments, cwd and environment; an executable configured literally as `kof` uses the concrete path selected for that invocation. Explicitly configured scripts and executables keep their own dependency resolution. Updating a PATH link does not switch an active evaluation’s frontend. Keep that concrete runtime installation available and unchanged until its active calls finish.

Preparation has 90 seconds total, including waiting for another preparation, up to 10 seconds per command and two shared seconds for process termination. It ends at the private launcher confirmation after validation, before the engine starts its own `budgetMs`. A confirmed evaluation with `budgetMs: 0` can run longer than 90 seconds; its individual command timeouts still apply. Failure, invalid protocol or changing components discards the candidate and returns 2 before project commands, with version, stage, cause and evidence path. INT/TERM return 130/143 and prevent late approval. Correct the cause and retry; no manual cleanup is required and there is no fallback to an earlier Kof. Unknown syntax in the evaluated project remains an explicit limitation and incomplete/3 result.

In a checkout, `build/cache/kof-launch-v2/` contains the bootstrap and `build/cache/compatibility/` contains `images/`, `approved/` references, `prepared/` candidate indexes and `locks/`. Preparation evidence stays in `.agent/tmp/m6/<UUID>/`. In an installation, all generated components stay under `state/kof-mut/compatibility/`, with evidence in `logs/<UUID>/`. The installed package stays unchanged. Identities use SHA-256 content; the minimal cache also uses BLAKE2b of the entire jar. Approval includes generated class hashes. Selected images keep unique paths; rebuilding publishes another reference without moving classes used by active evaluations.

Symbolic links in managed state are refused, including existing or broken links in bootstrap locations, generated images/classes, approval references, prepared indexes, locks and logs. The launcher checks path components before consulting executable caches; preflight and preparation repeat the checks before using state. This also applies when a link points to an evaluated project outside the installation prefix. Refusal returns 2, names the symbolic link on stderr and retains `launch-failure` or the preparation diagnostic in the reported private temporary evidence directory. It does not follow, replace or delete the link.

To recover, wait for active invocations to finish, inspect the named path and remove only the invalid symbolic link with `unlink -- PATH`. Preserve its target, installed package, receipts, healthy cache entries and logs. Repeat the original command: missing generated directories are recreated and existing healthy approvals are reused. Reinstallation or wholesale cache removal is unnecessary for this condition. Do not replace a link with a directory until you have checked what the path represents; missing ownership or coordination files still require the separate management recovery described above.

Damaged generated cache rebuilds automatically. Damaged installed sources or package files require repair with `./install.sh --prefix PATH`; they are not accepted as new runtime sources. Updates and uninstall preserve reports, logs and unknown or modified files. Before manually removing generated caches, wait for all invocations to finish and remove only generated images, approval references, prepared indexes and bootstrap, preserving logs. The filesystem must support locks and atomic moves. Installed invocations hold a shared flock lease throughout preparation and evaluation. Prepared calls also hold one continuous shared JVM lease during validation, confirmation and evaluation; JVM file locks continue to protect legacy executions. Uninstall requires both exclusive leases.

The [M6O validation](../.agent/validation/kofmut-m6o.md) records paired empty-scope and complete-round measurements, process counts, actual versions and limitations. Fewer internal JVMs do not promise the same reduction in total test time.

The [M6R validation](../.agent/validation/kofmut-m6r.md) records the symbolic link regression, recovery checks and startup cost diagnosis. The repair adds preservation checks; it makes no speedup promise.

[M6 evidence](../.agent/validation/kofmut-m6.md) records actually verified versions and initial/warm costs. This milestone sets no numeric performance regression threshold. [M1P measurements](../.agent/validation/kofmut-m1p.md) are historical; the [earlier 90 second target](../README.md#validation-and-next-milestones) remains deferred and unmet. Sensors remain future work.
