# M6L: JVM runtime lifecycle investigation

Status: M6L.1–3 complete as an investigation. The dominant empty-work termination mechanism is supported on the observed JDK. Initialization attribution and the complete remaining tail are partial; no optimization, available gain or portability claim is made.

Base `59ab4d9c6d495a07093434d2a7ccd10771d090d4`, existing `kofmut-frontend` branch, initially clean. Product, tests, existing checks, CLI, dependencies and public EN/PT guides are unchanged. Only EXECPLAN and new M6L evidence are delivered. No commits, worktrees, subagents, remotes, publication, Kof changes/downloads or real user installation.

All raw paths below are relative to **E = `.agent/tmp/m6l/5b7ba35a-463f-4fbe-86e9-cb42fa7542ca/`**, a fresh UUID directory. Raw samples, failures and diagnostic scripts remain there. [Timing audit](../tmp/m6l/5b7ba35a-463f-4fbe-86e9-cb42fa7542ca/timing-audit.json), [native correlation](../tmp/m6l/5b7ba35a-463f-4fbe-86e9-cb42fa7542ca/native-correlation.json), [real process profiles](../tmp/m6l/5b7ba35a-463f-4fbe-86e9-cb42fa7542ca/real-processes.json), [loaded runtime identities](../tmp/m6l/5b7ba35a-463f-4fbe-86e9-cb42fa7542ca/real-runtime-identities.json), and [preservation audit](../tmp/m6l/5b7ba35a-463f-4fbe-86e9-cb42fa7542ca/preservation-audit.json) are independently inspectable. Historical [M6R](kofmut-m6r.md) remains unchanged.

## Finding and strength of the conclusion

The effective generated `KofRuntime` initializer eagerly builds a TLS context and an HTTP client even when the program performs no HTTP operation. The independent matching Java HTTP control reproduces the approximately 317 ms observed interval after the last marker, without a Kof runtime or task hook. TLS alone, an empty task hook, and an unused virtual executor do not reproduce that interval.

Separate native stack traces place repeated shutdown sleeps inside `VM_Exit::wait_for_threads_in_native_to_block()` on `VM Thread`. In the same strace clock, `HttpClient-1-SelectorManager` enters `epoll_wait` before the last main marker and remains there until process death. Separate JVM logs locate approximately 303 ms between exit safepoint initiation and final exit statistics. JFR records the empty `kof-wait-tasks` hook ending promptly, below 0.3 ms after the shutdown event in the two initialized probe recordings. The hook cannot account for that later native wait in those recordings.

The actual `libjvm.so` disassembly reads `UserThreadWaitAttemptsAtExit`, constructs a budget in units of 10,000,000 ns, and uses exponential sleeps capped at that same 10 ms unit. `java -XX:+PrintFlagsFinal -version` observes the existing default `UserThreadWaitAttemptsAtExit = 30`; no flag is changed. This links the observed approximately 300 ms to the VM exit wait, beyond a duration-only association. Files: `diagnostics/native-wait-disassembly.txt`, `native-symbol.txt`, `jdk-flags.stdout`, `*-unwind.strace`, `*-native.log`.

The combined evidence supports eager HTTP creation as a cause of the dominant recurring empty-work exit interval **on these concrete runtimes and host**. It does not establish the full set of native threads considered by the VM, allocate every remaining millisecond, or prove that changing any one operation safely removes the cost. Both Kof distributions embed identical Java and libjvm binaries, so this is two Kof versions on one JVM build, not independent JDK coverage.

## Identity and local authority

Both `kof info --json` records report coherent compiler/runtime/stdlib 0.6.4 or 0.6.6, Linux x86_64, embedded Eclipse Adoptium 25.0.4.1. `java -version` identifies Temurin 25.0.4.1+1-LTS. `host.txt` and `cpu.txt` capture this Linux/WSL2 host. Exact executable paths/argv and both clocks are retained per command.

