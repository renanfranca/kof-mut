# M6R: state preservation and startup diagnosis

Status: M6R.1–3 complete, criteria C1–C6 accepted. Historical M6 C7/final acceptance were reopened and are now revalidated by this correction and its own evidence. Earlier evidence is unchanged.

Base: `03bc7c003524d3c0123be5ebd1d543b5df295a99`, existing branch `kofmut-frontend`. Artifacts below are relative to `.agent/tmp/m6r/` (E). No commits, worktrees, subagents, remotes, publications, Kof changes or downloads are authorized or performed. All evaluated projects are synthetic disposable copies.

## Initial observed evidence

`PATH=<real 0.6.6>/bin:$PATH kof test src/test/kof/kofmut/Install.kf --tag state-preservation`: `red.log`, exit 1, 25825 ms. Unchanged production base follows `compatibility -> external evaluated project/src`, completes no_scope instead of refusing, and changes the full project inventory. The assertion compares types, paths, empty directories, link text, permissions and SHA-256 of every regular file. Existing package/receipt checks are separate.

The same command in ordinary `git archive 03bc7c0` extraction `base-red/`, with new behavioral tests only: `red-warm.log`, exit 1, 61050 ms. The cold test fails preservation; the warm journey successfully primes approval but then follows the bootstrap link and reaches baseline commands, returning baseline_failed instead of a path-specific symbolic-link refusal. This is the expected missing protection, not a failed initial baseline.

After protection: `green-cold-2.log`, exit 0, 8889 ms; `green-nested.log`, exit 0, 56685 ms. Both initial journeys pass, including sixteen warm locations, broken link, command canary, unchanged project/prefix/report inventories, readonly package, removed checkout and two successful real detected evaluations with compilation refused and quiet approval reuse. These were initial checkpoints; the strengthened final matrix and broad results are recorded below.

## Boundaries and test audit

The shell refuses links before reading bootstrap location descriptors or loading cached executable classes. The independent source bootstrap checks cache trees before creating state and before deleting incomplete images/temporary trees. The coordinator checks before evidence creation, approval lookup, lease use and application entry, and before candidate deletion. Installed preflight checks real destinations for every run, including projects outside the installation prefix. Safe temporary contexts retain `launch-failure` or the actual preparation diagnostic, path and cause on stderr; links and targets are untouched.

Recursive checks cover existing generated cache/log descendants conservatively. These checks do not claim atomic protection against hostile concurrent path replacement after validation. Manual recovery requires waiting for invocations and preserving trusted ownership of state; no new concurrency guarantee or public profiling interface is introduced.

Local Kof research used `training/README.md`, `training/idioms/interop.md`, `training/language/io.md`, compiler `KofIo.java` and `IoRealPathE2ETest.java`; the latter explicitly verifies canonical confinement across links. The selected installed distribution supplies actual lexer/parser/compiler/runtime behavior. The new guards use existing JVM filesystem interop because historical stdlib surfaces are not assumed from the current checkout.


## Validated correction and regression matrix

All commands below ran in disposable copies with spaces and a curated PATH containing the selected real Kof, required Linux tools and no Python. Python orchestrates outside that child PATH; it is not a product dependency.

| Command / result | Kof 0.6.4 | Kof 0.6.6 |
| --- | --- | --- |
| `kof test src/test/kof/kofmut/Install.kf --tag state-preservation` | exit 0; 3 tests; 95.802 monotonic s | exit 0; 3 tests; 113.534 monotonic s |
| `kof test src/test/kof/kofmut/Install.kf --tag compatibility` | exit 0; 7 tests; 186.318 monotonic s | exit 0; 7 tests; 217.160 monotonic s |
| `./scripts/check` | exit 0; 29/44/27/15 | exit 0; 29/44/27/15 |
| Complete check duration, monotonic / wall | 2403.156 / 2671.965 s | 2363.203 / 2628.436 s |
| Frozen source inputs | 76 unchanged files, bytes/modes | 76 unchanged files, bytes/modes |
| Readonly installed examples, removed checkout | 0/1/3/1; JSON v1 and actual frontend | 0/1/3/1; JSON v1 and actual frontend |
| Independent JVM preflight/coordinator | exit 2, path/cause, preserved inventories | exit 2, path/cause, preserved inventories |
| Uninstall after restoring owner write mode | exit 0, generated state/targets retained | exit 0, generated state/targets retained |

