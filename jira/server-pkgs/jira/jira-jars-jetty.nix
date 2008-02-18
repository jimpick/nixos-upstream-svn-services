{stdenv, fetchurl, unzip}:

stdenv.mkDerivation {
  name = "jira-jars-jetty";

  src = fetchurl {
    url = http://www.atlassian.com/software/jira/docs/servers/jars/3.6.2/jira-jars-jetty.zip;
    md5 = "ff5799aafba58060b5047c4b33cb8521";
  };

  buildInputs = [unzip];

  buildPhase = "true";

  installPhase = ''
    ensureDir $out
    cp * $out
  '';
}
