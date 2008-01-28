set -e

source $stdenv/setup

mkdir -p $out/bin

cat > $out/bin/control <<EOF
start()
{
  $mysql/bin/mysqld_safe --port=$port --user=$user --datadir=$datadir --log-error=$log_error --pid-file=$pid_file
}

stop()
{
  ps ax | grep "$mysql/bin/mysqld_safe" | grep -v "grep" | cut -d\  -f2 | xargs kill
  kill \`cat $pid_file\`
}

if test "\$1" = start
then
  trap stop 15
  
  start
elif test "\$1" = stop
then
   stop
elif test "\$1" = init
then
  echo 'Are you sure you want to remove old MySQL DBs?'
  read
  if ! test "\$REPLY" = yes; then exit 1; fi

  rm -rf $datadir
  mkdir -p $datadir
  chown -R $user $datadir

  $mysql/bin/mysql_install_db --port=$port --user=$user --datadir=$datadir --log-error=$log_error --pid-file=$pid_file
fi
EOF

chmod +x $out/bin/*
