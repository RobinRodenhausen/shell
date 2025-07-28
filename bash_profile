function source_file {
    # Check if the file exists before sourcing it
    if [[ -f "$1" ]]; then
        source $1
    fi
}

function cleanup_history() {
    # Create a temporary file with unique entries (preserving timestamps)
    tac "${HISTFILE}" | awk '
    NR % 2 == 1 {
        # Odd line numbers are commands (when reversed)
        command = $0
        next
    }
    NR % 2 == 0 {
        # Even line numbers are timestamps (when reversed)
        timestamp = $0
        if (!seen[command]++) {
            print command
            print timestamp
        }
    }
    ' | tac > ${HISTFILE}.tmp
    # Only replace content because container mounted file cannot be (re)moved
    cat ${HISTFILE}.tmp > "${HISTFILE}"
    rm ${HISTFILE}.tmp
    history -c
    history -r
}

alias hclear=cleanup_history

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
## Set history file location
HISTFILE=~/.bash_eternal_history
## Set history filesize to unlimited
HISTFILESIZE=
HISTSIZE=
## Ignore commands that start with history
HISTIGNORE=history*:
## Add Timestamps to history
HISTTIMEFORMAT='[%Y-%m-%d %H:%M:%S] '
## Share history between multiple shell sessions
PROMPT_COMMAND="history -a; history -n;"
## cleanup history duplicates on exit and only keep the latest entry
trap cleanup_history EXIT

# Add personal bin folders to PATH
export PATH=${HOME}/.local/bin:${PATH}
export PATH=${HOME}/bin:${PATH}

BASH_PROFILED_FILES=$(find ${HOME}/.shell/bash_profile.d/ -type f -name '*.sh' -or -name '*.bash')
eval $(echo "${BASH_PROFILED_FILES}" | xargs -I {} echo "source_file {}; [ \$? == \"0\" ] && true || echo Failed to load {} >&2;")

BASH_COMPLETIOND_FILES=$(find ${HOME}/.shell/bash-completion.d/ -type f -name '*.sh' -or -name '*.bash')
eval $(echo "${BASH_COMPLETIOND_FILES}" | xargs -I {} echo "source_file {}; [ \$? == \"0\" ] && true || echo Failed to load {} >&2;")

source_file ${HOME}/.bashrc
