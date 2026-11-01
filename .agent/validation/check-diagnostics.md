# Explainable check failures and fewer repeated preparations

Validation record for the work specified in `.agent/specifications/check-diagnostics-and-repeated-preparation.md`, executed 2026-10-30 to 2026-10-31. Evidence is under `.agent/tmp/check-diagnostics/d0bc9dc1-cec1-4879-8d48-eaec18615bc2/` (`m1/` … `m7/`, `cleanup/`). Milestone details are in the dated section of the root `EXECPLAN.md`. A passing run proves its recorded tree and environment, not later revisions.

## Final acceptance run

- Tree: HEAD `5c40fd855ef62f518b05c957b851fcb675ed4f62`, plus uncommitted changes to `README.md`, `README.pt_BR.md` and `src/test/kof/kofmut/Install.kf` (the launcher anchor fix described under "Failures and gaps").
- Kof jars (SHA-256):

  | Kof | `kof.jar` SHA-256 |
  |---|---|
  | 0.6.6 | `198bb211dbcefe60bd02f703dff991e82ba55c94f805b1b2b863362757289e58` |
  | 0.6.8 | `3ee09cb1185c6b793a7ce2a842104d8455601ab506a700f13a6c3e233bd15c61` |
  | 0.6.9 | `8d966153017094bef5db1679bcf93d13ad658f8f175600b74bc90f01947df976` |

  0.6.9 was installed outside this work on 2026-10-31 and is the default on PATH. `kof info --json` outputs are in `m7/kof-*.json`.
- Host: load 0.35 before and 2.90 after (`m7/uptime-*.txt`). The runs were sequential.
- Commands and results (`m7/summary.txt`, outputs in `m7/*.out`):

  | Kof first on PATH | Command | Result |
  |---|---|---|
  | 0.6.6 | `kof test src/test/kof/kofmut/Cli.kf --tag compatibility` | exit 0, 9/9, 270 s |
  | 0.6.6 | `kof test src/test/kof/kofmut/Cli.kf --tag launch-arguments` | exit 0, 2/2, 40 s |
  | 0.6.6 | `KOF_MUT_COMPATIBILITY_OTHER=<0.6.8 bin> kof test src/test/kof/kofmut/Install.kf --tag compatibility` | exit 0, 7/7, 194 s |
  | 0.6.6 | `kof test src/test/kof/kofmut/Install.kf --tag launch-arguments` | exit 0, 1/1, 27 s |
  | 0.6.6 | `./scripts/launch contracts` | exit 0, 7 s |
  | 0.6.8 | `KOF_MUT_COMPATIBILITY_OTHER=<0.6.6 bin> ./scripts/check` | exit 0, 2631 s |

- The full check reached all stages:

  | Stage | Result | Time |
  |---|---|---|
  | version | passed | 5.8 s |
  | CLI | 34/34 | 587 s |
  | Run | 47/47 | 658 s |
  | Install | 31/31 | 1374 s |
  | contracts | passed | 6.6 s |

  - Observation directory: `.agent/tmp/check-f186ee8e-ed1c-4912-9e82-4dafe10b4690/`, with 1314 samples, the highest load1 at 5.25 and no leftover process after any stage.
  - The 0.6.6 runs above were observed under `m7/obs-066/`.
  - `git diff --check` passed.
- Preservation: `.agent/validation/` and `.agent/history/` have no diff from `5aeb0c5`. The first 1085 lines of `EXECPLAN.md` are byte-identical to `5aeb0c5`.

## Criteria

