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

pushd $INSTALL_DIR/pkg/jupyterkernel/
sed -i.bak "s@  GAP=gap@  GAP=$PREFIX/bin/gap@g" bin/jupyter-kernel-gap
rm bin/jupyter-kernel-gap.bak
rm setup.py
cp $RECIPE_DIR/setup.py setup.py
cp $RECIPE_DIR/gap-mode.json etc/
python -m pip install . --no-deps
rm -rf $SP_DIR/gap_jupyter-*
popd

# Delete doc for agt (we do not ship docs and these contain broken symlinks.)
rm -rf $INSTALL_DIR/pkg/agt/doc
