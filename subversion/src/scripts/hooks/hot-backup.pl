#! @perl@ -w

use strict;

my $svnlook = "@subversion@/bin/svnlook";
my $svnadmin = "@subversion@/bin/svnadmin";

my $repodir = "@reposDir@";
my $backupdir = "@backupsDir@";

my $reponame = $ARGV[0];
die unless defined($reponame);

print "backing up $reponame\n";

my $outdir = "$backupdir/$reponame";

system "mkdir -p $outdir";
die if ($?);

my %known;

foreach my $fn (glob "$outdir/*") {
    next unless $fn =~ (/(\d+)$/);
    my $rev = $1;
    $known{$rev} = 1;
}

my $repo = "$repodir/$reponame";

my $youngest = `$svnlook youngest $repo`;
die unless defined($youngest) && !$?;
chomp $youngest;

print "youngest revision is $youngest\n";

for (my $rev = 1; $rev <= $youngest; $rev++) {
    next if (defined $known{$rev});
    my $tmpfile = "$outdir/$rev.$$.tmp";
    system "$svnadmin dump --incremental --revision $rev $repo | bzip2 > $tmpfile";
    die if ($?);
    rename($tmpfile, "$outdir/$rev") || die;
}
