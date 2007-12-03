{ stdenv, postgresql, su
, port ? 5432
, serverUser ? "postgres"
, logDir
, dataDir
, subServices ? []
, allowedHosts ? []
, authMethod ? "trust"
}:

stdenv.mkDerivation {
  name = "postgresql-cluster";
  builder = ./builder.sh;
  inherit postgresql port serverUser logDir 
    dataDir subServices allowedHosts authMethod;
  inherit (stdenv) coreutils;
  inherit su;
}
