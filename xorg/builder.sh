source $stdenv/setup
source $substituter


ensureDir $out/bin

defaultPath=$(dirname $(type -tP mkdir))

substitute $control $out/bin/control \
    --subst-var logDir \
    --subst-var stateDir \
    --subst-var SHELL \
    --subst-var xorgserver \
    --subst-var defaultPath \
    --subst-var out
    
chmod +x $out/bin/control


ensureDir $out/conf

modulePath=
for i in $xorgserver $modules; do
    modulePath="${modulePath}ModulePath \"$i/lib/xorg/modules\"\\n"
done

substitute $xorgConf $out/conf/xorg.conf \
    --subst-var modulePath \
    --subst-var xorgserver \
    --subst-var out

