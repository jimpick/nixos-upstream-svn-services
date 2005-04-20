#! @SHELL@ -e

echo "creating missing files / tables..."

# Create missing state directories.
mkdir -p "@logDir@"
mkdir -p "@reposDir@"
mkdir -p "@dbDir@"
mkdir -p "@distsDir@"
mkdir -p "@backupsDir@"

# Create missing database tables.
echo | @db4@/bin/db_load -t hash -T "@dbDir@/svn-readers"
echo | @db4@/bin/db_load -t hash -T "@dbDir@/svn-writers"
echo | @db4@/bin/db_load -t hash -T "@dbDir@/svn-users"

# Create a root account with an impossible password (if the account
# doesn't exist already).
(echo root; echo "*") | @db4@/bin/db_load -n -t hash -T "@dbDir@/svn-users" 2> /dev/null || true
(echo root; echo "Subversion Server Admin") | @db4@/bin/db_load -n -t hash -T "@dbDir@/svn-fullnames" 2> /dev/null || true
