            if [[ -n "${KOF_MUT_READY_BARRIER:-}" ]]; then
                printf '%s\n' "$child" > "$KOF_MUT_READY_BARRIER.jvm"
                : > "$KOF_MUT_READY_BARRIER"
                while [[ ! -f "$KOF_MUT_READY_BARRIER.continue" ]]; do /bin/sleep 0.02; done
            fi
