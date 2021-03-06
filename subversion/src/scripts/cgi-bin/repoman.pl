#! @perl@ -w -T @perlFlags@

# SVN Server Repository Manager.

use IO::Handle;
use strict;
use CGI qw(:standard :html3 escape escapeHTML self_uri *ul *li);
use BerkeleyDB;
use Crypt::PasswdMD5;

$ENV{'PATH'} = "/no-path";

my $admin = '@adminAddr@';
my $svndir = "@subversion@";
my $repodir = "@reposDir@";
my $backupsdir = "@backupsDir@";
my $repoBase = "@urlPrefix@/repos";
my $dbdir = "@dbDir@";

my $userdb = "$dbdir/svn-users";
my $ownerdb = "$dbdir/svn-owners";
my $readerdb = "$dbdir/svn-readers";
my $writerdb = "$dbdir/svn-writers";
my $watcherdb = "$dbdir/svn-watchers";
my $tardb = "$dbdir/svn-tarballs";
my $descrdb = "$dbdir/svn-descriptions";
my $contactdb = "$dbdir/svn-contact";
my $fullnamedb = "$dbdir/svn-fullnames";
my $hiddenreposdb = "$dbdir/svn-hidden-repos";

my $base = script_name();

(my $dummy, my $action, my $repo, my @extrapaths) = 
    split('/', path_info());
$action = "list" unless defined($action);
$repo = param("repo") unless defined($repo);
my $repoesc;

my $in_html = 0;

my $userName = remote_user();


# Print page header, if we haven't done so before (i.e., it may be
# called any number of times).
sub begin {
    return if $in_html;
    $in_html = 1;
    print header;

    print start_html(
        -title => "Subversion Repoman",
        -style => {'src' => "@urlPrefix@/svn-files/style.css"});

    print a({href => "@orgUrl@"},
	    img{src => "@orgLogoUrl@", alt => "@orgName@ Logo"});
}


# Print page footer.
sub end {
    #print br;
    print hr;
    print a({href => $base}, "Start"), " / Admin: ", $admin;
    print end_html;
    exit;
}


# Check that $repo is a valid repository name.
sub checkRepo {
    unless (defined($repo) && $repo =~ /^([\w-]+)$/) {
	begin();
	print p, "Invalid repository name.";
	end();
    }
    $repo = $1; # untainting
    $repoesc = tt(escapeHTML($repo));
}


# Check that $repo refers to an existing repository.
sub repoExists {
    if (!-d $repodir . "/" . $repo) {
	begin();
	print p, "The repository does not exist.";
	end();
    }
}


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


# Return an entire database in a hash.
sub getEntireDB {
    my $dbname = shift;
    my %db = openDB($dbname);
    my %hash;
    while ((my $k, my $v) = each %db) {
	$hash{$k} = $v;
    }
    untie %db;
    return %hash;
} 


# Check that the argument is a valid repository description (i.e., is
# not just whitespace).
sub checkDescription {
    my $description = shift;
    if ($description =~ /^\s*$/) {
	print p, "Description should not be empty.";
	end();
    }
}


