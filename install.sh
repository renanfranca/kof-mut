#!/usr/bin/env bash
set -Eeuo pipefail
fail() { echo "kof-mut: installation preparation failed" >&2; exit 2; }
trap fail ERR
KOF_MUT_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
KOF_MUT_CHILD=""
KOF_MUT_GROUP=""
KOF_MUT_CREATING=0
KOF_MUT_SIGNAL=""
KOF_MUT_STATUS=2
KOF_MUT_BARRIER=""
cleanup() {
    if [[ -n "$KOF_MUT_CHILD" ]]; then
        # Before setsid there is only a PID. After the handshake the child has
        # reported its session leader. Cover both sides of that transition.
        if [[ -n "$KOF_MUT_GROUP" ]]; then kill -TERM -- "-$KOF_MUT_GROUP" 2>/dev/null || true; fi
        kill -TERM -- "-$KOF_MUT_CHILD" 2>/dev/null || true
        kill -TERM -- "$KOF_MUT_CHILD" 2>/dev/null || true
        if [[ -n "$KOF_MUT_GROUP" ]]; then kill -KILL -- "-$KOF_MUT_GROUP" 2>/dev/null || true; fi
        kill -KILL -- "-$KOF_MUT_CHILD" 2>/dev/null || true
        kill -KILL -- "$KOF_MUT_CHILD" 2>/dev/null || true
        wait "$KOF_MUT_CHILD" 2>/dev/null || true
    fi
    if [[ -n "$KOF_MUT_BARRIER" ]]; then rm -rf -- "$KOF_MUT_BARRIER"; fi
}
interrupted() {
    if [[ -z "$KOF_MUT_SIGNAL" ]]; then KOF_MUT_SIGNAL=$1; KOF_MUT_STATUS=$2; fi
    if (( KOF_MUT_CREATING )); then return; fi
    trap '' INT TERM
    exit "$KOF_MUT_STATUS"
}
trap cleanup EXIT
trap 'interrupted INT 130' INT
trap 'interrupted TERM 143' TERM
KOF_MUT_BARRIER="$(mktemp -d)"
mkfifo -- "$KOF_MUT_BARRIER/ready" "$KOF_MUT_BARRIER/release"
exec 8<>"$KOF_MUT_BARRIER/ready" 9<>"$KOF_MUT_BARRIER/release"
KOF_MUT_CREATING=1
setsid bash -c '
    printf "%s\n" "$BASHPID" >&8
    IFS= read -r -u9 release
    [[ "$release" == go ]] || exit 2
    exec 8>&- 9>&-
    exec "$@"
' bash "$KOF_MUT_ROOT/scripts/launch" install "$@" &
KOF_MUT_CHILD=$!
KOF_MUT_CREATING=0
if [[ -n "$KOF_MUT_SIGNAL" ]]; then interrupted "$KOF_MUT_SIGNAL" "$KOF_MUT_STATUS"; fi
while ! IFS= read -r -t 0.1 -u8 KOF_MUT_READY_GROUP; do
    kill -0 "$KOF_MUT_CHILD" 2>/dev/null || fail
done
[[ "$KOF_MUT_READY_GROUP" =~ ^[0-9]+$ ]] || fail
KOF_MUT_GROUP=$KOF_MUT_READY_GROUP
[[ "$KOF_MUT_GROUP" == "$KOF_MUT_CHILD" ]] || fail
printf 'go\n' >&9
exec 8>&- 9>&-
if wait "$KOF_MUT_CHILD"; then exit 0; else exit 2; fi
