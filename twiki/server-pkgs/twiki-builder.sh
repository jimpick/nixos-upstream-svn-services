. $stdenv/setup
. $substituter

set -e

if test -n "$twikiroot"; then
  echo "TWiki will be configured with root $twikiroot ... "
else
  twikiroot=$out
fi

echo "Unpacking source tarball ... "
tar zxf $src
mkdir -p $out

echo "Copying bin,lib and templates ... "
mv bin $out/bin
mv lib $out/lib
mv templates $out/templates
mv locale $out/locale

#patch $out/lib/TWiki/UI/View.pm $viewModulePatch

for skin in $skins
do
  cp -R $skin/templates/* $out/templates
done

echo "Setting plugins: $plugins"
for plugin in $plugins
do
  cp -R $plugin/bp* $out
  cp -R $plugin/lib $out
done

# todo: testenv script should be removed if this is a production server.
echo "Removing unnecessary scripts ..."


echo "Patching Perl interpreter path ..."
for i in $out/bin/*; do
  if test -f $i 
  then
    sed "s^/usr/bin/perl^$perl/bin/perl^" < $i > $i.tmp
    mv $i.tmp $i
  fi
done    


echo "Installing htaccess files ..."
cp ./subdir-htaccess.txt $out/lib/.htaccess
cp ./subdir-htaccess.txt $out/templates/.htaccess

echo "Copying initial files ..."
ensureDir $out/init
cp ./subdir-htaccess.txt $out/init/
cp -R ./data $out/init/data
cp -R ./pub $out/init/pub

echo "Patching RCS locks ..."
for file in `find $out/init/data -name \*.txt,v`
do
  sed "s/www:/nobody:/;s/apache:/nobody:/" < $file > $file.copy
  chmod +w $file
  mv $file.copy $file
done

cp $htpasswd $out/init/data/.htpasswd

#echo "Patching initial files ..."
#if test "x$pubDataPatch" != "x"
#then
#  (cd $out/init; patch -p1 < $pubDataPatch)
#fi

echo "Creating .htaccess file"
cat > $out/bin/.htaccess <<EOF
AuthUserFile $datadir/.htpasswd
AuthName "$twikiName (Cancel to register)"
AuthType Basic
EOF

if test "$alwaysLogin" = "1"; then

cat  >> $out/bin/.htaccess <<EOF
Require valid-user
EOF

else

cat >> $out/bin/.htaccess <<EOF
ErrorDocument 401 $scriptUrlPath/oops/TWiki/TWikiRegistration?template=oopsauth

EOF
cat $binHtaccess | sed s/@registrationDomain@/$registrationDomain/ >> $out/bin/.htaccess

fi

echo "Making scripts executable ..."
# Nothing executable in the bin
chmod uga-x $out/bin/*

# Except for the known scripts.
chmod 755 \
  $out/bin/attach       \
  $out/bin/changes      \
  $out/bin/configure    \
  $out/bin/edit         \
  $out/bin/login        \
  $out/bin/logon        \
  $out/bin/manage       \
  $out/bin/oops         \
  $out/bin/passwd       \
  $out/bin/preview      \
  $out/bin/rdiff        \
  $out/bin/rdiffauth    \
  $out/bin/register     \
  $out/bin/rename       \
  $out/bin/resetpasswd  \
  $out/bin/rest         \
  $out/bin/save         \
  $out/bin/search       \
  $out/bin/statistics   \
  $out/bin/twiki        \
  $out/bin/upload       \
  $out/bin/view         \
  $out/bin/viewauth     \
  $out/bin/viewfile  \
  $out/bin/logos

echo "Constructing config files ..."

# Generate config file $out/bin/LocalLib.cfg

echo "perlDigestSHA1 = $perlDigestSHA1"
echo "perlCGISession = $perlCGISession"

cat > $out/bin/LocalLib.cfg <<EOF
use vars qw( \$twikiLibPath \$CPANBASE \$cgiSessionPath \$digestSHA1Path );
\$twikiLibPath = '$twikiroot/lib';
\$cgiSessionPath = '$perlCGISession/lib/site_perl/5.8.6/';
\$digestSHA1Path = '$perlDigestSHA1/lib/site_perl/5.8.6/i686-linux';

# Prepend to @INC, the Perl search path for modules
unshift @INC, \$twikiLibPath;
unshift @INC, \$cgiSessionPath;
unshift @INC, \$digestSHA1Path;
unshift @INC, \$localPerlLibPath if \$localPerlLibPath;

1; # Required for successful module loading
EOF

echo $out/bin/LocalLib.cfg

# Generate config file $out/lib/LocalSite.cfg
# Comments have been removed. Consult the original cfg file for a description
# todo: of course the paths should refer to Nix packages in a Nix installation.

cat > $out/lib/LocalSite.cfg <<EOF
\$cfg{DefaultUrlHost}    = "$defaultUrlHost";
\$cfg{ScriptUrlPath}     = "$scriptUrlPath";
\$cfg{dispScriptUrlPath} = "$dispScriptUrlPath";
\$cfg{dispViewPath}      = "$dispViewPath";
\$cfg{PubUrlPath}        = "$dispPubUrlPath";
\$cfg{PubDir}            = "$pubdir";
\$cfg{TemplateDir}       = "$twikiroot/templates";
\$cfg{LocalesDir}        = "$twikiroot/locale";
\$cfg{DataDir}           = "$datadir";
\$cfg{LogDir}            = "\$cfg{DataDir}";

\$cfg{OS}                = 'UNIX';
\$cfg{scriptSuffix}      = "";
\$cfg{uploadFilter}      = "^(\.htaccess|.*\.(?:php[0-9s]?|phtm[l]?|pl|py|cgi))\\$";
\$cfg{safeEnvPath}       = "$(dirname $(type -tP grep))";
\$cfg{mailProgram}       = "false";
\$cfg{noSpamPadding}     = "";
\$cfg{mimeTypesFilename} = "\$cfg{dataDir}/mime.types";

\$cfg{rcsDir}            = '$rcs/bin';
\$cfg{rcsArg}            = "";
\$cfg{nullDev}           = '/dev/null';
\$cfg{useRcsDir}         = "0";
\$cfg{endRcsCmd}         = " 2>&1";
\$cfg{cmdQuote}          = "'";
\$cfg{storeTopicImpl}    = "RcsWrap"; 
\$cfg{lsCmd}             = "$(type -tP ls)";
\$cfg{egrepCmd}          = "$(type -tP egrep)";
\$cfg{fgrepCmd}          = "$(type -tP fgrep)";
\$cfg{displayTimeValues} = "gmtime";
1; # Required for successful module loading
EOF

# the following is no longer needed since LocalLib updates TWiki.cfg
#cat $staticTWikiCfg >> $out/lib/TWiki.cfg


echo "Creating Apache httpd.conf fragment ..."
ensureDir $out/types/apache-httpd/conf
substitute $conf $out/types/apache-httpd/conf/twiki.conf \
    --subst-var twikiroot \
    --subst-var pubdir \
    --subst-var datadir \
    --subst-var scriptUrlPath \
    --subst-var pubUrlPath \
    --subst-var dispScriptUrlPath \
    --subst-var absHostPath \
    --subst-var startWeb \
    --subst-var customRewriteRules

echo "Creating Apache pre httpd.conf fragment ..."
ensureDir $out/types/apache-httpd/conf-pre
substitute $preconf $out/types/apache-httpd/conf-pre/twiki.conf \
    --subst-var twikiroot \
    --subst-var pubdir \
    --subst-var datadir \
    --subst-var scriptUrlPath \
    --subst-var pubUrlPath \
    --subst-var dispScriptUrlPath \
    --subst-var absHostPath \
    --subst-var startWeb \
    --subst-var customRewriteRules

# dirty hack for allowing rewrite rules
ensureDir $out/rewritestub

echo "Creating startup hook ..."
ensureDir $out/types/apache-httpd
substitute $startupHook $out/types/apache-httpd/startup-hook.sh \
    --subst-var pubdir \
    --subst-var datadir \
    --subst-var user \
    --subst-var group \
    --subst-var skins \
    --subst-var plugins \
    --subst-var out \
    --subst-var sed \
    --subst-var-by initialPath "$(dirname $(type -tP find))"


cat > $out/DONT_EDIT_WARNING.txt <<EOF
*********************************************************************
 Warning   Warning   Warning   Warning   Warning   Warning   Warning
*********************************************************************

  Do not edit files in this directory or its subdirectories. This
  structure is automatically generated and will be replaced with the
  next update. We will *not* pay attention to files that have been
  edited by hand.

  Ugh.

  Questions? Martin Bravenboer <martin@cs.uu.nl>
EOF

