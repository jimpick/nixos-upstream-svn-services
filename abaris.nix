{productionServer}:

let {

#  body = twikiService;
  body = webServer;

  pkgs = import pkgs/system/all-packages.nix {system = __currentSystem;};

  instanceRootDir = "/home/wiki/web-server";

  adminAddr = "wiki-master@cs.uu.nl";

  httpPort = if productionServer then "8080" else "8081";  # !!! ugly

  hostName = "abaris.zoo.cs.uu.nl";
  
  canonicalName = "http://" + hostName + ":" + httpPort;

  
  webServer = import ./apache-httpd {
    inherit (pkgs) stdenv substituter apacheHttpd coreutils;
    
    logDir = instanceRootDir + "/log";
    stateDir = instanceRootDir + "/state";
    inherit hostName httpPort adminAddr;

    subServices = [
#      minWiki
#      ptWiki # staat in abaris-pt
      icsWiki
      intraWiki
      betaWiki
    ];
  };

  icsWiki = (import ./twiki/twiki-instance.nix).twiki {

    defaultUrlHost = canonicalName;

    name          = "ics-wiki";
    
    pubdir        = instanceRootDir + "/ics-wiki/pub";
    datadir       = instanceRootDir + "/ics-wiki/data";

    twikiName     = "ICS Wiki";
    scriptUrlPath = "/wiki/bin";
    pubUrlPath    = "/wiki/pub";
    absHostPath   = "/wiki";

    dispPubUrlPath    = "/wiki/pub";
    dispScriptUrlPath = "/wiki";
    dispViewPath      = "";

    registrationDomain = ".uu.nl";
  };

  intraWiki = (import ./twiki/twiki-instance.nix).twiki {

    defaultUrlHost = canonicalName;

    name          = "intra-wiki";
    
    pubdir        = instanceRootDir + "/intra-wiki/pub";
    datadir       = instanceRootDir + "/intra-wiki/data";

    twikiName     = "Intra Wiki";
    scriptUrlPath = "/intra/bin";
    pubUrlPath    = "/intra/pub";
    absHostPath   = "/intra";

    dispPubUrlPath    = "/intra/pub";
    dispScriptUrlPath = "/intra";
    dispViewPath  = "";

    registrationDomain = ".uu.nl";
    alwaysLogin = true;
  };

  betaWiki = (import ./twiki/twiki-instance.nix).twiki {

    defaultUrlHost = canonicalName;

    name          = "beta-wiki";
    
    pubdir        = instanceRootDir + "/beta-wiki/pub";
    datadir       = instanceRootDir + "/beta-wiki/data";

    twikiName     = "Beta Wiki";
    scriptUrlPath = "/beta/bin";
    pubUrlPath    = "/beta/pub";
    absHostPath   = "/beta";

    dispScriptUrlPath = "/beta";
    dispViewPath      = "";

    registrationDomain = ".uu.nl";
  };

  testWiki = (import ./twiki/twiki-instance.nix).twiki {

    defaultUrlHost = canonicalName;

    name          = "test-wiki";
    
    pubdir        = instanceRootDir + "/test-wiki/pub";
    datadir       = instanceRootDir + "/test-wiki/data";

    twikiName     = "Test Wiki";
    scriptUrlPath = "/test/bin";
    pubUrlPath    = "/test/pub";
    absHostPath   = "/test";

    dispScriptUrlPath = "/test";
    dispViewPath  = "";
  };

  minWiki = (import ./twiki/twiki-instance.nix).twiki {

    defaultUrlHost = canonicalName;

    name          = "min-wiki";
    
    pubdir        = instanceRootDir + "/min-wiki/pub";
    datadir       = instanceRootDir + "/min-wiki/data";

    twikiName     = "Minimal Wiki";
    scriptUrlPath = "/min/bin";
    pubUrlPath    = "/min/pub";
    absHostPath   = "/min";

    dispScriptUrlPath = "/min";
    dispViewPath  = "";

    registrationDomain = ".uu.nl";
  };

  ptWiki = (import ./twiki/twiki-instance.nix).twiki {

    defaultUrlHost = canonicalName;

    name          = "pt-wiki";
    
    pubdir        = instanceRootDir + "/pt-wiki/pub";
    datadir       = instanceRootDir + "/pt-wiki/data";

    twikiName     = "Program Transformation Wiki";
    scriptUrlPath = "/pt/bin";
    pubUrlPath    = "/pt/pub";
    absHostPath   = "/pt";

    dispScriptUrlPath = "/pt";
    dispViewPath  = "";

    startWeb = "Transform/WebHome";
  };

}
