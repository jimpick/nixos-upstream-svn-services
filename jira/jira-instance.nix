rec {
  pkgs =
    import pkgs/system/i686-linux.nix;

  j2re  = pkgs.blackdown;
  ant   = pkgs.apacheAntBlackdown14;

  jetty =
    (import ./server-pkgs/jetty/instance.nix) {
      webapps = [
          { path = "/jira"; war=jira ~ "/lib/atlassian-jira.war"; }
        ];

      sslKey = dummykey;    
      sslSupport = true;
      port   = 443;
      logdir = "/var/log/jetty";

      inherit j2re;
      inherit (pkgs) stdenv jetty;
    };

  jira =
    (import ./server-pkgs/jira/jira-war.nix) {
      dbaccount = import ./database-account.nix;

      inherit (pkgs) stdenv fetchurl unzip;
      inherit ant;
      postgresql = pkgs.postgresql_jdbc;
      plugins = [  
        subversion_plugin
      ];
    };

  subversion_plugin =
    (import ./server-pkgs/jira/subversion) {
      inherit (pkgs) stdenv fetchurl unzip;
    };

  dummykey =
    (import ./server-pkgs/ssl/keystore.nix) {
      key = 
        { dname   = "CN=catamaran.labs.cs.uu.nl, OU=Center for Software Technology, O=Universiteit Utrecht, L=Utrecht, C=NL";
          keyalg  = "RSA";
          keypass = "dummypass";
          alias   = "jetty";
        };
      storepass = "dummypass";
      inherit (pkgs) stdenv;
      inherit j2re;
    };
}
