{stdenv, fetchurl, unzip}:

stdenv.mkDerivation {
  name = "BlueBoxSkin-0.2";
  builder = ./unzip-builder.sh;
  src = fetchurl {
    url = http://losser.st-lab.cs.uu.nl/~mbravenb/software/BlueBoxSkin/BlueBoxSkin-0.2.zip;
    md5 = "11122c2be9986e7d8f433c403f868e2a";
  };

  inherit unzip;
}
