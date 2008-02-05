{ stdenv, fetchurl, writeText, reposDir, cacheDir, urlPrefix
, subversion, enscript, gnused, diffutils
}:

let

  config = writeText "config.inc" ''
    <?php
      $config->setSVNCommandPath("${subversion}/bin");
      $config->setEnscriptPath("${enscript}/bin");
      $config->setSedPath("${gnused}/bin");
      $config->setDiffPath("${diffutils}/bin");
      $config->parentPath("${reposDir}");
      $config->useEnscript();
      $config->useMultiViews();
      $config->setTemplatePath("$locwebsvnreal/templates/BlueGrey/");
      $config->setCacheDir("${cacheDir}");
    ?>
  '';

in


stdenv.mkDerivation {
  name = "websvn-2.0";

  buildPhase = "true";
  installPhase = ''
    ensureDir $out
    cp -prd * $out
    cp ${config} $out/include/config.php
    sed -e "s|^\$locwebsvnreal.*|\$locwebsvnreal=\"$out\";|" \
        -e "s|^\$locwebsvnhttp.*|\$locwebsvnhttp=\"${urlPrefix}\";|" \
        < $out/wsvn.php > $out/wsvn.php.tmp
    mv $out/wsvn.php.tmp $out/wsvn.php
  '';
  
  src = fetchurl {
    url = http://websvn.tigris.org/files/documents/1380/39378/websvn-2.0.tar.gz;
    sha256 = "1sm2rx1lbwp914yaickv0c4i836g8rxra2jvibqv62x9ss34l41q";
  };

  patches = [./rss-cache.patch];

  inherit reposDir subversion;
}
