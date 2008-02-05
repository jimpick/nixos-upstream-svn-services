{stdenv, fetchurl, python, subversion, enscript, reposDir, adminAddr, urlPrefix}:

stdenv.mkDerivation {
  name = "viewvc-1.0.4";
  
  src = fetchurl {
    url = http://viewvc.tigris.org/files/documents/3330/37319/viewvc-1.0.4.tar.gz;
    sha256 = "07yda0chvg4dalfb8rq2kkjr9n8kldp8azh7dgskp22gzbzyjpjm";
  };
  
  conf = ./viewvc.conf.in;

  patches = [
    # Needed with mod_python 3.3.1 to get rid of "AssertionError:
    # Import cycle in .../viewvc/bin/mod_python/viewvc.py".
    # Source: http://jfut.featia.net/diary/20070610.html
    ./cycle.patch
    
    # ./css.patch
 ];

  buildPhase = "true";

  installPhase = ''
    ensureDir $out/viewvc
    cp $conf viewvc.conf.dist
    substituteInPlace viewvc.conf.dist \
      --subst-var subversion \
      --subst-var enscript \
      --subst-var reposDir \
      --subst-var adminAddr \
      --subst-var urlPrefix
    (echo $out/viewvc; echo) | python viewvc-install
  '';

  buildInputs = [python];
  
  inherit subversion enscript reposDir adminAddr urlPrefix;
}
