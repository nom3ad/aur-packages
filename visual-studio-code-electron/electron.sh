#!/bin/bash

set -exo pipefail

function read_flags() {
    local -n flags_array=$1
    local flags_file=$2 line lines
    if [[ -f "${flags_file}" ]]; then
        mapfile -t lines <"${flags_file}"
    fi

    for line in "${lines[@]}"; do
        if [[ ! "${line}" =~ ^[[:space:]]*#.* ]]; then
            flags_array+=("${line}")
        fi
    done
}

# declare -a codeflags
# read_flags codeflags "${XDG_CONFIG_HOME:-$HOME/.config}/code-flags.conf"

ELECTRON_NAME=electron
declare -a electronflags
read_flags electronflags "${XDG_CONFIG_HOME:-$HOME/.config}/${ELECTRON_NAME}-flags.conf"

VSCODE_PATH=$(dirname "$0")
CODE_JS=$VSCODE_PATH/code.js

CLI_JS=$1
shift || {
    echo "Expected path to CLI JS as first argument" >&2
    exit 44
}

# Ref: https://gitlab.archlinux.org/archlinux/packaging/packages/code/-/blob/bd52fad1af1c9fade02d7b2c44d24edd6b742566/code.sh
export ELECTRON_RUN_AS_NODE=1
exec /usr/lib/${ELECTRON_NAME}/electron "$CLI_JS" "$CODE_JS" "${electronflags[@]}" "$@"
