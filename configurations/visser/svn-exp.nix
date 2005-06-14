# This is the server configuration for subversion at Eelco Visser's laptop.

{productionServer}:

let {

  body = webServer;

  pkgs = import ../../pkgs/system/all-packages.nix {system = __currentSystem;};

  webServer = import ../../apache-httpd {
    inherit (pkgs) stdenv substituter apacheHttpd coreutils;

    httpPort = if productionServer 
	       then webServerConfig.productionHttpPort 
	       else webServerConfig.testHttpPort;

    httpsPort = if productionServer 
	        then webServerConfig.productionHttpsPort 
	        else webServerConfig.productionHttpsPort;

    inherit (webServerConfig) hostName adminAddr 
      enableSSL sslServerCert sslServerKey logDir stateDir ;

    logDir = rootDir + "/" +
     (if productionServer then "logs" else "test-logs");

    stateDir = logDir;

    subServices = [
      subversionService
    ];
  };

  subversionService = import ../../subversion {
    inherit (pkgs) stdenv fetchurl
      substituter apacheHttpd openssl db4 expat swig zlib
      perl perlBerkeleyDB python libxslt enscript;

    reposDir   = subversionServiceConfig.rootDir + "/repos";
    dbDir      = subversionServiceConfig.rootDir + "/db";
    distsDir   = subversionServiceConfig.rootDir + "/dist";
    backupsDir = subversionServiceConfig.rootDir + "/backup";
    tmpDir     = subversionServiceConfig.rootDir + "/tmp";

    inherit (webServer) logDir;

    canonicalName =
      if webServer.enableSSL then
        "https://" + webServer.hostName + ":" + webServer.httpsPort
      else
        "http://" + webServer.hostName + ":" + webServer.httpPort;

    inherit (subversionServiceConfig) rootDir notificationSender adminAddr;

    # We use Berkeley DB repos.
    fsType = "bdb";
  };

} //
{
  webServerConfig = {
    hostName            = "localhost.localdomain";

    productionHttpPort  = "12080";
    productionHttpsPort = "12443";
    testHttpPort        = "12081";
    testHttpsPort       = "12444";

    adminAddr           = "eelco-visser@xs4all.nl";

    rootDir             = "/home/visser/subversion";


    enableSSL           = false;
    sslServerCert       = "/home/svn/ssl/server.crt";
    sslServerKey        = "/home/svn/ssl/server.key";
  };

  subversionServiceConfig = {
    adminAddr = webServerConfig.adminAddr;
    notificationSender = "svn@svn.cs.uu.nl";
  };

}
