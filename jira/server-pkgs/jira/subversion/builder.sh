set -e

. $stdenv/setup

unzip $src
mkdir $out
mv atlassian-jira-subversion-plugin*/* $out

