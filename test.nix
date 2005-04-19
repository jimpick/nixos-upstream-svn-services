let {

  body = server;

  pkgs = import pkgs/system/all-packages.nix {system = __currentSystem;};

  instanceRootDir = "/home/eelco/tmp/inst-basic-web-server";

  server = import ./apache-httpd {
    inherit (pkgs) stdenv substituter apacheHttpd coreutils;
    logDir = instanceRootDir + "/log";
    stateDir = instanceRootDir + "/state";
    adminAddr = "eelco@cs.uu.nl";
    hostName = "itchy.cs.uu.nl";
  };

}
