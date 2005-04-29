{ stdenv, substituter, apacheHttpd, coreutils

# Directory where Apache will store its log files.
, logDir

# Directory where Apache will keep state (e.g., the pid file).
, stateDir

# E-mail address of the administrator
, adminAddr 

# The canonical hostname.
, hostName

# The HTTP port.
, httpPort ? 8080

# Whether to enable SSL support
, enableSSL ? false

# The HTTPS port
, httpsPort ? 8443

# The default port for constructing self-references.
, defaultPort ? null

# SSL certificate and key.
, sslServerCert ? ""
, sslServerKey ? ""

# Subservices.  This is what it's all about.
, subServices ? []

# Site-local extensions to httpd.conf.
, siteConf ? ""

}:

assert enableSSL -> sslServerCert != "" && sslServerKey != "" && httpsPort != 0;

stdenv.mkDerivation {
  name = "apache-httpd-service";
  builder = ./builder.sh;

  scripts = [ ./ctl.in ];

  defaultPath = [
    (coreutils ~ "/bin")
  ];

  substFiles = [
    "=>/conf"
    ./httpd-basics.conf
    ./languages.conf
    ./icons.conf
  ];

  defaultPort = if defaultPort != null then defaultPort else httpPort;

  inherit
    substituter apacheHttpd
    logDir stateDir
    adminAddr hostName httpPort enableSSL httpsPort
    sslServerCert sslServerKey
    subServices siteConf;
}
