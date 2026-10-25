# M6: automatic Kof compatibility

Status: C1–C10 accepted for the delivered M6 tree on the two real installations tested, Kof 0.6.4 and 0.6.6. Complete source checkpoints, focused final diagnostic deltas, readonly installed evaluation suites, examples, performance and preservation audits are complete. Earlier M1–M5R reports and manifests remain historical evidence of their original trees.

Authority: the supplied M6 plan, preserved in EXECPLAN.md, replaces literal Kof 0.6.4 restrictions and installed independence from PATH. Public configuration/report JSON stay at `schemaVersion: 1`. Internal installed receipts use `schemaVersion: 2`, `buildDependency` and `runtimeSources`; legacy receipt 1 uses `dependency` and `files` and remains readable for management without rewriting its bytes.

All final artifacts are under `.agent/tmp/m6/294f9038-ecbf-470f-985c-55e57f9a7857/`, abbreviated **E** below. Fixtures are synthetic. No worktree, subagent, commit, remote, publication, sensor integration, Kof modification or Kof update was performed.

## Delivered behavior

Each invocation resolves the concrete Kof executable selected on PATH. A minimal bootstrap handles informational commands and coordinates preparation. Compatibility identity covers KofMut runtime sources/checks/launchers, fresh coherent installation metadata, the executable, the entire Kof jar and the embedded JDK files. Generated classes also have content inventories. Declared version, path and modification time cannot authorize reuse by themselves.

New combinations compile captured source bytes into a candidate, verify official lexer/parser operators and UTF-16 locations, and run synthetic killed/survived evaluations using the actual compiler and test protocol. Reports, baseline evidence, counts, locations and results must agree. Components are hashed again before publishing an atomic approval reference. Compiled images keep unique immutable paths, so replacement references do not move classes used by active evaluations. Failed candidates do not become approvals; a corrected invocation retries without manual cleanup.

The installed package carries runtime sources and provenance, without development tests, repository history/cache, Kof jar or JDK. Generated bootstrap/images/references/locks/evidence stay in `state/kof-mut/compatibility/`. A shared flock spans the entire installed invocation, including the JVM handoff. JVM file locks also preserve legacy execution coordination. Uninstall requires exclusive leases. Installed source corruption requests installation repair; generated cache corruption rebuilds.

Progress is stderr only and precedes evaluation: detected/preparing, checking compatibility, ready/starting evaluation. Warm approvals repeat none of those messages, compilation or behavioral checks. Help, `-h`, no arguments and `--version` avoid engine compilation/compatibility checks. `kofVersion` names the actual selected frontend. Unknown project syntax remains incomplete/3. Direct configured `kof` commands bind the concrete executable; their arguments, cwd and environment remain intact. Explicit scripts keep their own dependency resolution. Runtime installations must remain available and unchanged while their active calls finish.

Preparation has a total ninety second budget before the mutation budget. Individual compilation/probe commands have ten second limits and process cleanup shares two seconds. Bootstrap compilation readiness separates its initial compiler from orchestration/lock waiting; installer orchestration retains its established lifecycle. `budgetMs: 0` still permits mutation evaluations longer than ninety seconds.

## Evidence and assertions by criterion

