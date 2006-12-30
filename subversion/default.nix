{ pkgs
, user, group
, reposDir, dbDir, logDir, distsDir, backupsDir, tmpDir
, canonicalName
, adminAddr, notificationSender
, fsType ? "fsfs"
, autoVersioning ? false
}:

let

  # Build the Subversion service.
  svnServer = pkgs.stdenv.mkDerivation {
    name = "svn-server";
    builder = ./builder.sh;
    
    conf = ./subversion.conf;
    confPre = ./subversion-pre.conf;

    defaultPath = "/no-path";
    
    scripts = [
      "=>/types/apache-httpd"
      ./startup-hook.sh
      "=>/bin"
      ./src/maintenance/delete-repo.pl.in 
      ./src/maintenance/delete-user.pl.in 
      ./src/maintenance/reload.in 
      ./src/maintenance/resetpw.pl.in
      "=>/cgi-bin"
      ./src/repoman/repoman.pl.in
      "=>/hooks"
      ./src/hooks/commit-email.pl.in
      ./src/hooks/post-commit.in
      ./src/hooks/hot-backup.pl.in
      ./src/hooks/create-tarballs.pl.in
      ./src/hooks/query-head-revision.xsl # !!! not actually an executable
    ];

    staticPages = [
      "=>/types/apache-httpd/root"
      ./root/favicon.ico ./root/robots.txt ./root/style.css ./root/UU_merk.gif
      "=>/types/apache-httpd/root/xsl"
      ./root/xsl/svnindex.xsl ./root/xsl/svnindex.css 
    ];

    autoVersioning = if autoVersioning then "on" else "off";
      
    inherit user group reposDir dbDir logDir distsDir backupsDir
      tmpDir canonicalName adminAddr notificationSender fsType
      subversion authModules viewvc websvn;
    inherit (pkgs) perlBerkeleyDB python apacheHttpd mod_python php
      libxslt enscript db4;
    perl = pkgs.perl + "/bin/perl";
    perlFlags = "-I${pkgs.perlBerkeleyDB}/lib/site_perl";
  };


  # Build a Subversion instance with Apache modules and Swig/Python bindings.
  subversion = import ../pkgs/applications/version-management/subversion-1.4.x {
    inherit (pkgs) fetchurl stdenv apr aprutil neon expat swig zlib;
    bdbSupport = true;
    httpServer = true;
    sslSupport = true;
    compressionSupport = true;
    pythonBindings = true;
    httpd = pkgs.apacheHttpd;
  };

  
  # Build our custom authentication modules.
  authModules = import ./src/auth {
    inherit (pkgs) stdenv apacheHttpd;
  };

  
  # Build ViewVC.
  viewvc = import ./src/viewvc {
    inherit (pkgs) fetchurl stdenv python;
    inherit reposDir adminAddr subversion;
  };


  # Build WebSVN.
  websvn = import ./src/websvn {
    inherit (pkgs) fetchurl stdenv writeText enscript gnused;
    inherit reposDir subversion;
    cacheDir = tmpDir;
  };

  
in svnServer
