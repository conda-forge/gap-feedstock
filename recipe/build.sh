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

# Disable problematic packages. See https://github.com/conda-forge/gap-feedstock/pull/16
rm -rf xgap

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

# https://github.com/gap-system/gap/issues/1567
export TERM=dumb

if [[ "$target_platform" == *-64 ]]; then
  for folder in *; do
    pushd $folder
    echo "GAP_PKG_NAME: $GAP_PKG_NAME"
    GAP_PKG_NAME=$(echo $folder | cut -d- -f1)
    load_output=$(../../bin/gap.sh -q -T <<< "LoadPackage(\"$GAP_PKG_NAME\");")
    [[ "${load_output}" == "true" || "${load_output:1}" == "true" ]] || echo "Loading fails"
    popd
  done
fi