# Print a partial page that gives information about the repository
# $repo.
sub printRepoInfo {
    my $root = "@canonicalName@";
    my $url = $root . $repoBase . "/" . $repo . "/";

    print p, "The URL of the repository is ";
    print a({href => $url}, escapeHTML($url)), ". ";
    print "You can do a checkout of the ", em("entire"), " repository using the following command:";
    print blockquote(pre("svn checkout " . escapeHTML($url)));
    print "although typically you'll want to do a checkout of just a subdirectory ";
    print "(e.g., the ", tt("trunk/"), "). ";

    my $viewvcUrl = "@urlPrefix@/viewvc/" . $repo . "/";
    my $websvnUrl = "@urlPrefix@/websvn/" . $repo . "/";
    my $xmlUrl = "@urlPrefix@/repos-xml/" . $repo . "/";
    print p, "You can also browse the repository's history using ",
        a({href => $viewvcUrl}, "ViewVC"), " or ", a({href => $websvnUrl}, "WebSVN"),
        ", or browse the repository in ", a({href => $xmlUrl}, "XML format"), ".";

    my $tardirs = getDB($tardb, $repo);
    if (defined $tardirs && $tardirs =~ /\w/) {
	my $disturl = "@urlPrefix@/dist/" . $repo . "/";
	print p, "Distributions (in .tar.bz2 format) of the head revision ",
	    "of the repository are ",
            a({href => $disturl}, "generated automatically"), ".";
    }

    print h2("Access control");

    my $owner = getDB($ownerdb, $repo);
    $owner = "" unless defined $owner;
    my $readers = getDB($readerdb, $repo);
    my $writers = getDB($writerdb, $repo);
    my $watchers = getDB($watcherdb, $repo);
    my $description = getDB($descrdb, $repo);

    print start_form("post", $base . "/update/" . $repo);
    print "Owner: ", tt($owner);
    print p, "Description of the repository:";
    print p, textfield({size => 40,
        -default => $description, -override => 1, -name => "description"});
    print p, "Users with read access (comma-separated; ",
          tt("all"), " = every user, including anonymous users):";
    print p, textfield({size => 40, 
        -default => $readers, -override => 1, -name => "readers"});
    print p, "Users with write access (comma-separated):";
    print p, textfield({size => 40, 
        -default => $writers, -override => 1, -name => "writers"});
    print p, "E-mail addresses to send commit notification to:";
    print p, textfield({size => 40, 
        -default => $watchers, -override => 1, -name => "watchers"});
    print p, "Directories for which to generate source distributions:";
    print p, textfield({size => 40,
        -default => $tardirs, -override => 1, -name => "tardirs"});
    print p, submit(-label => 'Update');
    print end_form;

    print h2("Dump");
    print p, "You can dump the Subversion database. ",
        "The resulting file can be loaded into another repository ",
        "using the ", tt("svnadmin load"), " command. ",
        "Read permission is required for this operation.";
    print start_form("get", $base . "/dump/" . $repo);
    print p, submit(-label => 'Dump');
    print end_form;
}


# Processes add user and edit user forms.
sub editUserInfo {

    my $create = shift;

    my $password = param("password");
    my $password_again = param("password_again");

    # A new password is only required for the add user form.
    if ($create && $password eq "") {
	print p, "Password may not be empty.";
	end();
    }

    if ($password ne $password_again) {
	print p, "Passwords do not match.";
	end();
    }

    my $address = param("address");
    $address =~ s/\s//g;
    unless ($address =~ /^[\w\.\+-]+\@[\w\.\+-]+$/) {
	print p, "Invalid e-mail address.";
	end();
    }

    my $fullname = param("fullname");
    if ($fullname =~ /^\s*$/) {
	print p, "Full name should not be empty.";
	end();
    }

    if ($password ne "") {
	my $crypted = apache_md5_crypt($password);
	setDB($userdb, $userName, $crypted);
    }

    setDB($contactdb, $userName, $address);
    setDB($fullnamedb, $userName, $fullname);
}


# The "dump" action dumps the repository $repo.  This is a special
# case: we shouldn't call begin() or end(), since that would pollute
# the output (which is a .tar.gz file).
if ($action eq "dump") {
    checkRepo();
    repoExists();
    STDOUT->autoflush(1);
    print "Content-Type: application/x-gzip\n";
    print "Content-Disposition: attachment; filename=svnrepodump-$repo.gz\n";
    print "\n";
    system("($svndir/bin/svnadmin dump $repodir/$repo | gzip) 2> /dev/null");
    exit;
}


begin();


