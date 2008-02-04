set -e

source $stdenv/setup

mkdir -p $out/bin

cat > $out/bin/control <<EOF
export PATH=$PATH:$su/bin:$erlang/bin

export NODE=ejabberd
export HOST=localhost
export EJABBER_DB=/var/ejabberd/database/\$NODE
export ERL_INETRC_PATH=/etc/erlang/conf/inetrc
export EJABBERD_CONFIG_PATH=/etc/ejabberd
export EJABBERD_LOG_PATH=/var/log/ejabberd

mkdir -p \$EJABBERD_LOG_PATH
chown $user \$EJABBERD_LOG_PATH

start()
{
  env -i PATH=$PATH $su/bin/su $user -s /bin/sh -c "$erlang/bin/erl -noinput -detached \
    +P 25000 \
    -setcookie ejabberd \
    -sname \$NODE@\$HOST \
    -mnesia dir "\"\$EJABBERD_DB\"" \
    -kernel inetrc \"\$ERL_INETRC_PATH\" \
    -s ejabberd \
    -ejabberd config \"\$EJABBERD_CONFIG_PATH\" \
              log_path \"\$EJABBERD_LOG_PATH\" \
"
}

stop()
{
  echo
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
  mkdir -p \$EJABBERD_CONFIG_PATH
  cp $out/ejabberd.conf \$EJABBERD_CONFIG_PATH
  chown -R $user \$EJABBERD_CONFIG_PATH
fi

EOF

chmod +x $out/bin/*
cp $ejabberdCfg $out