| Criterion | Commands and observed evidence | Assertion strength and artifact |
| --- | --- | --- |
| C1 automatic adoption | Real 0.6.4/0.6.6 focused installation tags select the alternate real distribution after deleting the checkout and the full copied build distribution. First evaluation prepares, second works with compilation refused. | Checks receipt 2/runtime sources, actual report frontend, build trace and silent reuse. Accepted focused tag logs/results are `accepted-focused-install-<version>.*`; earlier five-journey logs are `focused-install-<version>-after-lease.log`. |
| C2 behavioral verification | `kof test .../Cli.kf --tag compatibility` changes the arithmetic family while compilation still succeeds. `python3 E/protocol-proof.py` injects invalid check counters and contradictory test summaries. | Both evidence failures stop at contracts with exit 2, no approval, no project canary or report directory; valid retry kills its candidate. `protocol-acceptance.json`, `protocol-invalid-check.*`, `protocol-invalid-test.*`, `protocol-recovery.*`. A successful compiler alone is insufficient. |
| C3 content identity | Compatibility tags change runtime source bytes during preparation and modify JDK release/jvm.cfg contents with timestamps restored; the original jar-content test updates a disposable archive. | Requires renewed preparation/reuse, refuses changed inputs before approval, and preserves real distributions. `accepted-focused-cli-<version>.*`, `preservation-preliminary.json`. Runtime checks and generated class hashes participate in approval. |
| C4 failure/retry/time | Compatibility tags cover compiler refusal, source drift and retry; observable command-timeout probes cover 10 seconds plus shared cleanup. `python3 E/acceptance-extra.py deadline` holds the preparation lease. `python3 E/preflight-final-proof.py` covers six final corruption/permission failures. | Total deadline exits 2 at 90.341 wall seconds, no project report/commands, holder alive, silent retry. Final source/class/permission cases locate actual failure files, retain previous approvals, preserve stdout and restore both 127-file payloads. `deadline-acceptance.json`, `timeout-observable-<version>.stdout`, `preflight-final-acceptance.json` and its copied evidence directories. |
| C5 concurrency/stability | Concurrent first calls share one complete preparation. `python3 E/acceptance-extra.py stable` holds A in baseline, changes the selector to B and evaluates B. A public handoff barrier tries uninstall before the next JVM takes its file lock. | A reports 0.6.4 and both direct checks remain A; B reports 0.6.6. A completes in 93786 mutation ms with budget zero. Flock exclusive attempt returns 1 and uninstall returns 2 while A is active. `stable-acceptance.json`, `stable invocation/observations/`, `handoff-lease-green.log`. No mixed frontend after symlink replacement. |
| C6 cancellation | Compatibility tags exercise INT/TERM after emission; `python3 E/early-cancellation.py` schedules signals during pending registration and before setsid. | All four early cases return 130/143, children are inactive before cleanup, releasing controls cannot publish late approval, retry succeeds and an independent B evaluation completes. `early-cancellation-acceptance.json`, `early preparation cancellation/`; final focused CLI logs cover emitted candidates and command timeout. |
| C7 installation/migration | `python3 E/acceptance-extra.py migration` installs actual a32a88b receipt 1, upgrades the same prefix with B, removes old checkout/full distribution, evaluates and uninstalls. Focused tags exercise readonly package, cache reconstruction, modified files and synthetic legacy ownership. | Original legacy receipt SHA-256 remains `db6a15d52ced8ed329ed33539fdb6a22294f8d02ec8af941d675b847c9364b05` through upgrade/evaluation. Unknown files, logs and report survive uninstall. `legacy-acceptance.json`, `legacy-*`; final installed inventories verify readonly payload preservation. |
| C8 visibility/fast paths | `python3 E/progress-proof.py` makes every configured project command read live public stderr/stdout before starting; traces the selected Kof. Compatibility tag deliberately invalidates engine syntax and invokes all informational commands. | All four project commands see ready plus reportPath before starting. Warm trace contains only `info`, with no `run`, `build` or operational probes. Cold output contains the exact three messages. `progress-acceptance.json`, `protocol and source integrity/progress.*`, final focused CLI logs. |
| C9 regressions | `./scripts/check` with both real distributions, final focused diagnostic/context journeys, independent installed Run suites and examples, all with spaces and PATH without Python. | Both source checkpoints pass 29 CLI/44 cycle/25 installation/15 frontend; both final installed cycles pass 44 and examples 0/1/3/1 with JSON 1/actual frontend. `confirmed-check-0.6.4.*`, `accepted-check-0.6.6.*`, `diagnostic-completion-*`, `final installed <version> with spaces/acceptance.json`, `final-audit.json`. See exact snapshot/delta boundaries below. |
| C10 performance | `python3 E/benchmark.py` runs after every suite stops, comparing a32a88b with final runtime sources on the same machine/Kof 0.6.4. | 264 valid warm samples: three blocks of eleven alternating pairs per source/installed version/empty-scope case; 33 samples per variant/case. Raw monotonic and wall times, nearest-rank p95 and initial phase costs are archived under `performance/`. The audit verifies pair order, sample count and exact benchmark runtime source hashes. No numeric regression threshold was imposed. |

## Final acceptance and snapshot boundaries

The exact public commands were run with each real distribution selected first on PATH:

```bash
kof test src/test/kof/kofmut/Cli.kf --tag compatibility
kof test src/test/kof/kofmut/Install.kf --tag compatibility
./scripts/check
```

Focused compatibility passes are 8 CLI and 7 installation per version (`accepted-focused-cli/install-<version>.stdout` and `.result.json`). The full source checkpoints and final installed checks are:

