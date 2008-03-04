source $stdenv/setup

ensureDir $out/bin
ensureDir $out/conf

mkdir conf 
chmod 0700 conf 
touch conf/raw
chmod 0700 conf/raw

substituteAll $confFile conf/raw
$seccureUser/bin/seccure-encrypt $(cat $pubkey) -i conf/raw -o $out/conf/gw6c.conf
substituteAll $controlScript $out/bin/control
chmod a+x $out/bin/control
