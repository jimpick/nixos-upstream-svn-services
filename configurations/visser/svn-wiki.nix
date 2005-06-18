# This is the server configuration for subversion at Eelco Visser's laptop.

{productionServer}:

let {

  body = webServer;

  pkgs = import ../../pkgs/system/all-packages.nix {system = __currentSystem;};

  baseDir = "/home/visser/test-server" ;

  rootDir = baseDir + "/server";

  svnDir = baseDir + "/subversion";

  logDir = rootDir + "/" +
     (if productionServer then "logs" else "test-logs");
     
#x  hostName  = "10.0.0.151";
  hostName  = "localhost.localdomain";
  httpPort  = if productionServer then "12080" else "12081";
  httpsPort = if productionServer then "12443" else "12444";

  canonicalName =
    if enableSSL then
        "https://" + hostName + ":" + httpsPort
      else
        "http://" + hostName + ":" + httpPort;

  enableSSL     = false;
  sslServerCert = "/home/svn/ssl/server.crt";
  sslServerKey  = "/home/svn/ssl/server.key";
  

  webServer = import ../../apache-httpd {
    inherit (pkgs) stdenv substituter apacheHttpd coreutils;

    adminAddr = "eelco-visser@xs4all.nl";

    inherit     logDir;
    stateDir  = logDir;

    inherit hostName httpPort httpsPort enableSSL 
      sslServerCert sslServerKey ;

    subServices = [
      subversionService wikiService 
    ];

  };

  subversionService = import ../../subversion {
    inherit (pkgs) stdenv fetchurl
      substituter apacheHttpd openssl db4 expat swig zlib
      perl perlBerkeleyDB python libxslt enscript;

    reposDir   = svnDir + "/repos";
    dbDir      = svnDir + "/db";
    distsDir   = svnDir + "/dist";
    backupsDir = svnDir + "/backup";
    tmpDir     = svnDir + "/tmp";

    inherit (webServer) logDir adminAddr;

    inherit canonicalName;

    notificationSender = "eelco-visser@xs4all.nl";

    # We use Berkeley DB repos.
    fsType = "bdb";
  };

  wikiService = (import ../../twiki/twiki-instance.nix).twiki {

    defaultUrlHost = canonicalName;

    name          = "JTS-Wiki";
    
    pubdir        = baseDir + "/wiki/pub";
    datadir       = baseDir + "/wiki/data";

    twikiName     = "JTS Wiki";
    scriptUrlPath = "/wiki/bin";
    pubUrlPath    = "/wiki/pub";
    absHostPath   = "/wiki";

    dispPubUrlPath = "/wiki/pub";
    dispScriptUrlPath = "/wiki";
    dispViewPath  = "";
  };

}
