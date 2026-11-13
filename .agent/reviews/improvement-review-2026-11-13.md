# Improvement review, 2026-11-13

Reading-only review of the tree at commit `7a3df14`, with Kof 0.7.2 as the reference for the compiler AST and CLI. Nothing was changed and `./scripts/check` was not run. Items marked "inferred" were concluded from the code and were not executed.

Points are ordered by impact inside each group.

## Product: what limits real use

1. **Unsupported syntax blocks `complete` easily.** `Frontend.kf` does not handle `record`, `interface`, `spawn`, `using`, local function declarations, `PatternExpr` and other nodes that exist in the Kof 0.7.2 AST (`RecordDeclarationNode`, `InterfaceDeclarationNode`, `SpawnStmt`, `UsingStmt`, `FunctionDeclStmt`, `PatternExpr`, `QueryDslExpr`, `TestDeclarationNode`, the entity, application and infra declarations, `ExternalFunctionNode`, `ForeignModuleNode`, `AnnotationNode`, `ExprDeclarationNode`). Any file with one of them produces a limitation and the run becomes `incomplete`. Almost every KofMut source file declares a `record`, so the tool cannot fully evaluate itself (inferred).
2. **A limitation is all or nothing.** One unknown node in one function downgrades the whole file. Reporting limitations per region and still giving a verdict for the rest would be more useful.
3. **Few operators.** There are 14 token replacement directions. The ones that usually expose weak tests are missing: condition negation, return value replacement, removal of `void` calls, `++`/`--`, numeric constants.
4. **The cost per mutant is the whole project.** Each mutant runs check and the full suite on a full copy, with a fixed ceiling of 4 parallel mutants. There is no test selection per file and no stop at the first failing test. The 90 second target on a real project is still unmet, according to `.agent/README.md`.
5. **No adoption conveniences.** No scope from a Git diff, no suppression of known equivalents, no operator filter, no reuse of results between runs.

## Code

6. **A global lock serializes the parallelism.** `resources.lock` is held during the copy of each variant (`RunResources.prepare`), during token validation with lexer and parser (`MutationRun.evaluateCandidate`) and during the cleanup of each command (`terminateGroups`, up to 2 s). The 4 slots only run in parallel during the external command itself.
7. **Expensive cleanup after every command.** Even when a command ends normally, `releaseCommand` spawns an external `kill` and scans all of `/proc` in a loop with a 10 ms sleep. This happens twice per mutant.
8. **Quadratic frontend.** `tokenAt`, `tokenBefore` and the operator search in `BinaryExpr` scan the whole token list per node. This weighs on large files.
9. **`visit` is a 400 line `if instanceof` chain.** The parameter loop is copied four times (function, method, constructor, lambda).
10. **Fragile coupling to the parser.** Each node type interprets its position differently (a literal uses `tokenBefore`, an identifier uses `tokenAt`). An internal change in Kof breaks this, and the only safety net is the compatibility probe.
11. **States as loose strings.** `"Killed"`, `"passed"`, `"rejected"`, `"Pending"` are spread across the code. The approved baseline is detected with `tested.status != "Survived"`, which confuses the reader. An `enum` would solve it.
12. **Text based test protocol.** `parseTestEvidence` interprets the `SUITE`/`PASS`/`FAIL` lines of `kof test`. Kof 0.7.2 offers no JSON output for tests (`CmdTestFlags.java` accepts only `--timeout` and `--tag`), so there is no alternative today. Worth requesting upstream.
13. **Minor details.**
    - `Run.kf:51` has a redundant `canPublish = false`.
    - `excludedInput` in `Sandbox.kf` embeds KofMut's own paths (`.agent/tmp`, `build/cache/kof-launch-v2`, `build/cache/compatibility`) in generic logic.
    - `CompileError` is a dead state that is always 0.
    - The whole snapshot stays in memory as `Int[]`. The real cost per byte was not verified.
    - `install.sh` duplicates almost all of `scripts/supervise`.

## Proportion and maintenance

14. **Infrastructure larger than the product.** Launcher, installation and compatibility add up to about 2,000 lines (Kof and Bash), against about 1,700 for the engine. The installation tests (1,492 lines) are almost the size of the engine.
15. **Slow feedback loop.** The full check takes 795 s, and took 2,631 s before the parallel queues. Almost everything is an end to end test. Only `FrontendContracts` and `CompatibilityContracts` are fast. Direct tests are missing for `Evidence`, `Inputs` and `JsonShape`, which are mostly pure functions.
16. **No CI and no tag.** There is no `.github/`, and `VERSION` says 0.1.0 without a matching Git tag.
17. **`.agent/tmp` occupied 41 GB locally on 2026-11-13.** There is no cleanup routine. It is ignored by Git, so it is a local problem only, but it grows with every check.

## Documentation

18. **README with internal detail.** The "Validation and next milestones" section describes queues, `.tsv` files and check tags, which matter to a maintainer and not to a user.
19. **Overly defensive tone.** The docs repeat what the tool does not prove in almost every section. It is correct, but it hides the simple answer to "how do I use this and what do I get".
20. **Leftovers in the repository.**
    - The last line of `AGENTS.md` is a one time model authorization, not a durable rule.
    - `.gitignore` lists `__pycache__` and `*.pyc` in a project without Python.
    - `.agent/validation/` has 50 versioned historical files, and its own index has to explain which ones still hold.

## Suggested order

Items 1 and 2 first (support for `record` and `interface`, limitations per region), because without them real projects rarely reach `complete`. Then item 6, which is cheap and unlocks the parallelism that already exists. New operators (item 3) only after that.
