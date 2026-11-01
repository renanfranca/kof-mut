# Recovery of the implementation from before Luna, 2026-10-26

## Scope and identity

KofMut base a40b20ac37afac302efc2a0dae7702e44720e166, existing multiple-test-invocations branch. This record continues, without modifying, [the original acceptance](multiple-invocations.md) and [its manifest](multiple-invocations.sha256). Recovery and acceptance are separate: exact recovery passed; public and real acceptance still require the commands and scenarios below. No time limit is widened.

Recovery source: local session 01a178d1-f353-7300-ad3f-22c8b5fbbb44. Only the original file edits were replayed in disposable storage, not arbitrary session commands. All ten SHA-256 values matched before any recovered file was applied. Immediately after application, `sha256sum -c .agent/validation/multiple-invocations.sha256` returned 0:

```text
.agent/README.md: OK
.agent/validation/multiple-invocations.md: OK
EXECPLAN.md: OK
docs/cli.md: OK
docs/cli.pt_BR.md: OK
docs/report-format.md: OK
docs/report-format.pt_BR.md: OK
src/main/kof/kofmut/Evidence.kf: OK
src/test/fixtures/mutation-runner: OK
src/test/kof/kofmut/Run.kf: OK
```

The exact recovered snapshot remains in optional local evidence `.agent/tmp/recovery-20261026/reconstructed/`. The original manifest identifies that snapshot. Subsequent plan/index additions are continuations and will be covered by a separate delivery manifest, without replacing the historical seal. Code, tests and public KofMut guide bytes still match the recovered versions.

## Corrected comparison

All eight inventories retained from Luna identify Evidence.kf as `be118bd66eab68887315bba54f119676ae8f9c31d13a3745e821874b95aafded`, including the four copies labelled current. Those comparisons did not exercise the corrected reader and cannot support a performance or correctness comparison. Original scripts, logs and inventories are retained unchanged as historical evidence.

Fresh base copies came from `git archive a40b20a`. Fresh corrected copies received the recovered checkout's actual file bytes. Before each measurement, every tracked file hash was checked against its designated source and no build cache existed. Expected reader identities:

| Version | Evidence.kf SHA-256 |
| --- | --- |
| Base | be118bd66eab68887315bba54f119676ae8f9c31d13a3745e821874b95aafded |
| Recovered | 5e46e9ce8c6a7f8f951b1a46108eb44442d0bdcde624fdc8aa24d71d6a22fc46 |

The same real PATH Kof 0.6.6 was fixed for all runs, jar SHA-256 `198bb211dbcefe60bd02f703dff991e82ba55c94f805b1b2b863362757289e58`, research checkout `7c237861a9035d84b1f7ec4cfddd89daef4c6ddd`. Default JVM settings were preserved. Each fresh copy ran the same version warmup before evaluation. Order was base/detected, recovered/survived, recovered/detected, base/survived. No suites ran concurrently with these measurements. Initial page-cache state and unrelated host work were not controlled; no speed regression or host-load causality is inferred.

| Trial | Version warmup, seconds / exit | Evaluation, seconds / exit | Observed stage |
| --- | --- | --- | --- |
| 1-base-detected | 22.589 / 0 | 14.209 / 2 | application compile deadline, no user report |
| 2-current-survived | 23.446 / 0 | 14.063 / 2 | application compile deadline, no user report |
| 3-current-detected | 23.082 / 0 | 14.47 / 2 | application compile deadline, no user report |
| 4-base-survived | 23.024 / 0 | 13.956 / 2 | application compile deadline, no user report |

Each run's stderr contains:

```text
compile exceeded its command deadline (10000 ms maximum)
```

These are preparation refusals, not wrong mutant classifications. Successful informational warmup only proves bootstrap readiness. It does not approve the application or its real mutation behavior. Separate bounded compilation/probe observations follow; failed compilation leaves the unexecuted probes unknown.

## Separate compilation and probe measurements

The command was `kof build --target jvm --classpath <fixed kof.jar> --output <fresh classes>`, over exact source copies with the same generated source-root manifest used in preparation. The observer enforced ten seconds per command and recorded process exits separately from timeout. Base compilation hit the ten-second bound (10.122 s including termination, observed exit 143). Recovered compilation passed in 9.374 s, exit 0. One success and one timeout are insufficient to establish a performance difference.

Direct invocation of the unchanged compiled CompatibilityProbe measured frontend, killed and survived separately, with outer commands limited to ten seconds and the unchanged 8500 ms internal budget. Frontend passed in 0.977 s. Both mutation probes refused approval with exit 2; neither exceeded the outer ten-second limit. Their independent reports show:

| Probe | Whole command, seconds | Engine, ms | Baseline check / test, ms | Result |
| --- | --- | --- | --- | --- |
| killed | 9.428 | 8559 | 1132 / 6923 | incomplete; one Timeout at mutant check |
| survived | 9.467 | 8559 | 1087 / 6591 | incomplete; one Timeout at mutant check |

Both baselines contain one executed case, zero failures and exit 0. Both reports have one candidate, one executed, zero killed, zero survived, one timeout, zero testError/pending/discards. They are diagnostic runs of the unchanged probe, not public readiness or user-project approval. No behavioral approval was fabricated or bypassed. The baseline consumes most of the internal budget, and the remaining time expires during the mutant check; no mutant test result establishes detection/survival. Budget expiration is demonstrated; why these commands take this long remains unresolved.

