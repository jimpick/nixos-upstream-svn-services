source $stdenv/setup

ensureDir $out/bin

cat > $out/bin/$control <<EOF
#! $SHELL -e

export DISPLAY=:$display.0
$server/bin/Xorg -config $xorgConf -ac :$display vt$terminal -logfile $logDir/Xorg.log \
  & su $user -c $init
EOF

chmod u+x $out/bin/$control
