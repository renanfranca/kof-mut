[English](operators.md) | [Português](operators.pt_BR.md) | [KofMut](../README.md)

# Concepts and selection

## Mutation

A mutation is one deliberate change to a production token, such as replacing `+` with `-`. KofMut applies each change to a disposable copy, preserving original sources and tests. It does not accumulate changes between copies.

## Baseline

The baseline is a check and test run on an intact copy of the captured project inputs. It must pass with valid evidence before any mutation is evaluated. A failing project cannot establish whether an injected change caused a failure. KofMut invokes the official configured commands and interprets their evidence; it does not implement a replacement test runner.

## Candidate

A candidate is a proposed mutation selected from the official Kof syntax tree and associated with exactly one lexer token. For example, the production expression `a + b` proposes a single change to `a - b`. Deterministic selection follows normalized file paths and token offsets.

## Discarded candidate

A discarded candidate is a proposed change that fails token preservation, reparsing or a coherent compiler check. It never counts as a change detected by tests. In `fixtures/invalid`, `7 * 0` proposes `7 / 0`; the official check rejects division by zero with `ARITH001`. That run returns `no_mutants/3`, with one item in `discardedCandidates`, no retained evaluations and no `Killed`.

Only valid/coherent rejection evidence permits a discard. Before check, KofMut confirms the original token against the snapshot, replaces it, compares both token streams through the official lexer and reparses with the official parser. Every other token must be preserved, including offsets adjusted for replacement length. Lexer/parser rejection and unintended token changes are recorded with diagnostics. If only token comparison fails, the message is `Variant changes tokens other than the selected token`.

A valid check rejection requires exit 1, `success: false` and positive error counts matching ERROR diagnostics. Invalid or contradictory evidence does not authorize a discard. Snapshot divergence, unexpected exceptions and infrastructure failure remain errors. IDs and log indices retain the original selection positions after discards.

## Mutant

A mutant is an evaluation record for a selected change that has not been discarded. `Killed` requires an approved check and completed tests with recognized failure evidence. `Survived` requires an approved check and completed tests without failures. For example, `fixtures/detected` tests the changed arithmetic result and yields one `Killed/complete/0`; `fixtures/survived` accepts both results and yields one `Survived/complete/1`.

`Timeout`, `TestError` and `Pending` describe inconclusive evaluation, not detection by tests. `CompileError` is a historical status retained in JSON v1; new coherent compiler rejections are discards. See [states and counts](report-format.md#mutant-states) for exact semantics. `complete` describes completion and can include survivors; it is not quality approval.

## Operator

An operator is the rule that chooses the replacement token. The five family identifiers below are canonical CLI/JSON vocabulary, in both languages. Each arrow is bidirectional: fourteen replacement directions in total.

| Family identifier | Replacements | Selected form |
| --- | --- | --- |
| `boundary` | `<` ↔ `<=`; `>` ↔ `>=` | Binary comparison expression |
| `equality` | `==` ↔ `!=` | Binary equality expression |
| `logical` | `&&` ↔ `||` | Binary logical expression |
| `boolean` | `true` ↔ `false` | Boolean literal |
| `arithmetic` | `+` ↔ `-`; `*` ↔ `/` | Binary arithmetic expression, excluding known concatenation |

For example, `x < 0` proposes `x <= 0`; it does not also change `0`, delete the condition or rewrite the function. Each variant starts independently from the intact input snapshot. This version has no operator selection flag or plugin system.

## Traversal and exclusions

Traversal covers functions, methods, constructors, field initializers, lambdas, conditionals, loops, switch, try/catch/finally, declarations, calls, assignments, array access, returns, throws and assertions. Traversing an expression does not mean that every token inside it is a supported replacement.

Symbols in comments, strings, characters and generic delimiters are not production expressions to change. Unary signs, increment/decrement, arbitrary numbers, block removal and signature changes have no replacement rule. Tests are never selected for mutation; choose production scope explicitly and keep generated code outside it.

Known string concatenations are excluded using literals, declarations and unambiguous local propagation. Explicit `this.field` resolves the class field independently of same named parameters/locals; an unqualified identifier follows lexical scope. This is limited type knowledge, not full semantic inference. Arithmetic whose type is uncertain can become a candidate, then must pass the compiler check before tests run.

## Limitations

A limitation is an explicit reason the tool cannot claim a complete evaluation of the selected scope. Valid syntax not yet traversed, such as `record` declarations, yields a limitation and prevents `complete`, even if other mutations were evaluated. Ambiguous or missing token associations also remain explicit. Lexical/parser errors in the original source are errors, not test kills. Absence of a replacement in the supported families is different from unsupported syntax.

Locations come from the official lexer, with line/column starting at 1 and offsets/lengths in JVM UTF-16 units. See [location rules](report-format.md#locations-and-evidence) before indexing a source buffer or displaying a byte location.

## Possible equivalents

An equivalent mutation preserves observable behavior despite changing the source. A possible equivalent is a survivor that needs human analysis to establish this property. KofMut does not diagnose equivalence automatically.

The `fixtures/equivalent` production code clamps negative values:

```kf
if (x < 0) { x = 0 }
```

Changing `<` to `<=` only adds an assignment of zero when `x` is already zero. The fixture tests negative, zero and positive inputs and still returns one `Survived`, `complete/1`, with no discard. Reproduce it using the [fourth runnable example](../README.md#run-an-evaluation).

Do not demand an impossible distinguishing test for equivalent behavior. Inspect each survivor to decide whether an observable difference exists and whether a suitable test is missing. There is no coverage instrumentation, `NoCoverage`, automatic exclusion, suppression comment or approval percentage. A survivor alone proves neither lack of coverage nor equivalence. [CLI configuration](cli.md#configure-a-project) and the [report reference](report-format.md) describe how to collect and interpret the actual evidence.
