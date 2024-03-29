INSTALL_DIR="$PREFIX/share/gap"

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

echo "done"
set -e

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
    resclasses \
    sophus \
    tomlib ; do
    mv $pkg $INSTALL_DIR/pkg/$pkg
done

popd

# remove broken symlink in GAP 4.12.2 (TODO: remove in next GAP release)
rm -f $INSTALL_DIR/pkg/agt/doc/mathjax
