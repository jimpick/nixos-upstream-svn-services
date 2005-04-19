{stdenv, fetchurl, unzip, ant, postgresql, dbaccount}:

let {
  body =
    stdenv.mkDerivation {
      name = "jira-instance";
      builder = ./jirawar-builder.sh;

      src = ./atlassian-jira-professional-3.0.3.tar.gz;
      version = "3.0.3";

      inherit ant unzip postgresql;
      extrajars = jirajarsjetty;

      inherit (dbaccount) database host port username password;
    };

  jirajarsjetty =
    (import ./jira-jars-jetty.nix) {
      inherit stdenv fetchurl unzip;
    };
}
