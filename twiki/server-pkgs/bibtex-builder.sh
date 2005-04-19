. $stdenv/setup
echo PERL=$perl

$unzip/bin/unzip $src

mkdir $out
mv * $out/

# substitute perl location in BP perl script
${perl}/bin/perl -i -p -e "s@/usr/bin/perl@$perl/bin/perl@" ${out}/bp/bin/conv.pl

# subsitute BP location in BibTex plugin
${perl}/bin/perl -i -p -e "s@__bpdir__@${out}/bp@" ${out}/lib/TWiki/Plugins/BibTexPlugin.pm
