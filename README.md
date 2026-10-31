[English](README.md) | [Português](README.pt_BR.md)

# KofMut

KofMut evaluates Kof tests by changing one production token at a time in disposable copies and running the project's check and test commands. Original production files and tests are preserved. Selection, mutation, execution and reporting are written in Kof and use the official lexer and parser on Linux/JVM.

**Version `0.1.0`.** Run from source or install locally for daily use. Start with the [human usage tutorial](docs/usage.md) or the [operational guide for LLMs](docs/llm-guide.md). Both work with the installed package.

| I want to… | Read |
| --- | --- |
| Complete my first evaluation, then use my own project | [Usage: complete minimal project](docs/usage.md) |
| Install, update, select another Kof, repair or uninstall | [Installation procedures](docs/installation.md) |
| Use an LLM or automate evidence based decisions | [LLM guide](docs/llm-guide.md) |
| Understand the evaluation cycle and supported changes | [Concepts and operators](docs/operators.md) |
| Look up commands, configuration, paths, limits or recovery | [CLI reference](docs/cli.md) |
| Discover and validate results and process exits | [JSON v1 reference](docs/report-format.md) |

## Requirements

- Linux, Bash 4.4 or later and the official **Kof** Linux distribution on `PATH`, including `lib/kof.jar` and its embedded JDK.
- GNU coreutils (`dirname`, `readlink`, `mktemp`, `mkfifo`, `mkdir`, `rmdir`, `rm`, `cat`, `sort`, `sha256sum`, `b2sum`, `date`, `timeout`, `cp`), GNU findutils (`find`) and GNU diffutils (`cmp`).
- `setsid` and `flock` from util-linux, the external `kill` command and procfs at `/proc`. The official Kof launcher also uses `sed` and `head`; validation uses `ps`, `cp`, `ln`, `env` and `which`.
- A writable checkout for building and source execution (`build/cache/` and `.agent/tmp/`), a writable installation prefix, and temporary disk space for disposable project copies. Installed evaluations write logs to state and do not need the checkout.

Python is not required by KofMut or its validation suite. Project commands can have their own dependencies. Each installation selected on PATH must pass compatibility preparation before evaluation. KofMut does not download or update Kof. If needed, select an existing installation:

```bash
export PATH="/path/to/selected-kof/bin:$PATH"
kof info --json
```

## Install for daily use

From a writable source checkout with Kof selected on PATH:

```bash
./install.sh
export PATH="$HOME/.local/bin:$PATH"
kof-mut --version
kof-mut --help
```

The default prefix is `$HOME/.local`, without `sudo` or shell profile edits. The application includes these public guides and runtime sources; evaluations need no checkout. Read [installation](docs/installation.md) for custom prefixes, documentation location, updates, compatibility preparation and recovery.

## Run from source

From the checkout root:

```bash
./bin/kof-mut --version
./bin/kof-mut --help
```

Use `./bin/kof-mut` in place of the installed `kof-mut`. Version and help return 0 without evaluating test quality. Source execution needs a writable checkout. See [launcher and cache](docs/cli.md#launcher-and-cache) for preparation details.

## Run an evaluation

Create the five files in the [minimal project tutorial](docs/usage.md#create-all-project-files), which is usable without checkout fixtures. Then evaluate that configured project:

```bash
kof-mut run --project "my-project" --files "my-project/scope.json"
```

`my-project` denotes your project directory, not a bundled example. The tutorial provides an executable setup, captures stdout/stderr/exit and checks that originals are unchanged. Its expected result is baseline passed, one `Killed`, `complete/0`. The [four checkout examples](docs/usage.md#additional-checkout-examples) also demonstrate survival, discard and equivalence with exits `0/1/3/1`.

## Operators and evidence

A mutation is a single deliberate production token change. Read [concepts and selection](docs/operators.md) for the ordered cycle, five operator families, fourteen replacement directions and limitations. File copies isolate project files; external services and absolute paths used by project commands can remain shared. Parallelism is optional, from one to four mutants after a single baseline.

A `Survived` change needs analysis; it alone establishes neither equivalence nor missing coverage. A discarded candidate is not a test detection. There is no coverage instrumentation, `NoCoverage` state, automatic equivalence diagnosis, suppression or approval percentage. [Possible equivalents](docs/operators.md#possible-equivalents) explains how to investigate survivors.

## JSON v1 report and exits

A reserved run announces `reportPath=<JSON string>`. Decode that value with a JSON parser, wait for completion and read only that exact final report. The announcement is a reservation; publication can fail. Never use a previous or newest report as a substitute.

The [JSON reference](docs/report-format.md) owns all fields, states, counts and exits. `complete/0` means all applicable mutants in scope were killed; `complete/1` means completion with survivors and fails quality validation. Errors use 2; inconclusion, no scope and no applicable mutants use 3. Missing or contradictory current evidence does not approve tests. The [LLM guide](docs/llm-guide.md) turns these rules into an operational procedure.

## Validation and next milestones

For a source checkout, `./scripts/check` runs launcher contracts, mutation cycle tests, installation journeys and frontend assertions against the selected installed Kof. Each run writes `.agent/tmp/check-<id>/` with machine load samples (`samples.tsv`), stage timings (`stages.tsv`) and processes left alive (`leftover.txt`), and prints `check observations: <path>` at the end. The samples record load; they do not prove why a run was slow. For your evaluated project, use its real configured commands and inspect its own current report. [Usage](docs/usage.md#interpret-and-follow-up) covers follow-up; [CLI](docs/cli.md#timeouts-and-cancellation) covers limits and cancellation.

Unsupported syntax, invalid evidence, timeouts and cleanup failures remain explicit limitations or inconclusive/error results. Compatibility approval applies to verified contents, with no literal version allowlist or universal latency guarantee. Sensor integration remains future work.

## License

KofMut uses **GPL-3.0-only**. See [LICENSE](LICENSE) and [NOTICE](NOTICE). The Kof jar and embedded JDK stay in the user's installation and are not bundled in this source checkout.
