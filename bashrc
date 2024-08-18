function source_file {
    if [[ -f "$1" ]]; then
        source $1
    fi
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

BASHRCD_FILES=$(find ${HOME}/.shell/bashrc.d/ -type f -name '*.sh' -or -name '*.bash')
eval $(echo "${BASHRCD_FILES}" | xargs -I {} echo "source_file {}; [ \$? == \"0\" ] && true || echo Failed to load {} >&2;")
