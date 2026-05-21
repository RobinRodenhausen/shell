function source_file {
    if [[ -f "$1" ]]; then
        source "$1"
    fi
}

function source_files_in_dir {
    local search_dir="$1"
    local file

    [[ -d "${search_dir}" ]] || return 0

    while IFS= read -r file; do
        source_file "${file}" || echo "Failed to load ${file}" >&2
    done < <(find "${search_dir}" -type f \( -name '*.sh' -o -name '*.bash' \) | sort)
}

function warn_missing_history_flock {
    [[ -z "${HISTORY_FLOCK_WARNING_SHOWN:-}" ]] || return 0
    HISTORY_FLOCK_WARNING_SHOWN=1

    if [[ -w /dev/tty ]]; then
        printf 'Warning: flock is not available. History synchronization will run without file locking, which can cause inconsistencies when multiple shell sessions are open.\n' > /dev/tty
    else
        printf 'Warning: flock is not available. History synchronization will run without file locking, which can cause inconsistencies when multiple shell sessions are open.\n' >&2
    fi
}

function with_history_lock {
    # Run a history action while holding the per-file lock.
    local exit_code
    local history_lock_fd
    local history_lock_file="${HISTFILE}.lock"

    # Fall back to unlocked execution if flock is unavailable.
    if ! command -v flock >/dev/null 2>&1; then
        warn_missing_history_flock
        "$@"
        return $?
    fi

    # Open and lock the sidecar lock file.
    exec {history_lock_fd}>>"${history_lock_file}" || return 1
    flock -x "${history_lock_fd}" || {
        exec {history_lock_fd}>&-
        return 1
    }

    # Run the requested action under the lock.
    "$@"
    exit_code=$?

    # Release the lock and close the descriptor.
    flock -u "${history_lock_fd}"
    exec {history_lock_fd}>&-

    return "${exit_code}"
}

function _history_sync_locked {
    local history_version=""
    local history_version_file="${HISTFILE}.version"

    # Flush this shell's new commands first.
    builtin history -a

    if [[ -f "${history_version_file}" ]]; then
        read -r history_version < "${history_version_file}"
    fi

    # Fully reload if another shell rewrote the file.
    if [[ "${HISTORY_COMPACTION_VERSION:-}" != "${history_version}" ]]; then
        builtin history -c
        builtin history -r
        HISTORY_COMPACTION_VERSION="${history_version}"
        return 0
    fi

    # Otherwise only read newly appended lines.
    builtin history -n
}

function history_sync {
    # Preserve the user's last exit code for the prompt.
    local previous_exit_code=$?

    # Skip sync if the history file is unavailable.
    [[ -n "${HISTFILE:-}" ]] || return "${previous_exit_code}"
    touch "${HISTFILE}" || return "${previous_exit_code}"

    with_history_lock _history_sync_locked >/dev/null 2>&1 || true

    return "${previous_exit_code}"
}

function compact_history_file {
    local temp_file

    # Use a unique temp file to avoid cross-shell collisions.
    temp_file=$(mktemp "${HISTFILE}.XXXXXX") || return 1

    awk '
    # Finish the buffered entry and drop any older duplicate.
    function flush_entry(previous_index) {
        if (!entry_has_command) {
            return
        }

        previous_index = last_index[command]
        if (previous_index > 0) {
            keep[previous_index] = 0
        }

        entry_count++
        timestamps[entry_count] = timestamp
        commands[entry_count] = command
        keep[entry_count] = 1
        last_index[command] = entry_count

        timestamp = ""
        command = ""
        entry_has_command = 0
    }

    # Timestamp lines start a new history entry.
    /^#[0-9]+$/ {
        flush_entry()
        timestamp = $0
        next
    }

    # Collect the command text, including multiline entries.
    {
        if (entry_has_command) {
            command = command ORS $0
        } else {
            command = $0
            entry_has_command = 1
        }
    }

    # Emit entries in original order, skipping older duplicates.
    END {
        flush_entry()

        for (entry_index = 1; entry_index <= entry_count; entry_index++) {
            if (!keep[entry_index]) {
                continue
            }

            if (timestamps[entry_index] != "") {
                print timestamps[entry_index]
            }

            print commands[entry_index]
        }
    }
    ' "${HISTFILE}" > "${temp_file}" || {
        rm -f "${temp_file}"
        return 1
    }

    # Replace the file contents without renaming the mount target.
    cat "${temp_file}" > "${HISTFILE}"
    rm -f "${temp_file}"
}

