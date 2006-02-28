{stdenv, fetchurl, python, substituter, reposDir, adminAddr}:

stdenv.mkDerivation {
  name = "viewvc-20060228";
  builder = ./builder.sh;
  
  src = fetchurl {
    url = http://www.viewvc.org/nightly/viewvc-2006-02-28.tar.gz;
    md5 = "532fcb4e51de304fc23fcd5cc1111cfc";
  };
  conf = ./viewcvs.conf.in;

  patches = [./css.patch];

  buildInputs = [python];
  inherit substituter reposDir adminAddr;
}
