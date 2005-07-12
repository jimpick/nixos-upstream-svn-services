# This is the server configuration for svn.cs.uu.nl.

{productionServer}:

let {

  body = webServer;

  pkgs = import ../../pkgs/system/all-packages.nix {system = __currentSystem;};


  rootDir = "/data/subversion";

  logDir = rootDir + "/" +
     (if productionServer then "logs" else "test-logs");
     
  
  webServer = import ../../apache-httpd {
    inherit (pkgs) stdenv substituter apacheHttpd coreutils;

    hostName = "svn.cs.uu.nl";
    httpPort = if productionServer then "12080" else "12081";
    httpsPort = if productionServer then "12443" else "12444";

    adminAddr = "eelco@cs.uu.nl";

    inherit logDir;
    stateDir = logDir;

    subServices = [
      subversionService
    ];

    enableSSL = true;
    sslServerCert = "/home/svn/ssl/server.crt";
    sslServerKey = "/home/svn/ssl/server.key";
  };

  
  subversionService = import ../../subversion {
    inherit (pkgs) stdenv fetchurl
      substituter apacheHttpd openssl db4 expat swig zlib
      perl perlBerkeleyDB python libxslt enscript;

    reposDir = rootDir + "/repos";
    dbDir = rootDir + "/db";
    distsDir = rootDir + "/dist";
    backupsDir = rootDir + "/backup";
    tmpDir = rootDir + "/tmp";

    inherit (webServer) logDir adminAddr;

    canonicalName =
      if webServer.enableSSL then
        "https://" + webServer.hostName + ":" + webServer.httpsPort
      else
        "http://" + webServer.hostName + ":" + webServer.httpPort;

    notificationSender = "svn@svn.cs.uu.nl";

    # We use Berkeley DB repos.
    fsType = "bdb";

    # Arthur wants WebDAV autoversioning support.
    autoVersioning = true;
  };
}
