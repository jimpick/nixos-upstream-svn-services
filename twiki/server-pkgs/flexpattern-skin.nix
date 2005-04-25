{stdenv, fetchurl, unzip}:

stdenv.mkDerivation {
  name = "FlexPatternSkin-0.1";
  builder = ./unzip-builder.sh;
  src = fetchurl {
    url = http://catamaran.labs.cs.uu.nl/dist/tarballs/FlexPatternSkin-0.1.zip;
    md5 = "30635b72ddc98835502713d1d5a053d6";
  };
  inherit unzip;
}
