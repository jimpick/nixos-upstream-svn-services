#! @shell@ -ex

PATH=@defaultPath@:@libxslt@/bin

src=$1
out=$2

mkdir -p $out
xsltproc -o $out/latest100.xhtml releases2latest100.xsl $src 
xsltproc -o $out/latest.xhtml releases-of-packages.xsl $src 
xsltproc -o $out/overviews.xhtml overviews.xsl $src 
xsltproc --param out \'$out\' releases-for-each-package.xsl $src

cp success.gif $out
cp failure.gif $out
cp menuback.png $out
chmod 644 $out/*.gif $out/*.png
