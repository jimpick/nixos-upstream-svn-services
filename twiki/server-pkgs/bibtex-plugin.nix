{stdenv, fetchurl, unzip, perl}:

stdenv.mkDerivation {
  name = "BibTexPlugin-0.1";
  builder = ./bibtex-builder.sh;
  src = /tmp/BibTexPlugin-0.1.zip;
  inherit unzip perl;
}
