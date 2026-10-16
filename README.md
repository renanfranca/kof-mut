[English](README.md) | [Português](README.pt_BR.md)

# KofMut

KofMut is a mutation testing tool being built for Kof. Its selection, transformation, process execution and reporting logic belongs in Kof, initially running on the JVM on Linux.

**Development status: milestones M1, M1R and M1P are implemented.** The Kof source launcher, file reading and official frontend integration are available. Mutation runs, project configuration, sandboxes and the version 1 JSON report are pending. The `0.1.0` value identifies this development source; it does not mean the planned product is complete.

## Requirements

- Linux with Bash 4.4 or later and GNU coreutils (`dirname`, `readlink`, `mktemp`, `rm`, `cat`, `sort`, `sha256sum` and `b2sum`), GNU findutils (`find`) and `cmp` from GNU diffutils.
- The official **Kof 0.6.4** Linux distribution on `PATH`, including `lib/kof.jar` and its embedded JDK.
- A writable checkout for the local `build/cache/` directory.

Kof 0.6.5 and other versions are rejected until their frontend contracts are verified. The official Kof launcher also requires `sed` and `head`. The launcher discovers the installation with `kof info --json`; it does not download or update Kof.

If another version is selected on your machine, put the supported installation first on `PATH`:

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

The version command prints `KofMut 0.1.0`, reading `VERSION`. Both version and help return exit code 0. Unsupported commands, including `run` at this stage, return 2. A version or help command is not a quality evaluation.

The Bash bridge pins the real Kof executable and obtains fresh `info --json` on every invocation. With a warm cache it hashes the launcher inputs and the entire installed jar, then uses `exec` to start the compiled `kofmut.launch.RuntimeEntry`. This Kof entry validates the fresh installation evidence, installation paths and image identity, removes its temporary context, sets the application properties and calls `Default.Main.main` in the same JVM. Version, help and other commands use this path. Arguments, working directory, environment, exit codes and signals reach the application directly. Python is not required. The official Kof 0.6.4 script also starts a short `java -version` probe before the installation query: there are two working JVMs plus this probe, and startup measurements include all three Java executions.

`scripts/bootstrap/Launch.kf` runs through `kof run` only when preparation is needed. It validates the installation, checks the captured input hashes, compiles the captured source bytes with `kof build --target jvm --classpath` and publishes the complete image atomically under a file lock. Both JVM entry points and the application specific generated JSON runtime are compiled together. The published image includes SHA-256 checksums of its generated classes; the launcher verifies them before execution. A second cache check under the lock prevents duplicate compilation. Validation and compilation failures return 2 without falling back to an older image.

The cache uses `build/cache/kof-launch-v2/locations/` for installation descriptors and `build/cache/kof-launch-v2/images/` for compiled programs. The preliminary SHA-256 identity includes the mode, checkout root, pinned Kof path and contents, raw fresh JSON, launchers, VERSION, manifest and relevant source contents, in deterministic order with NUL terminated fields. The final SHA-256 identity also includes a BLAKE2b 512 bit hash of the entire installed jar, computed by GNU `b2sum`. Timestamps do not determine validity. Changes in a future evaluated project do not recompile KofMut.

The former `kofmut-launch-v1` command delivery has been replaced by `kofmut-location-v1`, whose NUL terminated fields carry the validated Java and jar paths. Bash reads these fields without parsing JSON or evaluating command text. Each launch passes five internal arguments (root, pinned Kof, mode, context directory and image directory), followed by the original application arguments. No application arguments pass through the `kof run` option parser. Old Python and `kof-bootstrap-v1` cache entries are ignored.

Missing or inconsistent descriptors and incomplete images trigger automatic preparation. To discard the new cache and recover after an abrupt interruption, run `rm -rf -- build/cache/kof-launch-v2` from the checkout root. This also removes unused staging directories and forces preparation on the next invocation. The cache filesystem must support file locks and atomic directory moves. The initial preparation cost and warm startup comparison are recorded in the [M1P validation report](.agent/validation/kofmut-m1p.md); the warm startup target does not apply to the first build.

Warm startup met the M1P target: Kof median **0.7129 s**, Python median **0.6738 s** (5.81% above Python, within 10%), across 33 alternating pairs with no compilation. Three empty cache starts took 5.05 s, 5.15 s, 5.17 s. See the [M1P report](.agent/validation/kofmut-m1p.md) for dispersion, raw results and conditions. The 90 second integration budget remains unproven.

## What M1 proves

The behavioral checks exercise the real Kof 0.6.4 lexer and parser. They verify file reading, exact association of a `<` expression with its lexer token, traversal of functions, methods, constructors, field initializers and lambdas, repeated and nested operators, and exclusion of symbols in strings, comments and generic parameters. Locations use line and column starting at 1 and **JVM UTF-16 string offsets**, rather than UTF-8 byte offsets.

Lexer and parser diagnostics prevent candidate generation. Unsupported AST forms are reported explicitly. This milestone proves `<` to `<=` selection; the remaining operators and full traversal are pending M2. It does not compile or execute mutants and cannot assess test quality yet.

`./scripts/check` runs named Kof CLI tests through `kof test`, then compiles and executes a Kof contract program with `assert` and the official frontend on its classpath. The installed `kof test` does not accept `--classpath`, so the frontend proof uses the documented whole program assertion style. It does not introduce a test framework. Projects evaluated by the future mutator will use their configured `kof check --json` and `kof test` commands.

The launcher checks use disposable source copies and ordinary Linux test utilities: GNU coreutils, `which`, `ps` and `setsid`. They cover a PATH without Python, argument preservation, cache invalidation, toolchain rejection, concurrent compilation and recovery after failed or interrupted builds. Process group termination in these checks is a bootstrap recovery proof; process limits for future mutation runs remain part of M3.

## Next milestones

M2 adds the mutation cycle, explicit input copies and all planned operator families. M3 adds process limits, descendant cleanup, reports and external acceptance. M4 completes the English and Portuguese CLI, operators and report guides. See [the execution plan](EXECPLAN.md), [M1R launcher validation](.agent/validation/kofmut-m1r.md) and [historical M1 evidence](.agent/validation/kofmut-v0.1.0.md).

## License

KofMut uses **GPL-3.0-only**. See [LICENSE](LICENSE) and [NOTICE](NOTICE). The Kof jar and embedded JDK remain in the user's installation and are not bundled in this source checkout.
