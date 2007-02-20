{ stdenv, perl, saxon8
, distDir, distPrefix, distConfDir, canonicalName
, directories ? ./directories.conf
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
    directories
    "=>/scripts"
    ./overview/compose-release-info.sh
    ./overview/generate-overview.sh
    ./overview/full-indices-per-package.xsl 
    ./overview/full-status-per-package.xsl  
    ./overview/main-index.xsl  
    ./overview/nix-release-lib.xsl  
    ./overview/quick-view.xsl
    ./overview/rss-feed.xsl
    ./overview/success.gif
    ./overview/failure.gif
    ./overview/menuback.png
  ];

  staticPages = [
    "=>/css"
    ./css/releases.css
  ];

  perl = perl + "/bin/perl";
  inherit saxon8
    distDir distPrefix distConfDir canonicalName;
}
