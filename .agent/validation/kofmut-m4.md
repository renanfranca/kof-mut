# M4 public documentation validation

M4 is complete locally on 2026-10-22, based on `cac24db6b9fef0badd89517e5da6de41cad65649`, branch `kofmut-frontend`, initially clean. This is a documentation delivery with no product contract change. The [M4 plan](../../EXECPLAN.md) defines criteria A1–A6. The [SHA-256 manifest](kofmut-m4.sha256) identifies the delivered files, including unchanged implementation/tests and historical records; it excludes itself.

The public entry points are [README EN](../../README.md) and [README PT](../../README.pt_BR.md). The canonical references are [CLI EN](../../docs/cli.md)/[PT](../../docs/cli.pt_BR.md), [operators EN](../../docs/operators.md)/[PT](../../docs/operators.pt_BR.md) and [report EN](../../docs/report-format.md)/[PT](../../docs/report-format.pt_BR.md). All fourteen prior README section titles and their fragments remain available. The M1 record [kofmut-v0.1.0.md](kofmut-v0.1.0.md) and every other historical validation record are unchanged.

## Environment and provenance

All new logs, scripts, copies and synthetic observation artifacts are isolated under `.agent/tmp/m4/32869d6e-611b-4da5-b666-eadbd7c2fd97/`. Paths below are relative to that directory unless linked. These raw artifacts are local ignored evidence, not bundled public source dependencies.

The validation checkout is `checkout with spaces/` inside that directory. It was created from the working tree, including the new guides, with no `.git`, build/cache or previous logs. Source files and permissions were copied before execution. All 49 execution inputs match the original checkout by SHA-256 and remained unchanged through validation. Final wording corrections, M4 records and EXECPLAN progress were synchronized afterward; final documentation checks apply to that synchronized content. The behavioral suite did not need repetition for those documentation changes.

Runtime: Linux x86_64, WSL2 kernel `6.18.54.1-microsoft-standard-WSL2`, glibc 2.35; GNU Bash 5.1.16. The official Kof 0.6.4 distribution reports embedded Eclipse Adoptium JDK 25.0.4.1. Jar SHA-256 remains `137a838d38757e317545474d55ad6a3ad291fb86d263ae77d9197cf705829c62`.

PATH was restricted to a dedicated directory of symlinks to the supported Kof executable and required Linux utilities. Neither `python` nor `python3` resolved there, including in the commands evaluated by KofMut. Python was used outside that PATH only to record evidence, copy files, consume JSON for verification and run the skill's link checker; it is not a KofMut runtime or suite dependency. See [environment](../tmp/m4/32869d6e-611b-4da5-b666-eadbd7c2fd97/environment.json), [Kof info](../tmp/m4/32869d6e-611b-4da5-b666-eadbd7c2fd97/kof-info.json), [PATH observation](../tmp/m4/32869d6e-611b-4da5-b666-eadbd7c2fd97/no-python.log) and [execution input parity](../tmp/m4/32869d6e-611b-4da5-b666-eadbd7c2fd97/execution-parity.json).

Local Kof documentation, implementation and tests were consulted directly at `7c237861a9035d84b1f7ec4cfddd89daef4c6ddd` (source VERSION 0.6.6): training README/CLI, learn testing guide, CmdCheck, CmdTest, CmdTestSuiteTest, Token and parser/Lexer. Newer sources are research evidence only; runtime compatibility comes from the installed 0.6.4 and its behavioral contracts. No Kof change or upgrade occurred.

The recorder's first preflight looked for `kofVersion` in `kof info --json`; that command actually uses `kof`. The recorder was corrected before invoking version/help/check. The preflight traceback is preserved in `preflight-validation-driver.stderr`; no product failure or test correction is inferred from it.

## Acceptance audit

Each row distinguishes the expected behavior's authority from the strength of its observation. A green suite alone does not establish the documentary criteria.

