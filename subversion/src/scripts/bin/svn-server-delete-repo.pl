#! @perl@ -w @perlFlags@

use strict;
use BerkeleyDB;

my $svndir = "@subversion@";
my $repodir = "@reposDir@";
my $backupdir = "@backupsDir@";
my $userdb = "@dbDir@/svn-users";
my $ownerdb = "@dbDir@/svn-owners";
my $readerdb = "@dbDir@/svn-readers";
my $writerdb = "@dbDir@/svn-writers";
my $watcherdb = "@dbDir@/svn-watchers";
my $descrdb = "@dbDir@/svn-descriptions";

my $deldir = shift @ARGV;
$deldir || die "trashcan not set";

sub del_db {
    my $dbname = shift;
    my $name = shift;
    
    my $db = new BerkeleyDB::Hash
        -Filename => $dbname,
        -Flags    => DB_CREATE
        -Mode     => 0600
        or die "Cannot open database $dbname: $! $BerkeleyDB::Error\n";

    $db->db_del($name);
}

foreach my $repo (@ARGV) {
    print "deleting $repo\n";

    del_db($ownerdb, $repo);
    del_db($readerdb, $repo);
    del_db($writerdb, $repo);
    del_db($watcherdb, $repo);
    del_db($descrdb, $repo);

    system "mv $repodir/$repo $deldir";
    die "cannot move $repodir/$repo" if ($? != 0);

    if (-e "$backupdir/$repo") {
	system "mv $backupdir/$repo $deldir/BACKUP-$repo";
	die "cannot move $backupdir/$repo" if ($? != 0);
    }
}
