{stdenv, fetchurl}:

stdenv.mkDerivation {
  name = "atlassian-jira-rpc-plugin-3.6.2-1.jar";
  builder = ./builder.sh;
  src = fetchurl {
    url = http://losser.st-lab.cs.uu.nl/~mbravenb/mirror/jira-plugins/atlassian-jira-rpc-plugin-3.6.2-1.jar;
    md5 = "0b72d941357b2ca6231dbd0cede4f1ae";
  };

  installer = ./install.sh;
}