## All thirteen historical CLI failures

Historical command: `kof test src/test/kof/kofmut/Cli.kf` inside `./scripts/check`, suite exit 1, 18 passed and 13 failed of 31. Eight failures have preparation diagnostics in that command's output. Five lack enough evidence to identify the failing child command, numeric return or stderr. Later failures do not retroactively establish their causes. The test source determines the intended command sequence but not which unlabelled assertion failed.

| Test | Stage established by original log | Child exit evidence | Original diagnostic |
| --- | --- | --- | --- |
| launcher preserves argv cwd environment and application exit status | compatibility killed probe | 2 inferred from preparation error path; numeric child exit not printed | compatibility killed verification failed |
| cache is reused and invalidated by VERSION and source contents | unknown | unknown; not captured | assertion failed |
| a prepared evaluation uses one work JVM and keeps its own report | compatibility killed probe | 2 inferred from preparation error path; numeric child exit not printed | compatibility killed verification failed |
| prepared evaluations repair damaged candidates and revalidate source bytes | compatibility killed probe | 2 inferred from preparation error path; numeric child exit not printed | compatibility killed verification failed |
| warm argument fixture preserves the public invocation without a compiler | unknown | unknown; not captured | assertion failed |
| application consumes its handoff and forwards TERM through the public invocation | unknown | unknown; not captured | assertion failed |
| a new Kof prepares and checks compatibility once before evaluation | compatibility killed probe | 2 inferred from preparation error path; numeric child exit not printed | compatibility killed verification failed |
| compilation alone cannot approve a frontend behavior change and retry repairs it | application compilation | 2 inferred from preparation error path; numeric child exit not printed | compile exceeded its command deadline (10000 ms maximum) |
| concurrent first evaluations share one complete preparation | unknown | unknown; not captured | assertion failed |
| INT and TERM discard an emitted candidate and allow retry without cleanup | compatibility killed probe | 2 inferred from preparation error path; numeric child exit not printed | compatibility killed verification failed |
| a preparation command timeout refuses evaluation and retry needs no cache cleanup | application compilation | 2 inferred from preparation error path; numeric child exit not printed | compile exceeded its command deadline (10000 ms maximum) |
| contents changing during preparation cannot publish approval even with preserved timestamps | unknown | unknown; not captured | assertion failed |
| JDK contents invalidate approval with the same declared version and timestamps | application compilation | 2 inferred from preparation error path; numeric child exit not printed | compile exceeded its command deadline (10000 ms maximum) |

The timeout-refusal test deliberately causes one compile timeout; its historical failure occurs on the subsequent retry's killed verification. That expected timeout alone is not a defect. The frontend-change test expects behavioral refusal but its original diagnostic stops earlier at compilation, so it does not prove behavior rejection. For the five unknown stages, no additional cause is assigned. The six known killed-verification refusals have no retained individual report in the original suite output; their internal cause remains unknown. A current diagnostic timeout does not prove that every historical probe timed out.

Optional local `.agent/tmp/recovery-20261026/historical-failures.json` stores each test's exact source starting line, command expressions, suite return, original stderr excerpts and explicit unknown fields. This record preserves the essential conclusions without requiring those logs.

## Public and real acceptance

Required public commands: `kof test src/test/kof/kofmut/Cli.kf --tag compatibility`, `kof test src/test/kof/kofmut/Run.kf --tag multiple-invocations`, `./scripts/check`, `git diff --check`. Their fresh outcomes will be appended at the validation boundary. Any check short-circuit will be distinguished from a missing-suite standalone attempt.

Required fresh SiFuture cases use unchanged Bash recipes/configuration and two separate suite files totaling 115 cases: Background Killed/complete/0; calculation detected by last file Killed/complete/0; surviving calculation Survived/complete/1; initially failing test baseline_failed/2, 115 cases/one failure/no evaluated mutant. UUID, announced current report, scope, all counters and input bytes/modes must match. No guide limitation is removed before all public and real acceptance passes.

### Fresh required public commands

All commands used the fixed real Kof 0.6.6 on Linux/JVM and unchanged execution inputs. `kof test src/test/kof/kofmut/Cli.kf --tag compatibility` returned 1 (365.355 external seconds):

```text
7 failed of 8 tests
exit code: 1
0 passed, 1 failed
time: 365038ms total, slowest src/test/kof/kofmut/Cli.kf (365038ms)
```

`kof test src/test/kof/kofmut/Run.kf --tag multiple-invocations` returned 1 (82.230 external seconds):

```text
FAIL complete invocations accumulate cases and retain failure in either order: behavior failed; see evidence above
one report path announcement required:
FAIL failure in first or last baseline invocation prevents every mutant: behavior failed; see evidence above
one report path announcement required:
FAIL invalid trailing invocations cannot approve baseline or detect mutation: behavior failed; see evidence above
────────
3 failed of 3 tests
```

Trailing spaces after the diagnostic colon are omitted in this excerpt. The first group prints preparation killed-verification refusal. The other groups require a current report and fail its discovery; their expected exit 2 alone does not prove a legitimate baseline failure. No complete public parser-scenario acceptance is demonstrated.

