{ stdenv, jdk, tomcat6, su,
  user ? "nobody",
  baseDir ? "/var/tomcat"
}:

stdenv.mkDerivation {
  name = "tomcat-server";
  builder = ./builder.sh;
  inherit stdenv jdk tomcat6 su user baseDir;
}
