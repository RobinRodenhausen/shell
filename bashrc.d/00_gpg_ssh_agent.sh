unset SSH_AGENT_PID
gpgconf --launch gpg-agent >/dev/null 2>&1
export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"

if [[ -t 0 ]]; then
  export GPG_TTY="$(tty)"
  gpg-connect-agent updatestartuptty /bye >/dev/null 2>&1
fi
