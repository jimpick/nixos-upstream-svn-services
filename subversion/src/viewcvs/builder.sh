. $stdenv/setup
. $substituter

buildPhase=buildPhase
buildPhase() {
    return
}

installPhase=installPhase
installPhase() {
    ensureDir $out/viewcvs
    cp $conf viewcvs.conf.dist
    substituteInPlace viewcvs.conf.dist \
      --subst-var reposDir \
      --subst-var adminAddr
    (echo $out/viewcvs; echo) | ./viewcvs-install
}

genericBuild
