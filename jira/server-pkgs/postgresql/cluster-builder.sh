set -e

. $stdenv/setup

if ( cat /etc/passwd | grep $serveruser > /dev/null )
then
  echo "User $serveruser exists. Great."
else
  echo "User $serveruser does not exist. Please create this user first. (useradd)"
  exit 1
fi

mkdir -p $out/bin

echo "Creating cluster init script."
cat > $out/bin/pg_cluster_init <<EOF
#! /bin/sh

set -e
/bin/su --login -c "env -i LANG=en_US $postgresql/bin/initdb -D $datadir" $serveruser

echo "--------------------------------------------------------------------------------"
echo "Database cluster has been initialized."
echo "How exciting!"
echo "  "
echo "  Commands for creating a user and database:"
echo "  > $postgresql/bin/createuser --no-createdb --no-adduser -U postgres -p $port owner"
echo "  > $postgresql/bin/createdb -U postgres -p $port -O owner jira"
echo "  "
echo "  You can start the database with: "
echo "  > $out/bin/pg_cluster_ctl start -w"
echo "--------------------------------------------------------------------------------"
EOF

echo "Creating cluster ctl script."
cat >> $out/bin/pg_cluster_ctl <<EOF
#! /bin/sh

EXTRAOPTS=""
if test "\$1" = "start"
then
  date=\`date +"%Y-%m-%d-%H-%M-%S"\`
  EXTRAOPTS="-o -i -l $logdir/postmaster-\$date"
fi

export LANG=en_US
/bin/su --login -c "env -i LANG=en_US PGPORT=\"$port\" $postgresql/bin/pg_ctl \$* -D $datadir \$EXTRAOPTS" $serveruser
EOF

chmod a+x $out/bin/pg_cluster_init
chmod a+x $out/bin/pg_cluster_ctl
