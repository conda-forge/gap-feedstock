INSTALL_DIR="$PREFIX/share/gap"

mkdir -p "$INSTALL_DIR"

make install-headers install-libgap

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
cp "$RECIPE_DIR/gap.sh" "$PREFIX/bin/gap"
chmod +x "$PREFIX/bin/gap"

GAP_SRC_PATH=`ls -d "$INSTALL_DIR"/bin/*/src`
rm "$GAP_SRC_PATH"
ln -s "$INSTALL_DIR"/src/ "$GAP_SRC_PATH"

rm "$INSTALL_DIR"/build/gap
ln -s "$INSTALL_DIR"/src/ "$INSTALL_DIR"/build/gap

mkdir -p "$INSTALL_DIR/pkg"
cd pkg
for GAP_PKG_NAME in smallgrp transgrp primgrp gapdoc;
do
    echo "GAP_PKG_NAME: $GAP_PKG_NAME"
    mv $GAP_PKG_NAME $INSTALL_DIR/pkg/$GAP_PKG_NAME
done
