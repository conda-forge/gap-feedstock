#!/bin/bash

INSTALL_DIR="$PREFIX/share/gap"

mkdir -p "$INSTALL_DIR"

make install

set +e
pushd pkg
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
      \) -exec rm -rf {} \;
popd
echo "done"
set -e

mkdir -p "$INSTALL_DIR/pkg"
cd pkg
for GAP_PKG_NAME in smallgrp transgrp primgrp gapdoc;
do
    echo "GAP_PKG_NAME: $GAP_PKG_NAME"
    mv $GAP_PKG_NAME $INSTALL_DIR/pkg/$GAP_PKG_NAME
done

# remove broken symlink in GAP 4.12.2 (TODO: remove in next GAP release)
rm -f $INSTALL_DIR/pkg/agt/doc/mathjax
