# KofMut internal records

Public product instructions start at [README](../README.md) ([Português](../README.pt_BR.md)); installed documentation does not depend on this directory. This entry is for maintainers reconstructing decisions, validation and remaining work. A historical passing run proves its recorded tree and environment, not every later revision.

## Current entry points

- [Recovered implementation and resumed acceptance](validation/multiple-invocations-recovery.md): exact recovery verified and public reader groups pass; complete compatibility/full check and four real cases remain unapproved under preserved deadlines.
- [Concatenated test invocations](validation/multiple-invocations.md): current parser correction and separate expectation/proof audits; public executable and real SiFuture acceptance remain pending under preparation deadline failures.
- [Root EXECPLAN](../EXECPLAN.md): complete retained plan, dated authorizations, decisions, milestones and observed boundaries. Its older requirements remain historical where explicitly superseded.
- [M7R discard rule correction](validation/kofmut-m7r.md) and [manifest](validation/kofmut-m7r.sha256): qualifies all-discarded outcomes in both LLM guides and supplements M7 D3 with the unsupported-syntax case. Records reused evidence separately from fresh validation and the preexisting M7 archive hash discrepancy; the original M7 report/manifest remain preserved.
- [M7 documentation validation](validation/kofmut-m7.md) and [manifest](validation/kofmut-m7.sha256): inventory, canonical document ownership, audience journeys, preservation and new guide acceptance. Read its criterion results and limitations before treating M7 as complete.
- [M6O validation](validation/kofmut-m6o.md) and [manifest](validation/kofmut-m6o.sha256): latest implementation acceptance preceding M7, prepared evaluation in one work JVM, complete-round measurements, exact runtime delta and limits. Code/tests/scripts are unchanged by M7.
- [M6R validation](validation/kofmut-m6r.md) and [manifest](validation/kofmut-m6r.sha256): managed-state symbolic link preservation and recovery contracts retained by M6O.
- [M6 validation](validation/kofmut-m6.md) and [manifest](validation/kofmut-m6.sha256): content and behavioral compatibility approval, real Kof installations and automatic adoption. Actual verified contents do not constitute a literal version allowlist.

## Decisions and pending work

M7 supersedes the older requirement to keep milestone history and incidents in the public READMEs. [Archived public history from `3b959ae`](history/public-docs-before-m7.md) preserves the relocated prose in both languages, including links to original evidence. The complete EXECPLAN remains at the root. Public current concepts, commands and schema remain in `docs/`; internal records do not redefine them.

Sensor integration and its S1–S3 acceptance remain future work. The historical real-project 90 second performance target is deferred and unmet. M6O's synthetic measurements do not close that target or promise universal speed/latency. M6L's remaining native-thread/initializer attribution remains partial; distinguish supported findings from unanswered forensic questions in its report.

The M3P/M3F [preservation incident](validation/kofmut-m3p.md#preservation-incident-during-the-first-focused-run) lost historical standalone JSON/stdout copies and reused observation files; their original bytes were not recovered. Surviving independent observations are distinguished in that report. Do not reconstruct missing evidence or present earlier performance samples as measurements of a corrected tree.

## Historical validations

| Record | What it establishes in its dated context |
| --- | --- |
| [M1 source delivery](validation/kofmut-v0.1.0.md), [manifest](validation/kofmut-m1.sha256) | Initial frontend/source acceptance; preserved original delivery record |
| [M1R](validation/kofmut-m1r.md), [manifest](validation/kofmut-m1r.sha256) | Kof bootstrap and execution without Python |
| [M1P](validation/kofmut-m1p.md), [manifest](validation/kofmut-m1p.sha256), [JSON](validation/kofmut-m1p-performance.json), [TSV](validation/kofmut-m1p-performance.tsv) | Original startup measurements, not current timing promises |
| [M2](validation/kofmut-m2.md), [initial manifest](validation/kofmut-m2-initial.sha256), [corrected manifest](validation/kofmut-m2.sha256) | Mutation cycle, evidence protocols and corrections |
| [M3](validation/kofmut-m3.md), [manifest](validation/kofmut-m3.sha256), [external manifest](validation/kofmut-m3-external.sha256) | Independent reports, cancellation and recovery |
| [M3P/M3F](validation/kofmut-m3p.md), [M3P manifest](validation/kofmut-m3p.sha256), [438c775 manifest](validation/kofmut-m3p-438c775.sha256), [M3F manifest](validation/kofmut-m3f.sha256), [external manifest](validation/kofmut-m3f-external.sha256), [candidate observations](validation/kofmut-m3f-candidates.tsv) | Parallelism, corrected cleanup, unbounded global budget, complete historical round and preservation incident |
| [M4](validation/kofmut-m4.md), [manifest](validation/kofmut-m4.sha256) | Previous bilingual public documentation acceptance |
| [M5](validation/kofmut-m5.md), [manifest](validation/kofmut-m5.sha256) | Original installer journeys |
| [M5 corrections](validation/kofmut-m5-corrections.md), [manifest](validation/kofmut-m5-corrections.sha256) | Installer ownership, HOME, update capture and recovery corrections |
| [M6L](validation/kofmut-m6l.md), [manifest](validation/kofmut-m6l.sha256) | JVM lifecycle forensic investigation; partial remaining attribution |

## Raw artifacts and preservation

Reports name their command logs and immutable manifests. Raw task artifacts live under ignored `.agent/tmp/`; these paths are local evidence, not portable installation contents. M7 uses `.agent/tmp/m7/<UUID>/` and its `current` locator. Keep each command, stdout, stderr, exit and current report associated; never substitute a newest or earlier report for an invocation's missing result.

Historical validation files are preserved byte for byte. New evidence is recorded in its own milestone report and UUID directory. Moving navigation does not erase limitations, alter prior conclusions or imply revalidation.
