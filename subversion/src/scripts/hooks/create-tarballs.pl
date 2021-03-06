#! @perl@ -w @perlFlags@

use strict;
use BerkeleyDB;
use IO::File;
use Fcntl ':flock';

my $svn = "@subversion@/bin/svn";

my $repodir = "@reposDir@";
my $distdir = "@distsDir@";
my $tmpdir = "@tmpDir@";

my $reponame = $ARGV[0];
die unless defined($reponame);
my $repopath = "$repodir/$reponame";

print "creating tarballs for $reponame\n";

my $dbname = "@dbDir@/svn-tarballs";
my %db;
tie %db, "BerkeleyDB::Hash",
    -Filename => $dbname,
    -Flags    => DB_CREATE
    -Mode     => 0600
    or die "Cannot open database $dbname: $! $BerkeleyDB::Error\n";
my $tardirs = $db{$reponame};
untie %db;

exit unless (defined($tardirs));

my @dirs = ();

foreach my $dir (split(/,/, $tardirs)) {
    push @dirs, $dir;
    next if ($dir =~ /\.\./);

    my $nm = $dir;
    $nm =~ s/^\///;
    $nm =~ s/\/$//;
    $nm =~ s/\//-/g;
    $nm =~ s/[^a-zA-Z0-9.\-]//g;

    next if (substr($nm, 0, 1) eq ".");

    my $tarname = "$distdir/$reponame/$reponame-$nm.tar.bz2";

    # Create the dist directory.
    mkdir "$distdir/$reponame", 0777;

    # Acquire an exclusive lock.
    open LOCK, ">$tarname.lock" or die "open lock";
    flock LOCK, LOCK_EX;

    print "tarring $reponame/$dir into $tarname\n";

    my $lastrev = 
        `$svn log --xml "file://$repopath/$dir" | @libxslt@/bin/xsltproc @out@/hooks/query-head-revision.xsl -`;
    die "svn log" if ($?);
    chomp $lastrev;
    die unless $lastrev =~ /^[0-9]*$/;

    my $prevrev = -1;
    if (open REV, "< $tarname.rev") {
	$prevrev = <REV>;
	chomp $prevrev;
	close REV;
	die unless $lastrev =~ /^[0-9]*$/;
    }

    print "latest revision is $lastrev, previous was $prevrev\n";

    if ($prevrev >= $lastrev) { goto done };

    my $tmppath = "$tmpdir/create-tarballs-$$";
    mkdir $tmppath, 0777 or die "mkdir $tmppath";

    system "$svn export --quiet --revision $lastrev file://$repopath/$dir $tmppath/$reponame-$nm";
    die "svn export" if ($?);

    system "echo -n $lastrev > $tmppath/$reponame-$nm/svn-revision";
    die "writing revision" if ($?);

    system "cd $tmppath && tar cfj $tarname.tmp $reponame-$nm";
    die "tar" if ($?);

    rename "$tarname.tmp", $tarname or die "rename";

    system "echo -n $lastrev > $tarname.rev";
    die "writing revision" if ($?);

    system "rm -rf $tmppath";

  done:
    flock LOCK, LOCK_UN;
    close LOCK;
}
