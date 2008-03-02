set -e

source $stdenv/setup

mkdir -p $out/bin

cat > $out/bin/control <<EOF
export PATH=$PATH:$su/bin:$erlang/bin

start()
{
  env -i PATH=$PATH $su/bin/su $user -s /bin/sh -c "$ejabberd/sbin/ejabberdctl \
  --config /etc/ejabberd/ejabberd.conf \
  --ctl-config /etc/ejabberd/ejabberdctl.conf \
  --logs /var/log/ejabberd \
  --spool /var/lib/ejabberd/db/ejabberd start"
}

stop()
{
  env -i PATH=$PATH $su/bin/su $user -s /bin/sh -c "$ejabberd/sbin/ejabberdctl stop"
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
  mkdir -p /etc/ejabberd
  cp $ejabberd/etc/ejabberd/* /etc/ejabberd
  mkdir -p /var/log/ejabberd
  chown -R $user /var/log/ejabberd
  mkdir -p /var/lib/ejabberd/db/ejabberd
  chown -R $user /var/lib/ejabberd/db/ejabberd    
fi

EOF

chmod +x $out/bin/*
