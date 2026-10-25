# M7R: qualify discarded candidates in the LLM guides

Authorized and validated on 2026-10-25, clean base `611eaa7b0a2cc5d2e1f00e4f53c1f3c972262c4e`, existing branch `kofmut-frontend`. Scope: the two LLM guide discard rows, append-only M7R entries in the root plan, the internal index and this report/manifest. No product code, tests, scripts, configuration or earlier validation records change.

## Correction and authority

The previous discard row unconditionally said that all candidates discarded means `no_mutants/3`. The [canonical JSON count rule](../../docs/report-format.md#counts) already required the absence of another limitation. `Run.kf` assigns `no_mutants` for an empty mutant list, then assigns `incomplete` when limitations exist or the budget expires (lines 115–117). No product contract changes.

Both [English](../../docs/llm-guide.md#6-separate-completion-from-quality) and [Portuguese](../../docs/llm-guide.pt_BR.md#6-separar-conclusão-de-qualidade) now require no other cause of error or inconclusion for `no_mutants/3` and explicitly retain `incomplete/3` for unsupported syntax. They preserve the distinction between discards and detections/counts and explicitly refuse test quality approval from discards. Each public file changes exactly one table row. The existing overall decision table remains consistent with both cases.

Local Kof documentation, parser implementation, record AST and frontend tests were consulted directly. Their revision and hashes are in `TASK/research.json`. Kof supports records; the explicit limitation here belongs to KofMut's AST traversal. Source research does not substitute for the actual distribution used by the preserved reproduction.

## Procedures and evidence

`TASK` is `.agent/tmp/m7r/552371a2-9eb5-4102-b545-2edb3a9e63b1/`. All paths below are local maintainer artifacts, outside the installed documentation. Audit helpers are documentation verification tools, not new product tests.

Two questions were checked separately: whether the corrected rule agrees with the existing contract, and whether the two preserved scenarios actually demonstrate its conditional behavior. `TASK/audit-evidence.py` records these separately in `guide-rule-audit.json` and `scenario-audit.json`.

| Check | Procedure and required result | Observation and evidence |
| --- | --- | --- |
| Rule correctness and language parity | Read both corrected rows against the JSON reference, implementation precedence and overall decision tables; retain no detection/quality approval | Passed. Equivalent EN/PT conditions, explicit unsupported syntax precedence, and one changed row per guide. `guide-rule-audit.json` records the actual rows and both interpretations. |
| Discard without another limitation | Reuse M7's explicit-ID `invalid` example, verify its manifest, stdout report discovery, run ID, scope, baseline, counts and exit | Passed: baseline `passed` (1 executed test, 0 failed), one `ARITH001` discard, no mutants/detections/limitations, `no_mutants/3`. Existing M7 report, stdout and exit record reused; no new evaluation. |
| Discard with unsupported syntax | Reuse the independent review summary's boundary report; corroborate stdout discovery, recorded exit, scope, record source and installed package contents | Passed: baseline `passed` (1 executed test, 0 failed), one `ARITH001` discard, zero mutants/detections, `incomplete/3`, explicit `src/math/Point.kf: Unsupported AST node: dev.kof.compiler.RecordDeclarationNode`. `scenario-audit.json` and `evaluated-code-identity.json`. |
| Both guides applied to both reports, supplementing M7 D3 | Interpret each scenario using both corrected rows and the overall result table | Passed: no limitation → `no_mutants/3`; record limitation → `incomplete/3`. Neither case approves test quality. These are fresh consumer interpretations of reused execution reports. |
| Evaluated code and regression identity | Compare M7's frozen execution inputs and retained source copy, plus independent package inventory/runtime sources and its recorded Kof dependency contents | Passed: 86 non-document execution inputs match bytes/modes; 45 execution files in the renamed M7 source copy match current bytes. Independent package: all 135 inventoried payload files pass hashes; all 24 runtime sources match current checkout and release; five recorded Kof dependency files match. No affected scenario requires rerunning. `regression-reuse.json`, `evaluated-code-identity.json`. |
| Source/internal links and whitespace | Run the existing Markdown link checker on both guides, internal index, M7R report and root plan; run `git diff --check` | Passed, exit 0 for both. Exact argv/cwd/exits and logs are in `final-commands.json`, `source-links.*`, `diff-check.*`. |
| Distributed correction | Install a disposable tracked-file copy into a fresh prefix with spaces; make the installer source path unavailable; compare guide bytes and validate installed README/docs links | Passed. Install exit 0, installed links exit 0; both guide files match delivery byte for byte. The package has no `.agent`, EXECPLAN, fixtures or Git metadata. `fresh-commands.json`, `install.*`, `installed-links.*`, `installed-documents.json`. No real user installation is touched. |
| Preservation and final scope | Compare initial tracked bytes/modes, original plan prefix and final diff; verify earlier validation records and researched Kof files/status | Passed. Only the two public rows and authorized internal records change; original M7 report/manifest and historical files remain unchanged. `preservation-audit.json` records counts and comparisons. |

The reused `invalid` report has run ID `2395dd32-de0f-4aee-a417-d62d9aed8d95`, SHA-256 `1c51add81b49657742e3dee8d28ee7c61cc4b008a24b98b6784e39cba4cfa140`. Its path, stdout and exit are associated in the M7 `final journeys/examples.json` and sealed by the original M7 manifest.

The independent review report has run ID `4e009376-33dd-4d2e-8f68-5cd9315d8efe`, SHA-256 `15e3e2df1e745679dc21a936922c7e12ef9a53b61a5ddaceff599280e0f4175c`. Its path and exit are recorded in `.agent/tmp/m7-review-1amijhf9/summary.json`; its own stdout announces exactly that report. The review package's runtime source identities match this tree and its dependency records match actual Kof 0.6.6. This review had no earlier separate evidence manifest. M7R seals its presently verified artifacts without claiming a historical hash seal or a new execution. Its configured baseline check selects `Calc.kf`; the record is selected mutation scope and produces an explicit scanner limitation. This case demonstrates status precedence, not mutation support for records or test coverage of the record.

The first source link check included the historical plan from the repository working directory and returned 1 for its 14 absolute filesystem links. The checker resolves paths beginning with `/` against its working directory, treating them as website root paths. Repeating the same checker with absolute input filenames from `/` resolves the existing filesystem links correctly and passes. Initial stdout/stderr and command records remain as `source-links-initial.*` and `final-commands-initial.json`. No historical plan link was edited; this was a validation invocation adjustment.

The freshly installed guides have SHA-256:

| Guide | SHA-256 |
| --- | --- |
| `docs/llm-guide.md` | `275d4cc1fceaab00df5921f5b6e8e2632f5ed0be0dc594369ae9a0a083b065e4` |
| `docs/llm-guide.pt_BR.md` | `2e40be9327ed75124ed8adef30cd3e6c7ef0379b6e777936fb48a20e25828f43` |

Fresh installation selected the existing PATH Kof 0.6.6, with embedded JDK 25.0.4.1; `kof-info.stdout` retains actual version evidence. The package is `TASK/installed prefix/share/kof-mut/releases/0b6bcdfea6b579fb00265e66921a51a26865a447052e95c2ed2c6df43f32f994/`. Its original installer copy path is absent after installation. Reading installed guides and checking their links requires neither that path nor the internal records.

## Reused full suite

The M7 `./scripts/check` remains the full regression evidence: exit 0, 31 CLI / 44 mutation-cycle / 31 installation cases and 15 frontend groups, 2584.710 external monotonic seconds with actual Kof 0.6.6. The original `check-result.json`, stdout/stderr, frozen `regression-inputs.json` and `regression-summary.json` pass the M7 manifest. All 86 frozen non-document execution inputs match current bytes/modes. This documentation correction does not rerun the full suite or add product tests. Installed packaging and guide links were verified freshly, independently of that historical suite.

## Preexisting integrity limitation

Before any edit, `sha256sum --check .agent/validation/kofmut-m7.sha256` returned 1: 187 of 188 entries passed. Only `.agent/history/public-docs-before-m7.md` differed. The recorded expected hash is `c9a60a5501f30c7a09d75ad1d3b91f539813b3f67e09f41c54e6b5d3f348680c`; the clean base's actual hash is `990d8131a876e23d74f19359d6659581583b368bd32eaa910b7bc51d6fe514fa`. The base commit already contains those actual bytes. I do not know the origin of this discrepancy. `initial.json`, `m7-manifest-check.*` and `old-manifest-audit.json` preserve the observation.

This prevents claiming that the entire original M7 manifest passes. It does not invalidate the matching scenario/regression entries or their verified execution inputs. The original archive, M7 report and M7 manifest are preserved, without repair or replacement. The new M7R manifest records present contents separately; it does not retrospectively reseal M7.

## Closure

M7R.1–2 complete locally. [The separate M7R manifest](kofmut-m7r.sha256) identifies delivery files, audit helpers/results and selected reused artifacts; it excludes itself. Fresh checks cover interpretation, integrity/content comparison, disposable installation, distributed guide identity, links and preservation. The two scenario executions and full suite remain explicitly reused evidence. No product test, code/configuration edit, commit, subagent, worktree, remote, publication or Kof download/update/modification was performed. Existing unrelated historical limitations remain in their original records; the preexisting M7 archive discrepancy remains unresolved.
