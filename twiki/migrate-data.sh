#! /bin/sh

old=$1
new=$2

for source in `find $old/data/* -type d -and -not -name TWiki`
do
  target="$new/data/`basename $source`"
  echo "Copying files from $source to $target"
  mkdir -p $target
  for file in $source/*
  do 
     cp -r --reply=yes $file $target
  done
  mv $target/WebContents.txt   $target/WebLeftBar.txt
  mv $target/WebContents.txt,v $target/WebLeftBar.txt,v
done

cp -r --reply=yes $old/data/TWiki/CustomSiteMenus* $new/data/TWiki/

cp -r --reply=yes $old/pub/* $new/pub/

cp --reply=yes $old/data/.htpasswd $new/data/

echo "Patching RCS locks ..."
for file in `find $new/data -name \*.txt,v`
do
  sed "s/www:/nobody:/;s/apache:/nobody:/" < $file > $file.copy
  chmod +w $file
  mv $file.copy $file
done

echo "Touching default web topics ..."
for dir in `find $new/data -type d`
do
  touch $dir/WebCustomMenus.txt $dir/WebNews.txt
done
