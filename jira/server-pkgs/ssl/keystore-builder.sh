set -e
. $stdenv/setup

$j2re/bin/keytool -genkey \
  -alias $alias -keyalg $keyalg \
   -validity 500 \
   -dname "$dname" \
   -keypass $keypass \
   -storepass $storepass \
   -keystore $out
