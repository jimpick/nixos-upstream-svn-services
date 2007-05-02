# This is the server configuration for svn.cs.uu.nl.

{productionServer ? true}:

let {

  body = webServer;

  pkgs = import ../../pkgs/top-level/all-packages.nix {};


  rootDir = "/data/subversion";

  logDir = rootDir + "/" +
     (if productionServer then "logs" else "test-logs");

  
  webServer = import ../../apache-httpd {
    inherit (pkgs) stdenv apacheHttpd coreutils;

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

    siteConf = pkgs.writeText "site.conf" "
      RedirectMatch ^/$ ${subversionService.canonicalName}/repoman
    ";
  };

  
  subversionService = import ../../subversion {
    reposDir = rootDir + "/repos";
    dbDir = rootDir + "/db";
    distsDir = rootDir + "/dist";
    backupsDir = rootDir + "/backup";
    tmpDir = rootDir + "/tmp";

    inherit (webServer) logDir adminAddr user group;

    canonicalName =
      if webServer.enableSSL then
        "https://" + webServer.hostName + ":" + webServer.httpsPort
      else
        "http://" + webServer.hostName + ":" + webServer.httpPort;

    notificationSender = "svn@svn.cs.uu.nl";

    userCreationDomain = "cs.uu.nl";

    # Arthur wants WebDAV autoversioning support.
    autoVersioning = true;

    inherit pkgs;
  };
}
