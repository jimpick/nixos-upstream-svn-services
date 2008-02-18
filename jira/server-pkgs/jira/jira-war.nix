{stdenv, fetchurl, unzip, ant, jdbc, dbaccount, plugins ? []}:

let

  jirajarsjetty = import ./jira-jars-jetty.nix {
    inherit stdenv fetchurl unzip;
  };

in

  stdenv.mkDerivation {
    name = "jira-instance";
    builder = ./jirawar-builder.sh;

    src = ./atlassian-jira-professional-3.6.2.tar.gz;
    version = "3.6.2";

    inherit ant jdbc;
    extrajars = jirajarsjetty;

    inherit (dbaccount) database host port username password;

    inherit plugins;
    plugin_installers = map (plugin : plugin.installer) plugins;
  }
