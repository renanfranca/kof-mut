# Parallel check queues

Validation record for running `./scripts/check` suites as parallel queues, executed 2026-10-31. Evidence is under `.agent/tmp/check-parallel/73bea95c-8d8c-4fb5-af66-813c93e89d09/` and the observation directory `.agent/tmp/check-7d7f5cea-10c0-4f99-8c89-839fea76f67f/`. A passing run proves its recorded tree and environment, not later revisions.

## Change

- `scripts/check` runs `version` alone, then `cli`, `run`, `install-a`, `install-b` and `contracts` at the same time, each under `scripts/observe`. Each queue writes `<queue>.out`; the check prints it whole when the queue finishes, followed by `queue <queue>: exit <n> in <s> s`.
- Every `Install.kf` test carries exactly one of `check-install-a` (15 tests) or `check-install-b` (16 tests), balanced longest first by the durations in `.agent/tmp/measure-d847c0f6-a4d9-4ada-972d-dca5a9b211b1/results/results.tsv` (1047 s and 1062 s measured alone).
- After all queues pass, the check reads `kof test: tag '<tag>' (k of N)` from both Install queues and fails with `check queues do not cover Install.kf: <a> + <b> of <N>` unless a + b = N.
- A failing check waits for every queue and exits with the status of the first failing queue in the order cli, run, install-a, install-b, contracts. INT and TERM reach every running queue and the check exits 130 or 143.
- `scripts/observe` is unchanged. Its header race does not apply because `version` runs alone first and creates both headers; 12 observers started together into one directory, three times, produced one header each (`race-*`).

## Results

| Run | Command | Result |
|---|---|---|
| Fake harness (`fake/`, PATH shim `shim/kof`) | pass | exit 0 (`pass.out`, `pass2.out`) |
| Fake harness | install-a reports 14 of 31 | exit 1, `check queues do not cover Install.kf: 14 + 16 of 31` (`coverage.out`) |
| Fake harness | run queue fails | exit 1, all other queues finished and printed (`fail.out`) |
| Fake harness | TERM, then INT to the check during the queues | exit 143 and 130, every queue stopped with the same status (`sig-*.out`) |
| Kof 0.6.8 first, `KOF_MUT_COMPATIBILITY_OTHER` = 0.6.6 | `./scripts/check` | exit 0 in 1037 s (`real-check.out`) |

Real run per queue, compared with the sequential check of the same day (`.agent/validation/check-diagnostics.md`, 2631 s):

| Queue | Tests | Parallel | Sequential |
|---|---|---|---|
| version | | 5 s | 6 s |
| contracts | | 12 s | 7 s |
| cli | 34/34 | 902 s | 587 s |
| run | 47/47 | 954 s | 658 s |
| install-a | 15/15 | 1032 s | 1374 s (whole suite) |
| install-b | 16/16 | 949 s | |
| total | | 1037 s | 2631 s |

- The highest load1 was 13.77 (sequential: 5.25). Load average was 0.10 before the run.
- No queue left a process (`leftover.txt`: six `none`).
- Each queue ran about 45 to 55 percent slower than alone, so the gain is 61 percent, not the 4x of perfect parallelism.

## Gaps

- Signals and failure handling were verified on the fake harness only, not during a real run.
- In the fake TERM and INT runs, `leftover.txt` listed `sleep` processes from the shim, which is a bash script that does not use `exec`; the real `kof` launcher uses `exec` to start Java.
- A test that is missing from one queue and duplicated in the other at the same time leaves the sum unchanged and is not caught.
- One real run only. Timing tests passed under this load, but sensitivity to heavier host load is not measured.
- Kof 0.6.6 was not rerun as the first Kof; the change touches only the check script and test tags.
