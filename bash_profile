function source_file {
    if [[ -f "$1" ]]; then
        source $1
    fi
}

### Command Prompt
# Get username for prompt
PROMPTUSER=${USER-$USERNAME}
if [ -z "$PROMPTUSER" ]; then
    PROMPTUSER=$(whoami)
fi
PROMPTUSER=${PROMPTUSER,,}

# Get hostname for prompt
PROMPTHOST=$(hostname -s)
PROMPTHOST=${PROMPTHOST,,}

### Prompt explanation
# \n - Add additional new line for better readability
# \[$([ $? = 0 ] && F=0 B=2 || F=3 B=1; tput setaf $F; tput setab $B)\] - Color prompt depending of the return code of the last command: 0 = Green/Black = Success; !0 = Red/Yellow = Error
# ${PROMPTUSER}@${PROMPTHOST} - user@host
# \[$(tput sgr0)\] - Rest of the line in white
# $(pwd) - Current working directory
# $(date +"%Y-%m-%d %H:%M:%S") - Current data & time
# $(__git_ps1) - Current Git branch (requires git bash completion)
# \n\$ - actual command prompt in new line
export PS1='\n\[$([ $? = 0 ] && F=0 B=2 || F=3 B=1; tput setaf $F; tput setab $B)\]${PROMPTUSER}@${PROMPTHOST}\[$(tput sgr0)\]$(pwd) - $(date +"%Y-%m-%d %H:%M:%S")$(__git_ps1)\n\$ '
export GIT_PS1_SHOWDIRTYSTATE=1

### Shell behaivior
# Requires STRG + D twice to end shell
export IGNOREEOF=1

### History
export HISTCONTROL=ignoredups:erasedups:ignorespace
## Set history filesize to unlimited
export HISTFILESIZE=
export HISTSIZE=
## Set history file location
export HISTFILE=~/.bash_eternal_history
## Support history in multiple shell sessions
export PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND$'\n'}history -a; history -c; history -r"
## Add Timestamps to history
export HISTTIMEFORMAT='[%Y-%m-%d %H:%M:%S] '

# Add personal bin folders to PATH
export PATH=${HOME}/.local/bin:${PATH}
export PATH=${HOME}/bin:${PATH}

BASH_PROFILED_FILES=$(find ${HOME}/.shell/bash_profile.d/ -type f -name '*.sh' -or -name '*.bash')
eval $(echo "${BASH_PROFILED_FILES}" | xargs -I {} echo "source_file {}; [ \$? == \"0\" ] && true || echo Failed to load {} >&2;")

BASH_COMPLETIOND_FILES=$(find ${HOME}/.shell/bash-completion.d/ -type f -name '*.sh' -or -name '*.bash')
eval $(echo "${BASH_COMPLETIOND_FILES}" | xargs -I {} echo "source_file {}; [ \$? == \"0\" ] && true || echo Failed to load {} >&2;")

source_file ${HOME}/.bashrc
