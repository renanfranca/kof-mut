[English](README.md) | [Português](README.pt_BR.md)

# KofMut

KofMut evaluates Kof tests by changing one production token at a time in disposable copies and running the project's check and test commands. Selection, transformation, execution and reporting are written in Kof and run on Linux/JVM through the official Kof frontend.

**Development source, version `0.1.0`.** The mutation cycle, independent reports, cancellation, recovery and optional evaluation of up to four mutants are implemented. This delivery provides source and public guides; it does not include a binary installer. Sensor integration is future work.

## Requirements

- Linux, Bash 4.4 or later and the official **Kof 0.6.4** Linux distribution on `PATH`, including `lib/kof.jar` and its embedded JDK.
- GNU coreutils (`dirname`, `readlink`, `mktemp`, `mkdir`, `rmdir`, `rm`, `cat`, `sort`, `sha256sum`, `b2sum`), GNU findutils (`find`) and GNU diffutils (`cmp`).
- `setsid` from util-linux, the external `kill` command and procfs at `/proc`. The official Kof launcher also uses `sed` and `head`; validation uses `ps`, `cp`, `ln`, `env` and `which`.
- A writable checkout for `build/cache/` and `.agent/tmp/`, plus temporary disk space for disposable project copies.

Python is not required by KofMut or its validation suite. Project commands can have their own dependencies. Other Kof versions are rejected until their frontend contracts are verified. If necessary, select your existing supported installation:

```bash
export PATH="/path/to/kof-0.6.4-linux-x86_64/bin:$PATH"
kof info --json
```

## Run from source

From the checkout root:

```bash
./bin/kof-mut --version
./bin/kof-mut --help
./scripts/check
```

The version prints `KofMut 0.1.0`; version and help return 0. The first invocation prepares a local compiled image. Later invocations validate and reuse it. Checkout paths with spaces work; quote path arguments. See [CLI and cache recovery](docs/cli.md#launcher-and-cache) for preparation, dependencies and recovery.

## Run an evaluation

These synthetic examples are ready to run from the checkout root with Kof 0.6.4 on `PATH`:

```bash
./bin/kof-mut run --project fixtures/detected \
  --files fixtures/detected/scope.json --report-dir .agent/tmp/reports
# exit 0: complete, one Killed

./bin/kof-mut run --project fixtures/survived \
  --files fixtures/survived/scope.json --report-dir .agent/tmp/reports
# exit 1: complete, one Survived

./bin/kof-mut run --project fixtures/invalid \
  --files fixtures/invalid/scope.json --report-dir .agent/tmp/reports
# exit 3: no_mutants, one discarded candidate with ARITH001, no Killed

./bin/kof-mut run --project fixtures/equivalent \
  --files fixtures/equivalent/scope.json --report-dir .agent/tmp/reports
# exit 1: complete, one equivalent boundary mutation survives
```

Each run first checks and tests the intact snapshot. A `Killed` mutation changed behavior that the tests detected. A `Survived` mutation passed those tests and needs human analysis. A rejected candidate is a discard, never a test kill. `complete/1` means evaluation finished with survivors and fails quality validation. `no_mutants/3` provides no test quality approval.

For your own project, start with [CLI configuration and scope](docs/cli.md#configure-a-project). It explains `--project`, `--files`, `--config`, `--report-dir`, `--run-id`, input copies, timeouts and `maxParallelMutants`. The removed `--report` flag returns 2; use the [migration instructions](docs/cli.md#migrate-from---report).

## Operators and evidence

Read [the operator guide](docs/operators.md) for definitions, all five families and fourteen replacements, exclusions and unsupported syntax. KofMut uses the official lexer and parser; it preserves original production files and tests. It consumes the official check/test evidence instead of providing another test runner.

There is no coverage instrumentation, `NoCoverage` status, automatic equivalence diagnosis, suppression or approval percentage. The equivalent fixture demonstrates why a surviving change can preserve behavior. See [possible equivalents](docs/operators.md#possible-equivalents).

## JSON v1 report and exits

Every reserved run announces `reportPath=<JSON string>` for its own final JSON destination. Decode that string with a JSON parser and wait for the invocation to finish. A reservation does not prove publication; never search for the newest report or reuse an earlier result.

The [JSON v1 reference](docs/report-format.md) owns discovery, every field and null, status/count rules, UTF-16 locations and the exit mapping. Exit 0 means complete with all applicable mutants killed; 1 means complete with survivors; 2 means error or failed baseline; 3 means incomplete, no scope or no applicable mutants. Help/version exit 0 is not a quality evaluation.

## Validation and next milestones

`./scripts/check` runs the launcher contracts, Kof mutation cycle tests and frontend assertions against the installed jar. See [M4 acceptance evidence](.agent/validation/kofmut-m4.md) and the [execution plan](EXECPLAN.md) for the reviewed source delivery and remaining work.

Historical M3F evaluated `Background.kf` + `Meteor.kf` on SiFuture revision `82111142c85f98b970ccd65fbf044e492d017729` with `commandTimeoutMs: 10000`, `budgetMs: 0` and `maxParallelMutants: 4`, without an external deadline. The full invocation took **96.456 seconds**: `complete/1`, 42 evaluated candidates, 29 `Killed`, 13 `Survived`, no discards or inconclusive results, and 114 baseline cases. This is a historical observation of complete execution; quality failed because survivors remained. It does not diagnose equivalence or coverage or promise latency. The historical 90 second performance target remains **deferred and unmet**; sensors and their S1–S3 acceptance remain pending.

The [M3P/M3F historical report](.agent/validation/kofmut-m3p.md#preservation-incident-during-the-first-focused-run) also records lost historical standalone JSON/stdout copies and reused observation files whose original bytes were not recovered. Surviving independent evidence and performance records are distinguished there. See [per candidate observations](.agent/validation/kofmut-m3f-candidates.tsv), [M3](.agent/validation/kofmut-m3.md), [M2](.agent/validation/kofmut-m2.md), [M1R](.agent/validation/kofmut-m1r.md) and [M1P](.agent/validation/kofmut-m1p.md) for dated results and their limits.

## License

KofMut uses **GPL-3.0-only**. See [LICENSE](LICENSE) and [NOTICE](NOTICE). The Kof jar and embedded JDK stay in the user's installation and are not bundled in this source checkout.
