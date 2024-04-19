#!/bin/bash

set -x

export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
export CFLAGS="-g -O3 -fPIC $CFLAGS"
rm -f $BUILD_PREFIX/bin/curl-config

# Following is adapted from https://github.com/sagemath/sage

shopt -s extglob

# Stuff that isn't GAP sources:
cd extern
rm -r !(Makefile.in)
cd ..

export MAKEFLAGS="-j${CPU_COUNT}"

CONFIGURE_FLAGS=

if [[ "$target_platform" != "$build_platform" ]]; then
  if [[ "$target_platform" == "osx-arm64" ]]; then
    # Set target host correctly when building for M1s (otherwise, it defaults to aarch64-apple-darwin.)
    CONFIGURE_FLAGS="--host=arm64-darwin"
  fi
fi

./configure \
    --prefix="$PREFIX" PREFIX="$PREFIX" \
    --with-gmp="$PREFIX" \
    $CONFIGURE_FLAGS \
    CC="$CC" CXX="$CXX" CFLAGS="$CFLAGS" CXXFLAGS="$CXXFLAGS"

make

cd pkg

# cddinterface relies on a very outdated version of cddlib
rm -rf cddinterface
# nconvex requires cddinterface
rm -rf nconvex
# toricvarieties requires nconvex
rm -rf toricvarieties
# 4ti2interface requires 4ti2 (only available on x86_64 on conda-forge.)
conda list 4ti2 | grep 4ti2 || rm -rf 4ti2interface

bash ../bin/BuildPackages.sh \
   --add-package-config-Semigroups "--with-external-libsemigroups --without-march-native" \
   --add-package-config-Digraphs "--with-external-bliss --with-external-planarity --without-intrinsics" \

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
