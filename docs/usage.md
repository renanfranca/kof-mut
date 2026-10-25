[English](usage.md) | [Português](usage.pt_BR.md) | [KofMut](../README.md)

# First evaluation and daily use

This tutorial creates a complete synthetic project in a disposable directory. It works with an installed KofMut and does not need fixtures or a checkout. For vocabulary and the ordered evaluation cycle, read [concepts](operators.md); exact options and configuration belong to the [CLI reference](cli.md).

## Choose the command

Meet the [requirements](../README.md#requirements) and select the official Kof on `PATH`. For an installed application, set:

```bash
KOFMUT_BIN="$(command -v kof-mut)"
kof info --json
"$KOFMUT_BIN" --version
```

For source execution, set `KOFMUT_BIN` to the absolute path of your checkout's `bin/kof-mut` instead, for example `KOFMUT_BIN="/absolute/path/to/kof-mut/bin/kof-mut"`. Only installation, source commands and the additional fixture examples below require the checkout. [Install KofMut](installation.md) if the command is unavailable.

## Create all project files

Run in Bash from any writable working directory. The five files below are based on the checkout's `fixtures/detected`; no copying from that fixture is required. `kof.toml` lets the test resolve `src.math.Calc`. The KofMut configuration declares both commands, all copied inputs and which directories contain production and tests. `scope.json` selects exactly one production file.

```bash
demo="$(mktemp -d)"
mkdir -p "$demo/src/math" "$demo/tests"
cat > "$demo/kof.toml" <<'EOF'
[sources]
app = "."
test = "tests"
EOF
cat > "$demo/src/math/Calc.kf" <<'EOF'
package src.math

class Calc {
    Int sum(Int a, Int b) { return a + b }
}
EOF
cat > "$demo/tests/Suite.kf" <<'EOF'
import src.math.Calc

test "sum contract" {
    assert(new Calc().sum(2, 3) == 5)
}
EOF
cat > "$demo/kof-mut.json" <<'EOF'
{
  "schemaVersion": 1,
  "sourceRoots": ["src"],
  "testRoots": ["tests"],
  "inputs": ["kof.toml", "src", "tests"],
  "checkCommand": ["kof", "check", "src/math/Calc.kf", "--json"],
  "testCommand": ["kof", "test", "tests"],
  "commandTimeoutMs": 10000,
  "budgetMs": 90000
}
EOF
cat > "$demo/scope.json" <<'EOF'
["src/math/Calc.kf"]
EOF
(cd "$demo" && sha256sum kof.toml kof-mut.json scope.json src/math/Calc.kf tests/Suite.kf > originals.sha256)
```

Keep the created directory in the `demo` variable for the following steps. The checksum file lets you confirm that evaluation preserved all five original files.

## Check the intact project

```bash
(cd "$demo" && kof check src/math/Calc.kf --json && kof test tests)
```

Both commands must return 0. Check must report valid JSON approval and tests must execute one passing case. Fix an original failure before evaluating tests with KofMut. The tool will run its own baseline on a copy even after this manual check.

## Evaluate and retain evidence

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

The conditional retains a nonzero exit even in a shell using `set -e`. Keep command, stdout, stderr and exit together in the exclusive directory held in `run_dir`; repeating the example creates another directory and preserves earlier evidence. Initial compatibility preparation can print progress to stderr; it has a separate deadline and no fixed expected duration. See [preparation and recovery](installation.md#prepare-a-selected-kof).

Expect exit `0`, all checksum checks `OK` and a stdout discovery line `reportPath=<JSON string>`. Decode the text after `reportPath=` with a JSON parser, wait for the process to finish and open only that exact final file. Do not strip quotes, choose the newest file or reuse another run. An announcement alone is not a report. Follow the complete [discovery and validation contract](report-format.md#discover-the-current-report).

The current report must contain `schemaVersion: 1`, your `runId`, `scope: ["src/math/Calc.kf"]`, the actual `kofVersion`, baseline `passed` with one executed test, `status: "complete"`, one `Killed`, no survivors, no discarded candidates and no limitations. The changed expression is `a - b`; the original test detects the changed result. This validates the example's selected mutation, not every possible behavior or all tests in another project.

## Apply to your project

1. Identify the real check and test commands and verify that their evidence follows the [supported protocols](cli.md#configure-a-project). Exit 0 alone is insufficient.
2. Declare required files, imports, scripts and manifests in `inputs`. Select explicit production paths in a JSON array; include new or untracked sources when requested. Selection does not consult Git and evaluates whole selected files. See [scope and inputs](cli.md#select-scope-and-inputs).
3. Keep tests outside selected production scope. The tool copies tests without mutating them. File copies do not isolate external databases, fixed ports or absolute paths used by commands.
4. Choose a safe report root, a fresh run ID and suitable limits. [Timeouts and cancellation](cli.md#timeouts-and-cancellation) explains the positive per-command limit, global `budgetMs` (zero disables only that global budget), INT/TERM and inconclusive results. Parallel limits 1 through 4 apply after the single baseline; use 1 for shared external resources.
5. Capture each invocation as above and validate its own final report against the [JSON reference](report-format.md). Keep reports and referenced local logs together for review.

## Interpret and follow up

`complete/0` means all applicable mutations in this evaluated scope were detected. `complete/1` is a completed evaluation with survivors and fails quality validation. Inspect each survivor's original expression, replacement, location, relevant tests and intended behavior. Add a meaningful test only when it distinguishes an observable requirement, then run the real project checks and a fresh evaluation. Survival alone proves neither equivalence nor missing coverage. See [possible equivalents](operators.md#possible-equivalents).

Discards never count as detections. `no_scope/3` and `no_mutants/3` do not approve tests. Timeouts, pending work, invalid evidence, unsupported syntax and tool errors remain explicit; report them using the [state and exit rules](report-format.md#overall-status-and-process-exit). Missing or contradictory current evidence cannot establish a result. The [LLM guide](llm-guide.md) gives an evidence based decision procedure also useful for automation.

## Additional checkout examples

These commands require the source checkout root; they are not included projects in the installed package. Run each separately and retain each exit, including nonzero values:

```bash
./bin/kof-mut run --project fixtures/detected \
  --files fixtures/detected/scope.json --report-dir .agent/tmp/reports
./bin/kof-mut run --project fixtures/survived \
  --files fixtures/survived/scope.json --report-dir .agent/tmp/reports
./bin/kof-mut run --project fixtures/invalid \
  --files fixtures/invalid/scope.json --report-dir .agent/tmp/reports
./bin/kof-mut run --project fixtures/equivalent \
  --files fixtures/equivalent/scope.json --report-dir .agent/tmp/reports
```

Expected exits are `0/1/3/1`: one detected arithmetic change; one arithmetic survivor; one coherent check discard (`ARITH001`) with `no_mutants` and no kill; one equivalent boundary survivor. All four have passing baselines. Each command announces its own report. The complete standalone project above is the installed equivalent of the first example.