Command artifacts: `state-preservation-<version>.*`, `compatibility-<version>.*`, `check-<version>.*`, `inputs-<version>.json`, `validated-<version>.json`, `installed-acceptance-<version>.json`, `extra-<fixture>-<version>.*`, `direct-preflight/coordinator-<version>.*`, `direct-source-bootstrap.*`. Per-command result JSON records exact argv, cwd, exit and both clocks. Matrix dispatch was split into independent version runners; the original dispatcher subsequently encountered the already-created 0.6.6 directory after recording successful 0.6.4 acceptance. That setup collision is not a product/check failure; both actual `./scripts/check` result records are exit 0.

The final production/test bytes match both complete checkpoints. The subsequent documentation-only delta adds one M6R evidence-link paragraph to each CLI guide. Final installed examples include those guide bytes. `documentation-audit.json` verifies unchanged headings, working local links, diagnostic and recovery text in EN/PT. `expectations-audit.json` separately reviews behavioral observations and assertion strength; new tests live in the existing installed public CLI suite, with no tests tied to helper topology.

The warm matrix covers 22 locations: compatibility root; bootstrap root/locations/descriptor/images/identity/build.lock; engine images/class/approval.json; approved directory/reference; locks directory/file; preparation and application log directories/files; broken log link; owner.json/usage.lock/manage.lock. Valid configurations, nonempty scope and touch canaries prevent accidental invalid configuration from standing in for refusal. Full prefix/project/report inventories and explicit link target assertions enforce no publication, no project command and no target damage. Early evidence contains the actual path/cause outside rejected state. Cold unlink-only recovery detects one mutant, reports complete/JSON v1/actual kofVersion and silently reuses healthy approval with run/build refused. The existing source compatibility journey and final benchmark independently check all three preparation progress messages are absent on warm reuse.

Independent raw cold inventories:

- `base`: 12 → 259 entries, 247 added, exit 3.
- `new`: 12 → 12 entries, 0 added, exit 2.

The base creates generated state through the external project/src link. The corrected tree has exact before/after equality, retains the link and package, and creates no report. `raw-cold-summary.json` names every added entry; before/after JSON includes directories, links and target text, regular-file SHA-256, permissions and types. All fixtures are disposable and synthetic.


## Recurring cost: uninstrumented benchmark

Base `03bc7c003524d3c0123be5ebd1d543b5df295a99` versus the corrected runtime/test tree on the same host with concrete Kof 0.6.6 fixed on PATH. All suites and installed/direct-boundary validations stopped before measurement; setup explicitly rejects leftover validation JVMs. Linux/WSL2 kernel 6.18.54.1, Intel Core i9-14900HX, 32 logical CPUs; embedded Eclipse Adoptium JDK 25.0.4.1. `performance/environment.json` stores full CPU/OS/load/installation evidence and SHA-256 of the selected executable, jar, Java and libjvm. `performance/sources.json` identifies both measured source trees; the new runtime bytes match the delivered production files.

Three blocks of eleven adjacent alternating base/fix pairs per case, 33 samples per variant/case and 264 total. Both clocks are retained. p95 is nearest rank `ceil(0.95 * 33)` (rank 32). No sample was dropped and no regression threshold was imposed. Every version call returns 0 with the exact version line; every empty-scope call returns 3/no_scope, JSON v1, actual kofVersion 0.6.6 and zero candidates. Every warm call omits all three preparation messages. Raw data and harness: `performance/samples.jsonl`, `summary.json`, `wall-summary.json`, `setup.json`, `environment.json`; `prepare-benchmark.py` and `benchmark.py`.

Monotonic milliseconds:

