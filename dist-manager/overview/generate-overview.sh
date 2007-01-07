#! /bin/sh -ex

PATH=@defaultPath@:@saxon8@/bin

src="$1"
out="$2"
baseURL="$3"

mkdir -p $out

cp success.gif $out
cp failure.gif $out
cp menuback.png $out
chmod 644 $out/*.gif $out/*.png

saxon8 -o $out/index.html $src main-index.xsl
saxon8 $src full-indices-per-package.xsl out="$out"

saxon8 -o $out/quick-view.html $src quick-view.xsl
saxon8 -o $out/quick-view-by-date.html $src quick-view.xsl sortByDate=1
saxon8 $src full-status-per-package.xsl out="$out"

saxon8 -o $out/index.rss $src rss-feed.xsl \
    baseURL="$baseURL" sortByDate=1