function _cleanup_history_locked {
    local history_version
    local history_version_file="${HISTFILE}.version"

    # Flush this shell, then compact the file.
    builtin history -a

    compact_history_file || return 1

    # Bump the version so other shells do a full reload.
    history_version=$(date +%s%N)
    printf '%s\n' "${history_version}" > "${history_version_file}"
    HISTORY_COMPACTION_VERSION="${history_version}"

    # Reload the compacted file into this shell.
    builtin history -c
    builtin history -r
}

function cleanup_history {
    # Exit-trap entrypoint.
    [[ -n "${HISTFILE:-}" ]] || return 0
    touch "${HISTFILE}" || return 0

    with_history_lock _cleanup_history_locked
}

alias ls='ls -lAh --color=auto'
alias ll='ls -lAh --color=auto'

bind -f ${HOME}/.inputrc

## Correct minor errors in paths
shopt -s cdspell
## Save multi line commands as single line in history
shopt -s cmdhist
## Appends history instead of overwriting
shopt -s histappend
## Don't autocomplete commands if line is empty
shopt -s no_empty_cmd_completion

# Command Prompt
PROMPTUSER=$(whoami | tr '[:upper:]' '[:lower:]')
PROMPTHOST=$(hostname -s | tr '[:upper:]' '[:lower:]')

### Prompt explanation
# \n - Add additional new line for better readability
# \[$([ $? = 0 ] && F=0 B=2 || F=3 B=1; tput setaf $F; tput setab $B)\] - Color prompt depending of the return code of the last command: 0 = Green/Black = Success; !0 = Red/Yellow = Error
# ${PROMPTUSER}@${PROMPTHOST} - user@host
# \[$(tput sgr0)\] - Rest of the line in white
# $(pwd) - Current working directory
# $(date +"%Y-%m-%d %H:%M:%S") - Current date & time
# $(__git_ps1) - Current Git branch (requires git bash completion)
# \n\$ - actual command prompt in new line
PS1='\n\[$([ $? = 0 ] && F=0 B=2 || F=3 B=1; tput setaf $F; tput setab $B)\]${PROMPTUSER}@${PROMPTHOST}\[$(tput sgr0)\]$(pwd) - $(date +"%Y-%m-%d %H:%M:%S")$(__git_ps1)\n\$ '
GIT_PS1_SHOWDIRTYSTATE=1

# Shell behavior
## Requires STRG + D twice to exit shell
IGNOREEOF=1

# History
HISTCONTROL=ignoreboth:erasedups
HISTFILE=${HOME}/.bash_eternal_history
## Set history filesize to unlimited
HISTFILESIZE=
HISTSIZE=
## Ignore commands that start with history
HISTIGNORE=history*:
## Add timestamps to history
HISTTIMEFORMAT='[%Y-%m-%d %H:%M:%S] '
## Share history between multiple shell sessions
if [[ -z "${PROMPT_COMMAND:-}" ]]; then
    PROMPT_COMMAND="history_sync"
elif [[ ";${PROMPT_COMMAND};" != *";history_sync;"* ]]; then
    PROMPT_COMMAND="${PROMPT_COMMAND%;}; history_sync"
fi
## cleanup history duplicates on exit and only keep the latest entry
trap cleanup_history EXIT

source_files_in_dir "${HOME}/.shell/bashrc.d/"
source_files_in_dir "${HOME}/.shell/bash-completion.d/"
