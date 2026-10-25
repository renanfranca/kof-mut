[English](llm-guide.md) | [Português](llm-guide.pt_BR.md) | [KofMut](../README.md)

# Operational guide for LLMs

Use this guide when evaluating a project's tests with KofMut. It is independent of provider, model, IDE and framework, and accompanies the installed package. For an executable first example, use the [complete minimal project](usage.md). [Concepts](operators.md) defines the evaluation cycle; [CLI](cli.md) and [JSON v1](report-format.md) are the canonical references for commands and evidence.

## 1. Inspect before configuring

Read the project's instructions, build configuration, production layout, test layout and existing scripts. Identify the actual commands that check and test the requested production scope. Verify that check produces official `kof check --json` evidence and tests produce supported named `kof test` suites with executed cases. Do not invent a test command or infer success from exit 0 alone.

Establish the requested scope explicitly, including relevant new/untracked files and changes from earlier work when requested. KofMut does not select from Git or changed lines. If an important scope or command decision cannot be established from the project, request clarification before claiming an evaluation of it. Record the chosen Kof (`kof info --json`) and KofMut (`kof-mut --version`); informational calls are not evaluations.

## 2. Prepare the configuration and inputs

Create/adapt the [configuration and explicit scope array](cli.md#configure-a-project). Include production, tests, imports, manifests and needed scripts in `inputs`; selected paths must obey [scope constraints](cli.md#select-scope-and-inputs). Preserve production and tests. Never weaken or mutate tests to obtain a favorable result.

Set a positive individual command timeout and an explicit global budget. `budgetMs: 0` removes the global mutation budget while retaining individual timeouts. Select parallelism 1 through 4 based on resources and external dependencies. File copies do not isolate databases, ports or external paths. Choose a report root outside protected inputs; preparation state and logs also must not overlap inputs. Use the [installation guide](installation.md) when preparation or management fails.

## 3. Execute with an independent identity

Use a fresh caller generated UUID as `--run-id`, even though the tool can generate one. Record the exact argv, working directory, configuration/scope and relevant input identity with stdout, stderr and process exit. Capture nonzero exits instead of letting shell error handling hide them. Do not change the project during capture/evaluation or imply results apply to later edited bytes.

Here is a complete invocation example after creating all five files from [usage](usage.md#create-all-project-files), which leaves `demo` set. Set `KOFMUT_BIN` to the installed command's absolute path or your source checkout's `bin/kof-mut`, as that tutorial explains:

```bash
run_id="$(cat /proc/sys/kernel/random/uuid)"
run_dir="$(mktemp -d "$demo/run-$run_id-XXXXXX")"
printf '%q ' "$KOFMUT_BIN" run --project "$demo" --files "$demo/scope.json" \
  --report-dir "$demo/reports" --run-id "$run_id" > "$run_dir/command"
printf '\n' >> "$run_dir/command"
if "$KOFMUT_BIN" run --project "$demo" --files "$demo/scope.json" \
  --report-dir "$demo/reports" --run-id "$run_id" \
  > "$run_dir/stdout" 2> "$run_dir/stderr"; then
  run_exit=0
else
  run_exit=$?
fi
printf '%s\n' "$run_exit" > "$run_dir/exit"
cat "$run_dir/stdout" "$run_dir/stderr" "$run_dir/exit"
(cd "$demo" && sha256sum --check originals.sha256)
```

Expected for that unchanged synthetic project: exit 0, passing baseline with one executed case, one arithmetic `Killed`, `complete`, no discards/limitations and unchanged originals. The exclusive `run_dir` retains this invocation’s command/stdout/stderr/exit without replacing earlier files. Preparation messages can precede evaluation on stderr; no fixed timing is implied. This run must be consumed using the next steps, even if stdout looks successful.

## 4. Discover and validate this invocation's report

After process completion, require exactly one stdout line beginning `reportPath=`. Parse the remainder as a JSON string using a JSON parser, including escapes. Require an absolute path and read the final UTF-8 JSON only at that location. A reservation is not successful publication. Run ID alone is insufficient because even the same UUID can reserve separate directories.

Apply the full [JSON v1 contract](report-format.md#discover-the-current-report):

1. Validate required fields, JSON types, null rules and `schemaVersion == 1`. Retain actual `toolVersion`, `kofVersion`, `startedAt` and local evidence paths.
2. Compare `runId` to your UUID and `scope` to the normalized, deduplicated, sorted requested production paths. An error report with empty scope is no evidence that the requested scope was evaluated. Keep the process's reservation path as part of identity.
3. Check baseline evidence and its executed cases; null means unavailable, not zero. Input/baseline failure can stop before selection.
4. Validate IDs and locations, permitted operators, phases and states in both arrays. Reconcile per-state counts with `mutants`, `candidates == mutants.length`, `executed == candidates - pending` and the [complete count equations](report-format.md#counts). Discards are outside those counts; add their array length only to describe the total selected after selection.
5. Check limitations and the overall status against baseline, states and process exit using the [exact outcome rules](report-format.md#overall-status-and-process-exit). A `complete` report cannot contain inconclusive states or limitations.

Treat `summary` and `evidence` as diagnostic text with local log references, not a stable machine protocol. Read referenced logs when needed; preserve them alongside the report. Locations use JVM UTF-16 units rather than UTF-8 byte positions.

## 5. Refuse unavailable or contradictory evidence

If discovery is missing/duplicated/malformed, the announced final file is missing, JSON is invalid, identity/scope is wrong, counts do not reconcile or exit contradicts the report, state **current evidence unavailable**. Retain what was observed and investigate. Never choose the latest report, search another directory for a success or substitute an earlier report, including one with the same UUID.

A launcher/input/publication error may return 2 without JSON. SIGINT/SIGTERM can return 130/143 without a promised final report. Do not turn either into test quality approval. After correction, make a new invocation with fresh identity and consume only its report.

## 6. Separate completion from quality

Use this decision table after structural and identity validation. Exact definitions remain in the [JSON state tables](report-format.md#overall-status-and-process-exit).

| Observed overall result | Decision / next action |
| --- | --- |
| `complete`, exit 0 | Evaluation completed and every applicable mutant was `Killed`. Describe only the evaluated scope and supported changes; do not claim comprehensive correctness. |
| `complete`, exit 1 | Evaluation completed with survivors; quality validation fails. Analyze survivors and propose a distinguishing test only when an observable requirement supports it. |
| `baseline_failed`, exit 2 | No valid passing prerequisite. Diagnose original check/test evidence; do not assess mutation quality. |
| `error`, exit 2 | Input/frontend/tool/task/cleanup error. Preserve diagnostics and fix the cause before reevaluation. Partial kills cannot approve the scope. |
| `incomplete`, exit 3 | Budget, inconclusive states, unsupported syntax or another limitation prevents completeness. Report the uncompleted scope/work and cause; choose a justified next action. |
| `no_scope`, exit 3 | No selected production scope. Report that absence; do not approve tests or claim a full mutation evaluation. |
| `no_mutants`, exit 3 | No applicable mutants, including all discarded. Report the reason; do not approve tests. |
| Missing/invalid/contradictory current report; any exit | Evidence unavailable. Preserve stdout/stderr/exit and investigate; do not substitute another report. |

| Candidate evidence | Decision |
| --- | --- |
| `Killed` | Recognized test failure after approved check; counts as detection. It cannot override an overall error/inconclusion. |
| `Survived` | Tests passed that change. Inspect behavior, expression and tests; survival alone proves neither equivalence nor missing coverage. |
| `Timeout` | Deadline interrupted check/test; inconclusive. Review phase, cleanup and suitable limits. |
| `TestError` | Evidence/runner/task/cleanup failure; inconclusive or overall error. Diagnose logs. |
| `Pending` | Work/next phase did not start. Report the reason and remaining work; do not count as detection. |
| `CompileError` | Historical compatibility value. Do not count as detection; new coherent rejections are discards. |
| `discardedCandidates` entry | Rejected before test evaluation, not a kill and not part of mutant counts. Explain diagnostics; all discarded is `no_mutants/3`. |

For survivors, determine whether the change can alter observable required behavior. Distinguish a plausible test gap from a possible equivalent and from insufficient information. The [equivalent example](operators.md#possible-equivalents) shows why a distinguishing test may be impossible. No coverage instrumentation, automatic equivalence classification, suppression or score exists.

## 7. Report a concise evidence based result

State scope and input identity, actual tool/Kof versions, baseline result, overall status and exit, relevant counts (including discards and inconclusive work), current report path, limitations and a justified next step. State completion and quality separately. If no usable report exists, say so and retain the failed invocation's evidence locations.

For the minimal example, a result could read: “Evaluated `src/math/Calc.kf` at the recorded input hashes with KofMut `<toolVersion>` and Kof `<kofVersion>`. Baseline passed (1 case). `complete/0`: 1 Killed, 0 Survived, 0 discarded and no inconclusive states or limitations. Current report: `<decoded reportPath>`. Originals preserved. This establishes detection of the selected arithmetic change; next, evaluate the requested real project scope.” Replace placeholders from that invocation, never from this example or an earlier run.
