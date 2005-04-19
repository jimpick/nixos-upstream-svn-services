{stdenv, postgresql, port ? 5432, serveruser ? "postgres", logdir, datadir} :

stdenv.mkDerivation {
  name = "postgresql-cluster";
  builder = ./cluster-builder.sh;
  inherit postgresql port serveruser logdir datadir;
}