| Invocation | Base median | Fix median | Base p95 | Fix p95 | Median delta |
| --- | ---: | ---: | ---: | ---: | ---: |
| Checkout / --version | 689.1 | 709.8 | 708.5 | 729.7 | +20.7 ms / +3.0% |
| Checkout / empty scope | 1516.0 | 1545.1 | 1556.3 | 1583.7 | +29.1 ms / +1.9% |
| Installed / --version | 1677.2 | 1743.2 | 1696.1 | 1764.6 | +66.0 ms / +3.9% |
| Installed / empty scope | 2042.1 | 2127.4 | 2067.8 | 2155.1 | +85.3 ms / +4.2% |

The correction adds preservation work; these observations do not promise acceleration. The absolute recurring costs remain substantial relative to the extra 21–85 ms introduced here.

Wall milliseconds, from the same retained samples:

| Invocation | Base median | Fix median | Base p95 | Fix p95 |
| --- | ---: | ---: | ---: | ---: |
| Checkout / --version | 689.1 | 709.8 | 708.5 | 729.7 |
| Checkout / empty scope | 1521.0 | 1545.1 | 5101.3 | 1583.7 |
| Installed / --version | 1677.2 | 1743.9 | 1696.1 | 5330.0 |
| Installed / empty scope | 2045.2 | 2129.0 | 5612.7 | 5727.3 |

In 12/264 calls wall elapsed exceeds monotonic elapsed by 3581.4–3600.5 ms. Their cause is not isolated. Wall p95 is retained, not replaced or attributed to application work. No host clock/scheduling explanation is asserted.

### Initial preparation, separate from warm samples

These are single observations per case, not percentile estimates. Cold means that the app-mode bootstrap/engine approval has not yet been prepared in these disposable snapshots; installation-mode caches and OS filesystem caches may already exist. The first empty-scope call follows the initial version call, so its minimal bootstrap is already prepared. Installer durations are separately retained as `performance/base/new-install.result.json`.

| Initial invocation | Base monotonic s | Fix monotonic s | Base wall s | Fix wall s |
| --- | ---: | ---: | ---: | ---: |
| Checkout / --version | 4.876 | 5.093 | 4.876 | 5.093 |
| Checkout / empty scope | 12.298 | 12.319 | 15.884 | 12.319 |
| Installed / --version | 6.347 | 6.415 | 9.930 | 6.415 |
| Installed / empty scope | 13.263 | 13.353 | 13.263 | 16.937 |

Externally observed progress splits the fix's first empty call into capture before detected, candidate copy/compile, behavioral checks plus final identity/publication, and application handoff/evaluation:

| Location | Before detected | Candidate copy/compile | Checks/final integrity/publication | Handoff/evaluation |
| --- | ---: | ---: | ---: | ---: |
| source | 0.753 s | 2.236 s | 8.575 s | 0.755 s |
| installed | 1.303 s | 2.339 s | 8.927 s | 0.784 s |

These are progress-to-progress elapsed intervals, not pure compiler or CPU time. `performance/initial.json` retains timestamps/events and both clocks; initial stdout/stderr files retain actual messages.

## Separate tracing and temporary timers

`trace-diagnosis.py` traces eight unmodified warm cases after the benchmark, then builds independent disposable instrumented copies. It records three untraced timed calls per variant/case (24 calls) after separate warmups, plus eight correlated instrumented traces. Product sources contain none of `M6R_TIMER`, `M6R_HASH` or `M6R_SHELL`; no public profiling flag/property was added.

`strace -f -ttt -T -e trace=process` proves the process structure in all 16 traces:

| Warm invocation | Java processes, base and fix | Roles |
| --- | ---: | --- |
| Checkout --version | 3 | Kof launcher's Java version probe, Kof info, compatibility coordinator |
| Checkout empty scope | 4 | Those three plus application JVM |
| Installed --version | 5 | Version probe, info, installed preflight, coordinator, application JVM |
| Installed empty scope | 5 | Same five roles |

No warm engine compilation appears in these traces. Process lifetimes include their actual work and tracing overhead; they are not treated as JVM startup times. Tracing visibly perturbs elapsed time. The untraced temporary timers provide phase observations independently of the 264 benchmark samples.

