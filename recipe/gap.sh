#!/bin/bash

# GAP startup script, installed in $PREFIX/bin/gap

CONDA_GAP_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

GAP_ROOT="$(dirname $CONDA_GAP_SCRIPT_DIR)/share/gap"

exec "$GAP_ROOT/gap" -l "$GAP_ROOT" -m 64m "$@"
