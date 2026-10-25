# KofMut M6O validation

M6O is implemented and verified locally. Prepared `run` calls use one KofMut work JVM, besides official Kof discovery and the configured project processes. The reference used two work JVMs in a checkout and three in an installation. The configured check/test work, mutation results, isolation, parallel limit, CLI and JSON v1 remain preserved. Preparation of a new combination may still use separate processes. No universal latency promise follows.

## Identity and delivery

Production reference: `59ab4d9c6d495a07093434d2a7ccd10771d090d4`, captured before changes by [initial-manifest.json](../tmp/m6o/628bfae5-3af6-477b-9a37-d87df8b51063/initial-manifest.json) and the baseline checkout. [baseline-execution-inputs.json](../tmp/m6o/628bfae5-3af6-477b-9a37-d87df8b51063/baseline-execution-inputs.json) confirms its execution inputs stayed identical. Existing branch `kofmut-frontend`. During execution an external actor created `66e994d`, recording the pending M6L documents, initial M6O plan and synthetic fixtures. This agent issued no commit. Baseline identity is by content, independent of that later HEAD.

Task evidence root: `.agent/tmp/m6o/628bfae5-3af6-477b-9a37-d87df8b51063/`. Original pending plan and M6L documents are preserved. Real installed Kof 0.6.4 and 0.6.6 were selected explicitly; final paired measurements fix 0.6.6. No Kof download, update, source change, real user installation, subagent, worktree, remote or publication was performed. Local Kof research, effective installation info and distribution inventories are retained in [kof-research.json](../tmp/m6o/628bfae5-3af6-477b-9a37-d87df8b51063/kof-research.json), `info-<version>.stdout`, [distributions-before.json](../tmp/m6o/628bfae5-3af6-477b-9a37-d87df8b51063/distributions-before.json) and [distributions-after.json](../tmp/m6o/628bfae5-3af6-477b-9a37-d87df8b51063/distributions-after.json).

Changed implementation: `scripts/launch`, `scripts/installed-launch`, `InstalledPreflight.kf`, `launch/Compatibility.kf` and new `launch/PreparedEntry.kf`. The atomic `kofmut-prepared-v1` index is published only after content and behavioral approval. It identifies a candidate image, Java/jar, launch key, approval digest and exact class checksum manifest. Bash checks location, links and the complete class file inventory before loading. The JVM repeats request hashes, complete installation/JDK/jar/source/launcher fingerprints and approval validation before admitting evaluation. A stale candidate requests normal preparation with the same captured Kof and original clock. Generated damage can rebuild; damaged packages are refused.

A shared JVM lease covers validation, readiness confirmation and the engine in one lexical lifetime. The existing invocation flock covers the whole call. Atomic private readiness and launcher confirmation end preparation control before engine entry. The engine retains its own budget and command limits. Help/version retain minimal startup without engine compilation or behavioral preparation. No selection, mutation, command execution or report source was changed. Public EN/PT CLI guides describe these boundaries and recovery.

## Functional reference and complete rounds

`fixtures/startup-1-file` and `fixtures/startup-4-file` contain byte-identical production with three boolean sites, and the same eight cases distributed across one/four files. Every test explicitly calls `time.now()`. `budgetMs: 0`, `commandTimeoutMs: 60000`, configured parallelism 1/4. Only disposable configuration copies vary the parallel limit. Three candidates mean at most three active mutant tasks even when the configured limit is four.

Real `kof check` and `kof test` pass. All full reference and optimized measurements require eight baseline cases, zero failures, three candidates, two Killed, one Survived, no pending/timeout/test error, no discarded candidates or limitations, `complete/1`. The deliberate survivor is the unobserved boolean method, not quality approval. Every call has its own report and test logs; results are not reused between mutants or invocations. The paired analyzer compares IDs, operators, original/replacement tokens, positions, scope, phases, states and counts in each call's own JSON.