| Identity | SHA-256 |
| --- | --- |
| Kof 0.6.4 jar | `137a838d38757e317545474d55ad6a3ad291fb86d263ae77d9197cf705829c62` |
| Kof 0.6.6 jar | `198bb211dbcefe60bd02f703dff991e82ba55c94f805b1b2b863362757289e58` |
| Both embedded Java launchers | `7380ce48ed5013735d2c8414db54adb8f981e7933ff594bd36f3baccddaafba3` |
| Both libjvm.so | `5e0fb6e83a5676090f28ff0b453e9199df06af1ff90d473c1b9837e41096114c` |
| Primary 0.6.4 generated KofRuntime | `cc56622d7f944a37a8cd072a8f38ec14aa78fd1f2a4cbc5ef1bbad0ad22bf3cc` |
| Primary 0.6.6 generated KofRuntime | `91524fed0c734366f07eb998665e12887398754eef66fc9d96e997e5b3ef1efa` |
| Original M6R probe runtime, separate confirmation | `91524fed0c734366f07eb998665e12887398754eef66fc9d96e997e5b3ef1efa` |

`runtime-images.json` identifies the original full application images from the two M6R validated source checkpoints. M6L copies those images and places generated classes before the selected jar, with an identical Java/classpath for all six cases within each version. `identity-<version>.stdout` records actual CodeSource, class resource URL and SHA-256, without class initialization. Every sample references that identity. `identity-check.py` additionally verifies the three actual load/init states in six separate class logs (`identity-mode-audit.json`). Before/after inventories verify those exact bytes throughout. Bare runs intentionally do not load the runtime. Real instrumented invocations have separately recorded loaded origins/hashes; they are not silently equated with the primary probe image or packaged image.

The primary matrix's full application images differ from the packaged image used by the historical M6R ExitProbe. `historical.py` additionally copies that exact historical image and original Java reproducer, compiles it with the same JDK and repeats three alternating calls per mode. Whole-process medians are 17.60 ms bare and 419.13 ms initialized. `historical-identity.stdout` and `historical-confirmation.json` prove the historical runtime identity; historical originals are retained. Historical 17/411 ms values are references, not thresholds.

Local Kof sources are clean at `7c237861a9035d84b1f7ec4cfddd89daef4c6ddd`. Research read `training/README.md`, concurrency/interop idioms, concurrency reference, `kof-runtime/.../KofJvmMain.java`, compiler `jvm/JvmRuntimeCore.java`, `JvmWebHttpRuntime.java`, `JvmRuntimeWebServer.java`, and `SpawnE2ETest.java`. Effective `javap -p -c` output for **each copied generated class**, rather than source version labels, confirms:

- the stdin reader, active task counter, `kof-wait-tasks` registration and its zero-task return/spin loop;
- TLS context, trust manager, SecureRandom, SSLParameters and eager HTTP builder with redirects/15 second connect timeout;
- `Executors.newVirtualThreadPerTaskExecutor()` for the web executor.

Current local sources explain those mechanisms; their contents are not assumed identical to historical release source. The installed JDK `src.zip` confirms the selector manager is a daemon and shows the Java shutdown-hook path. Its SHA-256 is `657dc2b53da098d8053f28284eb275a4394e05849fda89ea90ef8adc3a2b87a8`. Effective bytecode, native binary, profiles and behavioral execution govern conclusions about the distributions.

## M6L.1: separated observations

`m1.py`: 396 fresh JVMs, two distributions × bare/load/init × normal return/System.exit(0) × three blocks × eleven samples. Each adjacent group reverses case and version order on alternate iterations. The same classpath is used within a distribution. `analyze.py` independently asserts all cells, order, monotonic event chronology and successful exits. No samples are dropped. p95 is nearest rank `ceil(0.95 × 33)`, rank 32.

One parent monotonic clock records the pre-Popen start request, spawn return, receipt of every main/operation/last marker and observed process completion. Parent wall timestamps are retained alongside it. Child nanoTime values are used only for within-child differences. No cross-process epoch equivalence is assumed. Before-entry includes launch, marker construction and delivery; after-last includes remaining marker delivery/return/exit and observer scheduling. Process observation polls at up to 10 ms plus host scheduling; markers can share a read timestamp. These are observable boundaries, not exact kernel start/exit or pure JVM startup times. Short observed phases can be zero. Per-sample external intervals can be reconstructed from that sample's event list without overlapping sums; separate column medians must not be added or subtracted as an allocation.

