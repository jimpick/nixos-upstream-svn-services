{ stdenv, postgresql
, port ? 5432
, serverUser ? "postgres"
, logDir
, dataDir
, subServices ? []
}:

stdenv.mkDerivation {
  name = "postgresql-cluster";
  builder = ./builder.sh;
  inherit postgresql port serverUser logDir dataDir subServices;
}
