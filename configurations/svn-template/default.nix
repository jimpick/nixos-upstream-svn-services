# This is the server configuration for svn.cs.uu.nl.

{productionServer ? true}:

let {

  body = webServer;

  pkgs = import ../../pkgs/top-level/all-packages.nix {};


  rootDir = "/tmp/subversion";

  logDir = rootDir + "/" +
     (if productionServer then "logs" else "test-logs");
     
  
  webServer = import ../../apache-httpd {
    inherit (pkgs) apacheHttpd coreutils;
    stdenv = pkgs.stdenvNew;

    hostName = "localhost";
    httpPort = if productionServer then "12080" else "12081";
    httpsPort = if productionServer then "12443" else "12444";

    adminAddr = "eelco@cs.uu.nl";

    inherit logDir;
    stateDir = logDir;

    subServices = [
      subversionService
    ];

    enableSSL = false;
    sslServerCert = "/home/svn/ssl/server.crt";
    sslServerKey = "/home/svn/ssl/server.key";
  };

  
  subversionService = import ../../subversion {
    inherit (pkgs) fetchurl
      apacheHttpd mod_python openssl db4 expat swig
      zlib perl perlBerkeleyDB python libxslt enscript
      apr aprutil neon;
    stdenv = pkgs.stdenvNew;

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

    notificationSender = "svn@localhost";

    # Arthur wants WebDAV autoversioning support.
    autoVersioning = true;
  };
}
