#!/bin/bash
set -exo pipefail

source $RECIPE_DIR/install-shared.sh

# Every output starts from a fresh copy of the build's work directory, so the
# packages of gap-core and gap-defaults are still there; skip them.
for pkg in `ls pkg/`; do
  if grep -qxF "$pkg" <<< "$CORE_PKGS"$'\n'"$DEFAULT_PKGS"; then
    continue
  fi
  mv pkg/$pkg $INSTALL_DIR/pkg/$pkg
done

pushd $INSTALL_DIR/pkg/jupyterkernel/

sed -i.bak "s@  GAP=gap@  GAP=$PREFIX/bin/gap@g" bin/jupyter-kernel-gap
rm bin/jupyter-kernel-gap.bak
rm setup.py
cp $RECIPE_DIR/setup.py setup.py
cp $RECIPE_DIR/gap-mode.json etc/
python -m pip install . --no-deps
rm -rf $SP_DIR/gap_jupyter-*

popd
