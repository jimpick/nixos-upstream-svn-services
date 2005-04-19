{ dataDir, tmpDir, logsSuffix
, enableSSL ? false, sslServerCert ? "", sslServerKey ? ""
, hostName, httpPort, httpsPort ? 0, defaultPort
, admin, notificationSender
}:

assert enableSSL -> sslServerCert != "" && sslServerKey != "" && httpsPort != 0;

let {

  body = svnserver;

  pkgs = import pkgs/system/all-packages.nix {system = __currentSystem;};

  
  # Build the Subversion service.
  svnserver = pkgs.stdenv.mkDerivation {
    name = "svn-server";
    builder = ./builder.sh;
    
    conf = ./conf/httpd.conf.in;
    
    scripts = [
      "=>/bin"
      ./bin/ctl.in
      ./src/maintenance/delete-repo.pl.in 
      ./src/maintenance/delete-user.pl.in 
      ./src/maintenance/reload.in 
      ./src/maintenance/resetpw.pl.in
      "=>/cgi-bin"
      ./src/repoman/repoman.pl.in
      "=>/hooks"
      ./src/hooks/commit-email.pl.in
      ./src/hooks/post-commit.in
      ./src/hooks/post-commit-link.in
      ./src/hooks/hot-backup.pl.in
      ./src/hooks/create-tarballs.pl.in
      ./src/hooks/query-head-revision.xsl # !!! not actually an executable
    ];

    staticPages = [
      "=>/" ./root/favicon.ico ./root/robots.txt ./root/style.css ./root/UU_merk.gif
      "=>/xsl" ./root/xsl/svnindex.xsl ./root/xsl/svnindex.css 
    ];
      
    inherit dataDir tmpDir logsSuffix hostName httpPort httpsPort defaultPort
      admin notificationSender subversion authModules viewcvs enableSSL
      sslServerCert sslServerKey;
    inherit (pkgs) perl perlBerkeleyDB
      python apacheHttpd libxslt
      bash coreutils gnutar gzip bzip2 diffutils gnused
      enscript db4;
    substituter = ./pkgs/build-support/substitute/substitute.sh;
  };

  
  # Build a Subversion instance with Apache modules and Swig/Python bindings.
  subversion = import pkgs/applications/version-management/subversion-1.1.x {
    inherit (pkgs) fetchurl stdenv openssl db4 expat swig zlib;
    localServer = true;
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

  
  # Build ViewCVS.
  viewcvs = import ./src/viewcvs {
    inherit (pkgs) stdenv python;
    substitute  = ./pkgs/build-support/substitute/substitute.sh;
    reposDir = dataDir + "/repos";
    adminAddr = admin;
  };

}
