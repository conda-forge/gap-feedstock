#!/bin/bash
set -exo pipefail

source $RECIPE_DIR/install-shared.sh

make install

for pkg in smallgrp \
    transgrp \
    primgrp \
    gapdoc \
    utils; do
  mv pkg/$pkg $INSTALL_DIR/pkg/$pkg
done