The initial installed reference full round including cold compatibility took 29.924 monotonic seconds, with 9451 ms public engine duration. It is not a prepared-call performance sample. M6O.1 reports and independent instrumented profiles are retained in [baseline.jsonl](../tmp/m6o/628bfae5-3af6-477b-9a37-d87df8b51063/baseline.jsonl), `baseline-round-*.report.json`, [profile-lifecycle.json](../tmp/m6o/628bfae5-3af6-477b-9a37-d87df8b51063/profile-lifecycle.json) and raw strace/JVM logs.

## Commands and regression evidence

Copies use spaces in paths and a PATH with no Python executable. Installed cycles remove the installer checkout, enforce readonly payload permissions, exercise the real installed entry and compare payload/input inventories. All commands below exited 0; `N/0` means N behavior cases passed with zero failures. Both complete source checks include all 31 CLI, 44 execution and 31 installation cases, then all 15 frontend contracts.

| Version | Command / outcome | Monotonic / wall seconds | Evidence |
| --- | --- | ---: | --- |
| 0.6.4 | `kof test src/test/kof/kofmut/Cli.kf --tag startup-optimization`: 9/0 | 389.348 / 432.359 | [stdout](../tmp/m6o/628bfae5-3af6-477b-9a37-d87df8b51063/Cli-startup-optimization-0.6.4.stdout), [command and clocks](../tmp/m6o/628bfae5-3af6-477b-9a37-d87df8b51063/Cli-startup-optimization-0.6.4.result.json) |
| 0.6.4 | `kof test src/test/kof/kofmut/Install.kf --tag startup-optimization`: 9/0 | 578.686 / 643.208 | [stdout](../tmp/m6o/628bfae5-3af6-477b-9a37-d87df8b51063/Install-startup-optimization-0.6.4.stdout), [command and clocks](../tmp/m6o/628bfae5-3af6-477b-9a37-d87df8b51063/Install-startup-optimization-0.6.4.result.json) |
| 0.6.4 | `kof test src/test/kof/kofmut/Install.kf --tag state-preservation`: 3/0 | 132.436 / 146.769 | [stdout](../tmp/m6o/628bfae5-3af6-477b-9a37-d87df8b51063/Install-state-preservation-0.6.4.stdout), [command and clocks](../tmp/m6o/628bfae5-3af6-477b-9a37-d87df8b51063/Install-state-preservation-0.6.4.result.json) |
| 0.6.4 | `./scripts/check`: CLI31 / Run44 / Install31 / frontend15, exit 0 | 2968.137 / 3297.889 | [stdout](../tmp/m6o/628bfae5-3af6-477b-9a37-d87df8b51063/full-check-0.6.4.stdout), [command and clocks](../tmp/m6o/628bfae5-3af6-477b-9a37-d87df8b51063/full-check-0.6.4.result.json) |
| 0.6.4 | `kof test src/test/kof/kofmut/Run.kf` through readonly installation: 44/0 | 633.691 / 705.377 | [stdout](../tmp/m6o/628bfae5-3af6-477b-9a37-d87df8b51063/installed-cycle-0.6.4.stdout), [command and clocks](../tmp/m6o/628bfae5-3af6-477b-9a37-d87df8b51063/installed-cycle-0.6.4.result.json) |
| 0.6.4 | supplemental Kof `--tag prepared-active-proof`: 1/0 | 71.911 / 82.665 | [stdout](../tmp/m6o/628bfae5-3af6-477b-9a37-d87df8b51063/prepared-active-proof-0.6.4.stdout), [command and clocks](../tmp/m6o/628bfae5-3af6-477b-9a37-d87df8b51063/prepared-active-proof-0.6.4.result.json) |
| 0.6.6 | `kof test src/test/kof/kofmut/Cli.kf --tag startup-optimization`: 9/0 | 389.293 / 432.303 | [stdout](../tmp/m6o/628bfae5-3af6-477b-9a37-d87df8b51063/Cli-startup-optimization-0.6.6.stdout), [command and clocks](../tmp/m6o/628bfae5-3af6-477b-9a37-d87df8b51063/Cli-startup-optimization-0.6.6.result.json) |
| 0.6.6 | `kof test src/test/kof/kofmut/Install.kf --tag startup-optimization`: 9/0 | 579.504 / 644.026 | [stdout](../tmp/m6o/628bfae5-3af6-477b-9a37-d87df8b51063/Install-startup-optimization-0.6.6.stdout), [command and clocks](../tmp/m6o/628bfae5-3af6-477b-9a37-d87df8b51063/Install-startup-optimization-0.6.6.result.json) |
| 0.6.6 | `kof test src/test/kof/kofmut/Install.kf --tag state-preservation`: 3/0 | 132.335 / 146.668 | [stdout](../tmp/m6o/628bfae5-3af6-477b-9a37-d87df8b51063/Install-state-preservation-0.6.6.stdout), [command and clocks](../tmp/m6o/628bfae5-3af6-477b-9a37-d87df8b51063/Install-state-preservation-0.6.6.result.json) |
| 0.6.6 | `./scripts/check`: CLI31 / Run44 / Install31 / frontend15, exit 0 | 2973.198 / 3306.534 | [stdout](../tmp/m6o/628bfae5-3af6-477b-9a37-d87df8b51063/full-check-0.6.6.stdout), [command and clocks](../tmp/m6o/628bfae5-3af6-477b-9a37-d87df8b51063/full-check-0.6.6.result.json) |
| 0.6.6 | `kof test src/test/kof/kofmut/Run.kf` through readonly installation: 44/0 | 634.941 / 706.627 | [stdout](../tmp/m6o/628bfae5-3af6-477b-9a37-d87df8b51063/installed-cycle-0.6.6.stdout), [command and clocks](../tmp/m6o/628bfae5-3af6-477b-9a37-d87df8b51063/installed-cycle-0.6.6.result.json) |
| 0.6.6 | supplemental Kof `--tag prepared-active-proof`: 1/0 | 71.961 / 82.714 | [stdout](../tmp/m6o/628bfae5-3af6-477b-9a37-d87df8b51063/prepared-active-proof-0.6.6.stdout), [command and clocks](../tmp/m6o/628bfae5-3af6-477b-9a37-d87df8b51063/prepared-active-proof-0.6.6.result.json) |


