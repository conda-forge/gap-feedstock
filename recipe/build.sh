#!/bin/bash

set -x

pushd pkg/caratinterface
    tar pzxf carat.tgz
popd

# Get an updated config.sub, config.guess and libtool
for f in $(find $SRC_DIR -name config.sub); do
    cp $BUILD_PREFIX/share/gnuconfig/config.sub $f
done
for f in $(find $SRC_DIR -name config.guess); do
    cp $BUILD_PREFIX/share/gnuconfig/config.guess $f
done
for f in $(find $SRC_DIR -name libtool); do
    cp $BUILD_PREFIX/bin/libtool $f
done
for f in $(find $SRC_DIR -name libtool.m4); do
    cp $BUILD_PREFIX/share/aclocal/libtool.m4 $f
    pushd $(dirname $(dirname $f))
        autoreconf -vfi || true
    popd
done

autoreconf -vfi

export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
export CFLAGS="-g -O3 -fPIC $CFLAGS"
rm -f $BUILD_PREFIX/bin/curl-config

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

CONFIGURE_FLAGS=

if [[ "$target_platform" != "$build_platform" ]]; then
  if [[ "$target_platform" == "osx-arm64" ]]; then
    # Set target host correctly when building for M1s (otherwise, it defaults to aarch64-apple-darwin.)
    CONFIGURE_FLAGS="--host=arm64-darwin"
  fi
fi

chmod +x configure

./configure \
    --prefix="$PREFIX" PREFIX="$PREFIX" \
    --with-gmp="$PREFIX" \
    $CONFIGURE_FLAGS \
    CC="$CC" CXX="$CXX" CFLAGS="$CFLAGS" CXXFLAGS="$CXXFLAGS"

make

cd pkg

# Disable problematic packages. See https://github.com/conda-forge/gap-feedstock/pull/16
# anupq, cohomolo because of duplicate symbols
for GAP_PKG_NAME in anupq cohomolo xgap polymakeinterface;
do
    PKG_DIR=`find . -maxdepth 1 -iname "$GAP_PKG_NAME-*" -type d`
    rm -rf $PKG_DIR
done

ACE_PKG_DIR=`find . -maxdepth 1 -iname "ace-*" -or -iname "ace" -type d`
pushd $ACE_PKG_DIR
  sed -i.bak "s/CC=/CC?=/g" Makefile.in
popd

for pkg in nq; do
  pushd $pkg
    if [[ "$target_platform" == osx-* ]]; then
      mv VERSION .VERSION || true
      sed -i.bak "s/< VERSION/< .VERSION/g" configure.ac || true
      sed -i.bak 's@$(top_srcdir)/VERSION@$(top_srcdir)/.VERSION@g' || true
      autoreconf -vfi
    fi
  popd
done

sed -i.bak "s@./build-normaliz.sh@echo@g" ../bin/BuildPackages.sh
bash ../bin/BuildPackages.sh \
   --add-package-config-Semigroups "--with-external-libsemigroups --without-march-native" \
   --add-package-config-Digraphs "--with-external-bliss --with-external-planarity --without-intrinsics"

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
