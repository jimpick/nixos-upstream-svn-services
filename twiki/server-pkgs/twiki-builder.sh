source $stdenv/setup

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
mv twiki/bin $out/bin
mv twiki/lib $out/lib
mv twiki/templates $out/templates

patch $out/lib/TWiki/UI/View.pm $viewModulePatch

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
    sed "s^/usr/bin/perl^$perl/bin/perl^" < $i > $i.tmp
    mv $i.tmp $i
done    


echo "Installing htaccess files ..."
cp ./twiki/subdir-htaccess.txt $out/lib/.htaccess
cp ./twiki/subdir-htaccess.txt $out/templates/.htaccess

echo "Copying initial files ..."
ensureDir $out/init
cp ./twiki/subdir-htaccess.txt $out/init/
cp -R ./twiki/data $out/init/data
cp -R ./twiki/pub $out/init/pub

echo "Patching RCS locks ..."
for file in `find $out/init/data -name \*.txt,v`
do
  sed "s/www:/nobody:/;s/apache:/nobody:/" < $file > $file.copy
  chmod +w $file
  mv $file.copy $file
done

cp $htpasswd $out/init/data/.htpasswd

echo "Patching initial files ..."
if test "x$pubDataPatch" != "x"
then
  (cd $out/init; patch -p1 < $pubDataPatch)
fi

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
  $out/bin/attach \
  $out/bin/changes \
  $out/bin/edit \
  $out/bin/geturl \
  $out/bin/installpasswd \
  $out/bin/mailnotify \
  $out/bin/manage \
  $out/bin/oops \
  $out/bin/passwd \
  $out/bin/preview \
  $out/bin/rdiff \
  $out/bin/rdiffauth \
  $out/bin/register \
  $out/bin/rename \
  $out/bin/save \
  $out/bin/search \
  $out/bin/statistics \
  $out/bin/testenv \
  $out/bin/upload \
  $out/bin/view \
  $out/bin/viewauth \
  $out/bin/viewfile

echo "Constructing config files ..."
# Generate config file $out/bin/setlib.cfg
cat > $out/bin/setlib.cfg <<EOF
#    Path to lib directory containing TWiki.pm.
\$twikiLibPath = '$twikiroot/lib';

# Prepend to @INC, the Perl search path for modules
unshift @INC, \$twikiLibPath;
unshift @INC, \$localPerlLibPath if \$localPerlLibPath;

1; # Return success for module loading
EOF

# Generate config file $out/lib/TWiki.cfg
# Comments have been removed. Consult the original cfg file for a description
# todo: of course the paths should refer to Nix packages in a Nix installation.
cat > $out/lib/TWiki.cfg <<EOF
\$defaultUrlHost    = "$defaultUrlHost";
\$scriptUrlPath     = "$scriptUrlPath";
\$dispScriptUrlPath = "$dispScriptUrlPath";
\$dispViewPath      = "$dispViewPath";
\$pubUrlPath        = "$dispPubUrlPath";
\$pubDir            = "$pubdir";
\$templateDir       = "$twikiroot/templates";
\$dataDir           = "$datadir";
\$logDir            = "$datadir";

\$OS                = 'UNIX';
\$scriptSuffix      = "";
\$uploadFilter      = "^(\.htaccess|.*\.(?:php[0-9s]?|phtm[l]?|pl|py|cgi))\\$";
\$safeEnvPath       = "$(dirname $(type -tP grep))";
\$mailProgram       = "false";
\$noSpamPadding     = "";
\$mimeTypesFilename = "\$dataDir/mime.types";

\$rcsDir            = '$rcs/bin';
\$rcsArg            = "";
\$nullDev           = '/dev/null';
\$useRcsDir         = "0";
\$endRcsCmd         = " 2>&1";
\$cmdQuote          = "'";
\$storeTopicImpl    = "RcsWrap"; 
\$lsCmd             = "$(type -tP ls)";
\$egrepCmd          = "$(type -tP egrep)";
\$fgrepCmd          = "$(type -tP fgrep)";
\$displayTimeValues = "gmtime";

EOF

cat $staticTWikiCfg >> $out/lib/TWiki.cfg


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

