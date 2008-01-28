{ stdenv, jboss, su,
  tempDir ? "/tmp",
  logDir ? "/var/log/jboss",
  libUrl ? "file:///nix/var/nix/profiles/default/server/default/lib",
  deployDir ? "/nix/var/nix/profiles/default/server/default/deploy/",
  user ? "nobody",
  serverDir ? "/var/jboss/server",
  useJK ? null
}:

stdenv.mkDerivation {
  name = "jboss-server";
  builder = ./builder.sh;
  inherit stdenv jboss tempDir logDir libUrl deployDir user serverDir useJK su;
}
