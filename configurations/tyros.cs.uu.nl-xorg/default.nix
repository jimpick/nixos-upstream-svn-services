{productionServer ? true}:

let {
  body = xorgService;

  pkgs = import ../../pkgs/system/all-packages.nix {system = __currentSystem;};

  xorgService = import ../../xorg {
    inherit (pkgs) stdenv substituter;
    inherit (pkgs.xorg) xorgserver;

    logDir = "/tmp/Xstate";
    stateDir = "/tmp/Xstate";

    modules = [
      pkgs.xorg.xf86inputmouse
      pkgs.xorg.xf86inputkeyboard
      pkgs.xorg.xf86videoi810
    ];
  };

}