Milliseconds, 33 samples per row:

| Kof / mode / ending | Total p50 / p95 | Internal operation p50 | Before entry observation p50 | After last observation p50 | Wall p50 / p95 |
| --- | ---: | ---: | ---: | ---: | ---: |
| 0.6.4 / bare / return | 17.99 / 21.33 | 0.02 | 17.19 | 0.66 | 17.99 / 21.33 |
| 0.6.4 / bare / exit | 30.26 / 35.19 | 0.02 | 17.14 | 13.03 | 30.26 / 35.19 |
| 0.6.4 / load / return | 19.35 / 23.00 | 1.52 | 17.11 | 0.61 | 19.35 / 23.00 |
| 0.6.4 / load / exit | 32.28 / 38.55 | 1.55 | 17.40 | 12.94 | 32.28 / 38.55 |
| 0.6.4 / init / return | 421.14 / 437.25 | 87.74 | 17.59 | 316.50 | 421.14 / 478.75 |
| 0.6.4 / init / exit | 420.71 / 438.78 | 86.41 | 17.50 | 316.92 | 420.71 / 438.78 |
| 0.6.6 / bare / return | 18.36 / 26.51 | 0.02 | 17.65 | 0.64 | 18.36 / 26.51 |
| 0.6.6 / bare / exit | 30.40 / 43.34 | 0.02 | 17.14 | 12.83 | 30.40 / 43.34 |
| 0.6.6 / load / return | 19.43 / 22.75 | 1.54 | 17.28 | 0.66 | 19.43 / 22.75 |
| 0.6.6 / load / exit | 31.73 / 37.20 | 1.50 | 17.46 | 12.92 | 31.73 / 37.20 |
| 0.6.6 / init / return | 421.60 / 448.39 | 87.43 | 17.35 | 316.38 | 421.60 / 448.39 |
| 0.6.6 / init / exit | 419.98 / 456.01 | 85.92 | 17.75 | 316.28 | 420.24 / 456.19 |

Loading without initialization is approximately 1.5 ms internally and does not reproduce the long tail. Initialized tails recur with both endings. System.exit is confined to diagnostics here and does not bypass shutdown hooks. Raw: `samples.jsonl`, `samples/*.json`, stdout/stderr per call, `summary.json`; original and revised diagnostic source versions are retained.

2 primary samples have wall/monotonic differences above 100 ms. Their full identities and values remain in `timing-audit.json`; both-clock summaries include them. The host clock discrepancy remains unexplained, and wall outliers are not attributed to runtime CPU work.

## M6L.2: controls and causal checks

`m2.py`: eleven alternating repetitions per mechanism, ending and version, 308 control calls. Independent Java mechanisms reproduce the operations observed in the effective initializer. The HTTP control retains its client, uses the same TLS/builder settings, and performs no requests. `http-default` is a separate ordinary default client. The executor control uses the effective virtual executor; an earlier unused diagnostic source contained a scheduled executor but that case was never executed in M6L.1 and was corrected before all executor controls.

Normal-return medians in milliseconds; all exit controls, wall clocks and distributions are in `controls-summary.json` and `controls.jsonl`:

| Control, normal return | 0.6.4 total / operation / tail | 0.6.6 total / operation / tail |
| --- | ---: | ---: |
| bare | 17.59 / 0.02 / 0.59 | 17.98 / 0.02 / 0.65 |
| hook | 18.58 / 0.92 / 0.78 | 19.18 / 0.96 / 0.83 |
| executor | 18.40 / 0.97 / 0.61 | 18.26 / 0.94 / 0.64 |
| tls | 76.65 / 47.70 / 12.00 | 76.14 / 47.93 / 11.97 |
| http | 410.91 / 78.78 / 317.00 | 413.97 / 81.38 / 316.58 |
| http-default | 464.85 / 127.58 / 316.91 | 461.46 / 127.34 / 316.48 |
| init | 421.02 / 85.91 / 318.05 | 420.62 / 85.26 / 317.67 |

