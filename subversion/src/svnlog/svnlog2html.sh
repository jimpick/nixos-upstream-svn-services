#! /bin/sh -e

repos="$1"
path="$2"

function doyear() {
  month="12" transform
  month="11" transform
  month="10" transform
  month="09" transform
  month="08" transform
  month="07" transform
  month="06" transform
  month="05" transform
  month="04" transform
  month="03" transform
  month="02" transform
  month="01" transform
}

function transform() {
  xsltproc -o ${year}-${month}.html \
        --param year ${year} \
        --param month ${month} \
        --stringparam repos "${repos}" \
        --stringparam path "${path}" \
    svnlog2html.xsl log.xml
}

svn log -v --xml https://svn.cs.uu.nl:12443/repos/${repos}/${path} > log.xml

xsltproc -o index.html svnlog2index.xsl log.xml

year="2004" doyear
year="2003" doyear
year="2002" doyear
year="2001" doyear
year="2000" doyear
year="1999" doyear
