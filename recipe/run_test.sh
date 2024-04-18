#!/bin/bash
set -e

INSTALL_DIR="$PREFIX/share/gap"

# https://github.com/gap-system/gap/issues/1567
export TERM=dumb

cd $INSTALL_DIR/pkg

if [[ "$target_platform" == *-64 ]]; then
  for folder in *; do
    pushd $folder
    GAP_PKG_NAME=$(echo $folder | cut -d- -f1)
    echo "*******************************************************"
    echo "* Verifying that GAP package $GAP_PKG_NAME loads."
    echo "*******************************************************"
    load_output=$(gap -q -T <<< "LoadPackage(\"$GAP_PKG_NAME\");")
    [[ "${load_output}" == "true" || "${load_output:1}" == "true" ]]
    echo "*******************************************************"
    echo "* OK. GAP package $GAP_PKG_NAME loads."
    echo "*******************************************************"
    popd
  done
fi
