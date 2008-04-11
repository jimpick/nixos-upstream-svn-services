# This is the server configuration for nix.cs.uu.nl.

{productionServer}:

let {

  body = webServer;

  pkgs = import ../../pkgs/top-level/all-packages.nix {};


  rootDir = "/data/webserver";

  logDir = "/var/log/www" +
     (if productionServer then "" else "/test");

  distDir = rootDir + "/dist";
  distPrefix = "/dist";
  distConfDir = rootDir + "/dist-conf";
     
  
  webServer = import ../../apache-httpd {
    inherit (pkgs) stdenv apacheHttpd coreutils;

    hostName = "nix.cs.uu.nl";
    httpPort = if productionServer then "80" else "8080";

    adminAddr = "eelco@cs.uu.nl";

    inherit logDir;
    stateDir = logDir;

    subServices = [
      #distManager
    ];

    siteConf = ./site.conf;

    documentRoot = "/data/webserver/docroot";
  };

  distManager = import ../../dist-manager {
    inherit (pkgs) stdenv perl;
    saxon8 = pkgs.saxonb;
    inherit distDir distPrefix distConfDir;
    canonicalName = "http://" + webServer.hostName + 
      (if webServer.httpPort == "80" then "" else ":" + webServer.httpPort);
  };
}
