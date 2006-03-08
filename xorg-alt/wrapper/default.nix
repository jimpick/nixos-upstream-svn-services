{name, stdenv, xorg, modules, fonts ? [], addDefaultFonts ? true}:

stdenv.mkDerivation {
  inherit name;
  builder = ./builder.sh;
  makeWrapper = ../../pkgs/build-support/make-wrapper/make-wrapper.sh;

  modules = [xorg.xorgserver] ++ modules;

  fonts =
    fonts ++ (
      if addDefaultFonts then [
          # xorg.fontbhttf TODO
        ] 
      else []
    );

  inherit (xorg) xorgserver;
  xorgserverBuildInputs = xorg.xorgserver.buildInputs;
}
