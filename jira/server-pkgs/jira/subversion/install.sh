
cp $plugin/lib/atlassian-jira-subversion-plugin-*.jar webapp/WEB-INF/lib
cp $plugin/lib/javasvn-*.jar webapp/WEB-INF/lib
cp $plugin/lib/jsch-*.jar webapp/WEB-INF/lib

cat > edit-webapp/WEB-INF/classes/subversion-jira-plugin.properties <<EOF
svn.root=https://svn.cs.uu.nl:12443/repos/StrategoXT/
#----------------------------------------
# REVISION INDEXING
#----------------------------------------
# if this property is uncommented and set to true, every revision in Subversion will be indexed
# and linked to any mentioned issue keys
revision.indexing=true

# the number of revisions to keep cached in memory for quick retrieval
# note: this number does not affect the speed with which revisions are looked up from the index (to get revisions for a given issue)
# this affects the speed at which the full content of those revisions are retrieved from SVN.
revision.cache.size=10000

#----------------------------------------
# WEB LINKING
#----------------------------------------
# If you specify the URL of your ViewCVS server, JIRA will hyperlink file entries, change lists and jobs to it.
viewcvs.url=https://svn.cs.uu.nl:12443/viewcvs/StrategoXT/
EOF
