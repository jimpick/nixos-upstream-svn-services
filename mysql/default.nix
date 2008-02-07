{ stdenv, mysql,
  port ? 3306,
  user ? "nobody",
  dataDir ? "/var/mysql",
  logError ? "/var/log/mysql_err.log",
  pidFile ? "/var/mysql/mysql.pid"
}:

stdenv.mkDerivation {
  name = "mysql-server";
  builder = ./builder.sh;
  inherit stdenv mysql port user dataDir logError pidFile;
}
