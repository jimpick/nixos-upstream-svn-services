rec {
  pkgs =
    import pkgs/system/i686-linux.nix;

  jetty =
    (import ./server-pkgs/jetty/instance.nix) {
      webapps = [
          { path = "/jira"; war=jira ~ "/lib/atlassian-jira.war"; }
        ];

      sslKey = dummykey;    
      # sslSupport = false;
      port   = 443;
      logdir = "/var/log/jetty";

      j2sdk  = pkgs.blackdown;
      inherit (pkgs) stdenv jetty;
    };

  jira =
    (import ./server-pkgs/jira/jira-war.nix) {
      dbaccount = import ./database-account.nix;

      inherit (pkgs) stdenv fetchurl unzip postgresql;
      ant = pkgs.apacheAntBlackdown14;
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
      j2sdk = pkgs.blackdown;
    };
}
