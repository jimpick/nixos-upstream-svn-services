. $stdenv/setup

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

if test -d $datadir; then
  echo "Datadir $datadir exists. Adding new files ..."
  cp -R -i --reply=no twiki/data/* $datadir/
else
  echo "Copying fresh TWiki data to datadir ..."  
  mv twiki/data $datadir
fi

echo "Setting permissions, owner and group of datadir ... "
find $datadir -type f | xargs -i chmod 664 "{}"
find $datadir -type d | xargs chmod 775

find $datadir | xargs -i chown $user "{}"
find $datadir | xargs -i chgrp $group "{}"

if test -d $pubdir; then
  echo "Pubdir $pubdir exists. Adding new files ..."
  cp -R -i --reply=no twiki/pub/* $pubdir/
else
  echo "Copying fresh TWiki pub files to pubdir ..."  
  mv twiki/pub $pubdir
fi

echo "Setting permissions and owner of pubdir ... "
find $pubdir -type f | xargs -i chmod 664 "{}"

for skin in $skins
do
  cp -R $skin/pub/* $pubdir
  cp -R $skin/templates/* $out/templates
done

echo "Setting plugins: $plugins"
for plugin in $plugins
do
  cp -R $plugin/bp* $out
  cp -R $plugin/data/* $datadir
  cp -R $plugin/lib $out
done

echo "Setting permissions and owner of pubdir ... "
find $pubdir -type f | xargs -i chmod 664 "{}"
find $pubdir -type d | xargs -i chmod 775 "{}"
find $pubdir -type d | xargs -i chown $user "{}"
find $pubdir -type d | xargs -i chgrp $group "{}"

# todo: testenv script should be removed if this is a production server.
echo "Removing unnecessary scripts ..."


# todo: scripts should refer to a Nix Perl if we are going to deploy the entire
# Wiki and its dependencies with Nix.

echo "Installing htaccess files ..."
cp ./twiki/subdir-htaccess.txt $datadir/.htaccess
cp ./twiki/subdir-htaccess.txt $out/lib/.htaccess
cp ./twiki/subdir-htaccess.txt $out/templates/.htaccess

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
cat $binHtaccess >> $out/bin/.htaccess

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
\$pubUrlPath        = "$pubUrlPath";
\$pubDir            = "$pubdir";
\$templateDir       = "$twikiroot/templates";
\$dataDir           = "$datadir";
\$logDir            = "$datadir";

\$OS                = 'UNIX';
\$scriptSuffix      = "";
\$uploadFilter      = "^(\.htaccess|.*\.(?:php[0-9s]?|phtm[l]?|pl|py|cgi))\\$";
\$safeEnvPath       = "/bin:/usr/bin";
# this option will not be used: Net::SMTP is preferred.
\$mailProgram       = "/usr/sbin/sendmail -t -oi -oeq";
\$noSpamPadding     = "";
\$mimeTypesFilename = "\$dataDir/mime.types";

\$rcsDir            = '$rcs/bin';
\$rcsArg            = "";
\$nullDev           = '/dev/null';
\$useRcsDir         = "0";
\$endRcsCmd         = " 2>&1";
\$cmdQuote          = "'";
\$storeTopicImpl    = "RcsWrap"; 
\$lsCmd             = "/bin/ls";
\$egrepCmd          = "$grep/bin/egrep";
\$fgrepCmd          = "$grep/bin/fgrep";
\$displayTimeValues = "gmtime";

EOF

cat $staticTWikiCfg >> $out/lib/TWiki.cfg

echo "Creating Apache httpd.conf helper ..."

cat > $out/example-httpd.conf <<EOF
ScriptAlias $scriptUrlPath "$twikiroot/bin"
Alias $pubUrlPath "$pubdir"

<Directory "$twikiroot/bin">
   Options +ExecCGI
   SetHandler cgi-script
   AllowOverride All
   Allow from all
</Directory>
<Directory "$twikiroot/templates">
   deny from all
</Directory>
<Directory "$twikiroot/lib">
   deny from all
</Directory>
<Directory "$pubdir">
   Options FollowSymLinks +Includes
   AllowOverride None
   Allow from all
</Directory>
<Directory "$datadir">
   deny from all
</Directory>
EOF


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
