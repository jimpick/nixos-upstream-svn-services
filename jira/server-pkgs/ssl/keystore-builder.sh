set -e
. $stdenv/setup

$j2sdk/bin/keytool -genkey \
  -alias $alias -keyalg $keyalg \
   -dname "$dname" \
   -keypass $keypass \
   -storepass $storepass \
   -keystore $out
