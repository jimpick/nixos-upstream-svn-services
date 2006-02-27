#! /bin/sh -ex

#PATH=@defaultPath@:@libxslt@/bin

src="$1"
out="$2"
baseURL="$3"

mkdir -p $out

cp success.gif $out
cp failure.gif $out
cp menuback.png $out
chmod 644 $out/*.gif $out/*.png

xsltproc -o $out/index.html main-index.xsl $src 
xsltproc --stringparam out "$out" full-indices-per-package.xsl $src

xsltproc -o $out/quick-view.html quick-view.xsl $src 
xsltproc --stringparam sortByDate 1 -o $out/quick-view-by-date.html quick-view.xsl $src 
xsltproc --stringparam out "$out" full-status-per-package.xsl $src

xsltproc --stringparam baseURL "$baseURL" --stringparam sortByDate 1 \
    -o $out/index.rss rss-feed.xsl $src

