source $stdenv/setup

ensureDir $out/modules

cp $noauth mod_authn_noauth.c
$apacheHttpd/bin/apxs -c mod_authn_noauth.c -o mod_authn_noauth.la

cp $dyn mod_authz_dyn.c
$apacheHttpd/bin/apxs -c mod_authz_dyn.c -o mod_authz_dyn.la

cp .libs/*.so $out/modules/
