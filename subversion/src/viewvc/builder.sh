. $stdenv/setup

buildPhase=buildPhase
buildPhase() {
    return
}

installPhase=installPhase
installPhase() {
    ensureDir $out/viewvc
    cp $conf viewvc.conf.dist
    substituteInPlace viewvc.conf.dist \
      --subst-var reposDir \
      --subst-var adminAddr \
      --subst-var subversion
    (echo $out/viewvc; echo) | ./viewvc-install
}

genericBuild
