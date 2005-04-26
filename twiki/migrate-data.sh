#! /bin/sh

old=$1
new=$2

for dir in `find $old/data/* -type d -and -not -name TWiki`
do
  echo "Copying files from $dir"
  mkdir -p $new/data/`basename $dir`
  cp -r --reply=yes $dir/ $new/data/`basename $dir`
  mv $new/data/`basename $dir`/WebContents.txt $new/data/`basename $dir`/WebLeftBar.txt
  mv $new/data/`basename $dir`/WebContents.txt,v $new/data/`basename $dir`/WebLeftBar.txt,v
done

cp -r --reply=yes $old/data/TWiki/CustomSiteMenus* $new/data/TWiki/

cp -r --reply=yes $old/pub/* $new/pub/

cp --reply=yes $old/data/.htpasswd $new/data/

