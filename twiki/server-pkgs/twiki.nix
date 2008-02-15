{ name
, stdenv
, fetchurl
, rcs
, perl
, twikiroot ? null
, user ? ""
, group ? ""
, datadir
, pubdir
, defaultUrlHost
, scriptUrlPath ? "/twiki/bin"
, absHostPath ? "/twiki"
, dispScriptUrlPath ? null   # defaults to scriptUrlPath
, dispViewPath ? "/view"
, pubUrlPath ? "/twiki/pub"
, dispPubUrlPath ? null      # defaults to pubUrlPath
, twikiName ? "TWiki"
, startWeb ? "Main/WebHome"
, customRewriteRules ? ""
, skins ? []
, plugins ? []
, alwaysLogin ? false
, pubDataPatch ? ""
, sed
, htpasswd
, registrationDomain ? "all"
}:

stdenv.mkDerivation {
  inherit name;

  builder = ./twiki-builder.sh;
  src = fetchurl {
    url = http://twiki.org/swd/TWiki20040904.tar.gz;
    md5 = "1ee1fdf5309ee0300d29cafacc30b75c";
  };

  inherit rcs perl;
  inherit user group;
  inherit twikiroot datadir pubdir;
  inherit skins;
  inherit plugins;
  inherit sed;
  inherit htpasswd;

  conf = ./twiki.conf;
  preconf = ./twiki-pre.conf;

  startupHook = ./startup-hook.sh;

  viewModulePatch = ./View.pm.patch;

  dispScriptUrlPath =
    if dispScriptUrlPath != null then dispScriptUrlPath else scriptUrlPath;

  dispPubUrlPath =
    if dispPubUrlPath != null then dispPubUrlPath else pubUrlPath;

  inherit 
    pubDataPatch
    alwaysLogin
    defaultUrlHost
    scriptUrlPath
    absHostPath
    dispViewPath
    pubUrlPath
    twikiName
    registrationDomain;

  # Local helper files to make builder more compact.
  staticTWikiCfg = ./TWiki.nochange.cfg;
  binHtaccess = ./bin-htaccess;
}
