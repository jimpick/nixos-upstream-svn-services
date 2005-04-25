let {

#  body = twikiService;
  body = webServer;

  pkgs = import pkgs/system/all-packages.nix {system = __currentSystem;};

  instanceRootDir = "/home/visser/web-server";

  adminAddr = "visser@cs.uu.nl";

  canonicalName = "http://127.0.0.2:8080"; # !!! ugly
  
  webServer = import ./apache-httpd {
    inherit (pkgs) stdenv substituter apacheHttpd coreutils;
    
    logDir = instanceRootDir + "/log";
    stateDir = instanceRootDir + "/state";
    hostName = "itchy.cs.uu.nl";
    inherit adminAddr;

    subServices = [
      minWiki
      testWiki
      visserWiki
      ptWiki
      stWiki
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

  visserWiki = (import ./twiki/twiki-instance.nix).twiki {

    defaultUrlHost = canonicalName;

    name          = "visser-wiki";
    
    pubdir        = instanceRootDir + "/visser-wiki/pub";
    datadir       = instanceRootDir + "/visser-wiki/data";

    twikiName     = "Eelco Visser's Personal Wiki";
    scriptUrlPath = "/visser/bin";
    pubUrlPath    = "/visser/pub";
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

  stWiki = (import ./twiki/twiki-instance.nix).twiki {

    defaultUrlHost = canonicalName;

    name          = "st-wiki";
    
    pubdir        = instanceRootDir + "/st-wiki/pub";
    datadir       = instanceRootDir + "/st-wiki/data";

    twikiName     = "ST Wiki";
    scriptUrlPath = "/st/bin";
    pubUrlPath    = "/st/pub";
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
