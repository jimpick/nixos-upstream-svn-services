{ stdenv, substituter, xorgserver

# X modules that should be added to the server's ModulePath.  Modules
# are assumed to reside in $prefix/lib/xorg/modules, for each $prefix
# in this list.
, modules ? []

# Directory where the X server will store its log files.
, logDir 

# Directory where the X server will keep state (e.g., the pid file).
, stateDir 

}:

stdenv.mkDerivation {
  name = "xorg-server-config";
  builder = ./builder.sh;

  xorgConf = ./xorg.conf; 
  control = ./control.in;

  inherit substituter xorgserver modules logDir stateDir;
}

