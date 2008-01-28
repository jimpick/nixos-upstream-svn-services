{ stdenv, mysql,
  port ? 3306,
  user ? "nobody",
  datadir ? "/var/mysql",
  log_error ? "/var/log/mysql_err.log",
  pid_file ? "/var/mysql/mysql.pid"
}:

stdenv.mkDerivation {
  name = "mysql-server";
  builder = ./builder.sh;
  inherit stdenv mysql port user datadir log_error pid_file;
}