| Criterion | Expectation and authority | Procedure, result and distinguishing assertion | Artifacts and limits |
| --- | --- | --- | --- |
| A1: source use | Requirements and source commands must work on Kof 0.6.4 without Python, including spaces in paths. Authority: launch/bootstrap/RuntimeEntry, Main and existing Cli tests. | Isolated checkout: `./bin/kof-mut --version` returned 0 with exactly `KofMut 0.1.0`; `--help` returned 0 with usage. `./scripts/check` returned 0: 21 launcher contracts, 44 cycle tests and 15 frontend groups. The initial cache was absent and no Python executable resolved in PATH. All 49 execution inputs match before/after. | `version.stdout`, `help.stdout`, `commands.json`, `check.stdout`, `check.stderr`, `suite-summary.json`, `copy-before.json`, `copy-after-check.json`, `execution-inputs.sha256`. This proves the tested Linux/JVM source environment, not another Kof version or installer. |
| A2: interpretation | Four documented fixtures require 0/1/3/1 and the documented states/counts. Authority: fixture sources/tests and explicit Run.kf assertions. | The recorder extracted and executed the four README commands as argv after the suite. Each final path was JSON decoded from its own invocation. Human output, final JSON, schema, UUID, scope and all count formulas agree. Results appear below. `invalid` has ARITH001 in discard evidence and zero kills; `equivalent` executes three baseline cases and survives. Fixture bytes remain unchanged. | `documented-examples.json`, `example-{detected,survived,invalid,equivalent}.{stdout,stderr}` and current report files referenced by that JSON, with hashes. Constants and explicit outcomes distinguish a blanket kill or false compile rejection approval. |
| A3: current report consumption | Current `reportPath`, final publication, runId/scope/counts/exit must agree; reservation alone is insufficient. Authority: Run reserveReport/finish, m3 identity/concurrency/publication tests. | The full suite reuses those scenarios. A retained standalone reproduction also used the existing synthetic m3 runner: same UUID through a canonical project and its symlink alias yields the same project hash and distinct final directories; paths contain real quotes, emoji and newline. JSON decoding succeeds. While baseline is held, the announced final file is absent. Replacing that reserved directory with a file causes actual publication failure: exit 2, no final JSON and no false complete. Previous report bytes remain identical; the next invocation recovers at a new path with complete/0. All usable reports pass identity, scope and count checks. | `publication-audit.json`, `post-check.py`, `a3/{first,alias,failure,recovery}/{stdout,stderr}`, current final reports and command logs. The directory obstruction is deliberate synthetic evidence, not a product defect. It directly distinguishes reservation from publication and forbids stale fallback. Concurrent ownership is separately exercised by the unchanged suite. |
| A4: limits/compatibility | Zero removes only the global budget; individual timeout stays positive. Positive budgets remain bounded; `0.0` is invalid. Parallel limit is 1..4, omitted/null=1. Authority: approved M3F decision, Inputs/JsonShape/RunResources/Evidence. | The full 44 case cycle suite includes budget, parallel and m3 scenarios. Audited assertions reject original JSON decimal/exponential/null/overflow forms before commands, hold live baseline/candidate barriers beyond a positive budget with zero, require four interrupted groups and two queued candidates with positive budget, and require an individual timeout plus five completed kills with zero. Queue replacement, baseline gating, error conservation and INT/TERM ownership remain tested. Historical source comparison confirms former `--report` in 37b72ca and strict positive budget in 3b1e0be; current docs name `--report-dir` and explicit zero. | `check.stdout`, `migration-audit.json`, unchanged Run.kf, `suite-report-inventory.json`, retained observations under the isolated checkout's `.agent/tmp/m3f/`. Live process/descendant markers and six explicit variants are stronger than merely checking elapsed time or a parsed config value. No new latency or resource guarantee is claimed. |
| A5: navigation/languages | Both reader journeys reach complete current references; commands, defaults, fields, values and exits agree; prior anchors work. Authority: original README headings and current implementation contracts. | Skill link checker returned 0 for both READMEs and all six guides; the final M4 record also passed. Mechanical comparison found identical executable blocks (translated comments omitted), JSON examples and canonical table keys across all four language pairs. All fourteen prior README headings are unchanged. Manual review follows source user and integrator journeys and compares required/default/null distinctions and exit mappings. The schematic JSON covers every record field; its source offset is independently checked against the fixture, and the UTF-16/UTF-8 example is 44/46. | `docs-audit.json`, `static-checks.json`, `contract-audit.md`, `documentation-audit.md`, `old-anchors.json`. Manual semantic review complements, rather than being inferred from, string parity and valid links. |
| A6: honest evidence | Completion, quality and performance must remain distinct, including the historical loss caveat. Authority: M3P report's M3F observation and preservation incident. | Both READMEs describe 96.456 seconds, complete/1, 42 evaluated, 29 kills, 13 survivors and 114 baseline cases as a historical observation. They explicitly retain quality failure, no coverage/equivalence diagnosis, the deferred/unmet 90 second target, inactive sensors and the lost standalone historical copies. Public API references are self contained and do not require those records to define current fields. | README EN/PT validation sections and `contract-audit.md`, compared directly with unchanged `kofmut-m3p.md` M3F sections. No new SiFuture benchmark was run; no missing historical bytes were represented as recovered. |

