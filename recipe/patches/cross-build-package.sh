--- bin/BuildPackages.sh.bak    2021-05-30 10:16:44.000000000 -0700
+++ bin/BuildPackages.sh        2021-05-30 10:17:20.000000000 -0700
@@ -168,11 +168,7 @@
   then
     if grep Autoconf ./configure > /dev/null
     then
-      local PKG_NAME=$($GAPROOT/gap -q -T -A <<GAPInput
-Read("PackageInfo.g");
-Print(GAPInfo.PackageInfoCurrent.PackageName);
-GAPInput
-)
+      local PKG_NAME=$(cat ./PackageInfo.g | grep "PackageName := " | cut -b 17- | rev | cut -b 3- | rev)
       local CONFIG_ARGS_FLAG_NAME="PACKAGE_CONFIG_ARGS_${PKG_NAME}"
       echo_run ./configure --with-gaproot="$GAPROOT" $CONFIGFLAGS ${!CONFIG_ARGS_FLAG_NAME}
       echo_run "$MAKE" clean
