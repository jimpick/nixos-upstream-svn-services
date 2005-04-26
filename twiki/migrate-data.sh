#! /bin/sh

old=$1
new=$2

for source in `find $old/data/* -type d -and -not -name TWiki`
do
  target=$new/data/`basename $dir`
  echo "Copying files from $source to $target"
  mkdir -p $target
  cp -r --reply=yes $source/* $target
  mv $target/WebContents.txt   $target/WebLeftBar.txt
  mv $target/WebContents.txt,v $target/WebLeftBar.txt,v
done

cp -r --reply=yes $old/data/TWiki/CustomSiteMenus* $new/data/TWiki/

cp -r --reply=yes $old/pub/* $new/pub/

cp --reply=yes $old/data/.htpasswd $new/data/