# Repoman start page: list all repositories and users.
if ($action eq "list" or $action eq "listdetails") {

    my $listDetails = $action eq "listdetails";

    if ($listDetails && $userName ne "root") {
	print p, "Only root can do this.";
	end();
    }

    print h1("Subversion Server");

    print h2("Administrative tasks");
    print start_ul;
    print start_li;
    print "You can ";
    print a({href => $base . "/adduser"}, "add a new user"),
        " (only within the ", tt("@userCreationDomain@"), " domain).";
    print end_li;
    print start_li;
    print "You can ";
    print a({href => $base . "/create"}, "create a new repository"),
        " (only within the ", tt("@userCreationDomain@"), " domain).";
    print end_li;
    print start_li;
    print "You can ";
    print a({href => $base . "/edituser"}, "edit your user information"), ".";
    print end_li;
    print end_ul;

    print h2("Online information");
    print start_ul;
    print start_li;
    print a({href => "http://subversion.tigris.org/"}, "Subversion homepage"), ".";
    print end_li;
    print start_li;
    print a({href => "http://svnbook.red-bean.com/"}, "Subversion: The Definitive Guide"), ".";
    print end_li;
    print end_ul;

    # Print a table of all repositories, with their owners and
    # descriptions.
    print h2("Repositories");
    print p, "The following repositories are hosted on this server:";

    my @headings = ("Name", "Owner", "Description");
    my @rows = th(\@headings);

    my $DIR;
    opendir(DIR, $repodir);
    my %descriptions = getEntireDB($descrdb);
    my %owners = getEntireDB($ownerdb);
    my $isOdd = 0;
    foreach my $n (sort {uc($a) cmp uc($b)} readdir(DIR)) {
	next if ($n eq "." || $n eq "..");
	next unless (-d ($repodir . "/" . $n));
        my $isHidden = getDB($hiddenreposdb, $n);
	next if !$listDetails && defined $isHidden && $isHidden ne "";
	my $description = $descriptions{$n} || "";
	my $owner = $owners{$n} || "";
	push(@rows, td({class => $isOdd ? "odd" : "even"},
            [ a({href => $base . "/info/" . escape($n)}, tt($n))
            , $owner
            , escapeHTML($description)
            ]));
	$isOdd = !$isOdd;
    }
    closedir(DIR);

    print table({class => "listData"},
		"",
		Tr(\@rows));

    # Print a table of all users.
    print h2("Users");

    @headings = ("Name", "Full Name");
    if ($listDetails) {
	push @headings, "E-mail";
    }
    @rows = th(\@headings);

    my %users = getEntireDB($userdb);
    my %fullnames = getEntireDB($fullnamedb);
    my %addresses = getEntireDB($contactdb);
    $isOdd = 0;
    foreach my $name (sort {uc($a) cmp uc($b)} keys(%users)) {
	my $fullname = $fullnames{$name} || "";
	my $address = $addresses{$name} || "";
	my @columns = 
            ( $listDetails ? a({
		href => $base . "/edituser?username=" . $name}, 
		$name) : $name
            , escapeHTML($fullname)
	    );
	if ($listDetails) {
	    push @columns, escapeHTML($address);
	}
	push(@rows, td({class => $isOdd ? "odd" : "even"}, \@columns));
	$isOdd = !$isOdd;
    }

    print table({class => "listData"},
		"",
		Tr(\@rows));
}


elsif ($action eq "info") {

    checkRepo();
    repoExists();

    print h1("Subversion Repository " . $repoesc);

    printRepoInfo();

} 


elsif ($action eq "create" && !defined($repo)) {

    die unless defined $userName;

    print h1("Create a Repository");

    print start_form("post", $base . "/create");
    print p, strong("Note:"), " this server exists to support the ICS department's ",
        "research and education.  Any repository not created for this purpose ",
        "may be deleted without notice.";
    print p, strong("Note:"), " after creating a repository, you should subscribe ",
	"to the ", 
	a({href => "https://mail.cs.uu.nl/mailman/listinfo/svn-owners"},
	  tt("svn-owners"), " mailing list"),
	" to receive announcements about server maintenance.";
    print p, "Name of the repository ([A-Za-z0-9_-]+): ", textfield("repo");
    print p, "Description: ", textfield("description");
    print p, submit(-label => 'Create!');
    print end_form;

}


elsif ($action eq "create" && defined($repo)) {

    die unless defined $userName;

    checkRepo();

    my $description = param("description");
    checkDescription $description;

    if (-d $repodir . "/" . $repo) {
	print p, "The repository ", $repoesc, " already exists.";
	end();
    }

    my $backup = "$backupsdir/$repo";
    if (! -e "$backup") {
	if (! mkdir $backup, 0700) {
	    print h1("Error!");
	    print p, "Cannot create backup directory for ", $repoesc, ".";
	    end();
	}
    }

    system($svndir . "/bin/svnadmin", "create",
	   "--fs-type", "@fsType@",
	   $repodir . "/" . $repo);

    if ($? != 0) {

	print h1("Error!");
	print p, "I couldn't create the repository ", $repoesc, ".";
	print p, "Subversion exit code: ", $?;

    } else {

	# !!! ugly: cut/paste from reload.in.
	my $hookName = "$repodir/$repo/hooks/post-commit";
	open HOOK, ">$hookName";
	print HOOK "#! /bin/sh -e\n";
	print HOOK "exec @postCommitHook@ \"\$@\"\n"; # !!! ugly
	close HOOK;
	chmod 0755, $hookName or die;

	# By default, allow read/write access to the owner and 
	# nobody else.
	setDB($ownerdb, $repo, $userName);
	setDB($readerdb, $repo, $userName);
	setDB($writerdb, $repo, $userName);
	setDB($watcherdb, $repo, "");
	setDB($descrdb, $repo, $description);

	print h1("Repository created!");
	print p, "The repository has been created succesfully.";

	printRepoInfo();
    }

}


