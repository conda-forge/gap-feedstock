#!/bin/bash
set -e

INSTALL_DIR="$PREFIX/share/gap"

# https://github.com/gap-system/gap/issues/1567
export TERM=dumb

cd $INSTALL_DIR/pkg

broken_packages=()

if [[ "$target_platform" == *-64 ]]; then
  for folder in *; do
    pushd $folder
    GAP_PKG_NAME=$(echo $folder | cut -d- -f1)
    echo "*******************************************************"
    echo "* Verifying that GAP package $GAP_PKG_NAME loads."
    echo "*******************************************************"
    if ! gap --nointeract -b -c 'SetInfoLevel(InfoPackageLoading, 4); if LoadPackage("'$GAP_PKG_NAME'") = fail then GapExitCode(1); fi;'; then
      broken_packages+=("$GAP_PKG_NAME")
      echo "*******************************************************"
      echo "* Error. GAP package $GAP_PKG_NAME does not load."
      echo "*******************************************************"
    else
      echo "*******************************************************"
      echo "* OK. GAP package $GAP_PKG_NAME loads."
      echo "*******************************************************"
    fi
    popd
  done
fi

if [ ${#broken_packages[@]} -eq 0 ]; then
  echo "All GAP packages in this installation seem to be functional."
else
  echo "Some GAP packages in this installation are not functional:"
  printf " - %s\n" "${broken_packages[@]}"
  exit 1
fi