Median internal monotonic intervals from three untraced timed calls per cell, in milliseconds:

| Phase | Checkout base → fix, empty scope | Installed base → fix, empty scope |
| --- | ---: | ---: |
| Coordinator entry → application handoff | 512.7 → 537.4 | 537.1 → 562.7 |
| Full input inventory/fingerprints | 385.0 → 388.3 | 346.6 → 330.5 |
| JDK read/digest calls, aggregate | 231.0 → 241.6 | 203.3 → 196.4 |
| Kof jar read/digest call | 126.2 → 127.4 | 126.8 → 116.3 |
| Approval reference lookup → approval validation entry | 0.50 → 0.47 | 0.23 → 0.20 |
| Approval JSON/classes validation | 19.0 → 21.1 | 12.5 → 13.6 |
| Coordinator package validation | n/a | 71.0 → 66.3 |
| Preflight entry → package/ownership validation complete | n/a | 149.9 → 160.0 |
| Application entry → engine invocation | 92.1 → 92.9 | 109.7 → 131.5 |

The preflight interval includes its state guard and runtime initialization. Hash-call aggregates include allocation, provider setup, reads and digest operations. Package class hashes overlap other hash groups; installed state guard aggregates overlap preflight/dispatch/application spans. Do not add nested rows or subtract medians from different runs to allocate the exact 85 ms benchmark delta. Instrumented caches are separate/fresher than the benchmark caches, with different accumulated log cardinality. These data identify observed cost centers, not an exact additive decomposition of the uninstrumented sample.

Installed version calls additionally show coordinator package validation 71.4 → 67.1 ms, preflight entry through package validation 143.2 → 154.8 ms and application entry through engine invocation 106.1 → 118.3 ms. These checks recur even for installed version output. The fix's specifically timed installed guard calls aggregate 132.1 ms for version and 160.2 ms for empty scope across their separate JVM contexts; this is an overlapping diagnostic subset, not the net benchmark regression.

Shell markers use the Bash builtin EPOCHREALTIME, starting no timer subprocesses. All 24 untraced diagnostic calls have wall/monotonic agreement within 100 ms. Median wall intervals in the fix show:

- Kof info command, including its Java version probe: 56.6–59.8 ms.
- Initial source SHA-256 capture: 1.26–1.37 ms.
- Jar BLAKE2b/image-identity selection stage: 181.2–201.6 ms; minimal image checksum stage: 2.84–3.08 ms.
- Installed packaged-class checksum command: 2.58–2.64 ms.
- Shell launch boundary to the first preflight/coordinator/application marker: approximately 11–13 ms.
- Last preflight marker → shell resumes: 313.0–313.5 ms. Application handoff marker → coordinator shell resumes: 316.0–316.7 ms.

The latter intervals contain the return/termination path after the marked body and small shell/descriptor/lease operations. Their internal cause was not identified. They must not be relabeled as startup or hashing. `diagnosis/return-boundaries*.json` retain exact marker pairs and raw values; `timer-summary.json`, `timer-raw-summary.json` and `process-summary.json` retain all other observations. Raw stdout/stderr/strace and each command result remain alongside them. The separate `analyze-diagnosis.py` and `analyze-boundaries.py` reproduce the summaries.

### Bounded runtime lifecycle probe

A small standalone Java diagnostic, outside product code, uses the same selected JDK and classpath containing the generated installed classes before kof.jar. Three calls merely enter/leave main; three additionally execute `Class.forName("dev.kof.runtime.KofRuntime")`. It writes markers before/after the optional load. Median monotonic results:

| Probe | Whole process | Inside marked main | Outside marked main |
| --- | ---: | ---: | ---: |
| No runtime load | 17.3 ms | 3.3 ms | 14.0 ms |
| Load generated KofRuntime | 411.5 ms | 87.0 ms | 324.1 ms |

