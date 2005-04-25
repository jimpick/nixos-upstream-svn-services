PATH=$PATH:@initialPath@

if test -d @datadir@; then
  echo "Datadir @datadir@ exists. Adding new files ..."
  cp -R -i --reply=no @out@/init/data/* @datadir@/
else
  echo "Copying fresh TWiki data to datadir ..."
  mkdir -p @datadir@
  cp -R @out@/init/data/* @datadir@/
fi

echo "Setting permissions, owner and group of datadir ... "
find @datadir@ -type f | xargs -i chmod 664 "{}"
find @datadir@ -type d | xargs chmod 775

if test -n "@user@" -a -n "@group@"; then
    find @datadir@ | xargs -i chown @user@ "{}"
    find @datadir@ | xargs -i chgrp @group@ "{}"
fi    

if test -d @pubdir@; then
  echo "Pubdir @pubdir@ exists. Adding new files ..."
  cp -R -i --reply=no @out@/init/pub/* @pubdir@/
else
  echo "Copying fresh TWiki pub files to pubdir ..."  
  mkdir -p @pubdir@
  cp -R @out@/init/pub/* @pubdir@/
fi

echo "Setting permissions and owner of pubdir ... "
find @pubdir@ -type f | xargs -i chmod 664 "{}"
find @pubdir@ -type d | xargs -i chmod 775 "{}"

for skin in @skins@
do
  cp -R $skin/pub/* @pubdir@
done

echo "Setting plugins: @plugins@"
for plugin in @plugins@
do
  cp -R $plugin/data/* @datadir@
done

echo "Setting permissions and owner of pubdir ... "
find @pubdir@ -type f | xargs -i chmod 664 "{}"
find @pubdir@ -type d | xargs -i chmod 775 "{}"
if test -n "@user@" -a -n "@group@"; then
    find @pubdir@ -type d | xargs -i chown @user@ "{}"
    find @pubdir@ -type d | xargs -i chgrp @group@ "{}"
fi    

echo "Installing htaccess files ..."
cp @out@/init/subdir-htaccess.txt @datadir@/.htaccess # !!! hacky