| ID | Observed result | Evidence |
|---|---|---|
| A1 | The 23 covered tests went from 270 bare asserts to 0, with token streams equal after removing the inserted messages. An inverted `mcli27` check printed `assertion failed` before the change and `expected: child.exitValue() == expected` after it. `Cli.kf --tag compatibility` passed on 0.6.6 (M2, and again in the final run). | `m2/assert-audit.tsv`, `m2/verify-tokens.log`, `m2/red/control.out`, `m2/green/control.out`, `m7/066-cli-compatibility.out` |
| A2 | A failing CLI test, by assertion and by exception, keeps its project and prints `evidence retained: <path>`; a passing one deletes it. Install journeys are never deleted, and the path is printed. | `m2/green/control.out`, `m2/green/exception-control.out`, `m2/green/retained-dirs.txt` |
| A3 | Waits now measure up to 92000 ms from invocation start (wait table). Under a valid Kof slowed to 3 s per command, the old tree failed `minst08`, `minst21` and the integrity test, and the new tree passed. `minst08` (104 s) and `minst21` (30 s) passed alone on normal Kof. Production deadline lines have no diff. | `m3/wait-table.md`, `m3/red/`, `m3/green/`, `m3/validation/` |
| A4 | Sleep audit: polling intervals inside bounded loops, plus two fixed sleeps kept with justification. `mcli27` signals only after its readiness file exists. | `m2/sleep-audit.md` |
| A5 | `scripts/observe` tests: the observer keeps exit 7, writes samples, stops with the command, leaves no observer and lists detached processes. TERM gives 143 and keeps the samples. Disposable comparison: old and new check equal on failure (1), INT (130) and pass (0); TERM to the check process only now stops the suite (old: 143 with the suite left running). The final check printed its observation directory. | `m4/green/`, `m4/manual/`, `m4/check-stop/`, final run above |
| A6 | `mcli15` and the other converted tests assert, under refusal: exit 2, empty stdout, the refusal in stderr and an unchanged build log; after restore, exit 0 or 3 with reuse and no build. | `m6/measure-*/results/out/` |
| A7 | One real rebuild or recovery per family remains: bootstrap (`mcli15` changed input, `mcli14` missing class), approval (`mcli17` source change, `mcli31` `jvm.cfg`), installed image (Install suite unchanged). | `m6/guarantee-map.md` |
| A8 | Guarantee map: guarantee, then the test before and the test after. Each negative control failed a direct contract (M5) and an integration test (M6): (a) version and timestamp approval failed the identity contract and `mcli31`; (b) inventory ignored failed the approval contract and `mcli17`; (c) compilation-only approval failed the approval contract and `mcli17`. | `m5/controls/`, `m6/control-*.out`, `m6/guarantee-map.md` |
| A9 | Builds before → after: `mcli15` 10 → 2, `mcli14` 6 → 2, `mcli17` 6 → 4. `mcli31` bypasses the shim through its Kof copy; by its own build log it went 4 → 3. Durations: 73.5 → 22.0 s, 52.7 → 17.8 s, 99.4 → 58.7 s, 73.0 → 40.4 s, under different host load. | `m6/measure-e4172fcd-30aa-437c-9a26-0d0d122d1f54/` compared with `.agent/tmp/measure-d847c0f6-a4d9-4ada-972d-dca5a9b211b1/results/results.tsv` |
| A10 | Final acceptance run above: full check exit 0 on 0.6.8 with 0.6.6 as the alternate, all stages reached, observation directory written; all five 0.6.6 commands green. | `m7/` |

## Failures and gaps

- **A3, partial.** A preparation longer than 92 s was not exercised. The failure message includes the elapsed time by construction, which was checked by inspection, not by a run.
- **A5, partial.** INT is checked manually (`m4/manual/`, `m4/check-stop/`), not by the Kof test. The TERM path is covered by the test.
- **Coverage.** Asserts outside the 23 covered tests still exist without messages. `minst02` failed during the comment cleanup with a bare `assertion failed`, which had to be traced by hand.
- **Comment anchor.** Removing a comment in `scripts/launch` broke `minst02`, because `startupJourney` used that comment as a text anchor for its barrier. The anchor is now the call `end_preparation_deadline_and_start_evaluation_budget`. It is still a text search over the launcher (design risk below). That fix is not committed as of this run.
- **No retries.** Each recorded run is the first run of its tree.
- **Kof selection.** M1 to M4 ran with 0.6.8 as the PATH default, and M5 onward with 0.6.9. The specification's final run names 0.6.8 explicitly, so it was run that way. A complete stage set also passed on 0.6.9 with 0.6.8 as the alternate, but split across two invocations after the anchor fix (`cleanup/`).
- **Interpretation.** The samples record load; they do not establish the cause of a slow run.

## Design review

The review found no defect, and no refactor was applied. Risks reported, without action:

- **Design risk:** `Install.kf` `startupJourney` patches `scripts/launch` by text. A rename of that call breaks the test, and the failure is now named. Removing it needs a production seam, which the specification forbids as a test flag.
- **Maintainability:** the preparation bound of 92000 ms is defined once per test suite (`cliPreparationDeadlineWithCleanupMs`, `installPreparationDeadlineWithCleanupMs`) and mirrors the production values 90000 + 2000. Each suite compiles alone, so sharing it would need another test source arrangement.
- **Maintainability:** `signal_child_before_and_after_setsid` exists in both `scripts/supervise` and `install.sh`. Sharing it would add an installed input.
- **No action:** the contract fixture uses one `CompatibilityWork` with the 90 s activity bound for all contracts. They take seconds.

## Identity consequences

The extractions in `Compatibility.kf` and `PreparedEntry.kf`, the bootstrap mapping in `scripts/bootstrap/Launch.kf` and the later renames in launcher and runtime sources change the runtime source identity. Bootstrap caches rebuild once, and existing installations need the usual reinstall from the updated checkout. `docs/installation.md` and `docs/installation.pt_BR.md` already describe this; they were not changed.
