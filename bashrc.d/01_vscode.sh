# This file contains VSCode specific configurations

if [[ "${TERM_PROGRAM:-}" == "vscode" ]]; then
    # Disable double Ctrl+D to exit in VSCode integrated terminal since it causes issues with Copilot
    unset IGNOREEOF
    # Set VSCODE_SHARED_HISTORY to non-empty before starting VSCode if you don't want to use a separate history file.
    if [[ -z "${VSCODE_SHARED_HISTORY:-}" ]]; then
        HISTFILE=${HOME}/.bash_eternal_vscode_history
    fi
fi
