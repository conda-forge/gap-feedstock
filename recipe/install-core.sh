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


mkdir -p "$INSTALL_DIR/pkg"
cd pkg
for GAP_PKG_NAME in smallgrp transgrp primgrp gapdoc;
do
    PKG_DIR=`find . -maxdepth 1 -iname "$GAP_PKG_NAME-*" -type d`

    if [[ -z "$PKG_DIR" ]]; then
        PKG_DIR=`find . -maxdepth 1 -iname "$GAP_PKG_NAME" -type d`
    fi

    if [[ -z "$PKG_DIR" ]]; then
        PKG_DIR=`find . -maxdepth 1 -iname "$GAP_PKG_NAME[0-9]*" -type d`
    fi

    if [[ -z "$PKG_DIR" ]]; then
        PKG_DIR=`find . -maxdepth 1 -iname "$GAP_PKG_NAME*" -type d`
    fi

    mv $PKG_DIR $INSTALL_DIR/pkg/$PKG_DIR
done
