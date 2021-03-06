#! @perl@ -w -T @perlFlags@

use strict;
use BerkeleyDB;

my $svndir = "@subversion@";
my $dbdir = "@dbDir@";
my $userdb = "$dbdir/svn-users";
my $ownerdb = "$dbdir/svn-owners";
my $readerdb = "$dbdir/svn-readers";
my $writerdb = "$dbdir/svn-writers";
my $contactdb = "$dbdir/svn-contact";
my $fullnamedb = "$dbdir/svn-fullnames";

my $user = shift @ARGV;
defined $user or die "syntax: $0 USER";


# !!! cut and pasted from repoman.pl.in - share this.
sub open_db {
    my $dbname = shift;
    my %db;
    tie %db, "BerkeleyDB::Hash",
        -Filename => $dbname,
        -Flags    => DB_CREATE
        -Mode     => 0600
        or die "Cannot open database $dbname: $! $BerkeleyDB::Error\n";
    return %db;
}

sub set_db {
    my $dbname = shift;
    my $name = shift;
    my $value = shift;
#    my %db = open_db($dbname);

    my $db = new BerkeleyDB::Hash
        -Filename => $dbname,
        -Flags    => DB_CREATE
        -Mode     => 0600
        or die "Cannot open database $dbname: $! $BerkeleyDB::Error\n";

    $db->db_put($name, $value);
}

sub get_db {
    my $dbname = shift;
    my $name = shift;
    my %db = open_db($dbname);
    my $value = $db{$name};
    untie %db;
    return $value;
}

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

my $oldpwhash = get_db $userdb, $user;
die "unknown user `$user'" unless defined $oldpwhash;

# Check that the user is not an owner of any repository anymore and
# does not appear in any ACL.
my %db = open_db($ownerdb);
while ((my $k, my $v) = each %db) {
    die "user `$user' still owns repository `$k'" if ($v eq $user);
}
untie %db;

%db = open_db($readerdb);
while ((my $k, my $v) = each %db) {
    my @readers = split /,/, $v;
    foreach my $r (@readers) {
	die "user `$user' is still a reader of repository `$k'" if ($r eq $user);
    }
}
untie %db;

%db = open_db($writerdb);
while ((my $k, my $v) = each %db) {
    my @writers = split /,/, $v;
    foreach my $r (@writers) {
	die "user `$user' is still a writer of repository `$k'" if ($r eq $user);
    }
}
untie %db;

# Remove the user.
del_db $userdb, $user;
del_db $contactdb, $user;
del_db $fullnamedb, $user;
