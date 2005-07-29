{ stdenv, substituter, perl, libxslt
, distDir, distPrefix, distConfDir, canonicalName
}:

stdenv.mkDerivation {
  name = "dist-manager";
  builder = ./builder.sh;

  conf = ./httpd.conf;

  scripts = [
    "=>/types/apache-httpd"
    ./startup-hook.sh
    "=>/cgi-bin"
    ./cgi-bin/create-dist.pl
    "=>/"
    ./directories.conf
    "=>/scripts"
    ./overview/compose-release-info.sh
    ./overview/generate-overview.sh
    ./overview/overviews.xsl
    ./overview/releases2latest100.xsl
    ./overview/releases-for-each-package.xsl
    ./overview/releases-of-packages.xsl
    ./overview/nix-release-lib.xsl
    ./overview/success.gif
    ./overview/failure.gif
    ./overview/menuback.png
  ];

  staticPages = [
    "=>/css"
    ./css/releases.css
  ];

  inherit substituter perl libxslt 
    distDir distPrefix distConfDir canonicalName;
}
