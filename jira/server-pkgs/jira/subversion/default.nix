{stdenv, fetchurl, unzip}:

stdenv.mkDerivation {
  name = "jira-subversion-plugin-0.5.1";
  builder = ./builder.sh;
  src = fetchurl {
    url = http://repository.atlassian.com/atlassian-jira-subversion-plugin/distributions/atlassian-jira-subversion-plugin-0.5.1.zip;
    md5 = "1655ef1f622b1b74bc13e54f1a2a1028";
  };

  buildInputs = [unzip];
  installer = ./install.sh;
}
