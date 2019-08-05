INSTALL_DIR="$PREFIX/share/gap"

rm -rf "$INSTALL_DIR/pkg"

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
popd
set -e

mv pkg $INSTALL_DIR/pkg
cp $INSTALL_DIR/pkg/JupyterKernel-*/bin/jupyter-kernel-gap .
sed -i.bak "s@  GAP=gap@  GAP=$PREFIX/bin/gap@g" jupyter-kernel-gap
cp jupyter-kernel-gap $PREFIX/bin/jupyter-kernel-gap