`./scripts/check` returned 1 (1086.264 external seconds), stopping at its CLI command:

```text
12 failed of 31 tests
exit code: 1
0 passed, 1 failed
time: 1084832ms total, slowest src/test/kof/kofmut/Cli.kf (1084832ms)
```

This is 19 passing/12 failing CLI cases in the fresh run, distinct from the historical 18/13 classification above. Later suite execution cannot make this command pass retroactively. Full Run, Install and frontend contracts are being attempted separately to record their own outcomes. Fresh logs and exit and duration records for each command remain optional local evidence under `.agent/tmp/recovery-20261026/`; full results and remaining gaps will be appended after those commands and real attempts finish.

### Normal public preparation subsequently approved

During standalone Run, the normal launcher published source approval SHA-256 `725738568767a6396eae22f95d36263f8c953f2bf3db1747a407005fdb2dfce1`, containing the recovered reader input hash `5e46e9ce8c6a7f8f951b1a46108eb44442d0bdcde624fdc8aa24d71d6a22fc46`. The associated fresh synthetic probes in evidence UUID `eeb1d590-5695-4236-81a9-6de86bb00860` both completed within 8500 ms. Killed probe: 6069 ms, passed one-case baseline (test 2365 ms), one candidate/executed/Killed, complete. Survived probe: 5797 ms, passed one-case baseline (test 2366 ms), one candidate/executed/Survived, complete. Neither has timeout, testError, pending, compileError or discards.

These are later observed successes, not replacements for earlier failures. No cause for the timing variance is established. The receipt and exact independent reports are retained in `.agent/tmp/recovery-20261026/public-approval-observed.json` and copied synthetic preparation evidence. Full Run and remaining suites continue; a fresh focused attempt after them is justified by this newly demonstrated public readiness. A coherent final full check is still required if focused and real acceptance passes. No limit, approval check, input source or compiler content changed.

### Standalone full mutation-cycle result

`kof test src/test/kof/kofmut/Run.kf` returned 1 (1491.661 external seconds): 34 passed, 13 failed of 47. The failures occupy the first thirteen test positions; several print preparation refusals and others print assertions or missing report discovery, so not every individual cause is established. All subsequent 34 cases passed after automatic public approval, including these actual output lines:

```text
PASS complete invocations accumulate cases and retain failure in either order
PASS failure in first or last baseline invocation prevents every mutant
PASS invalid trailing invocations cannot approve baseline or detect mutation
────────
13 failed of 47 tests
exit code: 1
0 passed, 1 failed
time: 1491459ms total, slowest src/test/kof/kofmut/Run.kf (1491459ms)
```

Those three public groups now exercised the recovered reader through the normal launcher: six valid shapes, baseline failure in either invocation and fourteen invalid shapes at baseline/variant. They do not retroactively make this whole suite or the earlier focused invocation pass. Standalone Install and frontend contracts remain in progress before real acceptance and one justified final focused/full-gate attempt.

First resumed comparison metadata correction: `patchSha256` in the initial comparison result files hashes the literal diagnostic string `verified recovered file bytes`, not a Git patch, and must not be used to identify inputs. No patch was used to construct those corrected copies: actual recovered bytes were copied, every tracked file was checked against its designated source, and distinct reader hashes were asserted before each measurement. The complete checked inventories remain the authoritative identity proof, so this metadata defect does not invalidate those copy identities or observed compile refusals. The original artifacts are preserved, not rewritten. The new comparison-ready script removes that field and records a SHA-256 of its actual input inventory instead.

## Final observed results and acceptance gaps

Every suite was attempted: original check stopped at CLI; standalone full Run, Install and frontend contracts then executed. After normal public readiness was independently observed, one new verified comparison and one final compatibility/focused attempt were made. No second full check was attempted because comparison, compatibility and all four real criteria still failed. The earlier full-check failure remains the observed required gate result; no earlier run was replaced.

| Command or control, Linux/JVM Kof 0.6.6 | Native exit | Observed result | External seconds |
| --- | --- | --- | --- |
| First CLI compatibility tag | 1 | 1 passed / 7 failed of 8 | 365.355 |
| First multiple-invocations tag | 1 | 0 passed / 3 failed of 3; preparation/report discovery | 82.230 |
| ./scripts/check | 1 | CLI 19 passed / 12 failed of 31; short-circuit | 1086.264 |
| Standalone full Run.kf | 1 | 34 passed / 13 failed of 47; all three new groups passed | 1491.661 |
| Standalone full Install.kf | 1 | 16 passed / 15 failed of 31 | 2097.316 |
| ./scripts/launch contracts | 0 | 15 frontend groups passed | 15.601 |
| Exact recovered-reader control | 0 | 2 passed; six valid and fourteen invalid shapes | 5.375 |
| Exact base-reader negative control | 1 | valid-shape group failed; invalid-shape group passed (expected exit 1) | 5.579 |
| Final CLI compatibility tag | 1 | 1 passed / 7 failed of 8 | 327.502 |
| Final multiple-invocations tag | 0 | 3 passed / 0 failed of 3 | 173.063 |
| git diff --check | 0 | passed before final records | 0.010 |

The exact final focused output is:

