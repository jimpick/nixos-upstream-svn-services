#! @perl@ -w

use strict;
use POSIX qw(strftime);
use File::stat;
use File::Basename;


# Global settings.
my $conf = "@directoriesConf@";
my $baseURL = "@canonicalName@@urlPrefix@";
my $scripts = "@out@/scripts";
my $logFile = "@logFile@";
$ENV{"PATH"} = "@defaultPath@";

umask 0002;


sub printResult {
    my $result = shift;
    print "Content-Type: text/plain\n\n"; 
    print "$result\n"; 
}


sub barf {
    my $msg = shift;
    if (!defined $msg) { $msg = "undefined error" }
    print "Status: 500 Internal Error\n";
    print "Content-Type: text/plain\n\n";
    (my $package, my $filename, my $line) = caller;
    print "Fatal error at $filename line $line: $msg\n";
    exit 1;
}


sub uploadFileTo {
    my $path = shift;

    my $uniqueNr = int (rand 1000000);
    my $tmpfile = "${path}_tmp_${uniqueNr}";

    # !!! check exclusive open
    open OUT, ">$tmpfile" or barf "cannot create $tmpfile: $!";

    my $buf;
    while (1) {
        my $res = sysread STDIN, $buf, 32768;
        barf "I/O error on read: $!" if (!defined $res);
        last if ($res == 0);
        my $res2 = syswrite OUT, $buf, $res;
        barf "I/O error on write: $!" if (!defined $res2 || $res2 != $res);
    }
    
    close OUT or barf;

    rename $tmpfile, $path or barf "cannot rename $tmpfile to $path: $!";
}


# Regexps.
my $projectRE = "(?:[A-Za-z0-9-][A-Za-z0-9-\.]*)";
my $relNameRE = "(?:[A-Za-z0-9-][A-Za-z0-9-\.]*)";
my $sessionIdRE = "(?:[A-Za-z0-9-][A-Za-z0-9-\.]*)";
my $pathCompRE = "(?:\/[A-Za-z0-9-\+][A-Za-z0-9-\+\._]*)";
my $userNameRE = "(?:[A-Za-z\-]+)";


# Parse command.
my $args = $ENV{"PATH_INFO"};
barf "invalid arguments: $args" unless $args =~ /^\/($projectRE)\/([a-z-]+)\/(.*)$/;
my $project = $1;
my $command = $2;
$args = $3;


# Check access rights and determine the root directory of the given
# project.
my $root;
my $userName = $ENV{"REMOTE_USER"};
defined $userName or barf;
open CONF, "<$conf" or barf "cannot open $conf";
while (<CONF>) {
    /^\s*($projectRE)\s+($pathCompRE+)\s+($userNameRE(\s+$userNameRE)*)\s*$/
        or barf "invalid config line: $_";
    if ($1 eq $project) {
        foreach my $name (split " ", $3) {
            if ($name eq $userName) {
                $root = $2;
                last;
            }
        }
        last if defined $root;
    }
}
close CONF;

defined $root or barf "unknown project / user";


sub replaceLink {
    my $target = shift;
    my $link = shift;
    my $tmpLink = $link . "_tmp";
    symlink $target, $tmpLink or barf "cannot symlink: $!";
    rename $tmpLink, $link or barf "cannot rename: $!";
}


sub writeString {
    my $text = shift;
    my $path = shift;

    my $uniqueNr = int (rand 1000000);
    my $tmpfile = "${path}_tmp_${uniqueNr}";

    # !!! check exclusive open
    open OUT, ">$tmpfile" or barf "cannot create $tmpfile: $!";
    print OUT $text or barf;
    close OUT or barf;

    rename $tmpfile, $path or barf "cannot rename $tmpfile to $path: $!";
}


sub cmpVersions {
    my $splitRE = "([0-9]+|[a-zA-Z_]+)";
    my @as = split /$splitRE/, $a;
    my @bs = split /$splitRE/, $b;
    
    while (1) {
        my $x = shift @as;
        my $y = shift @bs;
        return 0 if !defined $x && !defined $y;
        $x = "" if !defined $x;
        $y = "" if !defined $x;
        if ($x =~ /^\d+$/ && $y =~ /^\d+$/) {
            my $c = $x <=> $y;
            return $c if $c != 0;
        }
        my $c = $x cmp $y;
        return $c if $c != 0;
    }
}


