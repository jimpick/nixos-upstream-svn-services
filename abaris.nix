let {

#  body = twikiService;
  body = webServer;

  pkgs = import pkgs/system/all-packages.nix {system = __currentSystem;};

  instanceRootDir = "/home/wiki/web-server";

  adminAddr = "wiki-master@cs.uu.nl";

  canonicalName = "http://abaris.zoo.cs.uu.nl:8080"; # !!! ugly
  
  webServer = import ./apache-httpd {
    inherit (pkgs) stdenv substituter apacheHttpd coreutils;
    
    logDir = instanceRootDir + "/log";
    stateDir = instanceRootDir + "/state";
    hostName = "abaris.zoo.cs.uu.nl";
    inherit adminAddr;

    subServices = [
      minWiki
      ptWiki
      icsWiki
      intraWiki
      betaWiki
    ];
  };

  testWiki = (import ./twiki/twiki-instance.nix).twiki {

    defaultUrlHost = canonicalName;

    name          = "test-wiki";
    
    pubdir        = instanceRootDir + "/test-wiki/pub";
    datadir       = instanceRootDir + "/test-wiki/data";

    twikiName     = "Test Wiki";
    scriptUrlPath = "/test/bin";
    pubUrlPath    = "/test/pub";
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
    dispScriptUrlPath = "/pt";
    dispViewPath  = "";
  };

  icsWiki = (import ./twiki/twiki-instance.nix).twiki {

    defaultUrlHost = canonicalName;

    name          = "ics-wiki";
    
    pubdir        = instanceRootDir + "/ics-wiki/pub";
    datadir       = instanceRootDir + "/ics-wiki/data";

    twikiName     = "ICS Wiki";
    scriptUrlPath = "/wiki/bin";
    pubUrlPath    = "/wiki/pub";
    dispScriptUrlPath = "/wiki";
    dispViewPath  = "";

    registrationDomain = ".uu.nl";
  };

  intraWiki = (import ./twiki/twiki-instance.nix).twiki {

    defaultUrlHost = canonicalName;

    name          = "st-intra-wiki";
    
    pubdir        = instanceRootDir + "/st-intra-wiki/pub";
    datadir       = instanceRootDir + "/st-intra-wiki/data";

    twikiName     = "Intra Wiki";
    scriptUrlPath = "/intra/bin";
    pubUrlPath    = "/intra/pub";
    dispScriptUrlPath = "/intra";
    dispViewPath  = "";

    registrationDomain = ".uu.nl";
  };

  betaWiki = (import ./twiki/twiki-instance.nix).twiki {

    defaultUrlHost = canonicalName;

    name          = "beta-wiki";
    
    pubdir        = instanceRootDir + "/beta-wiki/pub";
    datadir       = instanceRootDir + "/beta-wiki/data";

    twikiName     = "Beta Wiki";
    scriptUrlPath = "/beta/bin";
    pubUrlPath    = "/beta/pub";
    dispScriptUrlPath = "/beta";
    dispViewPath  = "";

    registrationDomain = ".uu.nl";
  };

}
