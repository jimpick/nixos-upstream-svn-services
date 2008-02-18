cp $plugin/lib/*.jar webapp/WEB-INF/lib

# TODO: this should really be described in Nix
cat > edit-webapp/WEB-INF/classes/subversion-jira-plugin.properties <<EOF
svn.root=https://svn.cs.uu.nl:12443/repos/StrategoXT/
svn.root.1=https://svn.cs.uu.nl:12443/repos/trace/

svn.display.name=Stratego/XT Repository
svn.display.name.1=TraCE Repository

linkformat.changeset=https://svn.cs.uu.nl:12443/viewvc/StrategoXT?view=rev&rev=\${rev}
linkformat.changeset.1=https://svn.cs.uu.nl:12443/viewvc/trace?view=rev&rev=\${rev}

linkformat.file.added=https://svn.cs.uu.nl:12443/viewvc/StrategoXT/\${path}/?rev=\${rev}&view=markup
linkformat.file.added.1=https://svn.cs.uu.nl:12443/viewvc/trace/\${path}/?rev=\${rev}&view=markup

linkformat.file.modified=https://svn.cs.uu.nl:12443/viewvc/StrategoXT/\${path}/?rev=\${rev}&view=diff&r1=\${rev}&r2=\${rev-1}&p1=\${path}&p2=\${path}
linkformat.file.modified.1=https://svn.cs.uu.nl:12443/viewvc/trace/\${path}/?rev=\${rev}&view=diff&r1=\${rev}&r2=\${rev-1}&p1=\${path}&p2=\${path}

linkformat.file.replaced=https://svn.cs.uu.nl:12443/viewvc/StrategoXT/\${path}/?rev=\${rev}&view=markup
linkformat.file.replaced.1=https://svn.cs.uu.nl:12443/viewvc/trace/\${path}/?rev=\${rev}&view=markup

linkformat.file.deleted=https://svn.cs.uu.nl:12443/viewvc/StrategoXT/\${path}/?rev=\${rev-1}&view=markup
linkformat.file.deleted.1=https://svn.cs.uu.nl:12443/viewvc/trace/\${path}/?rev=\${rev-1}&view=markup

linkformat.copyfrom=https://svn.cs.uu.nl:12443/viewvc/StrategoXT/\${path}?rev=\${rev-1}&view=markup
linkformat.copyfrom.1=https://svn.cs.uu.nl:12443/viewvc/trace/\${path}?rev=\${rev-1}&view=markup

revision.indexing=true
revision.cache.size=10000
EOF
