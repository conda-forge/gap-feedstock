INSTALL_DIR="$PREFIX/gap"

mkdir -p "$INSTALL_DIR"

cp -R * "$INSTALL_DIR"
rm -rf "$INSTALL_DIR/obj"
rm -rf "$INSTALL_DIR/pkg"
rm "$INSTALL_DIR"/conda_build.sh
ln -s "$INSTALL_DIR/gap" "$PREFIX/bin/gap"
ln -s "$GAP_DIR" "$PREFIX/gap/latest"

GAP_SRC_PATH=`ls -d "$INSTALL_DIR"/bin/*/src`
rm "$GAP_SRC_PATH"
ln -s "$INSTALL_DIR"/src/ "$GAP_SRC_PATH"