## Observed commands and fixture results

All product commands below ran in the isolated checkout with the restricted PATH:

```bash
./bin/kof-mut --version
./bin/kof-mut --help
./scripts/check
./bin/kof-mut run --project fixtures/detected \
  --files fixtures/detected/scope.json --report-dir .agent/tmp/reports
./bin/kof-mut run --project fixtures/survived \
  --files fixtures/survived/scope.json --report-dir .agent/tmp/reports
./bin/kof-mut run --project fixtures/invalid \
  --files fixtures/invalid/scope.json --report-dir .agent/tmp/reports
./bin/kof-mut run --project fixtures/equivalent \
  --files fixtures/equivalent/scope.json --report-dir .agent/tmp/reports
```

`./scripts/check` took 663.164 seconds externally and returned 0. Kof reported 233169 ms for the 21 launcher contracts and 423972 ms for the 44 cycle tests; all 15 frontend groups passed. These durations describe this validation only. See the [suite summary](../tmp/m4/32869d6e-611b-4da5-b666-eadbd7c2fd97/suite-summary.json) and [raw output](../tmp/m4/32869d6e-611b-4da5-b666-eadbd7c2fd97/check.stdout).

| Fixture | Exit | Overall status | candidates/executed | Killed | Survived | Discards | Baseline executed cases |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `detected` | 0 | `complete` | 1/1 | 1 | 0 | 0 | 1 |
| `survived` | 1 | `complete` | 1/1 | 0 | 1 | 0 | 1 |
| `invalid` | 3 | `no_mutants` | 0/0 | 0 | 0 | 1, `ARITH001` | 1 |
| `equivalent` | 1 | `complete` | 1/1 | 0 | 1 | 0 | 3 |

Every fixture has a passed baseline, distinct current UUID/path, zero compileError/timeout/testError/pending and no limitations. [documented-examples.json](../tmp/m4/32869d6e-611b-4da5-b666-eadbd7c2fd97/documented-examples.json) records exact argv, exit, duration, decoded path, UUID, counts and final file hash. The [publication audit](../tmp/m4/32869d6e-611b-4da5-b666-eadbd7c2fd97/publication-audit.json) records the additional same UUID, alias, failure and recovery observations.

The isolated suite retained 40 physical public report copies, including observation copies: 15 complete, four no_mutants, five incomplete, six baseline_failed, eight error and two no_scope. These are artifact counts, not 40 distinct invocations or additional acceptance claims. Paths, UUIDs, statuses, counts and hashes are in `suite-report-inventory.json`.

## Final documentation and preservation checks

The documentation restructuring skill was used for ownership, ordering and link validation; implement-execplan was used to keep the existing milestone and evidence reconciled. No skill delegated work or required an approval step.

```bash
git diff --check
python3 /home/renanfranca/.agents/skills/restructure-documentation/scripts/check_markdown_links.py README.md README.pt_BR.md docs .agent/validation/kofmut-m4.md
sha256sum --check .agent/validation/kofmut-m4.sha256
```

The final whitespace check includes all new Markdown files, not just tracked diffs. Final parity/link/manifest checks pass; details are in `final-checks.json`, `final-copy-parity.json`, `docs-audit.json` and `manifest-check.stdout`. The source user journey goes from README requirements/examples to CLI setup and operator explanations. The integrator journey goes directly from README JSON to discovery, full fields/nulls, counts, locations and exits. Neither requires circular navigation through internal plans.

Before edits, 73 protected tracked files and 41,137 surviving historical artifacts were inventoried by SHA-256, size and permissions. They remain unchanged, including the M1 report and prior manifests. [preservation-audit.json](../tmp/m4/32869d6e-611b-4da5-b666-eadbd7c2fd97/preservation-audit.json) records the comparison; final audit also confirms the 49 runtime inputs and unchanged installed jar. All new runtime/helper paths remain inside this M4 isolation directory, preventing fixed test helper paths from overwriting prior M3P/M3F evidence.

A1–A6 are satisfied within the stated source, fixture and documentation boundaries, with no product divergence found. This does not establish another Kof version, guaranteed latency, automatic equivalence/coverage analysis or sensor integration. The historical 90 second target remains deferred and unmet. S1–S3 and sensor activation are pending; the next plan must fix the actual KofMut revision consumed by SiFuture. No worktree, subagent, commit, remote, publication, sensor installation or new SiFuture benchmark was created.