| Hypothesis | Classification and evidence | Limit |
| --- | --- | --- |
| Definition/loading alone causes the long tail | Refuted as sufficient here: load(false) is short and does not initialize HTTP. | Loading still has a small cost. |
| Empty task hook causes approximately 300 ms | Refuted as sufficient here: isolated hook is short; actual empty hook ends before the native exit wait. | A nonempty hook intentionally waits, independently proved below. |
| Unused virtual executor causes approximately 300 ms | Refuted as sufficient here: isolated executor is short and starts no work. | No claim about submitted tasks. |
| TLS/security setup contributes to initialization | Supported: effective initializer calls it, isolated TLS has measurable initialization, and JFR samples include security provider/SSL setup. | Not an additive allocation of the runtime's approximately 87 ms. |
| Eager HTTP client causes the dominant exit wait | Supported on this host by matching independent controls, native VM exit stacks, selector epoll state and effective initializer. Default HTTP also reproduces it. | Exact VM blocker population and complete residual remain unknown. |

Separate JVM class/init/thread/VM/safepoint logs, strace and profile JFR were collected, never merged into the normal sample set. Twelve probe cases each have three diagnostic modalities (36 profiles), plus native unwind/VM traces and separate historical confirmation. JFR startup adds substantial work, its sampling misses short methods and its default event thresholds omit small compilations/waits. It corroborates events/order and sampled initialization stacks; it does not quantitatively allocate normal latency. `profiles-summary.json` retains counts and shutdown/hook events. Native unwinding is decisive for the exit-wait location; not every Java/JIT frame unwinds successfully, and those unwinder errors are retained.

Exact diagnostic shapes:

```sh
java -cp '<probe>:<generated classes>:<selected kof.jar>' ExitProbe init return
java -cp '<same classpath>' ExitProbe load exit
java '-Xlog:class+load=info,class+init=debug,os+thread=debug,safepoint=info,exit=debug:file=<log>:uptimenanos,tid,level,tags' -cp '<same classpath>' ExitProbe init return threads
java '-XX:StartFlightRecording=filename=<recording>,settings=profile,dumponexit=true' -cp '<same classpath>' ExitProbe init return
strace -f -k -ttt -T -s 160 -e trace=clock_nanosleep,epoll_wait,exit,exit_group,prctl,write -o '<trace>' java -cp '<same classpath>' ExitProbe init return
```

Per-command JSON contains expanded absolute argv. `native-correlation.json` aligns last marker, VM wait-stack samples, selector state and exit **within each strace clock**. Those instrumented spans are not subtracted from benchmark samples.

### Pending Kof task, external release

`fixture.py` compiles the same synthetic Kof fixture with each real distribution. It reads the argument into a local, starts `spawn pending(root)` without await, and prints `FIXTURE_LAST_MAIN`. The task writes ready, waits for a release file, then writes completion and prints `FIXTURE_DONE`. Three runs per version require readiness and last-main marker, continued process life with no completion for another 600 ms, external release, one completion marker/file and exit 0. All six passed. The third run on each version captures `jcmd <pid> Thread.print -l` while pending; `kof-wait-tasks` is RUNNABLE in the actual generated runtime spin loop.

Authority is the implicit join contract and JVM journeys in local `SpawnE2ETest.java`, supported here with an explicit external barrier rather than a sleep-only output check. The observer checks pending work before release and completion after release; a runtime that simply abandons the task cannot pass. Fixture build and process waits have explicit limits and kill/reap only their own groups on failure. Files: `fixture-<version>/Main.kf`, `fixture-<version>-<n>.json`, `fixture-threads-<version>.stdout`.

Initial diagnostic failures remain visible: `fixture.log` records invalid positional syntax to `kof build`; `fixture-corrected.log`, `fixture-direct-args.stderr/.exit` and `fixture-failed-direct-args-0.6.4/` retain a successful compilation followed by VerifyError for direct `spawn pending(args[0])`. Reading args[0] into a local before spawn uses the locally tested capture form and passed both distributions. No Kof fix or claim of support for the failed form is made. None of these failed attempts is relabeled as a passed fixture.

## M6L.3: actual invocation relevance

