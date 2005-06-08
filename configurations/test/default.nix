let {

#  body = twikiService;
  body = webServer;

  pkgs = import pkgs/system/all-packages.nix {system = __currentSystem;};

  instanceRootDir = "/home/eelco/tmp/inst-basic-web-server";

  adminAddr = "eelco@cs.uu.nl";

  canonicalName = "http://itchy.labs.cs.uu.nl:8080"; # !!! ugly
  
    
  webServer = import ./apache-httpd {
    inherit (pkgs) stdenv substituter apacheHttpd coreutils;
    
    logDir = instanceRootDir + "/log";
    stateDir = instanceRootDir + "/state";
    hostName = "itchy.cs.uu.nl";
    inherit adminAddr;

    subServices = [
      subversionService
      twikiService
    ];
  };

  
  subversionService = import ./subversion {
    inherit (pkgs) stdenv fetchurl
      substituter apacheHttpd openssl db4 expat swig zlib
      perl perlBerkeleyDB python libxslt enscript;

    reposDir = instanceRootDir + "/repos";
    dbDir = instanceRootDir + "/db";
    logDir = instanceRootDir + "/log";
    distsDir = instanceRootDir + "/dist";
    backupsDir = instanceRootDir + "/backup";

    # Evaluation semantics should be lazier.
    # inherit (webServer) canonicalName adminAddr;

    inherit adminAddr canonicalName;

    notificationSender = "svn@svn.cs.uu.nl";
  };


  twikiService = (import ./twiki/twiki-instance.nix).twiki {
    defaultUrlHost = canonicalName;

    name = "test-wiki";
    
    pubdir = instanceRootDir + "/twiki-pub";
    datadir = instanceRootDir + "/twiki-data";

    twikiName = "Test Wiki";
    scriptUrlPath = "/twiki/test/bin";
    pubUrlPath = "/twiki/test/pub";
  };

}
