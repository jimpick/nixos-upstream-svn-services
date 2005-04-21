# This is a pure version of TWiki. It is easy to configure an impure version.

rec {
  pkgs =
    import ../pkgs/system/i686-linux.nix;

  twiki = config :
    (import ./server-pkgs/twiki.nix) ({
      inherit (pkgs) stdenv fetchurl substituter;

      rcs = pkgs.rcs;
      perl = pkgs.perl;

      skins = [
        plugins.BlueBoxSkin
#        plugins.FlexPatternSkin
      ];
      
      plugins = [
#        plugins.BibTexPlugin
      ];

    } // config);

  plugins =
    (import ./twiki-plugins.nix);
}
