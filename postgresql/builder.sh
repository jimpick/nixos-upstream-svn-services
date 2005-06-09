set -e

. $stdenv/setup

mkdir -p $out/bin

echo "Creating cluster ctl script."
cat >> $out/bin/control <<EOF
#! $SHELL

mkdir -p $logDir # !!! hack, should happen as $serveruser

EXTRAOPTS=""
if test "\$1" = "start"
then
  date=\$(date +"%Y-%m-%d-%H-%M-%S")
  EXTRAOPTS="-o -i -l $logDir/postmaster-\$date"
fi

start()
{
    env -i LANG=C PGPORT="$port" $postgresql/bin/pg_ctl -D $dataDir \$EXTRAOPTS -w start
}

stop()
{
    env -i LANG=C PGPORT="$port" $postgresql/bin/pg_ctl -D $dataDir \$EXTRAOPTS -w stop
}

if test "\$1" = start; then

    start

elif test "\$1" = stop; then

    stop

elif test "\$1" = init; then

    env -i LANG=C $postgresql/bin/initdb -D $dataDir

    echo -n > $dataDir/pg_hba.conf
    echo "local all all trust" >> $dataDir/pg_hba.conf
    for i in $allowedHosts; do
        # !!! hack
        ip=\$(host \$i | sed 's/.* has address //')
        echo "host all all \$ip/32 trust" >> $dataDir/pg_hba.conf
    done
    
    start
    
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
