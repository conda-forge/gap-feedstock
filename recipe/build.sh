#!/bin/bash

export CPPFLAGS="-I$PREFIX/include $CPPFLAGS"
export LDFLAGS="-L$PREFIX/lib $LDFLAGS"
export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
export CFLAGS="-g -O3 -fPIC $CFLAGS"

# Following is adapted from https://github.com/sagemath/sage

VERSION=$PKG_VERSION
echo $VERSION
GAP_DIR="gap-$VERSION"
INSTALL_DIR="$PREFIX/gap/$GAP_DIR"

# Stuff that isn't GAP sources:
rm -rf bin/*

./autogen.sh
./configure \
    --prefix="$PREFIX" PREFIX="$PREFIX" \
    --with-gmp="$PREFIX" \
    CC="$CC" CXX="$CXX" CFLAGS="$CFLAGS" CXXFLAGS="$CXXFLAGS"

make

mkdir -p "$INSTALL_DIR"

cp -R * "$INSTALL_DIR"
cp bin/gap.sh "$PREFIX/bin/gap"
ln -s "$GAP_DIR" "$PREFIX/gap/latest"

# Delete tests that rely on the non-GPL small group library
rm "$INSTALL_DIR"/tst/testinstall/ctblsolv.tst
rm "$INSTALL_DIR"/tst/testinstall/grppc.tst
rm "$INSTALL_DIR"/tst/testinstall/morpheus.tst
