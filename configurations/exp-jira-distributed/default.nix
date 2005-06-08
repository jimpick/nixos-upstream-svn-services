let {

  # Packages for Linux and FreeBSD.
  pkgsLinux = import ../../pkgs/system/all-packages.nix {system = "i686-linux";};
  pkgsFreeBSD = import ../../pkgs/system/all-packages.nix {system = "i686-freebsd";};


  # Some variables.
  postgresPort = 5433;
  jettyPort = 12345;
  
  
  # Build a Postgres server on FreeBSD.
  postgresService = 
    (import ../../postgresql) {
      inherit (pkgsLinux) stdenv postgresql;
      port = postgresPort;
      logDir = "/home/eelco/postgres/logs";
      dataDir = "/home/eelco/postgres/jira-data-1";
      subServices = [jiraService];
    };


  # Build a Jetty container on Linux.
  jettyService =
    (import ../../jira/server-pkgs/jetty) {
      webapps = [
        { path = "/jira"; war = jiraService ~ "/lib/atlassian-jira.war"; }
      ];

      sslSupport = false;
      port = jettyPort;
      logdir = "/home/eelco/jetty";

      inherit (pkgsLinux) stdenv jetty;
      j2re = pkgsLinux.blackdown;
    };

  # Build a JIRA service.  
  jiraService = import ../../jira/server-pkgs/jira/jira-war.nix {
    inherit (pkgsLinux) stdenv fetchurl unzip;
    ant = pkgsLinux.apacheAntBlackdown14;
    postgresql = pkgsLinux.postgresql_jdbc;
    plugins = [  
#      subversion_plugin
    ];

    dbaccount = {
      database = "jira";
      host = "localhost";
      port = postgresPort;
      username = "eelco";
      password = "changethis";
    };
  };


  # The top-level server runner.
  serviceRunner = (import ../../runner) {
    inherit (pkgsLinux) stdenv substituter;
    services = [postgresService jettyService];
  };

  
  body = serviceRunner;
}
