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
      stIntraWiki
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
  };

  minWiki = (import ./twiki/twiki-instance.nix).twiki {

    defaultUrlHost = canonicalName;

    name          = "min-wiki";
    
    pubdir        = instanceRootDir + "/min-wiki/pub";
    datadir       = instanceRootDir + "/min-wiki/data";

    twikiName     = "Minimal Wiki";
    scriptUrlPath = "/min/bin";
    pubUrlPath    = "/min/pub";
  };

  ptWiki = (import ./twiki/twiki-instance.nix).twiki {

    defaultUrlHost = canonicalName;

    name          = "pt-wiki";
    
    pubdir        = instanceRootDir + "/pt-wiki/pub";
    datadir       = instanceRootDir + "/pt-wiki/data";

    twikiName     = "Program Transformation Wiki";
    scriptUrlPath = "/pt/bin";
    pubUrlPath    = "/pt/pub";
  };

  icsWiki = (import ./twiki/twiki-instance.nix).twiki {

    defaultUrlHost = canonicalName;

    name          = "ics-wiki";
    
    pubdir        = instanceRootDir + "/cs-wiki/pub";
    datadir       = instanceRootDir + "/cs-wiki/data";

    twikiName     = "ICS Wiki";
    scriptUrlPath = "/wiki/bin";
    pubUrlPath    = "/wiki/pub";
  };

  stIntraWiki = (import ./twiki/twiki-instance.nix).twiki {

    defaultUrlHost = canonicalName;

    name          = "st-intra-wiki";
    
    pubdir        = instanceRootDir + "/st-intra-wiki/pub";
    datadir       = instanceRootDir + "/st-intra-wiki/data";

    twikiName     = "ST IntraWiki";
    scriptUrlPath = "/st-intra/bin";
    pubUrlPath    = "/st-intra/pub";
  };

}
