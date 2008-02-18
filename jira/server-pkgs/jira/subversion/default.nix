{stdenv, fetchurl, unzip}:

stdenv.mkDerivation {
  name = "jira-subversion-plugin-0.9.3";
  builder = ./builder.sh;
  src = fetchurl {
    url = http://repository.atlassian.com/atlassian-jira-subversion-plugin/distributions/atlassian-jira-subversion-plugin-0.9.3.zip;
    md5 = "1f5c1dc0cfff8916c16c9d337b067edb";
  };

  buildInputs = [unzip];
  installer = ./install.sh;
}
