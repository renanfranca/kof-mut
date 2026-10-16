#!/usr/bin/env python3
"""Locate Kof, compile Kof sources and launch the emitted JVM entry point."""

import fcntl
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile


ROOT = Path(__file__).resolve().parent.parent


def launch():
    mode = sys.argv[1]
    if mode not in ("app", "contracts"):
        raise ValueError("unknown launch mode")
    kof = shutil.which("kof")
    if kof is None:
        raise ValueError("kof was not found on PATH; install Kof 0.6.4")
    kof = str(Path(kof).resolve())
    info = subprocess.run(
        [kof, "info", "--json"], capture_output=True, text=True, check=True
    )
    installation = json.loads(info.stdout)
    versions = ("kof", "compiler", "runtime", "stdlib")
    if any(installation.get(key) != "0.6.4" for key in versions):
        raise ValueError("this build requires Kof/compiler/runtime/stdlib 0.6.4")
    if installation.get("os") != "linux" or installation.get("embeddedJdk") is not True:
        raise ValueError("this build requires the Linux distribution with its embedded JDK")
    distribution = Path(installation["install"])
    jar = distribution / "lib/kof.jar"
    java = distribution / "jdk/bin/java"
    if not jar.is_file() or not java.is_file() or not os.access(java, os.X_OK):
        raise ValueError("incomplete Kof distribution: lib/kof.jar or jdk/bin/java missing")

    sources = sorted((ROOT / "src/main/kof").rglob("*.kf"))
    if mode == "contracts":
        sources = [source for source in sources if source.name != "Main.kf"]
        sources.append(ROOT / "src/test/kof/kofmut/FrontendContracts.kf")
    digest = hashlib.sha256()
    for path in [Path(__file__), ROOT / "VERSION", ROOT / "kof.toml", jar, *sources]:
        digest.update(str(path).encode("utf-8"))
        digest.update(b"\0")
        digest.update(path.read_bytes())
        digest.update(b"\0")
    digest.update(json.dumps(installation, sort_keys=True).encode("utf-8"))
    cache_root = ROOT / "build/cache"
    cache_root.mkdir(parents=True, exist_ok=True)
    build = cache_root / (mode + "-" + digest.hexdigest())
    with (cache_root / "build.lock").open("a") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        if not (build / "classes/Default/Main.class").is_file():
            with tempfile.TemporaryDirectory(prefix="compile-", dir=cache_root) as temporary:
                staging = Path(temporary)
                source_root = staging / "sources"
                for source in sources:
                    if source.is_relative_to(ROOT / "src/main/kof"):
                        relative = source.relative_to(ROOT / "src/main/kof")
                    else:
                        relative = Path("kofmut/Main.kf")
                    target = source_root / relative
                    target.parent.mkdir(parents=True, exist_ok=True)
                    shutil.copyfile(source, target)
                (staging / "kof.toml").write_text(
                    '[sources]\napp = "sources"\n', encoding="utf-8"
                )
                command = [
                    kof, "build", "--target", "jvm", "--classpath", str(jar),
                    "--output", str(staging / "classes"),
                ]
                result = subprocess.run(command, cwd=staging, capture_output=True, text=True)
                if result.returncode:
                    sys.stderr.write(result.stdout + result.stderr)
                    return 2
                if not (staging / "classes/Default/Main.class").is_file():
                    raise ValueError("Kof did not emit the verified entry point Default.Main")
                if build.exists():
                    shutil.rmtree(build)
                staging.rename(build)
    command = [
        str(java), "-Dkofmut.root=" + str(ROOT),
        "-Dkofmut.kof.version=" + installation["kof"],
        "-cp", str(build / "classes") + os.pathsep + str(jar),
        "Default.Main", *sys.argv[2:],
    ]
    os.execv(str(java), command)


if __name__ == "__main__":
    try:
        sys.exit(launch())
    except (OSError, ValueError, KeyError, subprocess.SubprocessError) as error:
        print("kof-mut: " + str(error), file=sys.stderr)
        sys.exit(2)
