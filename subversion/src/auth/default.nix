{stdenv, apacheHttpd}:

stdenv.mkDerivation {
  name = "svnserver-auth";
  builder = ./builder.sh;

  noauth = ./mod_authn_noauth.c;
  dyn = ./mod_authz_dyn.c;

  inherit apacheHttpd;
}
