INSTALL_DIR="$PREFIX/share/gap"

mkdir -p "$INSTALL_DIR"

make install-headers install-libgap
cp gen/config.h $PREFIX/include/gap

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

cp -R * "$INSTALL_DIR"
rm -rf "$INSTALL_DIR/obj"
rm -rf "$INSTALL_DIR/pkg"
rm "$INSTALL_DIR"/conda_build.sh
ln -s "$INSTALL_DIR/gap" "$PREFIX/bin/gap-bin"
cp "$RECIPE_DIR/gap.sh" "$PREFIX/bin/gap"

GAP_SRC_PATH=`ls -d "$INSTALL_DIR"/bin/*/src`
rm "$GAP_SRC_PATH"
ln -s "$INSTALL_DIR"/src/ "$GAP_SRC_PATH"

INSTALL_DIR="$PREFIX/gap"
mkdir -p "$INSTALL_DIR/pkg"
cd pkg
for GAP_PKG_NAME in smallgrp transgrp primgrp gapdoc;
do
    PKG_DIR=`find . -maxdepth 1 -iname "$GAP_PKG_NAME-*" -o -iname "$GAP_PKG_NAME" -type d`
    echo "GAP_PKG_NAME: $GAP_PKG_NAME"
    echo "PKG_DIR: $PKG_DIR"
    ls -al .
    mv $PKG_DIR $INSTALL_DIR/pkg/$PKG_DIR
done
