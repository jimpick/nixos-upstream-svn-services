{ stdenv, ejabberd, erlang, su,
  user ? "nobody" }:

stdenv.mkDerivation {
  name = "ejabberd-server";
  builder = ./builder.sh;
  ejabberdCfg = ./ejabberd.cfg;
  inherit stdenv ejabberd erlang su user;
}
