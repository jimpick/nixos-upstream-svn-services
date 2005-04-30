{ stdenv, fetchurl, substituter, apacheHttpd, openssl, db4, expat, swig, zlib
, perl, perlBerkeleyDB, python, libxslt, enscript
, reposDir, dbDir, logDir, distsDir, backupsDir
, canonicalName
, adminAddr, notificationSender
}:

let {

  body = svnserver;
  

  # Build the Subversion service.
  svnserver = stdenv.mkDerivation {
    name = "svn-server";
    builder = ./builder.sh;
    
    conf = ./subversion.conf;
    confPre = ./subversion-pre.conf;
    
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
      
    inherit reposDir dbDir logDir distsDir backupsDir canonicalName
      adminAddr notificationSender subversion authModules viewcvs;
    inherit perl perlBerkeleyDB
      python apacheHttpd libxslt
      enscript db4 substituter;
  };


  # Build a Subversion instance with Apache modules and Swig/Python bindings.
  subversion = import ../pkgs/applications/version-management/subversion-1.1.x {
    inherit stdenv fetchurl openssl db4 expat swig zlib;
    localServer = true;
    httpServer = true;
    sslSupport = true;
    compressionSupport = true;
    pythonBindings = true;
    httpd = apacheHttpd;
  };

  
  # Build our custom authentication modules.
  authModules = import ./src/auth {
    inherit stdenv apacheHttpd;
  };

  
  # Build ViewCVS.
  viewcvs = import ./src/viewcvs {
    inherit stdenv python substituter reposDir adminAddr;
  };

}
