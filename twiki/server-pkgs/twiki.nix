{ name
, stdenv
, fetchurl
, substituter
, rcs
, perl
, perlCGISession
, perlDigestSHA1
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
    url = http://twiki.org/p/pub/Codev/Release/TWiki-4.0.1.tgz;
    md5 = "bbfaa7fe279b374407a5bd7d946bbe7a";
  };

  inherit substituter rcs perl;
  inherit user group;
  inherit twikiroot datadir pubdir;
  inherit skins;
  inherit plugins;
  inherit sed;
  inherit htpasswd;
  inherit perlCGISession perlDigestSHA1;

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
