# Print with timestamp to stderr

function log {
    eval echo [$(date '+%Y-%m-%d %T%z')] $@ >&2
}

function error {
    log ERROR $@
}

function warning {
    log WARNING $@
}

function info {
    log INFO $@
}

