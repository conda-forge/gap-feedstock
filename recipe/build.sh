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

# cddinterface relies on a very outdated version of cddlib, see #79
rm -rf cddinterface
# nconvex requires cddinterface which is not installed, see #80
rm -rf nconvex
# toricvarieties requires nconvex which is not installed, see #81
rm -rf toricvarieties
# 4ti2interface requires 4ti2 (only available on x86_64 on conda-forge.)
conda list 4ti2 | grep 4ti2 || rm -rf 4ti2interface
# xgap fails to build because it does not detect the X11 headers, see #82
rm -rf xgap
# itc depends on xgap which is not installed, see #83
rm -rf itc
# normalizinterface fails to detect the normaliz headers, see #84
rm -rf normalizinterface

if [[ `uname` == 'Darwin' ]]; then
  # caratinterface fails to build with a compile errer, see #85
  rm -rf caratinterface
fi

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
