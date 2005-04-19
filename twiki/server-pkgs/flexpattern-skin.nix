{stdenv, fetchurl, unzip}:

stdenv.mkDerivation {
  name = "FlexPatternSkin-0.1";
  builder = ./unzip-builder.sh;
  src = /tmp/FlexPatternSkin-0.1.zip;
  inherit unzip;
}
