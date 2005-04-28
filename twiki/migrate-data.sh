#! /bin/sh

old=$1
new=$2

for source in `find $old/data/* -type d -and -not -name TWiki`
do
  target="$new/data/`basename $source`"
  echo "Copying files from $source to $target"
  mkdir -p $target
  for file in `find $source/* -type f`
  do 
     cp -r --reply=yes $file $target
  done
  cp $source/.changes $source/.mailnotify $target
  if test -f $target/WebContents.txt
  then
    mv $target/WebContents.txt   $target/WebLeftBar.txt
    mv $target/WebContents.txt,v $target/WebLeftBar.txt,v
  fi
done

echo "Copying password file ..."
cp -r --reply=yes $old/data/TWiki/CustomSiteMenus* $new/data/TWiki/

echo "Copying password file ..."
cp --reply=yes $old/data/.htpasswd $new/data/

echo "Copying log files ..."
cp --reply=yes $old/data/log* $new/data/

echo "Touching default web topics ..."
for dir in `find $new/data -type d`
do
  touch $dir/WebCustomMenus.txt $dir/WebNews.txt
done

echo "Patching RCS locks ..."
for file in `find $new/data -name \*.txt,v`
do
  sed "s/www:/nobody:/;s/apache:/nobody:/" < $file > $file.copy
  chmod +w $file
  mv $file.copy $file
done

echo "Copying pub/ ..."
cp -r --reply=yes $old/pub/* $new/pub/