Four installed examples per version retain exits `0/1/3/1` for detected/survived/invalid/equivalent. Their own reports retain JSON schemaVersion 1, actual `kofVersion`, expected states and counts; see `installed-example-<version>-<fixture>.report.json` and `installed-complete-<version>.json`.

Behavioral failure evidence was retained, not discarded: the first observer missed a JVM when `-D` arguments preceded classpath and falsely passed; the corrected observer reproduced two source work JVMs before implementation. An early launcher edit placed selection before its definition and failed explicitly. The installed count then exposed canonical versus lexical jar paths through a symlink, repaired by comparing the same concrete locations. The existing early-evidence test exposed a changed diagnostic/file path; the corrected implementation preserves `bootstrap-failure` and `preflight.stderr`. See `startup-observable-red.stdout`, `startup-green-*.stdout`, `install-startup-green-*.stdout` and `diagnostic-red/green.stdout`. The separate profiler first failed because `strace` was absent from the deliberately restricted PATH; `c2-profiles.log` and `pipeline.log` retain it. Resuming with the absolute strace path completed all profiles without rerunning or replacing normal samples. No failed observation is used as acceptance.

The new readiness journey proves the JVM lease before confirmation, flock exclusion of uninstall, absence of an early report, INT/130 and TERM/143 with no live work JVM before cleanup, no late evaluation after release, and successful retry. The supplemental active-update proof confirms PreparedEntry in the live engine process command line, its JVM lease during a blocked project command, exact inherited PATH and disposable cwd, uninstall refusal, successful B activation and independent B preparation while A stays active, unchanged A package/classes and A's original tool version on completion. It uses a controlled synthetic command protocol; real Kof mutation behavior is independently covered by the fixtures and complete suites.