elsif ($action eq "update" && defined(param("readers"))) {

    die unless defined $userName;

    checkRepo();
    repoExists();

    my $owner = getDB($ownerdb, $repo);
    if ($owner ne $userName && $userName ne "root") {
	print p, "You are not authorised to update this repository.";
	end();
    }

    my $readers = param("readers");
    $readers =~ s/\s//g;
    unless ($readers =~ /^([\w,])*$/) {
	print p, "Invalid list of readers.";
	end();
    }

    my $writers = param("writers");
    $writers =~ s/\s//g;
    unless ($writers =~ /^([\w,])*$/) {
	print p, "Invalid list of writers.";
	end();
    }

    my $watchers = param("watchers");
    unless ($watchers =~ /^([\w, \.\+\@-])*$/) { # !!! fix
	print p, "Invalid list of watchers.";
	end();
    }

    my $tardirs = param("tardirs");
    $tardirs =~ s/\s//g;
    unless ($tardirs =~ /^[\w\/\.,-]*$/) {
	print p, "Invalid list of distribution directories.";
	end();
    }

    my $description = param("description");
    checkDescription $description;

    setDB($readerdb, $repo, $readers);
    setDB($writerdb, $repo, $writers);
    setDB($watcherdb, $repo, $watchers);
    setDB($tardb, $repo, $tardirs);
    setDB($descrdb, $repo, $description);

    # Asynchronously start building tarballs (if any).
    if ($tardirs ne "") {
	system "@out@/hooks/create-tarballs.pl $repo >&2 &";
    }

    print h1("Repository updated!");
    print p, "The settings of the repository have been updated succesfully.";

    printRepoInfo();

}


elsif ($action eq "adduser" && !defined(param("username"))) {

    print h1("Add a User");

    print start_form("post", $base . "/adduser");
    print "User name ([A-Za-z0-9_]+): ", textfield("username");
    print p, "Note: repository owners must supply and maintain a valid contact address.";
    print p, "E-mail address: ", textfield("address");
    print p, "Full name: ", textfield("fullname");
    print p, "Password: ", password_field("password", "");
    print p, "Password (again): ", password_field("password_again", "");
    print p, submit(-label => 'Add!');
    print end_form;

}

elsif ($action eq "adduser" && defined(param("username"))) {

    $userName = param("username");

    unless ($userName =~ /^\w+$/ && !($userName eq "all")) {
	print p, "Invalid user name.";
	end();
    }

    if (defined(getDB($userdb, $userName))) {
	print p, "User already exists.";
	end();
    }

    editUserInfo(1);

    print h1("User added!");
    print p, "The user ", tt($userName), " has been added succesfully.";
}


elsif ($action eq "edituser" && !defined(param("password"))) {

    die unless defined $userName;

    print h1("Edit User Information");

    # Root is allowed to change other users.
    if ($userName eq "root" && defined(param("username"))) {
	$userName = param("username");
    }

    print p, "You are about to edit user ", tt($userName), ".";
    print start_form("post", $base . "/edituser");
    print p, "E-mail address: ", textfield({
        -default => getDB($contactdb, $userName, ""), 
	-override => 1, -name => "address"});
    print p, "Full name: ", textfield({
        -default => getDB($fullnamedb, $userName, ""), 
	-override => 1, -name => "fullname"});
    print p, "Leave the password fields empty to leave your password unchanged.";
    print p, "Password: ", password_field("password", "");
    print p, "Password (again): ", password_field("password_again", "");
    print hidden(-name => "username", -default => "$userName");
    print p, submit(-label => 'Change!');
    print end_form;
}


elsif ($action eq "edituser" && defined(param("password"))) {

    if ($userName eq "root" && defined(param("username"))) {
	$userName = param("username");
    }

    if (!defined(getDB($userdb, $userName))) {
	print p, "You don't exist, go away.";
	end();
    }

    editUserInfo(0);

    print h1("User Information Edited!");
    print p, "Information for user ", tt($userName), 
        " has been changed succesfully.";
}


else {
    print p, "Undefined action: ", $action;
}

end();
