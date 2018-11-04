INSTALL_DIR="$PREFIX/gap"

mkdir -p "$INSTALL_DIR/pkg"

cd pkg

GAP_PKG_NAME=`sed 's/gap-//g' <<< $PKG_NAME`

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
ln -s "$INSTALL_DIR/pkg/$PKG_DIR" "$PKG_DIR"
