[English](README.md) | [Português](README.pt_BR.md)

# KofMut

KofMut is a mutation testing tool being built for Kof. Its selection, transformation, process execution and reporting logic belongs in Kof, initially running on the JVM on Linux.

**Development status: milestones M1 and M1R are implemented.** The Kof source launcher, file reading and official frontend integration are available. Mutation runs, project configuration, sandboxes and the version 1 JSON report are pending. The `0.1.0` value identifies this development source; it does not mean the planned product is complete.

## Requirements

- Linux with Bash 4.4 or later and standard GNU utilities (`dirname`, `readlink`, `mktemp` and `rm`).
- The official **Kof 0.6.4** Linux distribution on `PATH`, including `lib/kof.jar` and its embedded JDK.
- A writable checkout for the local `build/cache/` directory.

Kof 0.6.5 and other versions are rejected until their frontend contracts are verified. The launcher discovers the installation with `kof info --json`; it does not download or update Kof.

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

The Kof bootstrap in `scripts/bootstrap/Launch.kf` validates the toolchain, manages the compilation cache and prepares the JVM command. It uses the Kof JSON and process APIs, plus JDK APIs for hashing, file locks and atomic directory publication. The small Bash bridge pins the Kof executable, receives a command marked `kofmut-launch-v1` with NUL separated fields and uses `exec` to start `Default.Main` with the original application arguments, working directory and environment. Python is not required.

The bootstrap runs through `kof run` on each invocation. The application and frontend contracts compile with `kof build --target jvm --classpath` and use `build/cache/kof-bootstrap-v1/`. Cache keys include the mode, resolved toolchain paths and information, compiler jar contents, launchers, manifest, version and source contents. A lock serializes compilation, and a complete build is published atomically after a successful compiler exit. Failed or interrupted builds cannot become usable cache entries. Removing `build/cache/` forces recompilation; entries from the former Python launcher are ignored.

## What M1 proves

The behavioral checks exercise the real Kof 0.6.4 lexer and parser. They verify file reading, exact association of a `<` expression with its lexer token, traversal of functions, methods, constructors, field initializers and lambdas, repeated and nested operators, and exclusion of symbols in strings, comments and generic parameters. Locations use line and column starting at 1 and **JVM UTF-16 string offsets**, rather than UTF-8 byte offsets.

Lexer and parser diagnostics prevent candidate generation. Unsupported AST forms are reported explicitly. This milestone proves `<` to `<=` selection; the remaining operators and full traversal are pending M2. It does not compile or execute mutants and cannot assess test quality yet.

`./scripts/check` runs named Kof CLI tests through `kof test`, then compiles and executes a Kof contract program with `assert` and the official frontend on its classpath. The installed `kof test` does not accept `--classpath`, so the frontend proof uses the documented whole program assertion style. It does not introduce a test framework. Projects evaluated by the future mutator will use their configured `kof check --json` and `kof test` commands.

The launcher checks use disposable source copies and ordinary Linux test utilities: GNU coreutils, `which`, `ps` and `setsid`. They cover a PATH without Python, argument preservation, cache invalidation, toolchain rejection, concurrent compilation and recovery after failed or interrupted builds. Process group termination in these checks is a bootstrap recovery proof; process limits for future mutation runs remain part of M3.

## Next milestones

M2 adds the mutation cycle, explicit input copies and all planned operator families. M3 adds process limits, descendant cleanup, reports and external acceptance. M4 completes the English and Portuguese CLI, operators and report guides. See [the execution plan](EXECPLAN.md), [M1R launcher validation](.agent/validation/kofmut-m1r.md) and [historical M1 evidence](.agent/validation/kofmut-v0.1.0.md).

## License

KofMut uses **GPL-3.0-only**. See [LICENSE](LICENSE) and [NOTICE](NOTICE). The Kof jar and embedded JDK remain in the user's installation and are not bundled in this source checkout.
