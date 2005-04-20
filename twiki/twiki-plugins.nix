rec {
  pkgs =
    import ../pkgs/system/i686-linux.nix;

  BlueBoxSkin =
    (import ./server-pkgs/bluebox-skin.nix) {
      inherit (pkgs) stdenv fetchurl unzip;
    };

  FlexPatternSkin =
    (import ./server-pkgs/flexpattern-skin.nix) {
      inherit (pkgs) stdenv fetchurl unzip;
    };

  BibTexPlugin = 
    (import ./server-pkgs/bibtex-plugin.nix) {
     inherit (pkgs) stdenv fetchurl unzip perl;
    };
              
/*
  FlexClassicSkin =
    pkgs.stdenv.mkDerivation {
      name = "FlexPatternSkin-0.1";
      builder = ./server-pkgs/unzip-builder.sh;
      src = /tmp/FlexClassicSkin-0.1.zip;
      inherit (pkgs) unzip;
    };*/
}
