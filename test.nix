let {

  body = webServer;

  pkgs = import pkgs/system/all-packages.nix {system = __currentSystem;};

  instanceRootDir = "/home/eelco/tmp/inst-basic-web-server";

  adminAddr = "eelco@cs.uu.nl";

    
  webServer = import ./apache-httpd {
    inherit (pkgs) stdenv substituter apacheHttpd coreutils;
    
    logDir = instanceRootDir + "/log";
    stateDir = instanceRootDir + "/state";
    hostName = "itchy.cs.uu.nl";
    inherit adminAddr;

    subServices = [
      subversionService
    ];
  };

  
  subversionService = import ./subversion {
    inherit (pkgs) stdenv fetchurl
      substituter apacheHttpd openssl db4 expat swig zlib
      perl perlBerkeleyDB python libxslt enscript;

    reposDir = instanceRootDir + "/repos";
    dbDir = instanceRootDir + "/db";
    logsDir = instanceRootDir + "/logs";
    distsDir = instanceRootDir + "/dist";
    backupsDir = instanceRootDir + "/backup";

    # Evaluation semantics should be lazier.
    # inherit (webServer) canonicalName adminAddr;

    canonicalName = "http://itchy.labs.cs.uu.nl:8080"; # !!! ugly
    inherit adminAddr;

    notificationSender = "svn@svn.cs.uu.nl";
  };

}
