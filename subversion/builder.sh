. $stdenv/setup
. $substituter


doSub() {
    local src=$1
    local dst=$2
    ensureDir $(dirname $dst)
    substitute $src $dst \
        --subst-var hostName \
        --subst-var httpPort \
        --subst-var httpsPort \
        --subst-var defaultPort \
        --subst-var-by ADMIN "$admin" \
        --subst-var-by NSENDER "$notificationSender" \
        --subst-var-by PREFIX "$out" \
        --subst-var-by LOGS "$dataDir/$logsSuffix" \
        --subst-var-by REPOS "$dataDir/repos" \
        --subst-var-by REPODB "$dataDir/db" \
        --subst-var-by distsDir "$dataDir/dist" \
        --subst-var-by tmpDir "$tmpDir" \
        --subst-var-by backupsDir "$dataDir/backup" \
        --subst-var-by APACHE "$apacheHttpd" \
        --subst-var authModules \
        --subst-var viewcvs \
        --subst-var db4 \
        --subst-var libxslt \
        --subst-var-by SVN "$subversion" \
        --subst-var-by SHELL "$SHELL" \
        --subst-var-by DEFAULTPATH "$coreutils/bin:$gnutar/bin:$gzip/bin:$bzip2/bin:$diffutils/bin:$enscript/bin:$gnused/bin" \
        --subst-var-by PERL "$perl/bin/perl" \
        --subst-var-by PERLFLAGS "-I$perlBerkeleyDB/lib/site_perl" \
        --subst-var enableSSL \
        --subst-var sslServerCert \
        --subst-var sslServerKey \
        # end
}


doSub $conf $out/conf/httpd.conf
        
subDir=/
for i in $scripts; do
    if test "$(echo $i | cut -c1-2)" = "=>"; then
        subDir=$(echo $i | cut -c3-)
    else
        dst=$out/$subDir/$((stripHash $i; echo $strippedName) | sed 's/\.in//')
        doSub $i $dst
        chmod +x $dst # !!!
    fi
done

subDir=/
for i in $staticPages; do
    if test "$(echo $i | cut -c1-2)" = "=>"; then
        subDir=$(echo $i | cut -c3-)
    else
        ensureDir $out/root/$subDir/
        cp $i $out/root/$subDir/$(stripHash $i; echo $strippedName)
    fi
done