Actual deadline tests observe the existing wall-clock preparation controller, including outer startup/termination. Monotonic/wall elapsed ms: 0.6.4 `82674/93426`, 0.6.6 `80984/91737`; both refuse/2 with `90000 ms`, no report, inactive child, no late admission and successful retry. Confirmed zero-budget evaluations execute real delayed check/test commands with 60000 ms individual limits and finish `no_mutants/3`: public engine `94771/94791` ms, outer monotonic `95943/95963` ms and wall `106699/106719` ms. The clock differences remain unexplained; they are not silently normalized or attributed to a cause. The engine has no total ninety-second wrapper after confirmation.

## Paired performance measurements

All suites finished before sampling. One fixed real Kof 0.6.6, same host, no concurrent task suites. Fresh baseline/optimized checkouts and installations use matching project contents and commands. Each empty-scope case has three blocks of eleven alternating pairs (33 per variant); each installed complete-round case has three blocks of five pairs (15 per variant). There are 252 normal prepared calls in total. Pair order alternates AB/BA, recorded per block/pair/position. All samples remain included.

A parent observer records monotonic and wall start/end around the complete invocation using blocking process wait. A separate watchdog handles unexpected hangs. Public engine duration is recorded from that invocation's report. These are distinct clocks and boundaries: engine duration excludes launch and final process termination and is captured before final report publication completes. Differences between separate-run medians are not phase allocations. p95 is nearest rank (with n=15, p95 is the observed maximum).

External monotonic clock:

| Case | n per variant | Baseline median / p95 (ms) | Prepared median / p95 (ms) | Median change |
| --- | ---: | ---: | ---: | ---: |
| `checkout-empty` | 33 | 1564.11 / 1616.87 | 1161.21 / 1205.49 | -25.8% |
| `installed-empty` | 33 | 2128.16 / 2160.52 | 1216.70 / 1245.45 | -42.8% |
| `installed-full-1-p1` | 15 | 10807.84 / 10898.86 | 9918.58 / 10010.25 | -8.2% |
| `installed-full-1-p4` | 15 | 7671.54 / 7759.56 | 6447.77 / 6872.09 | -16.0% |
| `installed-full-4-p1` | 15 | 19351.93 / 19561.35 | 18171.47 / 18450.15 | -6.1% |
| `installed-full-4-p4` | 15 | 12415.06 / 12640.97 | 11479.57 / 11581.60 | -7.5% |


External wall clock:

| Case | n per variant | Baseline median / p95 (ms) | Prepared median / p95 (ms) | Median change |
| --- | ---: | ---: | ---: | ---: |
| `checkout-empty` | 33 | 1564.11 / 5158.54 | 1163.64 / 1215.53 | -25.6% |
| `installed-empty` | 33 | 2128.16 / 2160.59 | 1221.82 / 4771.79 | -42.6% |
| `installed-full-1-p1` | 15 | 10872.12 / 14462.91 | 9935.26 / 13582.40 | -8.6% |
| `installed-full-1-p4` | 15 | 7679.18 / 11303.00 | 6452.54 / 10451.81 | -16.0% |
| `installed-full-4-p1` | 15 | 22696.50 / 23144.22 | 21644.72 / 22029.10 | -4.6% |
| `installed-full-4-p4` | 15 | 12640.97 / 16164.98 | 11571.72 / 15106.09 | -8.5% |


Public engine clock:

