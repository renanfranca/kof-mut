#!/usr/bin/env bash
set -Eeuo pipefail
fail() { echo "kof-mut: installation preparation failed" >&2; exit 2; }
trap fail ERR
KOF_MUT_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
KOF_MUT_CHILD=""
cleanup() {
    if [[ -n "$KOF_MUT_CHILD" ]]; then
        kill -TERM -- "-$KOF_MUT_CHILD" 2>/dev/null || true
        kill -KILL -- "-$KOF_MUT_CHILD" 2>/dev/null || true
        wait "$KOF_MUT_CHILD" 2>/dev/null || true
    fi
}
interrupted() {
    trap '' INT TERM
    if [[ -n "$KOF_MUT_CHILD" ]]; then kill -s "$1" -- "-$KOF_MUT_CHILD" 2>/dev/null || true; fi
    cleanup
    exit "$2"
}
trap cleanup EXIT
trap 'interrupted INT 130' INT
trap 'interrupted TERM 143' TERM
setsid "$KOF_MUT_ROOT/scripts/launch" install "$@" &
KOF_MUT_CHILD=$!
if wait "$KOF_MUT_CHILD"; then exit 0; else exit 2; fi
