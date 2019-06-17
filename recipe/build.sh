#!/bin/bash

set -x

export CPPFLAGS="-I$PREFIX/include $CPPFLAGS"
export LDFLAGS="-L$PREFIX/lib $LDFLAGS"
export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
export CFLAGS="-g -O3 -fPIC $CFLAGS"

# Following is adapted from https://github.com/sagemath/sage

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

shopt -s extglob

# Stuff that isn't GAP sources:
cd extern
rm -r !(Makefile.in)
cd ..

chmod +x configure

./configure \
    --prefix="$PREFIX" PREFIX="$PREFIX" \
    --with-gmp="$PREFIX" \
    CC="$CC" CXX="$CXX" CFLAGS="$CFLAGS" CXXFLAGS="$CXXFLAGS"

make

cd pkg

# Disable problematic packages. See https://github.com/conda-forge/gap-feedstock/pull/16
for GAP_PKG_NAME in kbmag cohomolo guava example ace xgap anupq polymakeinterface;
do
    PKG_DIR=`find . -maxdepth 1 -iname "$GAP_PKG_NAME-*" -type d`
    rm -rf $PKG_DIR
done

bash ../bin/BuildPackages.sh

# Build semigroups with external libsemigroups
SEMIGROUPS_PKG_DIR=`find . -maxdepth 1 -iname "semigroups-*" -type d`
pushd $SEMIGROUPS_PKG_DIR
./configure --with-graproot=$SRC_DIR --with-external-libsemigroups
make
popd

# Print error logs
mkdir -p log
ls -al log
touch log/fail.log
cat log/fail.log
for file in log/*; do
  echo "--------------------------$file--------------------"
  cat $file
done
rm -rf log
