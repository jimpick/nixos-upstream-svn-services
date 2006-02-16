#! /bin/sh -ex

PATH=@defaultPath@:@libxslt@/bin

src=$1
out=$2

mkdir -p $out

xsltproc -o $out/index.html main-index.xsl $src 
xsltproc --param out \'$out\' full-indices-per-package.xsl $src

xsltproc -o $out/quick-view.html quick-view.xsl $src 
xsltproc --param sortByDate 1 -o $out/quick-view-by-date.html quick-view.xsl $src 
xsltproc --param out \'$out\' full-status-per-package.xsl $src

cp success.gif $out
cp failure.gif $out
cp menuback.png $out
chmod 644 $out/*.gif $out/*.png
