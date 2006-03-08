# TODO: provide a real control script.

{ stdenv
, name            
, xorgConf        # xorg.conf configuration file
, server          # Installation prefix of xorg server
, init            # Full path to program to run in the X server
, user            # User for which the program should be run
, terminal ? 7
, display ? 0
, control ? null
, logDir ? "/var/log"
} :

stdenv.mkDerivation {
  inherit name xorgConf server init terminal display logDir user;
  builder = ./builder.sh;
  control =
    if control == null then "startx" else control;
}
