set -e

. $stdenv/setup

mkdir -p $out/bin

echo "Creating cluster ctl script."
cat >> $out/bin/control <<EOF
#! $SHELL

export PATH=$su/bin:$coreutils/bin
export HOME=/homeless-shelter

mkdir -p $logDir # !!! hack, should happen as $serveruser

EXTRAOPTS=""
if test "\$1" = "start"
then
  date=\$(date +"%Y-%m-%d-%H-%M-%S")
  EXTRAOPTS="-o -i -l $logDir/postmaster-\$date"
fi

start()
{
    su - $serverUser -s /bin/sh -c 'env -i HOME=/homeless-shelter PATH=\$PATH LANG=C PGPORT="$port" $postgresql/bin/pg_ctl -D $dataDir \$EXTRAOPTS -w start'
}

stop()
{
    su - $serverUser -s /bin/sh -c 'env -i HOME=/homeless-shelter PATH=\$PATH LANG=C PGPORT="$port" $postgresql/bin/pg_ctl -D $dataDir \$EXTRAOPTS -w stop'
}

if test "\$1" = start; then

    trap stop 15

    start

elif test "\$1" = stop; then

    stop

elif test "\$1" = init; then
   
    echo 'Are you sure you want to remove old PostgreSQL DBs?'
    read
    if ! test "\$REPLY" = yes; then exit 1; fi

    rm -rf $dataDir
    mkdir -p $dataDir
    chown $serverUser $dataDir 
    chmod 0700 $dataDir
    su - $serverUser -s /bin/sh -c "env -i HOME=/homeless-shelter PATH=\$PATH LANG=C $postgresql/bin/initdb -D $dataDir"
    touch $dataDir/postgresql.conf

    echo -n > $dataDir/pg_hba.conf
    echo "local all all ${authMethod}" >> $dataDir/pg_hba.conf
    for i in $allowedHosts; do
        # !!! hack
        ip=\$(host \$i | sed 's/.* has address //')
        echo "host all all \$ip/32 ${authMethod}" >> $dataDir/pg_hba.conf
    done
   
    start
    
    su - $serverUser -s /bin/sh -c "env -i HOME=/homeless-shelter PATH=\$PATH LANG=C $postgresql/bin/createuser -a -d root"

    for i in $subServices; do
        echo Subservice \$i...
        if test -f \$i/bin/control; then
            # !!! use of $SHELL here is a hack; in multi-machine
            # configurations the actual shell of the \$i/bin/control script
            # might be wrong.
            PATH=$postgresql/bin:\$PATH $SHELL \$i/bin/control postgres-init || true
        fi
    done

    stop

fi

EOF

chmod +x $out/bin/*
