{stdenv, fetchurl, unzip, ant, postgresql, dbaccount, plugins ? []}:

let {
  body =
    stdenv.mkDerivation {
      name = "jira-instance";
      builder = ./jirawar-builder.sh;

      src = ./atlassian-jira-professional-3.1.1.tar.gz;
      version = "3.1.1";

      inherit ant unzip postgresql;
      extrajars = jirajarsjetty;

      inherit (dbaccount) database host port username password;

      inherit plugins;
      plugin_installers = map (plugin : plugin.installer) plugins;

      warPath = "/lib/atlassian-jira.war";
    };

  jirajarsjetty =
    (import ./jira-jars-jetty.nix) {
      inherit stdenv fetchurl unzip;
    };
}
