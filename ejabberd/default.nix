{ stdenv, ejabberd, erlang, su,
  user ? "nobody" }:

stdenv.mkDerivation {
  name = "ejabberd-server";
  builder = ./builder.sh;
  inherit stdenv ejabberd erlang su user;
}
