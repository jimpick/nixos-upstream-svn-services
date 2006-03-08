# TODO: provide a real control script.

{ stdenv
, name
, xorgConf
, server
, init
, terminal ? 7
, display ? 0
, control ? null
, logDir ? "/var/log"
} :

stdenv.mkDerivation {
  inherit name xorgConf server init terminal display logDir;
  builder = ./builder.sh;
  control =
    if control == null then "startx" else control;
}
