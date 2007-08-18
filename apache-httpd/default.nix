{ stdenv, apacheHttpd, coreutils, 

  php ? null

, # Directory where Apache will store its log files.
  logDir

, # Directory where Apache will keep state (e.g., the pid file).
  stateDir

, # E-mail address of the administrator
  adminAddr 

, # The canonical hostname.
  hostName

, # The HTTP port.
  httpPort ? 8080

, # Whether to enable SSL support
  enableSSL ? false

, # The HTTPS port
  httpsPort ? 8443

, # The default port for constructing self-references.
  defaultPort ? null

, # The user/group under which the server will run.
  user ? "nobody"

, group ? "nobody"

, # SSL certificate and key.
  sslServerCert ? ""
, sslServerKey ? ""

, # Subservices.  This is what it's all about.
  subServices ? []

, # Site-local extensions to httpd.conf.
  siteConf ? ""

, # Use an explicit document root instead of synthesizing one.
  documentRoot ? ""

, # Prevent users from publishing public_html directories 
  # as /~user on server.
  noUserDir ? true

, # Verbatim chunk of config to go immediately after 
  # default directory aliases and directory entries.
  extraDirectories ? ""
}:

assert enableSSL -> sslServerCert != "" && sslServerKey != "" && httpsPort != 0;

stdenv.mkDerivation {
  name = "apache-httpd-service";
  builder = ./builder.sh;

  scripts = [ "=>/bin" ./control.in ];

  defaultPath = [
    (coreutils + "/bin")
  ];

  substFiles = [
    "=>/conf"
    ./httpd-basics.conf
    ./languages.conf
    ./icons.conf
  ];

  defaultPort = if defaultPort != null then defaultPort else httpPort;
 
  noUserDir = if noUserDir then "#" else "";

  extraDirectories = extraDirectories;

  inherit
    apacheHttpd
    logDir stateDir adminAddr hostName httpPort enableSSL httpsPort
    user group sslServerCert sslServerKey subServices siteConf
    documentRoot;
  
  phpClause=if php != null then "LoadModule php5_module ${php}/modules/libphp5.so" else "";
}
