let {

  # Packages for Linux and FreeBSD.
  pkgsLinux = import ../../pkgs/system/all-packages.nix {system = "i686-linux";};
  pkgsFreeBSD = import ../../pkgs/system/all-packages.nix {system = "i686-freebsd";};


  # Some variables.
  postgresPort = 5433;
  jettyPort = 12345;
  
  
  # Build a Postgres server on FreeBSD.
  postgresService = 
    (import ../../jira/server-pkgs/postgresql/cluster.nix) {
      inherit (pkgsFreeBSD) stdenv postgresql;
      port = postgresPort;
      logdir = "/home/eelco/postgres/logs";
      datadir = "/home/eelco/postgres/jira-data-1";
    };


  # Build a Jetty container with Jira on Linux
  jettyService =
    (import ../../jira/server-pkgs/jetty/instance.nix) {
      webapps = [
        { path = "/jira"; war = jiraService ~ "/lib/atlassian-jira.war"; }
      ];

      sslSupport = false;
      port = jettyPort;
      logdir = "/home/eelco/jetty";

      inherit (pkgsLinux) stdenv jetty;
      j2re = pkgsLinux.blackdown;
    };
  
  jiraService =
    (import ../../jira/server-pkgs/jira/jira-war.nix) {
      inherit (pkgsLinux) stdenv fetchurl unzip;
      ant = pkgsLinux.apacheAntBlackdown14;
      postgresql = pkgsLinux.postgresql_jdbc;
      plugins = [  
#        subversion_plugin
      ];

      dbaccount = {
        database = "jira";
        host = "131.211.84.77";
        port = postgresPort;
        username = "eelco";
        password = "changethis";
      };
    };

    
  body = [postgresService jettyService];
}
