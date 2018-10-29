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

# Delete PDF documentation and misc TeX files
find doc \( \
         -name "*.bbl" \
      -o -name "*.blg" \
      -o -name "*.aux" \
      -o -name "*.dvi" \
      -o -name "*.idx" \
      -o -name "*.ilg" \
      -o -name "*.l*" \
      -o -name "*.m*" \
      -o -name "*.pdf" \
      -o -name "*.ind" \
      -o -name "*.toc" \
      \) -exec rm {} \;

# DATABASES (to be separated out to database_gap-feedstock) except GAPDoc which is required:
rm -rf small prim trans
cd pkg
shopt -s extglob
rm -rf !(GAPDoc*)
cd ..

# Stuff that isn't GAP sources:
rm -r bin/*
cd extern
rm -r !(Makefile.in)
cd ..

chmod +x configure

./configure \
    --prefix="$PREFIX" PREFIX="$PREFIX" \
    --with-gmp="$PREFIX" \
    CC="$CC" CXX="$CXX" CFLAGS="$CFLAGS" CXXFLAGS="$CXXFLAGS"


make

mkdir -p "$INSTALL_DIR"

cp -R * "$INSTALL_DIR"
rm "$INSTALL_DIR/conda_build.sh"
rm -rf "$INSTALL_DIR/obj"
ln -s "$INSTALL_DIR/gap" "$PREFIX/bin/gap"
ln -s "$GAP_DIR" "$PREFIX/gap/latest"

GAP_SRC_PATH=`ls -d "$INSTALL_DIR"/bin/*/src`
rm "$GAP_SRC_PATH"
ln -s "$INSTALL_DIR"/src/ "$GAP_SRC_PATH"

# Delete tests that rely on the non-GPL small group library
rm "$INSTALL_DIR"/tst/testinstall/ctblsolv.tst
rm "$INSTALL_DIR"/tst/testinstall/grppc.tst
rm "$INSTALL_DIR"/tst/testinstall/morpheus.tst

