#!/bin/bash

set -x

# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* ./hpcgap/extern/gc
cp $BUILD_PREFIX/share/gnuconfig/config.* ./pkg/json-2.0.1/cnf
cp $BUILD_PREFIX/share/gnuconfig/config.* ./pkg/semigroups-3.2.3/libsemigroups/config
cp $BUILD_PREFIX/share/gnuconfig/config.* ./extern/gmp
cp $BUILD_PREFIX/share/gnuconfig/config.* ./pkg/io-4.7.0/cnf
cp $BUILD_PREFIX/share/gnuconfig/config.* ./pkg/semigroups-3.2.3/cnf
cp $BUILD_PREFIX/share/gnuconfig/config.* ./pkg/DeepThought-1.0.2/cnf
cp $BUILD_PREFIX/share/gnuconfig/config.* ./pkg/CddInterface-2020.01.01/cnf
cp $BUILD_PREFIX/share/gnuconfig/config.* ./pkg/float-0.9.1/build-aux
cp $BUILD_PREFIX/share/gnuconfig/config.* ./pkg/digraphs-1.1.1/extern/edge-addition-planarity-suite-Version_3.0.0.5
cp $BUILD_PREFIX/share/gnuconfig/config.* ./pkg/digraphs-1.1.1/cnf
cp $BUILD_PREFIX/share/gnuconfig/config.* ./pkg/curlInterface-2.1.1/cnf
cp $BUILD_PREFIX/share/gnuconfig/config.* ./pkg/ferret-1.0.2/cnf
cp $BUILD_PREFIX/share/gnuconfig/config.* ./hpcgap/extern/libatomic_ops
cp $BUILD_PREFIX/share/gnuconfig/config.* ./pkg/ZeroMQInterface-0.12/cnf
cp $BUILD_PREFIX/share/gnuconfig/config.* ./pkg/xgap-4.30/cnf
cp $BUILD_PREFIX/share/gnuconfig/config.* ./pkg/guava-3.15/src/leon
cp $BUILD_PREFIX/share/gnuconfig/config.* ./pkg/NormalizInterface-1.1.0/cnf
cp $BUILD_PREFIX/share/gnuconfig/config.* ./pkg/nq-2.5.4/cnf
cp $BUILD_PREFIX/share/gnuconfig/config.* ./pkg/profiling-2.2.1/cnf
cp $BUILD_PREFIX/share/gnuconfig/config.* ./pkg/grape-4.8.3/nauty22
cp $BUILD_PREFIX/share/gnuconfig/config.* ./cnf

set -x

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
for GAP_PKG_NAME in kbmag cohomolo guava example ace xgap anupq polymakeinterface fplsa;
do
    PKG_DIR=`find . -maxdepth 1 -iname "$GAP_PKG_NAME-*" -type d`
    rm -rf $PKG_DIR
done

if [[ -d NormalizInterface-1.1.0 ]]; then
    curl -L -O https://github.com/gap-packages/NormalizInterface/releases/download/v1.2.0/NormalizInterface-1.2.0.tar.gz
    tar -xvf NormalizInterface-1.2.0.tar.gz
    rm NormalizInterface-1.2.0.tar.gz
fi

for pkg in json profiling simpcomp ferret; do
  VERSION_PKG_DIR=`find . -maxdepth 1 -iname "$pkg-*" -or -iname "$pkg" -type d`
  pushd $VERSION_PKG_DIR
    if [[ "$target_platform" == osx-* ]]; then
      mv VERSION .VERSION
    fi
  popd
done

sed -i.bak "s@./build-normaliz.sh@echo@g" ../bin/BuildPackages.sh
bash ../bin/BuildPackages.sh --add-package-config-Semigroups "--with-external-libsemigroups --without-march-native"  --add-package-config-Digraphs "--with-external-bliss --with-external-planarity --without-intrinsics"

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
