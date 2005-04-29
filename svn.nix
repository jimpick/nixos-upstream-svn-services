# This is the server configuration for svn.cs.uu.nl.

{productionServer}:

let {

#  body = twikiService;
  body = webServer;

  pkgs = import pkgs/system/all-packages.nix {system = __currentSystem;};

  adminAddr = "eelco@cs.uu.nl";

  httpPort = if productionServer then "12080" else "12081";
  httpsPort = if productionServer then "12443" else "12444";

  hostName = "svn.cs.uu.nl";
  
  canonicalName = "https://" + hostName + ":" + httpsPort;

  instanceRootDir = "/data/subversion";

  logDir = instanceRootDir + "/" + 
    (if productionServer then "logs" else "test-logs");

  stateDir = logDir;

  
  webServer = import ./apache-httpd {
    inherit (pkgs) stdenv substituter apacheHttpd coreutils;

    inherit hostName httpPort httpsPort adminAddr logDir stateDir;

    subServices = [
      subversionService
    ];

    enableSSL = true;
    sslServerCert = "/home/svn/ssl/server.crt";
    sslServerKey = "/home/svn/ssl/server.key";
  };

  subversionService = import ./subversion {
    inherit (pkgs) stdenv fetchurl
      substituter apacheHttpd openssl db4 expat swig zlib
      perl perlBerkeleyDB python libxslt enscript;

    reposDir = instanceRootDir + "/repos";
    dbDir = instanceRootDir + "/db";
    distsDir = instanceRootDir + "/dist";
    backupsDir = instanceRootDir + "/backup";
    inherit logDir;

    # Evaluation semantics should be lazier.
    # inherit (webServer) canonicalName adminAddr;

    inherit adminAddr canonicalName;

    notificationSender = "svn@svn.cs.uu.nl";
  };
}
