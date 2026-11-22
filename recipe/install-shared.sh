#!/bin/bash

INSTALL_DIR="$PREFIX/share/gap"

# GAP packages shipped by gap-core.
CORE_PKGS="smallgrp
transgrp
primgrp
gapdoc
utils"

# GAP packages shipped by gap-defaults.
DEFAULT_PKGS="atlasrep
autpgrp
alnuth
crisp
ctbllib
factint
fga
irredsol
laguna
polenta
polycyclic
radiroot
resclasses
sophus
tomlib"

mkdir -p "$INSTALL_DIR/pkg"

# Remove all object files and temporary files.
find pkg \( \
         -name "*.o" \
      -o -name "*.lo" \
      -o -name "*.la" \
      -o -name "*.lai" \
      -o -name ".libs" \
      -o -name "config.log" \
      -o -name "config.status" \
      -o -name "libtool" \
      \) -exec rm -rf {} \; || true
