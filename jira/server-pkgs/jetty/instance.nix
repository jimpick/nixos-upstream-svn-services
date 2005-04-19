{stdenv, j2sdk, jetty, webapps, logdir, port ? 8080, stopport ? 9999, sslKey ? null, sslSupport ? true, minThreads ? 5, maxThreads ? 500} :

stdenv.mkDerivation ({
  name = "jetty-instance";
  builder = ./instance-builder.sh;

  paths = map (webapp : webapp.path) webapps;
  wars  = map (webapp : webapp.war)  webapps;

  inherit j2sdk jetty;                
  inherit sslSupport logdir port stopport minThreads maxThreads;

} // (if sslSupport then
       {inherit (sslKey) store storepass keypass;}
      else {}))
