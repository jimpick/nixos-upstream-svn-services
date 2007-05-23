{stdenv, fetchurl, python, reposDir, adminAddr, subversion}:

stdenv.mkDerivation {
  name = "viewvc-1.0.3";
  builder = ./builder.sh;
  
  src = fetchurl {
    url = http://viewvc.tigris.org/files/documents/3330/34803/viewvc-1.0.3.tar.gz;
    md5 = "3d44ad485d38bf9f61d8111661260b4a";
  };
  conf = ./viewvc.conf.in;

  patches = [./css.patch];

  buildInputs = [python];
  inherit reposDir adminAddr subversion;
}