| Case | n per variant | Baseline median / p95 (ms) | Prepared median / p95 (ms) | Median change |
| --- | ---: | ---: | ---: | ---: |
| `checkout-empty` | 33 | 13.00 / 15.00 | 7.00 / 8.00 | -46.2% |
| `installed-empty` | 33 | 9.00 / 10.00 | 3.00 / 3.00 | -66.7% |
| `installed-full-1-p1` | 15 | 8544.00 / 8730.00 | 8655.00 / 8729.00 | +1.3% |
| `installed-full-1-p4` | 15 | 5431.00 / 5521.00 | 5376.00 / 5538.00 | -1.0% |
| `installed-full-4-p1` | 15 | 17121.00 / 17294.00 | 16898.00 / 17159.00 | -1.3% |
| `installed-full-4-p4` | 15 | 10191.00 / 10356.00 | 10213.00 / 10305.00 | +0.2% |


Both empty-scope cases have lower external monotonic medians in every block. Tail results are not uniformly better: installed empty-scope wall p95 increases from 2160.59 to 4771.79 ms while its monotonic p95 decreases. The corresponding wall/monotonic divergence remains unexplained; no cause is inferred and no sample is dropped. This satisfies the planned median criterion, not a universal tail-latency promise. Complete-round conclusions:

- `installed-full-1-p1`: lower median in all three blocks, with a negative median paired delta; median paired external monotonic delta -916.33 ms.
- `installed-full-1-p4`: lower median in all three blocks, with a negative median paired delta; median paired external monotonic delta -1161.38 ms.
- `installed-full-4-p1`: lower median in all three blocks, with a negative median paired delta; median paired external monotonic delta -1112.38 ms.
- `installed-full-4-p4`: lower median in all three blocks, with a negative median paired delta; median paired external monotonic delta -938.96 ms.

All samples, pairwise deltas, all block medians and p95 are in [performance/observations.jsonl](../tmp/m6o/628bfae5-3af6-477b-9a37-d87df8b51063/performance/observations.jsonl) and [performance/summary.json](../tmp/m6o/628bfae5-3af6-477b-9a37-d87df8b51063/performance/summary.json); each observation identifies stdout/stderr and its own copied JSON. Raw commands, working directory and selected PATH remain recorded. Clock divergence and full-round variation are retained; the conclusion is limited to these fixtures, versions and this host.

Initial preparation is recorded separately and excluded above:

| Variant | Location | First preparation plus empty evaluation, monotonic / wall ms | Public engine ms |
| --- | --- | ---: | ---: |
| base | checkout | 18095.07 / 21680.53 | 14 |
| base | installed | 19246.38 / 19246.38 | 10 |
| next | checkout | 18182.28 / 21765.00 | 13 |
| next | installed | 19031.02 / 19031.01 | 9 |


## Separate JVM and lifecycle profiles

The following diagnostic runs are separate from normal timing samples. Strace records exec/chdir/write/exit with both absolute wall timestamps and relative monotonic timestamps. The installed strace manual documents the latter clock; the controlled fork/wait probe is retained in [strace-clocks-probe.json](../tmp/m6o/628bfae5-3af6-477b-9a37-d87df8b51063/strace-clocks-probe.json). Per-process costs are exec to observed termination and include tracing overhead. The analyzer retains individual intervals and their union, never sums overlapping process lifetimes into total round time. Whole reconstructed monotonic trace spans are compared independently with the parent observer. Marked/JVM-log passes are additional diagnostics with their own compiled image identities.

| Variant | Test files | Configured parallelism | Work JVMs | Test commands | Test execution JVMs | Test JVM median / p95, observed monotonic ms | Union of test JVM intervals, ms |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| base | 1 | 1 | 3 | 4 | 4 | 688.40 / 711.60 | 2762.81 |
| base | 1 | 4 | 3 | 4 | 4 | 886.19 / 997.97 | 1909.49 |
| base | 4 | 1 | 3 | 4 | 16 | 697.27 / 719.42 | 11132.49 |
| base | 4 | 4 | 3 | 4 | 16 | 907.73 / 1005.81 | 7286.72 |
| next | 1 | 1 | 1 | 4 | 4 | 698.20 / 723.32 | 2802.13 |
| next | 1 | 4 | 1 | 4 | 4 | 925.74 / 1019.12 | 2048.74 |
| next | 4 | 1 | 1 | 4 | 16 | 699.62 / 730.32 | 11216.86 |
| next | 4 | 4 | 1 | 4 | 16 | 893.27 / 1059.96 | 8160.04 |


