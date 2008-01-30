{ stdenv, jdk, tomcat6, su,
  user ? "nobody",
  baseDir ? "/var/tomcat",
  deployFrom ? null
}:

stdenv.mkDerivation {
  name = "tomcat-server";
  builder = ./builder.sh;
  inherit stdenv jdk tomcat6 su user baseDir deployFrom;
}
