#!/bin/bash

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
fi

sed -i.bak "s@./build-normaliz.sh@echo@g" ../bin/BuildPackages.sh
bash ../bin/BuildPackages.sh --add-package-config-semigroups "--with-external-libsemigroups --without-march-native"  --add-package-config-digraphs "--with-external-bliss --with-external-planarity --without-intrinsics"

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
