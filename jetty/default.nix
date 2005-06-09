{ stdenv
, j2re
, jetty
, subServices
, logDir
, port ? 8080
, initHeapSize ? "100m"
, maxHeapSize  ? "300m"
, stopport ? 9999
, sslKey ? null
, sslSupport ? true
, minThreads ? 5
, maxThreads ? 500
} :

stdenv.mkDerivation ({
  name = "jetty-instance";
  builder = ./builder.sh;

  paths = map (subService : subService.path) subServices;
  wars  = map (subService : subService.war ~ subService.war.warPath)  subServices;

  inherit j2re jetty;                
  inherit sslSupport logDir port stopport minThreads maxThreads initHeapSize maxHeapSize;

} // (if sslSupport then
       {inherit (sslKey) store storepass keypass;}
      else {}))
