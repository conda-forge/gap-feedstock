#!/bin/bash

INSTALL_DIR="$PREFIX/share/gap"

mkdir -p "$INSTALL_DIR/pkg"

# Remove all object files and temporary files.
find . \( \
         -name "*.o" \
      -o -name "*.lo" \
      -o -name "*.la" \
      -o -name "*.lai" \
      -o -name ".libs" \
      -o -name "config.log" \
      -o -name "config.status" \
      -o -name "libtool" \
      \) -exec rm -rf {} \; || true
