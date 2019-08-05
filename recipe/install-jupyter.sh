INSTALL_DIR="$PREFIX/share/gap"

cp $INSTALL_DIR/pkg/JupyterKernel-*/bin/jupyter-kernel-gap .
sed -i.bak "s@  GAP=gap@  GAP=$PREFIX/bin/gap@g" jupyter-kernel-gap
cp jupyter-kernel-gap $PREFIX/bin/jupyter-kernel-gap

pushd $INSTALL_DIR/pkg/JupyterKernel-*/
sed -i.bak "s/user=user/user=user, prefix=sys.prefix/g" setup.py
rm setup.py.bak
python setup.py install
popd

cp $RECIPE_DIR/scripts/post-link.sh $PREFIX/bin/.gap-jupyter-post-link.sh
cp $RECIPE_DIR/scripts/pre-unlink.sh $PREFIX/bin/.gap-jupyter-pre-unlink.sh
