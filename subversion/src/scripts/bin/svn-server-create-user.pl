#! @perl@ -w @perlFlags@

use strict;
use BerkeleyDB;
use Email::Send;
use Email::Simple;
use Crypt::PasswdMD5;

my $svndir = "@subversion@";
my $dbdir = "@dbDir@";
my $userdb = "$dbdir/svn-users";
my $contactdb = "$dbdir/svn-contact";
my $fullnamedb = "$dbdir/svn-fullnames";

die "syntax: create-user.pl USER MAIL-ADDRESS \"FULLNAME\"\n" if scalar @ARGV != 3;
my $userName = shift @ARGV;
my $address = shift @ARGV;
my $fullName = shift @ARGV;


# !!! cut and pasted from repoman.pl.in - share this.

# Open the specified database, return a hash object for it.
sub openDB {
    my $dbname = shift;
    my %db;
    tie %db, "BerkeleyDB::Hash",
        -Filename => $dbname,
        -Flags    => DB_CREATE
        -Mode     => 0600
        or die "Cannot open database $dbname: $! $BerkeleyDB::Error\n";
    return %db;
}


# Set a key/value pair in the specified database. 
sub setDB {
    my $dbname = shift;
    my $key = shift;
    my $value = shift;
#    my %db = openDB($dbname);

    my $db = new BerkeleyDB::Hash
        -Filename => $dbname,
        -Flags    => DB_CREATE
        -Mode     => 0600
        or die "Cannot open database $dbname: $! $BerkeleyDB::Error\n";

    $db->db_put($key, $value);
}


# Return the value for a key in the specified database. 
sub getDB {
    my $dbname = shift;
    my $key = shift;
    my $default = shift;
    my %db = openDB($dbname);
    my $value = $db{$key};
    untie %db;
    return defined $value ? $value : $default;
}


# Check that the user doesn't already exist.
my $oldpwhash = getDB($userdb, $userName);
die "user `$userName' already exists" if defined $oldpwhash;


# Generate a password.
my $password = `mkpasswd` or die;
chomp $password;
my $crypted = apache_md5_crypt($password);
print "Password is $password ($crypted)\n";


# Create the user.
setDB($userdb, $userName, $crypted);
setDB($contactdb, $userName, $address);
setDB($fullnamedb, $userName, $fullName);


# Send email to the user.
my $email = Email::Simple->new("");

my $msg = <<EOF;
Hi,

An account has been created for you on the Subversion server
at @canonicalName@/.

Your user name is: $userName
Your password is: $password

You can change your account information at

  @canonicalName@/repoman/edituser

Regards,

The Subversion server admin.
EOF

$email->body_set($msg);
$email->header_set("From", '@notificationSender@');
$email->header_set("Reply-To", '@adminAddr@');
$email->header_set("To", $address);
$email->header_set("Subject", "Subversion account created");

my $sender = Email::Send->new({mailer => 'SMTP'});
$sender->mailer_args([Host => "@smtpHost@"]) or die;
$sender->send($email) or die;
