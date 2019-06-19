#!/bin/sh

# GAP startup script, installed in $PREFIX/bin/gap

CONDA_GAP_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

GAP_ROOT="$(dirname $CONDA_GAP_SCRIPT_DIR)/share/gap"

exec "$(dirname $CONDA_GAP_SCRIPT_DIR)/bin/gap-bin" -l "$GAP_ROOT" -m 64m "$@"
