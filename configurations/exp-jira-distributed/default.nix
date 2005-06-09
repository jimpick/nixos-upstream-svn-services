let {

  # Packages for Linux and FreeBSD.
  pkgsLinux = import ../../pkgs/system/all-packages.nix {system = "i686-linux";};
  pkgsFreeBSD = import ../../pkgs/system/all-packages.nix {system = "i686-freebsd";};


  # Build a Postgres server on FreeBSD.
  postgresService = (import ../../postgresql {
    inherit (pkgsFreeBSD) stdenv postgresql;

    port = 5432;
    logDir = "/home/eelco/postgres/logs";
    dataDir = "/home/eelco/postgres/jira-data-1";
    
    subServices = [jiraService];

    allowedHosts = [jettyService.host];
    
  }) // {host = "losser.labs.cs.uu.nl";};# <- ugly


  # Build a Jetty container on Linux.
  jettyService = (import ../../jetty {
    inherit (pkgsLinux) stdenv jetty;
    j2re = pkgsLinux.blackdown;

    port = 8080;
    sslSupport = false;
    logDir = "/home/eelco/jetty";

    subServices = [
      { path = "/jira"; war = jiraService; }
    ];
  }) // {host = "itchy.labs.cs.uu.nl";};# <- ugly

    
  # Build a JIRA service.  
  jiraService = import ../../jira/server-pkgs/jira/jira-war.nix {
    inherit (pkgsLinux) stdenv fetchurl unzip;
    ant = pkgsLinux.apacheAntBlackdown14;
    postgresql = pkgsLinux.postgresql_jdbc;

    dbaccount = {
      database = "jira";
      inherit (postgresService) host port;
      username = "eelco";
      password = "changethis";
    };

    plugins = [
#      subversion_plugin
    ];
  };


  # The top-level server runner.
  serviceRunner = (import ../../runner) {
    inherit (pkgsLinux) stdenv substituter;
    services = [postgresService jettyService];
  };

  
  body = serviceRunner;
}
