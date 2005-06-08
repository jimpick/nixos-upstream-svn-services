{productionServer}:

let {

#  body = twikiService;
  body = webServer;

  pkgs = import pkgs/system/all-packages.nix {system = __currentSystem;};

  instanceRootDir = "/home/visser/web-server";

  adminAddr = "visser@cs.uu.nl";

  httpPort = if productionServer then "8080" else "8081";  # !!! ugly

  hostName = "127.0.0.2";
  
  canonicalName = "http://" + hostName + ":" + httpPort;

  
  webServer = import ./apache-httpd {
    inherit (pkgs) stdenv substituter apacheHttpd coreutils;
    
    logDir = instanceRootDir + "/log";
    stateDir = instanceRootDir + "/state";
    inherit hostName httpPort adminAddr;

    subServices = [
      visserWiki
#      minWiki
#      testWiki
#      ptWiki
#      stWiki
#      stIntraWiki
#      betaWiki
    ];
  };

  visserWiki = (import ./twiki/twiki-instance.nix).twiki {

    defaultUrlHost = canonicalName;

    name          = "visser-wiki";
    
    pubdir        = instanceRootDir + "/visser-wiki/pub";
    datadir       = instanceRootDir + "/visser-wiki/data";

    twikiName     = "Eelco Visser's Personal Wiki";
    scriptUrlPath = "/visser/bin";
    pubUrlPath    = "/visser/pub";
    dispScriptUrlPath = "/visser";
    dispViewPath  = "";
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

    registrationDomain = "127.0.0.2";
  };

}
