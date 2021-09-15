--- bin/BuildPackages.sh.bak    2021-09-15 12:34:45.729535956 -0700
+++ bin/BuildPackages.sh        2021-09-15 12:38:27.348142632 -0700
@@ -179,11 +179,7 @@
   then
     if grep Autoconf ./configure > /dev/null
     then
-      local PKG_NAME=$($GAP -q -T -A -r <<GAPInput
-Read("PackageInfo.g");
-Print(GAPInfo.PackageInfoCurrent.PackageName);
-GAPInput
-)
+      local PKG_NAME=$(cat ./PackageInfo.g | grep "PackageName := " | cut -b 17- | rev | cut -b 3- | rev)
       local CONFIG_ARGS_FLAG_NAME="PACKAGE_CONFIG_ARGS_${PKG_NAME}"
       echo_run ./configure --with-gaproot="$GAPROOT" $CONFIGFLAGS ${!CONFIG_ARGS_FLAG_NAME}
       echo_run "$MAKE" clean
