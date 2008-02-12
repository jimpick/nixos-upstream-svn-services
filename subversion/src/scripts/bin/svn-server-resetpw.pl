#! @perl@ -w -T @perlFlags@

use strict;
use BerkeleyDB;
use Crypt::PasswdMD5;

my $svndir = "@subversion@";
my $dbdir = "@dbDir@";
my $userdb = "$dbdir/svn-users";

my $user = shift @ARGV;
my $newpw = shift @ARGV;
($user && $newpw) || die "syntax: $0 USER PASSWORD";


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

my $oldpwhash = get_db $userdb, $user;
die "unknown user `$user'" unless defined $oldpwhash;

print "old password hash: $oldpwhash\n";

my $newpwhash = apache_md5_crypt($password);

print "new password hash: $newpwhash\n";

set_db $userdb, $user, $newpwhash;
