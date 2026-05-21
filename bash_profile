function source_file {
    # Check if the file exists before sourcing it
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

# Add personal bin folders to PATH
export PATH=${HOME}/.local/bin:${PATH}
export PATH=${HOME}/bin:${PATH}

source_files_in_dir "${HOME}/.shell/bash_profile.d/"

source_file "${HOME}/.bashrc"
