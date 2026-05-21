# Print a reminder to touch the YubiKey when using ssh or git commands that may require authentication/signing with the key.

# Set YUBIKEY_REMINDER_DISABLE to non-empty before starting the shell if you do not want these reminders.
if [[ -z "${YUBIKEY_REMINDER_DISABLE:-}" ]]; then
  _yk_remind() {
    printf '\n[YubiKey] If this command pauses for auth/signing, touch the key now.\n\n' > /dev/tty
  }

  ssh() {
    _yk_remind
    command ssh "$@"
  }

  git() {
    case "$1" in
      commit|merge|tag|rebase|cherry-pick|revert|am|push|pull|fetch|clone|ls-remote|remote|submodule)
        _yk_remind
        ;;
    esac
    command git "$@"
  }
fi
