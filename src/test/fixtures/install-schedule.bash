# Loaded by Bash in a disposable installer process. Observe process creation,
# independently of the next command, source line or registration variable.
install_schedule() {
    [[ "$0" == */install.sh && "$BASHPID" == "$$" && ! -e "$KOF_MUT_SCHEDULE_READY" ]] || return 0
    local children child status
    IFS= read -r children < "/proc/$$/task/$$/children" || true
    [[ -n "$children" ]] || return 0
    child=${children%% *}
    [[ -r "/proc/$child/stat" ]] || return 0
    IFS= read -r status < "/proc/$child/stat" || return 0
    [[ "$status" != *') Z '* ]] || return 0
    printf '%s\n' "$children" > "$KOF_MUT_SCHEDULE_READY.pid"
    printf '%s\n%s\n' "$BASH_COMMAND" "$status" > "$KOF_MUT_SCHEDULE_READY.event"
    : > "$KOF_MUT_SCHEDULE_READY"
    while [[ ! -e "$KOF_MUT_SCHEDULE_READY.continue" ]]; do /bin/sleep 0.02; done
}
trap install_schedule DEBUG