sub getCreationTime {
    my $path = shift;
    open TIME, "<$path/timestamp" or die "creation time missing for $path";
    my $time = <TIME>;
    chomp $time;
    close TIME;
    return $time;
}


sub cmpDates {
    return getCreationTime("$root/$a") <=> getCreationTime("$root/$b");
}


sub generateMainIndex {

    my %pkgNames;
    my %relNames;
    my %stable;
    my %unstable;
    my %failed;
    
    foreach my $relName (glob "$root/*") {
        if (-d $relName && (!-l $relName || readlink($relName) =~ /\/stable\//)) {
            my $pkgNameRE = "(?:(?:[A-Za-z0-9]|(?:-[^0-9]))+)";
            my $versionRE = "(?:[A-Za-z0-9\.\-]+)";
            if ($relName =~ /^.*\/(($pkgNameRE)-($versionRE))$/ &&
                !($relName =~ /\/channels.*/))
            {
                $relName = $1;
                next if $relName =~ "tmp" or $relName =~ "replaced";
                my $pkgName = $2;
                my $version = $3;
                $pkgNames{$pkgName} = "1";
                $relNames{$relName} = "1";
                if (-e "$root/$relName/failed") {
                    push @{$failed{$pkgName}}, $relName;
                } elsif ($version =~ /pre/) {
                    push @{$unstable{$pkgName}}, $relName;
                } else {
                    push @{$stable{$pkgName}}, $relName;
                }
            }
        }
    }

    # Also generate links to the most recent stable and unstable releases.
    # !!! sort order is bogus.

    foreach my $pkgName (keys %pkgNames) {

        local *linkLatest = sub {
            my $type = shift;
            my $releases = shift;
            return if (!defined $releases);
            my @releases = sort {-cmpVersions()} (@{$releases});
            my $latest = $releases[0];
            replaceLink "$latest", "$root/$pkgName-$type-latest";
            writeString "$latest", "$root/$pkgName-$type-latest-name";
        };
        
        linkLatest("stable", $stable{$pkgName});
        linkLatest("unstable", $unstable{$pkgName});
    }

    # Generate indices for this project.
    system("$scripts/compose-release-info.sh " .
           "$root $root/composed.xml 1 >> $logFile 2>&1") == 0
           or die "compose-release-info.sh failed: $?";
    
    system("cd $scripts && ./generate-overview.sh " .
           "$root/composed.xml $root '$baseURL/$project' >> $logFile 2>&1") == 0
           or die "generate-overview.sh failed: $?";

    # Generate indices for the entire build farm.
    my $allRoot = dirname $root;
    system("$scripts/compose-release-info.sh " .
           "$allRoot $allRoot/composed.xml 2 >> $logFile 2>&1") == 0
           or die "compose-release-info.sh failed: $?";
    
    system("cd $scripts && ./generate-overview.sh " .
           "$allRoot/composed.xml $allRoot '$baseURL' >> $logFile 2>&1") == 0
           or die "generate-overview.sh failed: $?";
}


# Perform the command.

# Start creation of a release.
if ($command eq "create") {
    barf unless $args =~ /^$/;

    my $uniqueNr = int (rand 1000000);
    my $sessionId = "tmp-$uniqueNr";
    my $sessionDir = "$root/$sessionId";

    mkdir $sessionDir, 0775 or barf "cannot create $sessionDir: $!";

    printResult "$sessionId";
}

# Create a subdirectory within a release.
elsif ($command eq "mkdir") {
    barf unless $args =~ /^($sessionIdRE)($pathCompRE+)$/;
    my $sessionId = $1;
    my $path = $2;

    my $fullPath = "$root/$sessionId/$path";

    system("mkdir -p '$fullPath'") == 0 or barf "cannot mkdir: $?";

    printResult "ok";
}

# Upload a file to a release.
elsif ($command eq "upload") {
    barf unless $args =~ /^($sessionIdRE)($pathCompRE+)$/;
    my $sessionId = $1;
    my $path = $2;

    my $fullPath = "$root/$sessionId/$path";

    uploadFileTo $fullPath;

    printResult "ok";
}

# Upload a symlink to a release.
elsif ($command eq "upload-link") {
    barf unless $args =~ /^($sessionIdRE)($pathCompRE+)($pathCompRE)$/;
    my $sessionId = $1;
    my $path = $2;
    my $target = $3;

    my $fullPath = "$root/$sessionId/$path";

    $target =~ s/^\///;

    symlink $target, $fullPath or barf "cannot symlink: $!";

    printResult "ok";
}

# Upload and unpack a tar file to a release.
elsif ($command eq "upload-tar") {
    barf unless $args =~ /^($sessionIdRE)($pathCompRE*)$/;
    my $sessionId = $1;
    my $path = $2; # may be empty

    my $fullPath = "$root/$sessionId/$path";

    system("cd $fullPath && tar xfj - 1>&2") == 0 or barf "cannot unpack: $?";
    
    printResult "ok";
}

# Finish the release.
elsif ($command eq "finish") {
    barf unless $args =~ /^($sessionIdRE)\/($relNameRE)$/;
    my $sessionId = $1;
    my $releaseName = $2;

    my $sessionDir = "$root/$sessionId";
    my $releaseDir = "$root/$releaseName";

    my $time = time;
    open TIME, ">$sessionDir/timestamp" or barf "cannot create timestamp";
    print TIME $time;
    close TIME;

    system("chmod -R g=u $sessionDir 1>&2") == 0 or barf "cannot chmod: $?";

    if (-d $releaseDir) {
	my $uniqueNr = int (rand 1000000);
	my $releaseDirOld = "$root/replaced-$uniqueNr-$releaseName";
	rename $releaseDir, $releaseDirOld
	    or barf "cannot rename $releaseDir to $releaseDirOld";
    }

    rename $sessionDir, $releaseDir
	or barf "cannot rename $sessionDir to $releaseDir";

    generateMainIndex;
    
    printResult "$releaseName";
}

elsif ($command eq "abort") {
    barf unless $args =~ /^($sessionIdRE)$/;
    my $sessionId = $1;

    my $sessionDir = "$root/$sessionId";

    system("chmod -R g=u $sessionDir 1>&2") == 0 or barf "cannot chmod: $?";
    system("rm -rf $sessionDir") == 0 or barf "cannot remove $sessionDir";

    printResult "removed";
}

# Check for release existence.
elsif ($command eq "exists") {
    barf unless $args =~ /^($relNameRE)$/;
    my $releaseName = $1;

    my $releaseDir = "$root/$releaseName";

    if (-d $releaseDir) {
	printResult "yes";
    } else {
	printResult "no";
    }
}

# Remove a release.
elsif ($command eq "remove") {
    barf unless $args =~ /^($relNameRE)$/;
    my $releaseName = $1;

    my $releaseDir = "$root/$releaseName";

    system("rm -rf $releaseDir") == 0 or barf "cannot remove $releaseDir";

    generateMainIndex;
    
    printResult "removed";
}

# Upload a single file, outside of a release.
elsif ($command eq "put") {
    $args = "/" . $args;
    barf unless $args =~ /^($pathCompRE+)$/;
    my $path = $1;

    my $fullPath = "$root/$path";
    
    uploadFileTo $fullPath;

    printResult "ok";
}

# Upload a single symlink, outside of a release.
elsif ($command eq "put-link") {
    $args = "/" . $args;
    barf unless $args =~ /^($pathCompRE+)$/;
    my $path = $1;
    # !!! may contain `..'; this is intentional, but we should prevent
    # escaping from $root.
    my $pathCompRE2 = "(?:\/[A-Za-z0-9-\+\._]+)";
    barf unless $ENV{"QUERY_STRING"} =~ /^($pathCompRE2+)$/;
    my $target = $1;

    my $fullPath = "$root/$path";
    system "mkdir -p -- \$(dirname -- $fullPath)";
    
    $target =~ s/^\///;

    replaceLink $target, $fullPath;

    printResult "ok";
}

# Force updating of the index page.
elsif ($command eq "index") {
    generateMainIndex;
    printResult "ok";
}

else {
    barf "invalid command";
}
