echo "creating missing files / tables..."

needDir() {
    mkdir -p "$1"
    if test "$(id -u)" = 0; then
	chown @user@.@group@ "$1"
    fi
    chmod 750 "$1"
}

# Create missing state directories.
needDir "@logDir@"
needDir "@reposDir@"
needDir "@dbDir@"
needDir "@distsDir@"
needDir "@backupsDir@"
needDir "@tmpDir@"

# Create missing database tables.
echo | @db4@/bin/db_load -t hash -T "@dbDir@/svn-readers"
echo | @db4@/bin/db_load -t hash -T "@dbDir@/svn-writers"
echo | @db4@/bin/db_load -t hash -T "@dbDir@/svn-users"

# Create a root account with an impossible password (if the account
# doesn't exist already).
(echo root; echo "*") | @db4@/bin/db_load -n -t hash -T "@dbDir@/svn-users" 2> /dev/null || true
(echo root; echo "Subversion Server Admin") | @db4@/bin/db_load -n -t hash -T "@dbDir@/svn-fullnames" 2> /dev/null || true

if test "$(id -u)" = 0; then
    chown @user@.@group@ @dbDir@/*
fi
