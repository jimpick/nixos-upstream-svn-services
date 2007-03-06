{stdenv, directory, urlPath} :

stdenv.mkDerivation {
  name = "serve-files-service";
  builder = ./builder.sh;
  inherit directory urlPath;
}