`base` and `next` execute the same four real Kof test commands, with four/sixteen execution JVMs according to file distribution, at both parallel limits. Only internal work JVM count changes from three to one in these installed profiles. Full argv, disposable cwd transitions, process lifetimes and command evidence remain in `c2-*.strace`, `c2-*.report.json` and [jvm-lifecycle.json](../tmp/m6o/628bfae5-3af6-477b-9a37-d87df8b51063/jvm-lifecycle.json). Test JVM cost is reported separately and is not claimed as an optimized saving.

The unchanged detected fixture is profiled separately: two test commands and two test execution JVMs. Its passing test JVM does not initialize KofRuntime, while its failing mutant test JVM does; all test execution JVMs in the explicit `time.now()` fixtures initialize it. Therefore the M6L HTTP/exit mechanism must not be generalized to every possible Kof test. JVM initialization logs and process mapping are in [profile-lifecycle.json](../tmp/m6o/628bfae5-3af6-477b-9a37-d87df8b51063/profile-lifecycle.json). The `engine-entry` marker names `MutationRun.evaluate`, after option parsing; the public engine clock starts earlier in `runMutation`. Optimized profiles also retain an explicit `run-entry` marker. Baseline completion, mutant start/completion, publication and final marker/termination intervals remain in raw marked traces and [jvm-lifecycle.json](../tmp/m6o/628bfae5-3af6-477b-9a37-d87df8b51063/jvm-lifecycle.json); child nanoTime intervals remain separate from observer clocks.

The compiler-generated runtime is not byte identical: adding `PreparedEntry` makes unchanged Kof generation add `kof_json_decode_kofmut_launch_PreparedEntry`, and shifts constant-pool/debug metadata. Baseline/optimized `KofRuntime.class` SHA-256 are `91524fed0c734366f07eb998665e12887398754eef66fc9d96e997e5b3ef1efa` / `3cbe034f60faa7c2a70fcd40502a28837109f30407a1702cc8b2602a1ec67bc6`. The strict comparison of all 32 runtime classes permits exactly that compiler-generated decoder and no other added/removed members or changes to common code. After normalizing only numeric constant-pool references and javap alignment, all existing helpers, fields, exception tables and static initializers remain identical. See [measured-runtime-comparison.json](../tmp/m6o/628bfae5-3af6-477b-9a37-d87df8b51063/measured-runtime-comparison.json), disassemblies and [runtime-research.json](../tmp/m6o/628bfae5-3af6-477b-9a37-d87df8b51063/runtime-research.json); local `JvmRuntime.source` emits a decoder for each IR class. No generated class/runtime source was edited. Task/shutdown hooks, configured commands, JVM flags, test selection and isolation were preserved. [M6L](kofmut-m6l.md) supports its historical HTTP/exit association on this JDK; it is not a formula guaranteeing 300 ms per removed JVM.

## Criterion audit: expectation versus proof

