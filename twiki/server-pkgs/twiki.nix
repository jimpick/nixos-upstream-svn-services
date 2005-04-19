{ name
, stdenv
, fetchurl
, rcs
, grep
, perl
, twikiroot ? null
, user
, group
, datadir
, pubdir
, defaultUrlHost
, scriptUrlPath ? "/twiki/bin"
, dispScriptUrlPath ? null      
, dispViewPath ? "/view"
, pubUrlPath ? "/twiki/pub"
, twikiName ? "TWiki"
, skins ? []
, plugins ? []
, alwaysLogin ? false
}:

stdenv.mkDerivation {
  inherit name;

  builder = ./twiki-builder.sh;
  src = fetchurl {
    url = http://twiki.org/swd/TWiki20040902.tar.gz;
    md5 = "d04b2041d83dc6c97905faa1c6b9116d";
  };

  inherit rcs grep perl;
  inherit user group;
  inherit twikiroot datadir pubdir;
  inherit skins;
  inherit plugins;

  viewModulePatch = ./View.pm.patch;

  dispScriptUrlPath =
    if dispScriptUrlPath != null then dispScriptUrlPath else scriptUrlPath;

  inherit 
    alwaysLogin
    defaultUrlHost
    scriptUrlPath
    dispViewPath
    pubUrlPath
    twikiName;

  # Local helper files to make builder more compact.
  staticTWikiCfg = ./TWiki.nochange.cfg;
  binHtaccess = ./bin-htaccess;
}