| Verification | Kof 0.6.4 | Kof 0.6.6 |
| --- | --- | --- |
| Complete source CLI | 29/0, 593374 ms | 29/0, 643590 ms |
| Complete source mutation cycle | 44/0, 741188 ms | 44/0, 705955 ms |
| Complete source installation | 25/0, 936751 ms | 25/0, 1081386 ms |
| Source frontend contracts | 15 passed | 15 passed |
| Source `./scripts/check` exit/duration | 0; 2282.580 monotonic s / 2533.477 wall s | 0; 2444.042 monotonic s / 2716.440 wall s |
| Final readonly installed cycle | 44/0, 839536 ms | 44/0, 841900 ms |
| Final installed examples: detected/survived/invalid/equivalent | 0/1/3/1 | 0/1/3/1 |
| Final package inventory / runtime source entries | 127 unchanged files / 23 | 127 unchanged files / 23 |

The accepted complete source checkpoints are `confirmed source 0.6.4 with spaces` and `accepted source 0.6.6 with spaces`. Each initial 76-file input inventory remains byte/mode identical. The 0.6.6 timing-test delta has an additional observable command probe; the complete 0.6.4 checkpoint includes the delivered command-timing body. The last change after both checkpoints is confined to early error formatting/context preservation in CompatibilityEntry and the shell forwarding branch, plus the two existing diagnostic tests. No successful dispatch, compatibility contract, deadline, mutation or reporting path changed. Both exact final 76-file snapshots pass the expanded installation/state-error journey and existing source context-cleanup journey (`diagnostic-completion-*`). Final readonly installed cycles/examples and measurements use those final runtime bytes. The complete source entry point was not rerun after this limited final error-handler change; acceptance combines the full checkpoints with focused delta proofs and complete installed cycles, and the audit verifies that boundary explicitly.

Every example parses the report named by its own stdout `reportPath`, checks schemaVersion 1, actual frontend, status, counts and baseline evidence. Both final source inputs and both final readonly payloads retain bytes/modes. Neither package contains development tests, Git, a Kof jar or a JDK. `preflight-final-acceptance.json` records six final public failure cases (source damage, preflight class damage, unwritable compatibility logs on both versions), the copied actual failure contexts, preserved approvals/no project report and exact payload restoration.

## Performance evidence

The baseline is a32a88bab05971b7a605f1bca8cd3aa00b5290bc. Measurements used the same host and Kof 0.6.4, after all validation suites stopped. `performance/environment.json` records Linux/WSL2, Intel Core i9-14900HX, 32 logical CPUs and 24605900 kB memory. `performance/setup.json` identifies source copies, prefixes, PATH without Python and the synthetic empty-scope project. The benchmark uses actual final runtime sources, confirmed by hashes in the final audit.

For each of four cases, three blocks each contain eleven adjacent alternating baseline/M6 pairs; there are 33 samples per variant/case and 264 total. Empty-scope calls return 3/no_scope with zero candidates, no baseline commands, JSON schemaVersion 1 and actual frontend. Version calls return the exact version line. All warm calls have no preparation messages. p95 uses nearest rank `ceil(0.95 * n)`; there is no imposed performance acceptance threshold. These measurements quantify startup/report overhead, not mutation throughput on a real project.

Warm monotonic durations in milliseconds (`performance/summary.json`):

| Location / call | Base median | M6 median | Base p95 | M6 p95 | Median change |
| --- | ---: | ---: | ---: | ---: | ---: |
| Checkout / --version | 703.5 | 693.2 | 719.8 | 716.4 | -1.5% |
| Checkout / empty scope | 708.8 | 1525.1 | 722.9 | 1560.5 | +115.2% |
| Installed / --version | 1611.7 | 1672.1 | 1658.8 | 1696.2 | +3.8% |
| Installed / empty scope | 1631.5 | 2035.9 | 1678.2 | 2073.6 | +24.8% |

The prepared empty-scope median increases by 816.3 ms (2.152 times) in the checkout and 404.4 ms (1.248 times) installed. Version medians remain near baseline. This is a measured regression in invocation overhead; acceptance does not describe M6 as faster. No profiling separates hashing, process startup and file I/O costs.

Wall durations are also retained for every sample (`performance/samples.jsonl`, `performance/wall-summary.json`):

