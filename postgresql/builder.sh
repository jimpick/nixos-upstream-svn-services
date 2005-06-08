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
    env -i LANG=en_US PGPORT="$port" $postgresql/bin/pg_ctl -D $dataDir \$EXTRAOPTS -w start
}

stop()
{
    env -i LANG=en_US PGPORT="$port" $postgresql/bin/pg_ctl -D $dataDir \$EXTRAOPTS -w stop
}

if test "\$1" = start; then

    start

elif test "\$1" = stop; then

    stop

elif test "\$1" = init; then

    env -i LANG=en_US $postgresql/bin/initdb -D $dataDir
    
    start
    
    for i in $subServices; do
        echo Subservice \$i...
        if test -f \$i/bin/control; then
            PATH=$postgresql/bin:\$PATH \$i/bin/control jira-init || true
        fi
    done

    stop

fi

EOF

chmod +x $out/bin/*
