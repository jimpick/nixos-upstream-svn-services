{
  all = let {
    body = rec {
      xorgTUD =
        xorgCommon {
          name     = "xorg-tud";
          control  = "startx-tud";
          xorgConf = ./xorg-tud.conf;
        };

      xorgUU =
        xorgCommon {
          name     = "xorg-uu";
          control  = "startx-uu";
          xorgConf = ./xorg-uu.conf;
        };

      xorgHome =
        xorgCommon {
          name     = "xorg-home";
          control  = "startx-home";
          xorgConf = ./xorg-home.conf;
        };

      xorgLaptop =
        xorgCommon {
          name     = "xorg-laptop";
          control  = "startx-laptop";
          xorgConf = ./xorg-laptop.conf;
        };

      xorgBeamer =
        xorgCommon {
          name     = "xorg-beamer";
          control  = "startx-beamer";
          xorgConf = ./xorg-beamer.conf;
        };
    };

    xorgCommon = config :
      (import ../../xorg-alt/config) ({
        user = "martin";
        init = "/opt/kde3/bin/startkde";
        server = xorgWrapper;
        terminal = 7;
        display = 0;
        inherit stdenv;
      } // config);

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
          "/usr/X11R6/lib/X11/fonts/encodings"
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

    pkgs = 
      (import ../../pkgs/top-level/all-packages.nix) { system = "i686-linux"; };

    xorg =
      pkgs.xorg;

    stdenv =
      pkgs.stdenv;

  };
}.all