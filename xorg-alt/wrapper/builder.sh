source $stdenv/setup
source $makeWrapper

# TODO: for fonts, and maybe modules as well, we need to find all the subdirectories.
xorgMakeWrapper() {
  original=$1
  wrapper=$2

  makeWrapper "$1" "$2" \
    --set LD_LIBRARY_PATH "" \
    --set PATH "" \
    --suffix-each XORG_MODULE_PATH ',' "$(filterExisting $(addSuffix /lib/xorg/modules $modules))" \
    --suffix-each XORG_MODULE_PATH ',' "$(filterExisting $(addSuffix /lib/xorg/modules/fonts $modules))" \
    --suffix-each XORG_MODULE_PATH ',' "$(filterExisting $(addSuffix /lib/xorg/modules/extensions $modules))" \
    --suffix-each XORG_MODULE_PATH ',' "$(filterExisting $(addSuffix /lib/xorg/modules/input $modules))" \
    --suffix-each XORG_FONT_PATH   ',' "$(filterExisting $fonts)" \
    --suffix-each LD_LIBRARY_PATH  ':' "$(filterExisting $(addSuffix /lib $xorgserverbuildInputs))" \
    --suffix-each PATH ':' "$xorgserver/bin" "$(filterExisting $(addSuffix /bin $xorgserverBuildInputs))"
}

xorgMakeWrapper "$out/bin/XorgENV" "$out/bin/Xorg"

# TODO: support the font path
cat > $out/bin/XorgENV <<EOF
#! $SHELL -e

exec "$xorgserver/bin/Xorg" -modulepath "\$XORG_MODULE_PATH"  -fp "\$XORG_FONT_PATH"  "\$@"
EOF
chmod u+x $out/bin/XorgENV
