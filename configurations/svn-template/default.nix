# This is the server configuration for svn.cs.uu.nl.

{productionServer}:

let {

  body = webServer;

  pkgs = import ../../pkgs/system/all-packages.nix {};


  rootDir = "/tmp/subversion";

  logDir = rootDir + "/" +
     (if productionServer then "logs" else "test-logs");
     
  
  webServer = import ../../apache-httpd {
    inherit (pkgs) stdenv substituter apacheHttpd coreutils;

    hostName = "svn.example.org";
    httpPort = if productionServer then "12080" else "12081";

    adminAddr = "admin@example.org";

    inherit logDir;
    stateDir = logDir;

    subServices = [
      subversionService
    ];
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

    notificationSender = "svn@example.org";

    # We use Berkeley DB repos.
    fsType = "bdb";

    # Arthur wants WebDAV autoversioning support.
    autoVersioning = true;
  };
}
