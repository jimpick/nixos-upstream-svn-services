. $stdenv/setup

ensureDir $out/modules

$apacheHttpd/bin/apxs -c $noauth -o mod_authn_noauth.la
$apacheHttpd/bin/apxs -c $dyn -o mod_authz_dyn.la

cp .libs/*.so $out/modules/
