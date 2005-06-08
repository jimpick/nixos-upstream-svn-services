{productionServer} :

let {

#  body = twikiService;
  body = webServer;

  pkgs = import pkgs/system/all-packages.nix {system = __currentSystem;};

  instanceRootDir = "/home/martin/tmp/web-server";

  adminAddr = "martin@cs.uu.nl";

  canonicalName = "http://127.0.0.1:8080"; # !!! ugly
  
  webServer = import ./apache-httpd {
    inherit (pkgs) stdenv substituter apacheHttpd coreutils;
    
    logDir = instanceRootDir + "/log";
    stateDir = instanceRootDir + "/state";
    hostName = "itchy.cs.uu.nl";
    inherit adminAddr;

    subServices = [
      testWiki
    ];
  };

  testWiki = (import ./twiki/twiki-instance.nix).twiki {

    defaultUrlHost = canonicalName;

    name          = "test-wiki";
    
    pubdir        = instanceRootDir + "/test-wiki/pub";
    datadir       = instanceRootDir + "/test-wiki/data";

    twikiName      = "Test Wiki";
    scriptUrlPath  = "/test/bin";
    pubUrlPath     = "/test/pub";
    absHostPath    = "/test";

    # Hacks for proxying and rewriting
    dispPubUrlPath    = "/pub";
    dispScriptUrlPath = "";
    dispViewPath      = "";
  };
}