```text
SUITE src/test/kof/kofmut/Run.kf (47 tests)
kof test: tag 'multiple-invocations' (3 of 47)
PASS complete invocations accumulate cases and retain failure in either order
PASS failure in first or last baseline invocation prevents every mutant
PASS invalid trailing invocations cannot approve baseline or detect mutation
────────
0 failed of 3 tests
1 passed, 0 failed
time: 172884ms total, slowest src/test/kof/kofmut/Run.kf (172884ms)
```

The final compatibility summary remains:

```text
────────
7 failed of 8 tests
exit code: 1
0 passed, 1 failed
time: 327221ms total, slowest src/test/kof/kofmut/Cli.kf (327221ms)
```

Standalone Install includes preparation refusals in printed diagnostics, including the final linked-state recovery case. Individual causes of every generic assertion have not all been established. Its failure is not converted into a passing installation claim. The frontend contract pass proves those fifteen executed contracts, not mutation readiness for every invocation. The negative reader control's exit 1 is expected and is not counted as an acceptance failure of the recovered parser.

### Second verified alternating comparison

This fresh matrix repeats the same archive-versus-byte-copy construction and independent full inventories, with empty build caches and identical version warmup policy. Each `inputInventorySha256` is verified against the actual saved inventory file. Both designated reader hashes are checked before every measurement. Samples remain sequential in base/recovered/recovered/base order. All four compiled, reached frontend/real killed approval, and were refused when the internal 8500 ms mutation budget expired during mutant test execution. No caller-project report was announced. The outer exit 2 is the compatibility refusal, distinct from the inner report's incomplete state.

| Trial | Warmup seconds / exit | Call seconds / exit | Internal engine ms | Baseline check / test ms | Mutant observation |
| --- | --- | --- | --- | --- | --- |
| 1-base-detected | 13.475 / 0 | 19.035 / 2 | 8554 | 792 / 4109 | Timeout at test, 3535 ms |
| 2-current-survived | 12.889 / 0 | 18.404 / 2 | 8555 | 732 / 4084 | Timeout at test, 3618 ms |
| 3-current-detected | 13.869 / 0 | 19.681 / 2 | 8552 | 887 / 5184 | Timeout at test, 2325 ms |
| 4-base-survived | 19.175 / 0 | 22.485 / 2 | 8544 | 1158 / 6067 | Timeout at test, 1144 ms |

Both source versions are genuinely exercised, but no complete user-fixture detection/survival comparison is accepted. These are censored deadline observations, not evidence of a reader regression or a completed speed comparison. No high-load observation alone identifies the underlying cause.

The separate base profile's one retry compiled successfully in 6.558 s and passed frontend in 0.770 s. Unchanged killed/survived probes were then measured independently, with outer commands limited to ten seconds and the original 8500 ms engine budget:

| Base probe | Outer seconds / exit | Engine ms / status | Baseline check / test ms | Mutant result |
| --- | --- | --- | --- | --- |
| killed | 9.247 / 2 | 8552 / incomplete | 724 / 4279 | Timeout / test |
| survived | 9.253 / 2 | 8573 / incomplete | 761 / 3977 | Timeout / test |

These later base measurements must not be directly compared to earlier recovered-profile clocks as though host and page-cache state were controlled. The separately recorded public recovered approval remains genuine, including successful killed/survived reports; it does not erase preparation refusals in other copies.

### Four fresh real SiFuture attempts

SiFuture checkout base for this attempt: `a451d311fe3beb7f37cbfd517aa96bbbb102a14b`; only disposable copies were evaluated. Every call used the existing run/inspection Bash recipes, real configuration and wrapper, two independent suite files and all 115 cases. Scope, schema/tool/Kof version, UUID, canonical report namespace and the single JSON-decoded `reportPath=` from each own call were checked. Each recipe, saved native exit and inspection returned 3. All four reports are incomplete, with check exit 0/filesChecked 1, baseline test exit 137 and an explicit test timeout. No candidate or mutant was evaluated; every mutant counter is zero, with empty mutants/discards/limitations. The empty limitations list and mutant timeout counter zero do not contradict a baseline timeout: the evidence lives in baseline.test, before mutation generation.

| Scenario | Expected mutation outcome | Normal test command | Observed mutation | Baseline check / test ms | Preserved input files |
| --- | --- | --- | --- | --- | --- |
| background | Killed, complete/0 | 115 cases / 0 failed / exit 0 | incomplete/3, no mutants | 7307 / 10033 | 190, equal bytes/modes |
| detected | Killed from second file, complete/0 | 115 cases / 0 failed / exit 0 | incomplete/3, no mutants | 7572 / 10032 | 191, equal bytes/modes |
| survived | Survived, complete/1 | 115 cases / 0 failed / exit 0 | incomplete/3, no mutants | 7304 / 10037 | 191, equal bytes/modes |
| baseline-failed | baseline_failed/2, one failing case, no evaluated mutant | 115 cases / 1 failed / exit 1 | incomplete/3, no mutants | 6231 / 10033 | 191, equal bytes/modes |