| Criterion and authority | Expected behavior | Observed proof and strength |
| --- | --- | --- |
| C1, public mutation/report contract | Eight baseline cases, three sites, two Killed/one Survived, complete/1, equal IDs/operators/positions/states/counts and no discard/limitation | Strong: real Kof check/test, installed behavior journey on both versions, four full reference configurations and every independent paired full report. Pairwise normalized comparison asserts the required fields; raw reports retain the rest. |
| C2, commands/isolation | Same work in independent copies; four test calls and four/sixteen file JVMs | Strong for these fixtures: eight profiles with unchanged project commands cover both source variants, one/four test files and both parallel limits with fixed Kof 0.6.6; all counts asserted. Full 44-case source/installed suites cover argv, environment, concurrency and preservation. Active prepared proof additionally observes PATH and sandbox cwd. No claim about arbitrary external resource isolation. |
| C3, M6 compatibility | Content changes invalidate reuse, failed approval precedes project work, correction permits retry | Strong: startup tags on both real versions, preserved timestamps, JDK/source changes, malformed index, class/manifest/extra-file corruption, behavioral frontend refusal, actual Kof switch and retry. Pre-load shell checks and full approval checks have separate authority. |
| C4, M6R preservation | Existing/broken links and package corruption refused before managed effects; projects/targets/receipts preserved | Strong for tested states: expanded index/directory/class/manifest paths in full inventories; exact state-preservation tag 3/0 per version and full installation suites. Readonly payload and removed checkout proofs pass. Existing-link protection assumes exclusive trusted ownership during manual repair, not hostile concurrent path replacement. |
| C5, M6/M3F deadlines/cancellation | Original preparation deadline, command limits, shared cleanup, independent engine budget; no late commands | Strong: actual withheld prepared-entry deadline and actual >90 s confirmed evaluations on both versions; readiness INT/TERM, retry and complete source/installed cancellation/timeout suites. Wall/monotonic divergence is explicit, so no stricter elapsed-monotonic deadline is inferred from the old wall-clock controller. |
| C6, M5/M6 leases/concurrency | Active image cannot be exchanged; uninstall blocked through transition and evaluation | Strong: readiness JVM/flock assertions, complete legacy/update suites, simultaneous calls and dedicated prepared A/B active-update proof on both versions. Unique image inventory and A's original tool version remain unchanged while B activates/prepares. |
| C7, measured gain | Reduce prepared startup without confusing process counts and complete-round gains | Strong for the sampled empty cases: three independent alternating blocks each. Full-round claims use their own retained samples and block/paired deltas; inconclusive cells stay identified above. Separate instrumented lifetimes distinguish internal and test JVMs and overlapping work. No universal guarantee or extrapolated saving is claimed. |

## Preservation, review and limits

[final-audit.json](../tmp/m6o/628bfae5-3af6-477b-9a37-d87df8b51063/final-audit.json) confirms all historical validation files, original plan prefix, original generated images, actual Kof distributions (bytes, modes, links and mtimes) and researched Kof source state remained unchanged. Both final full-source input inventories match delivered source/test/script/doc bytes, apart from the subsequently updated execution record. Installed payload inventories and suite inputs remain unchanged. No task markers are present in product source; no jar or JDK is bundled in the packages. GPL-3.0-only and current/legacy installed receipt schemas are unchanged.

[structural-review.md](../tmp/m6o/628bfae5-3af6-477b-9a37-d87df8b51063/structural-review.md) records the completed scoped refactor-design review: no structural change justified. Invocation state has one process lifetime; repeated verification crosses persistence/loading/approval boundaries; readiness is an explicit protocol; index transport is local/versioned; image immutability and lease scope remain explicit. Test scheduling seams are confined to fixtures or modified disposable copies.

Limitations: measurements describe this host and fixed Kof 0.6.6, not every machine/project/version. Diagnostic tracing and class logging add overhead. Clock divergence remains unexplained. User manual state replacement during active calls is unsupported; wait for calls before repair. Concrete selected runtimes must remain intact while in use. Unknown syntax, invalid evidence, compilation errors, timeout and cleanup failures remain explicit limitations/errors or inconclusive outcomes under the existing contracts. The historical real-project ninety-second target and sensors remain deferred. The public delivery manifest is `.agent/validation/kofmut-m6o.sha256`; listed raw evidence is additionally sealed by the task artifact manifest, while disposable build directories retain their own receipts and inventories.
