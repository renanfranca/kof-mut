[English](installation.md) | [Português](installation.pt_BR.md) | [KofMut](../README.md)

# Install, update and recover

Use these procedures for a local Linux/JVM installation. Meet the [requirements](../README.md#requirements) first. The [CLI reference](cli.md#local-installation-and-management) owns exact management arguments, paths, receipt formats and refusal rules.

## Install KofMut

Use a writable KofMut source checkout and an existing official Kof distribution on `PATH`. KofMut neither installs nor updates Kof. Check the selected installation, then run from the checkout root:

```bash
kof info --json
./install.sh
export PATH="$HOME/.local/bin:$PATH"
kof-mut --version
kof-mut --help
```

This installs for the current user into `$HOME/.local`, without `sudo` or editing shell profiles. Persist the `bin` entry in your own shell configuration if needed. Without an explicit prefix, `HOME` must be nonempty and absolute. For a custom writable prefix, use this alternative:

```bash
./install.sh --prefix "$HOME/tools/kofmut"
export PATH="$HOME/tools/kofmut/bin:$PATH"
kof-mut --version
```

An explicit prefix may be relative to the caller's working directory. Paths with spaces must be quoted. Installation returns 0 on success and 2 on management/preparation errors. Interrupted preparation leaves the previous active image available. Review refusals in the [management reference](cli.md#local-installation-and-management); foreign commands and invalid ownership do not authorize overwriting files.

The installed public documents are under `<prefix>/share/kof-mut/releases/<id>/README.md` and `docs/`, with `<prefix>/share/kof-mut/current` pointing to the active release. Read that active release's README or `docs/llm-guide.md` (and their Portuguese counterparts). `current` is a managed symbolic link to `releases/<id>`. For example:

```bash
kofmut_prefix="$HOME/.local"
ls "$kofmut_prefix/share/kof-mut/current/docs"
```

The installed package contains runtime sources and public documentation, without checkout fixtures, development tests, internal history, the Kof jar or JDK. It can be read only; generated state is stored separately. You can remove the installer checkout after success. Continue with the [standalone first evaluation](usage.md); its complete project needs no checkout files.

## Prepare a selected Kof

The first evaluation with new component contents prepares KofMut and runs behavioral compatibility checks before any project command. Version/help do not perform that approval. Progress goes to stderr:

```text
kof-mut: Kof <version> detected; preparing application...
kof-mut: checking compatibility...
kof-mut: ready; starting evaluation.
```

Retain stderr and wait for the process. Preparation is bounded separately from the evaluation budget; there is no promised preparation duration. Subsequent evaluations verify contents and reuse healthy approval without repeating these messages or behavioral checks. Every evaluation still runs its own baseline and independent mutations. See [launcher and cache](cli.md#launcher-and-cache) for identities, paths, the 90 second preparation deadline, leases and diagnostics.

A preparation failure returns 2 before project commands and identifies its cause/stage and evidence location. Preserve those logs, correct the cause and repeat the original command. There is no fallback to an earlier Kof. An interrupted call may have no final report; use the [report discovery rules](report-format.md#discover-the-current-report).

## Update KofMut

Choose the desired KofMut source checkout and rerun the installer with the same prefix:

```bash
./install.sh --prefix "$HOME/tools/kofmut"
"$HOME/tools/kofmut/bin/kof-mut" --version
```

For the default prefix, run `./install.sh` instead. This updates the application and its bundled documentation. Preparation validates the new package before atomic activation. Healthy identical inputs reuse their image; documentation changes update the package while reusing valid compiled classes. Older images remain available so active evaluations can finish. A detected checkout change during installation returns 2 with `checkout changed during installation; retry`; stabilize the checkout and retry. See [management](cli.md#local-installation-and-management) for update/receipt details, including one initial reinstall for a legacy schema 1 receipt.

Packages containing the older runtime sources need this KofMut update before adopting Kof 0.6.8. Those sources can fail during startup with `SEM021` at the reflection argument store, even for `--version`. Rerun the installer from a checkout containing the fix with the same prefix, as shown above; selecting another Kof on `PATH` does not replace the packaged KofMut sources. The corrected package can then prepare compatible Kof contents without the checkout, using the normal behavioral checks.

## Adopt another Kof

For a current installation, select an existing official distribution and run the next evaluation normally:

```bash
export PATH="/path/to/other-kof/bin:$PATH"
kof info --json
kof-mut run --project "my-project" --files "my-project/scope.json"
```

The placeholder project must already be configured using [usage](usage.md). This changes the Kof dependency for future calls; it does not update KofMut. A current package needs no reinstall or checkout to adopt compatible Kof contents. The next evaluation recompiles and checks new contents before approval; versions alone do not establish compatibility. Inspect the actual `kofVersion` in that call's report.

Active evaluations keep their concrete selected runtime. Keep that Kof installation available and unchanged until they finish; only then remove an old installation if desired. Explicit project scripts/executables retain their own dependency resolution. KofMut does not download, update or modify either Kof installation.

## Recover without losing evidence

| Observed condition | Procedure |
| --- | --- |
| Compatibility preparation fails | Preserve diagnostic files, correct the reported component/protocol problem and retry with the intended Kof. Do not treat an earlier approval/report as a result. |
| Generated cache is missing or damaged | Repeat the original invocation; generated components rebuild automatically. See [cache recovery](cli.md#launcher-and-cache) before any manual cleanup. |
| Managed state contains a refused symbolic link | Wait for active calls, inspect the named path and remove only the invalid link with `unlink -- PATH`, preserving its target. Retry. Follow the full [link recovery procedure](cli.md#launcher-and-cache). |
| Installed package files are damaged | Reinstall from a healthy desired checkout into the same prefix. Modified files are preserved rather than silently adopted. |
| Receipt/coordination ownership cannot be established, or command is foreign | Preserve the files for inspection and install into a fresh prefix. Do not replace ownership metadata manually. |
| Report announced but absent after completion | Retain stdout/stderr/exit as unavailable current evidence, investigate publication failure and run again with a fresh identity after repair. Never use another report. |

Manual cache removal requires waiting for all active calls and preserving logs, receipts, package and healthy unrelated state. State and installation locks require a filesystem supporting file locks and atomic moves. [CLI recovery](cli.md#launcher-and-cache) is the canonical detailed procedure.

## Uninstall

Using the installed command:

```bash
kof-mut uninstall
```

Only the installed command supports uninstall, including after the checkout is removed. Success returns 0; active invocations or management operations return 2 without removal, so wait and retry. Uninstall removes inventoried unchanged managed application files and command. It preserves projects, configuration, reports, logs, Kof, unknown or modified files and persistent coordination files. [Paths and ownership rules](cli.md#local-installation-and-management) define precisely what can remain.