| Scenario | Own runId | SHA-256 of announced report |
| --- | --- | --- |
| background | 68f9e38e-99ed-40c3-b33d-d11626d36874 | 27cfa3620ffee7fa7b6927e120ac2bf8b35caf496a786209d4ab1957f3f6bcf4 |
| detected | b15ef54a-c1cd-468e-b080-5e165f5c657b | eb4e5cab69cdd891d3a6affcafb728e5f5030936f1a8d6618035955ad7440502 |
| survived | f2304068-4a33-45cc-8cef-cff679c0bc9a | ce9faeaab2f428fbf9c88ae4da4a792afa018d04a7b99942f5c9f4ff4047c4d2 |
| baseline-failed | d12f6354-fad8-4098-a3ef-d052ce17b17f | d78e851f17658dd5df9ddcca08a8d9e447d2e0955e45a5a3afcccbe849d94dda |

All scopes were checked explicitly: Background uses `src/main/kof/sifuture/game/Background.kf`; the three controlled calculations use `src/main/kof/sifuture/game/ManualMutationProbe.kf`. Fresh exact announced paths, retained as optional local evidence, are:

- background: `/home/renanfranca/projects/kof-sifuture/.agent/tmp/recovery-20261026/integration/project-background/.agent/tmp/kof-mut-reports/2ccdfa1b26d3ed9c3826b7977fd84b297db9b17aa33ecaa1b94b14829b7a309b/68f9e38e-99ed-40c3-b33d-d11626d36874-7197087890370321369/report.json`
- detected: `/home/renanfranca/projects/kof-sifuture/.agent/tmp/recovery-20261026/integration/project-detected/.agent/tmp/kof-mut-reports/d50d89f6ce50028ba877f8914df2ffbb77bd6602c549681c0d2d040398e646da/b15ef54a-c1cd-468e-b080-5e165f5c657b-16755151144421050315/report.json`
- survived: `/home/renanfranca/projects/kof-sifuture/.agent/tmp/recovery-20261026/integration/project-survived/.agent/tmp/kof-mut-reports/e1245aae7e413890590278bab1b9e2c274f31728b918ef9d8daa1d65315c2505/f2304068-4a33-45cc-8cef-cff679c0bc9a-15150644555272767156/report.json`
- baseline-failed: `/home/renanfranca/projects/kof-sifuture/.agent/tmp/recovery-20261026/integration/project-baseline-failed/.agent/tmp/kof-mut-reports/8b338fc307a45650cfeaf147dc608545c47fcce8086597ac569425653be35fb8/d12f6354-fad8-4098-a3ef-d052ce17b17f-11279604528308794586/report.json`

The ordinary test commands themselves establish why the preserved ten-second limit prevents these observed runs. Each wrapper executes its suite calls sequentially; it does not give each suite a new KofMut command budget. Their reported CLI elapsed times, excluding wrapper preparation and CLI startup overhead, already exceed the single 10000 ms command deadline:

| Scenario | First / second Kof CLI ms | Sequential sum, lower bound for wrapper ms |
| --- | --- | --- |
| background | 4165 / 7820 | 11985 |
| detected | 9472 / 5928 | 15400 |
| survived | 9776 / 5865 | 15641 |
| baseline-failed | 8384 / 5441 | 13825 |

Actual Background ordinary-command timing excerpts:

```text
time: 4165ms total, slowest /tmp/sifuture-kof-4_tdaj9w/source/Main.kf (4165ms)
time: 7820ms total, slowest /tmp/sifuture-kof-ldl44t_v/source/Main.kf (7820ms)
```

