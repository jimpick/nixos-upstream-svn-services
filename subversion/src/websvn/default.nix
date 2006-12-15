{ stdenv, fetchurl, writeText, reposDir, cacheDir
, subversion, enscript, gnused
}:

let

  config = writeText "config.inc" "<?php
    $config->setSVNCommandPath(\"${subversion}/bin\");
    $config->setEnscriptPath(\"${enscript}/bin\");
    $config->setSedPath(\"${gnused}/bin\");
    $config->parentPath(\"${reposDir}\");
    $config->useEnscript();
    $config->useMultiViews();
    $config->setTemplatePath(\"$locwebsvnreal/templates/BlueGrey/\");
    $config->setCacheDir(\"${cacheDir}\");
  ?>";

in


stdenv.mkDerivation {
  name = "websvn-2.0-pre-rc4";

  buildPhase = "true";
  installPhase = "
    ensureDir $out
    cp -prd * $out
    cp ${config} $out/include/config.inc
    sed -e \"s|^\\$locwebsvnreal.*|\\$locwebsvnreal=\'$out\';|\" \\
        -e \"s|^\\$locwebsvnhttp.*|\\$locwebsvnreal=\'/websvn\';|\" \\
        < $out/wsvn.php > $out/wsvn.php.tmp
    mv $out/wsvn.php.tmp $out/wsvn.php
  ";
  
  src = fetchurl {
    url = http://websvn.tigris.org/files/documents/1380/34307/websvn-2.0rc4.tar.bz2;
    md5 = "8a5938bad14021c61f0bbf06f7faf618";
  };

  patches = [./rss-cache.patch];

  inherit reposDir subversion;
}
