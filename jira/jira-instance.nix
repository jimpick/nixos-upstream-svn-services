rec {
  pkgs = import ./pkgs/top-level/all-packages.nix {};

  j2re  = pkgs.jdk;
  ant   = pkgs.apacheAnt;

  jetty =
    (import ./server-pkgs/jetty/instance.nix) {
      webapps = [
          { path = "/"; war = "${jira}/lib/atlassian-jira.war"; }
        ];

      sslSupport = false;
      port   = 10080;
      logdir = "/home/eelco/jetty";

      inherit j2re;
      inherit (pkgs) stdenv jetty;
    };

  jira =
    (import ./server-pkgs/jira/jira-war.nix) {
      dbaccount = {
        database = "jira";
        host = "127.0.0.1";
        port = 5432;
        username = "jira";
        password = "changethis";
      };

      inherit (pkgs) stdenv fetchurl unzip;
      inherit ant;
      jdbc = pkgs.postgresql_jdbc;
      plugins = [subversion_plugin rpc_plugin];
    };

  subversion_plugin =
    (import ./server-pkgs/jira/subversion) {
      inherit (pkgs) stdenv fetchurl unzip;
    };

  rpc_plugin =
    (import ./server-pkgs/jira/rpc) {
      inherit (pkgs) stdenv fetchurl;
    };
}
