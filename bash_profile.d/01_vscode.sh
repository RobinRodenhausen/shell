# This file contains VSCode specific configurations

if [[ "${TERM_PROGRAM:-}" == "vscode" ]]; then
    # Disable double Ctrl+D to exit in VSCode integrated terminal since it causes issues with Copilot
    unset IGNOREEOF
    # Separate history file for VSCode to avoid extension and copilot entries to mess with the normal history file
    HISTFILE=~/.bash_eternal_vscode_history
fi