The [wrapper loop](../../../kof-sifuture/scripts/kof_project.py#L152) runs `_run(...)` synchronously for each file, and `_run` uses `subprocess.run`. Source excerpt (same bytes in all copies):

```python
    for path in suites:
        print(f"Suite: {path.relative_to(tests)}", flush=True)
        with prepared_sources(suite=path, root=root) as source:
            code = _run([str(kof_executable(kof)), "test", str(source / "Main.kf"), "--target", target])
            if code and not first_failure:
                first_failure = code
    return first_failure
```

The sums are therefore lower bounds, not overlapping process durations added together. All four baseline logs show that the second file had started when termination occurred. Background completes Extra first; the calculation cases complete GameJourney's 114 cases before starting ZProbe. No complete baseline test output is accepted from those truncated commands.

The [existing baseline guard](../../src/main/kof/kofmut/Run.kf#L91) explains the observed status and zero mutants:

```kof
        if (tested.status != "Survived") {
            if (tested.status == "Timeout" || tested.status == "Pending") { status = "incomplete" } else { status = "baseline_failed" }
            return
        }
```

Timeout selects incomplete and returns before candidate generation. A normally completed failing suite would follow baseline_failed instead. This is why the deliberately failing normal test command (115 cases/one failure) does not prove the required KofMut baseline_failed/2 scenario: KofMut's command was terminated first. Durations of approximately 10032–10037 ms include process-group termination/cleanup; the 10000 ms wait limit itself was preserved. The repeated baseline timeouts are demonstrated; why these commands take this long remains unresolved.

### Criterion disposition and necessary decision

- Recovery: passed, ten historical entries matched before application; original exact snapshot and manifest retained.
- Correct version selection and diagnosis: checked inventories/distinct readers, sequential measurements, separate compile/probes and all thirteen original failures classified. Relative performance and several original individual causes remain unknown; deadline-limited trials are not complete detection/survival comparisons.
- Reader behavior: passed through the normal launcher in all three new groups, final tag exit 0, plus exact current/base isolated discrimination controls.
- Public compatibility and full gate: not accepted; final compatibility exit 1, required complete check exit 1, standalone Run/Install also exit 1 despite partial passes. All suites were attempted, no suite was omitted or claimed passed after check short-circuited.
- Real four-scenario acceptance: not accepted, all four baseline test commands timed out and returned incomplete/3 before any mutation; normal test controls and file preservation passed.
- Documentation gate: SiFuture guides retain the limitation until both public and all four real outcomes pass. Wrapper, configuration, scope and permanent catalog remain unchanged.

The approved plan remains incomplete. The next decision is whether to repeat the measured commands under controlled execution conditions capable of meeting the existing deadlines, or explicitly reconsider the applicable deadlines/recipe constraints. No particular new limit is proposed or silently applied. Do not omit suite files, skip behavioral approval or reuse an earlier report to turn this record into approval. No new production defect beyond the recovered reader change was established; generic historical assertion causes are not assigned to host load.

## Final preservation and documentation checks

Fresh link validation of the KofMut index, recovery record and four restored public guides passed (exit 0); runner Bash syntax and final diff checks passed. The whole-history SiFuture link checker reports 51 messages, exactly identical when run against the initial HEAD texts. No message belongs to the appended sections; new links pass. Many old messages concern line suffixes interpreted as filenames, alongside old fragments. These are preserved historical diagnostics, not newly introduced links or an assertion that all historical links are valid.

Final preservation audit: KofMut has 141 initial tracked files; exactly the nine restored/continued tracked paths differ, and all other 132 files retain their initial bytes/modes. The eight historical manifest entries excluding the continued index/plan still match exactly, including the original validation record. All ten reconstructed entries verify in the retained exact snapshot, and the recovered original plan remains a prefix of the continued plan. The original manifest is unchanged. All 1590 previously sealed local evidence files remain present and equal. No historical validation artifact was removed or resealed as though earlier claims had passed.

SiFuture has 204 initial tracked files; only EXECPLAN.md and sensors-adoption.md receive appended continuity, leaving 202 protected tracked files unchanged. All 49 protected configuration/scope/manifest/wrapper/src/tests files and both guides retain their initial bytes/modes. Both recipe blocks retain their original bilingual SHA-256 values: execution `f7df764e0dbece0acf698dbcdab2ad6c512563838dd9796d9a8e8832b0652695`, inspection `11c97fb386e39860a69e87a1da1ad5422439f6e0c11711bc47fa28aac6353834`. All earlier SiFuture record/plan bytes remain prefixes. External plan prefix is preserved; its continued SHA-256 is `d573af18117f70b70334a4241f9bb3f8cbdf330d504069df3bca034de67a4a2d`.

Both actual repository Git exclusion files contain `/.agent/tmp/` exactly once. Kof source remains clean at 7c237861a9035d84b1f7ec4cfddd89daef4c6ddd; installed jar contents retain the captured SHA-256. No dependency modification/download/update, wrapper/configuration/catalog change, agent, worktree, commit or publication occurred.

[New delivery manifest](multiple-invocations-recovery.sha256) identifies the continued delivered files, without replacing the [historical manifest](multiple-invocations.sha256). It is expected that the old seal names the original index/plan bytes, while the new seal names their documented continuations. Optional local evidence is inventoried separately under `.agent/tmp/recovery-20261026/`; the findings and gaps above do not require it to be understood. Recovery and reader acceptance are demonstrated; overall plan acceptance remains pending as specified above.


## Authorized timeout integration acceptance (2026-10-26)

This continuation supersedes the pending public/real acceptance above under the explicitly authorized new deadlines. It does not rewrite the earlier failures or their unknown individual causes. Tested bases: SiFuture `54c317b52d010fbfa94e28499b05610d3ee62077`, KofMut `e8a08b6478d02bfd6d8e1158c2c9e9c913bc82b6`, plus this session's uncommitted changes identified below. Linux/JVM Kof 0.6.6, installed jar SHA-256 `198bb211dbcefe60bd02f703dff991e82ba55c94f805b1b2b863362757289e58`; local research checkout `7c237861a9035d84b1f7ec4cfddd89daef4c6ddd`. No CI workflow, commit, user installation or publication was performed; installation tests use disposable prefixes.

### Authorized boundaries and identity

SiFuture changes only `commandTimeoutMs` from 10000 to 30000 in its JSON configuration. `budgetMs: 0`, `maxParallelMutants: 1`, wrapper, permanent scope and permanent catalog remain unchanged. Config SHA-256: `a0303c0cd6fa65cb2e7d33e056a4e642a1f8dda00a1432b7d8b7bb3df6027f65`.

KofMut source launcher bootstrap compilation, bootstrap application compilation and coordinator compilation/probe commands use a 30000 ms maximum. The internal real mutation trial uses 25000 ms total while each check/test command retains 10000 ms. Full preparation remains 90000 ms from the original invocation including waits, and process cleanup keeps its shared 2000 ms deadline. The coordinator still computes remaining total time before limiting a command; the outer launcher also bounds bootstrap and coordinator by the original deadline. Starting another stage does not reset it. No evidence parser, JSON v1 shape, status, exit, mutation policy or real compatibility verification was changed.

Current source excerpt, [Compatibility.kf](../../src/main/kof/kofmut/launch/Compatibility.kf#L146):

```kof
var remaining = 90000 - (System.currentTimeMillis() - started)
if (remaining > 30000) { remaining = 30000 }
if (remaining <= 0 || !child.waitFor(remaining, TimeUnit.MILLISECONDS)) { throw label + " exceeded its command deadline (30000 ms maximum)" }
```

Subtracting elapsed time keeps the original total deadline; the cap changes only an individual command's maximum. Local CLI training and examples, Learn Kof chapters 21/23, interop/control-flow idioms, fake-idioms/weak-green-proof and current CmdTest implementation were consulted. Actual installed-target test execution, rather than compilation alone, is the evidence for this checkout.

| Changed execution input | SHA-256 |
| --- | --- |
| `scripts/launch` | `5d9164a74192b15c236cc8635161dc9df3dea47c0ff11b19448f82fce639c1c0` |
| `scripts/bootstrap/Launch.kf` | `79fe2bc625dadd9face9bd5ed0b0f5ae9476b636e2579b8d624cb16f83f5e521` |
| `src/main/kof/kofmut/launch/Compatibility.kf` | `2d45e3f52b3ddd58920bd738dd783070ed40413f97676fb9e7741cc6eef75bef` |
| `src/main/kof/kofmut/CompatibilityProbe.kf` | `e45031114f6ffe63b0bfdbee84f6cb61b5861157b767fa98ef54ea3a6f9ac078` |
| `src/test/kof/kofmut/Cli.kf` | `dbf9a4617117d8d789424c85b840ac8414a6c4d5a848d9236f4ebaf1ec9a8a01` |
| `src/test/fixtures/controlled-toolchain/kof` | `6357c4c377cca4b263804fdb556e7c7f24c3266f82270cd32e0261f119afa57b` |

### Commands and deadline controls

Commands ran sequentially from the KofMut root with the existing PATH distribution. External seconds use Python `time.monotonic`.

| Command | Native exit | External seconds |
| --- | --- | ---: |
| `kof test src/test/kof/kofmut/Cli.kf --tag compatibility` | 0 | 296.540 |
| `kof test src/test/kof/kofmut/Run.kf --tag multiple-invocations` | 0 | 86.363 |
| `./scripts/check` | 0 | 2822.044 |

Focused compatibility passes 9/0 and multiple-invocations passes 3/0. The complete check independently passes CLI 32/0, mutation cycle 47/0, installation 31/0 and all 15 frontend contracts, including the original ninety-second preparation deadline and evaluation beyond ninety seconds after confirmation. Essential complete-check summaries:

```text
0 failed of 32 tests
0 failed of 47 tests
0 failed of 31 tests
```

The added slow test first failed against the old compilation deadline, then passed after the implementation. Red command: `kof test src/test/kof/kofmut/Cli.kf --tag compatibility-limits`, exit 1:

```text
compile exceeded its command deadline (10000 ms maximum)
FAIL slow compilation and mutation trials retain real behavioral approval
1 failed of 1 tests
```

The controlled engine compile sleeps 11 seconds before invoking the real compiler, completes within the new 30-second cap and publishes valid behavioral approval. Both real internal mutation trials delay each individual command by 1.5 seconds, remain individually bounded at 10000 ms and finish at 10008/9608 ms in the focused run (10302/9835 ms in the full check). They are therefore above 8500 and below 25000. The production probe asserts the killed/survived states, complete JSON, exact counters and original Kof/frontend behavior; the new test reads each resulting duration and requires both trials, then reuses approval with compilation refused.

The blocked-compile focused control returns 2 after 30324 ms observed command/cleanup, 31213 ms whole preparation. It emits no caller stdout/report, confirms process termination and recovers on a fresh normal invocation. Full check additionally requires at least 29000 ms before timeout and an empty approval directory, so premature rejection or invalid publication cannot pass. Existing INT/TERM, content-integrity, frontend-behavior refusal, waiting/concurrency, contradictory/truncated evidence and real test-failure controls also pass. Additional time does not bypass any behavioral check or turn invalid evidence into approval.

### Four fresh SiFuture copies

Used the existing English run and inspection Bash blocks verbatim, byte-identical to Portuguese, from each new project's root. The configuration is the updated real configuration, the wrapper is unchanged and both independent suite files are included. Each normal command independently executes 115 cases: 0/0/0/1 failures and exits 0/0/0/1. Fresh run UUID, own single JSON-decoded `reportPath=`, canonical project namespace, report runId, schema/version, scope, baseline, exact counts, tool/recipe/inspection exits and input preservation were checked.

| Scenario | Run UUID | State/exit | Killed/Survived | External recipe seconds |
| --- | --- | --- | --- | ---: |
| background | `5edef194-8273-4eec-ac36-5554e9955b8f` | `complete/0` | 1/0 | 14.757 |
| detected | `660fb933-dfd0-45ae-9e29-61ea54e4b595` | `complete/0` | 1/0 | 15.538 |
| survived | `11984982-2786-4c42-b093-d32382099039` | `complete/1` | 0/1 | 15.543 |
| baseline-failed | `3612b9e3-4b33-49f7-8f95-ef33481848da` | `baseline_failed/2` | 0/0 | 8.912 |

Background scope is `src/main/kof/sifuture/game/Background.kf`; the other three use disposable `src/main/kof/sifuture/game/ManualMutationProbe.kf`. Successful baselines contain 115 executed cases and zero failures; failing baseline contains 115 cases and one failure. The first three have exactly one candidate and executed mutant; all timeout/testError/pending/compileError counters are zero, no discards or limitations. The failing baseline has zero candidates, executed mutants and all mutant counters, and returns before mutation. All 190/191/191/191 original copied input bytes and modes are preserved.

| Scenario report | SHA-256 of the own announced report |
| --- | --- |
| background | `738d5a24dece97084fb9107dab8ba6a23b586e3e64a807d76edfa4803ae18340` |
| detected | `9d8be817f01facbb158c96ef75aba4f2353e5d309fe0cef7cade12152614213f` |
| survived | `c3bff6ccc1cf91d6a298621109e578c636615bfe65a2238c829c95ca1715534b` |
| baseline-failed | `9708097c19bdfcfec8da0e7a2b39c80495d28404ce94cb4c0edefdb83778eae0` |

### Separate expectation and proof-discrimination audits

Expectation audit: Background advances `(offset + 5) % 60`; its existing real game test checks an offset of 5 after advance, detecting the arithmetic replacement. Calculation `a + b` tested with `(2, 3)` gives 5 while replacement `a - b` gives -1; only disposable ZProbe calls that production calculation. `(2, 0)` gives 2 for either operator, so survival is required, not quality approval. An initial expectation of 6 with `(2, 3)` must fail before any mutation. Agent-created synthetic calculations/tests were executed on JVM only, in disposable copies; they were not added to the permanent game catalog.

Proof audit: the actual detected-mutant stdout proves the failure is in the second file, after all 114 first-file cases passed:

```text
Suite: sifuture/game/GameJourney.kf
0 failed of 114 tests
Suite: sifuture/game/ZProbe.kf
FAIL probe contract: assertion failed
1 failed of 1 tests
```

The independent report checker accepts all four current reports and rejects 58 controls: wrong UUID, scope, status, executed/failed case count, killed counter and another scenario's current report. The public Kof regressions independently reject truncated/contradictory evidence and retain a first/last invocation's failure. Exit 1 for the survivor and exit 2 for the failing baseline are required successful observations of those scenarios, not a claim that their test quality passed. Historical failures and unknown old causes remain historical; this acceptance covers the current measured tree and target, with no universal timing guarantee or automatic further increase.

### Disposition and local evidence

Preparation, both focused commands, all four real scenarios and the complete check pass. This closes the pending concatenated-invocation/manual integration acceptance. SiFuture's two guides can remove the obsolete second-summary rejection limitation and explain the measured two-file acceptance. Sensor installation/activation and historical S1–S3/M2–M5 or 90-second project-performance goals are not closed by this work.

Optional local evidence: KofMut `.agent/tmp/timeouts-20261026/` contains red/focused/full logs, native exits/clocks, captured input inventories and Kof identity; SiFuture's same directory contains four fresh copies/reports, both exact recipes, normal commands, input hashes, failure-file audit and 58-control audit. Essential commands, outcomes, UUIDs, hashes and limitations are reproduced here so these paths are not prerequisites. New generated inventories/manifests stay ignored there; previous tracked manifests are preserved unchanged.


### Observed total deadline and final preservation audit

From the same successful `./scripts/check` on Linux/JVM Kof 0.6.6:

```text
prepared deadline monotonicMs=90026 wallMs=90027
PASS a prepared invocation retains the original ninety second preparation deadline
confirmed evaluation engineMs=94097 monotonicMs=95220 wallMs=95221
PASS confirmed evaluation with budget zero can exceed ninety seconds
```

The first observation confirms preparation stops at its original 90-second bound. The second confirms a ready evaluation starts its own budget and can continue beyond 90 seconds with budgetMs zero; it does not extend preparation. The full check returned 0 in 2822.044 external seconds. `git diff --check` returned 0 in both repositories.

Final independent byte/mode audit: SiFuture has 205 initial tracked files, five authorized changes and 200 unchanged; KofMut has 145, eleven authorized changes and 134 unchanged. Both continued plans/acceptance records preserve all original bytes as prefixes; every historical tracked SHA-256 manifest is unchanged. All 44 frozen execution inputs, installed Kof jar, clean Kof research checkout and both bilingual Bash recipes are preserved. Each repository's local exclusion contains `/.agent/tmp/` exactly once. Link diagnostics for the changed Markdown set are exactly equal to those from HEAD texts: 51 in SiFuture and 14 in KofMut, zero introduced. These preexisting historical line-suffix/fragment diagnostics remain recorded rather than being mislabeled as a clean whole-history link check. New acceptance/source links pass.

Generated delivery inventories and the structured audit are optional local evidence under `.agent/tmp/timeouts-20261026/` in each repository. Historical files/manifests were not resealed or replaced. Preparation, check, focused tests, four real scenarios, documentation gate and preservation are accepted for this continuation; no required acceptance gap remains for these authorized timeout/invocation changes.
