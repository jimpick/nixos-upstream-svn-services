{productionServer}:

import ./svn-server.nix (rec {

  # Location of all mutable data (except temporary files).
  dataDir = "/data/subversion";

  # Temporary files.
  tmpDir = "/home/svn/tmp";

  # Subdirectory of `dataDir' to store logs.
  logsSuffix = if productionServer then "logs" else "testlogs";

  # Do we want SSL?  If so, specify the server certificate and key.
  enableSSL = true;
  sslServerCert = "/home/svn/ssl/server.crt";
  sslServerKey = "/home/svn/ssl/server.key";

  # Host name and ports to use.
  hostName = "svn.cs.uu.nl";
  httpPort = if productionServer then 12080 else 12081;
  httpsPort = if productionServer then 12443 else 12444;
  defaultPort = if enableSSL then httpsPort else httpPort;

  # Administrator address.
  admin = "eelco@cs.uu.nl";

  # Commit notification sender address.
  notificationSender = "svn@svn.cs.uu.nl";

})
