{productionServer}:

let {

#  body = twikiService;
  body = webServer;

  pkgs = import pkgs/system/all-packages.nix {system = __currentSystem;};

  instanceRootDir = "/home/wiki/web-server";

  adminAddr = "wiki-master@program-transformation.org";

  httpPort = if productionServer then "8090" else "8091";  # !!! ugly

  hostName = "abaris.zoo.cs.uu.nl";
  
  canonicalName = "http://" + hostName + ":" + httpPort;

  
  webServer = import ./apache-httpd {
    inherit (pkgs) stdenv substituter apacheHttpd coreutils;
    
    logDir = instanceRootDir + "/pt-log";
    stateDir = instanceRootDir + "/pt-state";
    inherit hostName httpPort adminAddr;

    subServices = [
      ptWiki
    ];
  };

  ptWiki = (import ./twiki/twiki-instance.nix).twiki {

    defaultUrlHost = canonicalName;

    name          = "pt-wiki";
    
    pubdir        = instanceRootDir + "/pt-wiki/pub";
    datadir       = instanceRootDir + "/pt-wiki/data";

    twikiName     = "Program Transformation Wiki";
    scriptUrlPath = "/pt/bin";
    pubUrlPath    = "/pt/pub";
    dispScriptUrlPath = "";
    dispViewPath  = "";
    absHostPath   = "/pt";

    startWeb = "Transform/WebHome";
  };

}
