{stdenv, fetchurl, python, substituter, reposDir, adminAddr, subversion}:

stdenv.mkDerivation {
  name = "viewvc-1.0.1";
  builder = ./builder.sh;
  
  src = fetchurl {
    url = http://viewvc.tigris.org/files/documents/3330/33320/viewvc-1.0.1.tar.gz;
    md5 = "2e14b2aeadd4e9ddd6b3876ffd184e61";
  };
  conf = ./viewvc.conf.in;

  patches = [./css.patch];

  buildInputs = [python];
  inherit substituter reposDir adminAddr subversion;
}
