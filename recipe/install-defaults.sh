#!/bin/bash
set -exo pipefail

source $RECIPE_DIR/install-shared.sh

for pkg in $DEFAULT_PKGS; do
  mv pkg/$pkg $INSTALL_DIR/pkg/$pkg
done
