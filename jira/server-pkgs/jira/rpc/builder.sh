source $stdenv/setup

ensureDir $out/lib
cp $src $out/lib/$name
