{stdenv, fetchurl, unzip}:

stdenv.mkDerivation {
  name = "jira-jars-jetty";
  builder = ./unzip-builder.sh;

  src = fetchurl {
      url = http://www.atlassian.com/software/jira/docs/servers/jars/3.0/jira-jars-jetty.zip;
      md5 = "467af3590c59d9d2e59f7920852057e2";
    };

  inherit unzip;
  buildInputs = [unzip];
}