`m3-resume.py` uses ordinary disposable source copies and independent prefixes, selected Kof first on PATH, a synthetic empty project and reports outside the inputs. Plain copies run three normal smoke calls per cell after preparation (24 total). Separately marked copies add temporary Kof stderr markers to preflight/coordinator/application/engine boundaries, and run each cell with JVM logs, strace and JFR (24 successful instrumented calls). A single external strace clock pairs exec, role markers, selector threads and exits; every JVM log separately identifies the loaded generated runtime and its hash. Application empty-scope calls mark just before their existing process.exit; normal version paths return. Product sources contain no such markers.

All version calls return 0 with `KofMut 0.1.0`. Empty-scope calls return 3 with a current report discovered from that call's `reportPath`, `schemaVersion: 1`, `status: no_scope` and the actual selected `kofVersion`. The synthetic project's files remain byte identical. The new plain medians are smoke context with n=3, not a replacement benchmark or a speedup measurement.

| Kof / invocation | JVMs | Runtime initialized in | Last marker → process exit, trace ms | Exit stage in separate JVM log, ms | Normal smoke p50, ms |
| --- | ---: | --- | --- | --- | ---: |
| 0.6.4-source-version | 3 | coordinator | coordinator 312.1 | coordinator 303.4 | 685.7 |
| 0.6.4-source-empty | 4 | coordinator, application | coordinator 313.8, application 313.3 | application 304.1, coordinator 303.8 | 1522.8 |
| 0.6.4-installed-version | 5 | preflight, coordinator, application | preflight 308.6, coordinator 312.0, application 312.5 | application 303.9, preflight 304.2, coordinator 304.5 | 1696.7 |
| 0.6.4-installed-empty | 5 | preflight, coordinator, application | preflight 309.2, coordinator 313.8, application 318.0 | application 304.1, preflight 302.9, coordinator 303.7 | 2111.1 |
| 0.6.6-source-version | 3 | coordinator | coordinator 312.9 | coordinator 303.8 | 700.0 |
| 0.6.6-source-empty | 4 | coordinator, application | coordinator 313.6, application 307.9 | application 302.1, coordinator 302.6 | 1562.6 |
| 0.6.6-installed-version | 5 | preflight, coordinator, application | preflight 310.9, coordinator 315.0, application 309.9 | application 303.8, preflight 304.2, coordinator 303.9 | 1713.1 |
| 0.6.6-installed-empty | 5 | preflight, coordinator, application | preflight 319.0, coordinator 315.8, application 314.4 | application 303.9, preflight 303.9, coordinator 303.3 | 2144.3 |

The Kof launcher's Java version probe and Kof info account for the remaining Java processes. Eighteen observed real preflight/coordinator/application JVMs across these eight cells initialize the generated runtime, create the HTTP selector, and show an approximately 302–305 ms exit-stage span in separate JVM logs. Role-specific last-marker tails in independent strace are approximately 308–319 ms. This establishes recurrence at real boundaries. It does not add these diagnostic spans into the uninstrumented whole-call totals, explain hashing/package checks, or promise a gain from consolidation.

JFR is configured through a temporary environment only for these diagnostic calls, with `-Xlog:jfr+startup=off -XX:StartFlightRecording=settings=profile,dumponexit=true,filename=<directory>`. The first attempt without silencing startup messages polluted `kof info` stdout and was correctly rejected with exit 2 (`m3.log`, `real/0.6.4-marked-source-version-jfr.*`). That failed profile remains alongside successful profiles. An initial resume script NameError (`m3-resume.log`) and analyzer overcount of timeout wrappers as Java (`analyze-real.log`) are retained; the corrected analyzer matches the exec executable and verifies 3/4/5/5 JVMs. No validation or product JSON check was weakened to accommodate instrumentation.

## Reproduction and acceptance audit

Existing observations can be audited without rerunning measurements:

```sh
E="$PWD/.agent/tmp/m6l/5b7ba35a-463f-4fbe-86e9-cb42fa7542ca"
python3 "$E/analyze.py"
python3 "$E/analyze-real.py"
python3 "$E/preservation.py"
git diff --check
```