| Location / call | Base median | M6 median | Base p95 | M6 p95 |
| --- | ---: | ---: | ---: | ---: |
| Checkout / --version | 703.5 | 693.2 | 720.7 | 716.4 |
| Checkout / empty scope | 708.8 | 1532.5 | 4293.3 | 1561.7 |
| Installed / --version | 1614.1 | 1672.6 | 1669.8 | 5241.5 |
| Installed / empty scope | 1631.5 | 2041.5 | 1678.2 | 5613.3 |

Some wall samples contain about 3.58 additional seconds absent from the monotonic readings. Their cause was not established. In particular, installed empty-scope wall p95 is 5613.3 ms for M6 versus 1678.2 ms for baseline, while monotonic p95 is 2073.6 versus 1678.2 ms. Both are observations, and this report does not attribute the wall tail difference to KofMut or discard those samples. The earlier ninety second deadline probe also showed divergent clock readings. These host observations limit timing attribution beyond the recorded measurements.

Initial calls were recorded before warm sampling, with `--version` preceding empty-scope evaluation for each variant. KofMut application caches started unapproved; the OS page cache was not purged. Baseline source `--version` builds its engine; M6 informational commands prepare only the minimal bootstrap when needed. Initial monotonic seconds (`performance/initial.json`, with raw stdout/stderr and timestamped progress events):

| Location | Base first version | M6 first version | Base following empty scope | M6 first preparation + empty scope |
| --- | ---: | ---: | ---: | ---: |
| source | 5.502 | 5.247 | 0.710 | 12.829 |
| installed | 1.710 | 6.858 | 1.711 | 13.336 |

M6 first-evaluation phase intervals in monotonic seconds, delimited by actual progress messages:

| Location | Metadata/package/content capture before detected | Candidate creation + compilation | Operational checks + final integrity/publication | Handoff + empty evaluation/report |
| --- | ---: | ---: | ---: | ---: |
| source | 0.748 | 2.258 | 9.156 | 0.667 |
| installed | 1.297 | 2.275 | 9.156 | 0.609 |

Initial M6 checkout preparation/evaluation was 12.829 monotonic s and 16.409 wall s; installed was 13.336 s on both clocks. Initial capture and compilation are outside the mutation budget. `performance-complete.json` and `final-audit.json` confirm the sample count/order and exact final benchmark runtime inputs. Measurements require fresh disposable caches to reproduce the initial-call phase; rerunning against the populated archived images would measure warm reuse instead.

## Validation corrections and limits of earlier runs

Behavioral red/green artifacts are retained. First preparation initially lacked compatibility behavior. Installed source/receipt tests first failed until receipt 2 and runtime sources were included. The first state-overlap regression wrote generated metadata inside evaluated inputs; the existing inventory test reproduced it, and preflight now prevents that write. A handoff lease gap allowed uninstall; `handoff-lease-red.log` reproduces it and the continuous flock lease fixes it.

Kof 0.6.6 rejected calculated assert messages with PARSE087 before executing tests. Local StatementParser.java and AssertMessageLiteralTest.java confirm the literal-only contract and historical discarded messages. An editing probe used the installed official lexer/parser to replace only affected ASSERT keyword tokens with ordinary diagnostic functions. Conditions/diagnostic expressions were preserved; no other grammar or raw-source regular expression mutation was introduced. `assert-diagnostics-edits.log` records 14/70/47 replacements in CLI/Install/Run; later tests already use literal messages or those functions.

Both first installed cycles passed 43/44. Project `/` with invalid configuration exposed a changed diagnostic at preflight. The fix reuses MutationRun.finish from the captured failure, preserving the established refusal/error report contract without rereading config or admitting project commands. The existing preservation tag passed on both repaired installations, followed by complete installed cycles. Earlier failed cycles and unchanged payload inventories remain separately identified.

Six concurrent broad suites exposed an incorrect timeout boundary around the entire bootstrap orchestrator, which also constrained installer barriers and lock waiting. Those failures are not acceptance. Application compiler readiness, individual nested compilation deadlines and the total coordination budget now have separate boundaries; the established installer lifecycle is preserved. A twelve second installer barrier test passes. Final verification limits concurrency to two independent suites and measures performance afterward.

