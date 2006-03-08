{
  all = let {
    body = rec {
      xorgUU =
        (import ../../xorg-alt/config) {
          name    = "xorg-uu";
          control = "startx-uu";
          init = "/opt/kde3/bin/startkde";
          xorgConf = ./xorg-uu.conf;
          server = xorgWrapper;
          terminal = 8;
          display = 1;
          inherit stdenv;
        };
    };

    pkgs = 
      (import ../../pkgs/system/all-packages.nix) { system = "i686-linux"; };

    xorg =
      pkgs.xorg;

    stdenv =
      pkgs.stdenv;

    xorgWrapper =
      (import ../../xorg-alt/wrapper) {
        name = "xorg-wrapper-logistico";
        inherit stdenv xorg;

        modules = [
            xorg.xf86videoati
            xorg.xf86inputmouse
            xorg.xf86inputkeyboard
          ];

        fonts = [
          "/usr/X11R6/lib/X11/fonts/misc:unscaled"
          "/usr/X11R6/lib/X11/fonts/local"
          "/usr/X11R6/lib/X11/fonts/75dpi:unscaled"
          "/usr/X11R6/lib/X11/fonts/100dpi:unscaled"
          "/usr/X11R6/lib/X11/fonts/Type1"
          "/usr/X11R6/lib/X11/fonts/truetype"
          "/usr/X11R6/lib/X11/fonts/uni:unscaled"
          "/usr/X11R6/lib/X11/fonts/CID"
          "/usr/X11R6/lib/X11/fonts/misc"
          "/usr/X11R6/lib/X11/fonts/misc/sgi:unscaled"
          "/usr/X11R6/lib/X11/fonts/xtest"
          "/opt/kde3/share/fonts"
        ];
      };
  };
}