To repeat measurements, use a **new** UUID artifact directory. Copy `common.py`, `runtime-images.json`, `m1.py`, `m2.py`, `fixture.py`, `native.py`, `native-http.py`, `m3-resume.py` and the analyzers there; copy `ExitProbe.m1.java.source` as `ExitProbe.java` and create `samples/`. Run m1, m2, fixture, native, native-http and m3-resume in that order, with no concurrent suites/benchmarks. The scripts use their own directory as E, keep concrete installed Java/jar paths, copy original images and bound child execution. Preservation auditing additionally needs fresh before inventories like this run. Never run setup over existing evidence; existing-path failures preserve previous artifacts. `historical.py` is the additional exact M6R reproduction, not part of the 396-cell matrix.

| Criterion / authority | Expectation audit | Observed proof, command and limit |
| --- | --- | --- |
| C1, content identity / M6 | Correct generated class before jar; version text alone cannot authorize comparison. | `m1.py`, identity outputs, before/after image inventories and `analyze-real.py` loaded origins/hashes pass. Exact historical image additionally confirmed. |
| C2, M6R timing limitation | Separate observer boundaries and within-child durations, retain both clocks/all samples; no subtraction of medians. | `analyze.py` passes 396 samples, twelve cells, order and event chronology. Observer delay/polling and unexplained wall discrepancies remain explicit. |
| C3, causal evidence | A duration-only control cannot identify an internal wait; stacks/events must concur. | 308 controls, effective bytecode, JFR empty-hook events, native wait stacks and same-trace selector state support the HTTP/VM wait mechanism; complete allocation remains partial. |
| C4, local Kof spawn contract | Pending spawned work must survive main return until released/completed. | `fixture.py`: six barrier runs, actual pending hook stacks, then completion/0; accepted form only. Initial compilation/codegen failures preserved. |
| C5, real relevance | Observe each actual process and loaded image for checkout/installed version/empty. | `m3-resume.py` and `analyze-real.py`: eight cells, 24 normal smokes, 24 successful separate instrumented calls, 18 initialized role JVMs; project unchanged. |
| C6, preservation | Product, tests, history, Kof installations and original images stay intact. | `preservation.py` passes all 64 execution/test inputs against both M6R checkpoints, all 30 historical tracked validation files, both complete distribution inventories, original images and local Kof head/status. Original EXECPLAN is an exact prefix; diff/marker checks pass. |

Full suites are deliberately **reused**, as authorized for this investigation with no execution changes. Exact `./scripts/check` evidence is `.agent/tmp/m6r/check-0.6.4.result.json` and `check-0.6.6.result.json`: exit 0, 29 launcher / 44 execution / 27 installation / 15 frontend groups, 2403.156 / 2363.203 monotonic seconds. Both source checkpoints used spaces and no Python in the child PATH. `preservation-audit.json` verifies all 64 current execution/test/fixture/launcher inputs against each checkpoint before reusing that result. These are historical full-suite runs, not new M6L executions. All new fixtures and disposable public call smoke checks are current M6L evidence.

The final manifest identifies delivered files and retained reproduction/audit artifacts. Installed dependencies are referenced, never bundled. Further forensic work should capture the exact native-thread population considered inside VM_Exit and bracket individual initializer operations in an external reproducer, preserving the runtime and its hooks. A future optimization needs separate authorization and behavioral proof; this investigation does not recommend changing exit flags, removing hooks or weakening existing checks. Unknown codegen forms, failures, timeouts and insufficient evidence remain limitations.

## Resumo em português

A investigação sustenta que a criação antecipada do cliente HTTP pelo runtime participa da cauda de encerramento neste JDK. Os stacks mostram a espera em `VM_Exit::wait_for_threads_in_native_to_block()`, enquanto a thread seletora HTTP permanece em `epoll_wait`. O hook sem tarefas e o executor virtual sem trabalho não reproduzem a cauda longa. Uma tarefa Kof pendente foi preservada até a liberação externa em seis provas. O mesmo mecanismo aparece nos processos reais de preflight, coordenador e aplicação. A atribuição de toda a inicialização e dos milissegundos restantes continua parcial. Não houve otimização, alteração do produto ou promessa de ganho.