The next full source checkpoint passed 29 CLI/44 mutation tests on both distributions, but installation finished 24/25: the damaged-entry regression caught a ClassFormatError before package integrity could produce its established diagnostic. The old launcher hash guard had been replaced by a preflight that needed to load the damaged class. Independent class checksum guards now run in the shell and source bootstrap before loading packaged code, including a damaged preflight class. Failed checksum output and preflight stderr are retained with an evidence location. `class-integrity-red.stderr` and `preflight-evidence-red.*` preserve the two failures; `accepted-class-integrity-<version>.stdout` passes the original damaged-entry journey on both versions (28613/28882 ms). The readonly source-integrity journey also reads the actual retained stderr file. Fresh `accepted-*` source runs supersede the failed `final-*` checkpoint and include the full entry point; this is not accepted solely from a targeted rerun.

Both new focused tags passed (8 CLI/7 installation). The full 0.6.6 CLI passed all 29; 0.6.4 passed 28/29, with an unidentified assertion in the command-timeout journey. No assertion-level data survived in that old test. A diagnostic-only isolated repeat passed at 11243 total wall ms; it cannot explain the original failure. Independently, the test's 15 second whole-preparation ceiling was unjustified: the contract permits 90 seconds for capture/coordination. The delivered test now observes compiler readiness and requires exit within 10 command seconds plus 2 shared cleanup seconds using a monotonic clock, separately checks total preparation/cleanup, and retains exit/protocol/no-project-output/child-cleanup/retry assertions. Product deadlines did not change. Both new focused checks passed (command plus cleanup 10315/10319 ms, preparation 11163/11166 ms; `timeout-observable-<version>.stdout`). Final acceptance uses a new complete `confirmed-check-0.6.4` and completed `accepted-check-0.6.6`, with the latter's test-only timing delta covered by its separate focused probe and source hashes. The failed `accepted-check-0.6.4` remains historical evidence with an unknown failing assertion.

The complete 0.6.6 checkpoint subsequently passed 29/44/25/15; repeated 0.6.4 passed CLI29/Run44 and continued through installation. A final permission probe reproduced an early diagnostic gap (`state-permission-red.stderr`): the coordinator could not create its evidence directory, returned 2 without evaluating the project, but omitted version/evidence and suggested reinstalling. Its outer error handler now writes the failure into the existing private context using available fresh metadata; the shell preserves installed evidence or copies source evidence through the established cleanup helper. This is an error-path delta after the full source snapshots, with successful dispatch/deadlines/mutation/reporting unchanged. Both final focused snapshots pass readonly/cache/source-integrity plus blocked evidence writes/recovery, and the old source context-cleanup journey: 0.6.4 installation/context 54367/9386 ms, 0.6.6 55170/10141 ms. `diagnostic-completion-acceptance-<version>.json` inventories all 76 files; final installed suites/benchmarks use these exact updated sources. Acceptance distinguishes that explicit delta instead of claiming the complete source command was rerun after it.

The ninety second lease probe records both clock sources: wall 90.341 s and monotonic 81.549 s. An initial validation assumption that monotonic elapsed must exceed 88 s was not part of the upper-bound contract and was corrected; original observations are preserved in `deadline-first-observation/`. The cause of the clock divergence was not established. Runtime mutation budgets remain monotonic, and the successful 93786 ms evaluation verifies that preparation does not cap budget zero evaluations.

## Preservation and documentation

Final audit (`final-audit.json`) verifies the original a32a88b ExecPlan as an exact prefix, all 26 historical validation files unchanged, clean local Kof sources, and unchanged 0.6.4 jar SHA-256 `137a838d38757e317545474d55ad6a3ad291fb86d263ae77d9197cf705829c62`. Actual Java/JDK component fingerprints and absence of the real user KofMut command/current are recorded in `preservation-preliminary.json`.

English/Brazilian Portuguese README, CLI and report guides preserve all original headings. The link audit checks eight documents and 104 local links (`documentation-audit.json`). Receipt field names and object/array shapes are explicit in both CLI guides. The final delivery manifest `.agent/validation/kofmut-m6.sha256` identifies the accepted tree. `final-audit.json` confirms source/installed/focused snapshot hashes and modes, exact benchmark runtime sources and pair order, six final failure cases with restored payloads, no task processes, unchanged real distributions/local Kof sources and `git diff --check`.

This proves tested real installations, not unrestricted support for future versions. Future combinations must pass their own operational preparation. Filesystem locks/atomic moves, writable generated state and an available concrete runtime remain required. Unknown syntax and invalid execution evidence remain inconclusive/error results. Generated images/logs are retained; caches can be rebuilt after active calls finish. Sensor integration and the historical M3P ninety second project performance target remain deferred and unmet.
