#!/bin/bash
set -exo pipefail

source $RECIPE_DIR/install-shared.sh

for pkg in atlasrep \
    autpgrp \
    alnuth \
    crisp \
    ctbllib \
    factint \
    fga \
    irredsol \
    laguna \
    polenta \
    polycyclic \
    radiroot \
    resclasses \
    sophus \
    tomlib ; do
  mv pkg/$pkg $INSTALL_DIR/pkg/$pkg
done
