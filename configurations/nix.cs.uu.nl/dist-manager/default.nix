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
    ./overview/full-indices-per-package.xsl 
    ./overview/full-status-per-package.xsl  
    ./overview/main-index.xsl  
    ./overview/nix-release-lib.xsl  
    ./overview/quick-view.xsl
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
