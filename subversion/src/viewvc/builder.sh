. $stdenv/setup
. $substituter

buildPhase=buildPhase
buildPhase() {
    return
}

installPhase=installPhase
installPhase() {
    ensureDir $out/viewvc
    cp $conf viewcvs.conf.dist
    substituteInPlace viewcvs.conf.dist \
      --subst-var reposDir \
      --subst-var adminAddr \
      --subst-var subversion
    (echo $out/viewvc; echo) | ./viewcvs-install
}

genericBuild
