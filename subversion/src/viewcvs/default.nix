{stdenv, python, substitute, reposDir, adminAddr}:

stdenv.mkDerivation {
  name = "viewcvs";
  builder = ./builder.sh;
  
  src = ./viewcvs-20050416.tar.bz2;
  conf = ./viewcvs.conf.in;

  buildInputs = [python];
  inherit substitute reposDir adminAddr;
}