`diagnosis/exit probe/ExitProbe.java`, `samples.json`, `summary.json` and individual stderr files preserve the reproducer. This associates approximately 394 ms of additional whole-process time with loading the generated runtime in this controlled fixture; approximately 310 ms of that difference is outside the marked body. It supports investigating runtime lifecycle overhead rather than assigning the whole delay to ordinary JVM launch. It does not establish which internal runtime/JDK shutdown work causes the tail or guarantee that this isolated difference can be removed from a real invocation.

Additional local research inspected Kof's `jvm/JvmRuntimeCore.java`, runtime shutdown/task handling and `KofJvmMain.java`. The core source has a task-waiting shutdown hook, but this investigation does not prove that hook causes the observed tail. No Kof source, distribution, generated product runtime or runtime option was modified for an optimization.

### Limits and recommended next work

The remaining internal work after the last markers, some entry/initialization work and the wall-clock discrepancies remain unexplained. No CPU profiler, JIT/GC attribution or clock-root-cause analysis was performed. Counts/lifetimes under strace and isolated diagnostic medians do not form an additive decomposition of benchmark latency. Both clocks, all outliers and all snapshot identities are preserved.

Prioritize a bounded investigation of the generated runtime's initialization/termination cost using the small reproducer and existing KofMut return boundaries. Then evaluate a KofMut prototype that consolidates repeated preflight/coordinator/application JVM contexts while preserving content identity, integrity before loading, behavioral approval, shared/exclusive leases, signal cleanup and separate preparation/application budgets. Approval-reference lookup is a small measured cost; removing checks or trusting version/mtime would break the contract. Fresh input fingerprinting and the jar-selection stage are additional measured costs that a future design may share safely, with a behavioral proof before adoption. Investigate the host clock discrepancy separately before using wall p95 for a latency target. Optimization remains a future user decision; none was implemented here.

## Acceptance audit and preserved boundaries

| Criterion | Accepted evidence |
| --- | --- |
| C1, preservation | Base/new raw cold inventories: 247 added entries/exit 3 versus exact 12 → 12 equality/exit 2; cold Kof behavior test on both distributions. |
| C2, internal paths | 22 warm locations, nonempty scope, valid config, command canaries, unchanged prefix/approvals/reports; independent preflight/coordinator/bootstrap refusals. |
| C3, refusal without damage | Valid and broken links retain exact target text; bytes/types/modes/empty directories and safe retained actual diagnostics are asserted; payload/receipts/healthy approvals preserved. |
| C4, recovery | Unlink-only cold recovery detects one killed mutant, complete/JSON v1/actual version; compiler refusal with healthy approval reuse; readonly package and removed checkout. |
| C5, public regressions | Both exact focused commands and complete ./scripts/check exit 0; installed examples 0/1/3/1, lifecycle/management/parallel/signal journeys, no Python child PATH, spaces. |
| C6, diagnosis | 264 raw paired samples, independent median/p95/pair-order audit, both clocks, cold events, environment/source hashes, 16 traces, 24 untraced diagnostic calls and runtime lifecycle probe; explicit unknowns and next-work recommendation. |

`final-audit.json` verifies 39 code/test/launcher files match both complete checkpoints; 28 historical validation files remain unchanged; selected Kof executable/jar/Java/libjvm fingerprints and local Kof source head/status remain unchanged; measured fix runtime sources and installed receipt payloads match; no profiler markers entered product code; no task JVM remains and git diff --check passes. Both source checkpoints also preserve their entire 76-file input inventories. Final documentation link/heading/recovery audits pass in English and Brazilian Portuguese. `.agent/validation/kofmut-m6r.sha256` identifies the delivered product/test/documentation/plan/report inputs.

The base's deliberately contaminated synthetic fixture is retained for inspection. Recovery proofs start with the corrected refusal; the tool does not delete entries previously created by an older faulty version in an evaluated project. Existing-link validation assumes trusted state ownership and does not claim atomic protection against hostile concurrent replacement after checking. Unknown syntax, invalid evidence, compilation failure and timeout still remain explicit errors or inconclusive results under their existing contracts. GPL-3.0-only, PATH selection, actual version evidence, JSON v1 and CLI identifiers remain intact. No commit, worktree, subagent, remote, publication, real user installation, Kof update or Kof modification was performed.
