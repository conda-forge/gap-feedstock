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
    autpgrp-* \
    alnuth-* \
    crisp-* \
    ctbllib-* \
    FactInt-* \
    fga \
    irredsol-* \
    laguna-* \
    # nq-* \
    polenta-* \
    polycyclic-* \
    resclasses-* \
    sophus-* \
    tomlib-* ; do
    mv $pkg $INSTALL_DIR/pkg/$pkg
done

popd

