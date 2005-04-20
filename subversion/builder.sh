. $stdenv/setup
. $substituter


doSub() {
    local src=$1
    local dst=$2
    ensureDir $(dirname $dst)
    substitute $src $dst \
        --subst-var out \
        --subst-var canonicalName \
        --subst-var adminAddr \
        --subst-var notificationSender \
        --subst-var reposDir \
        --subst-var dbDir \
        --subst-var distsDir \
        --subst-var tmpDir \
        --subst-var backupsDir \
        --subst-var apacheHttpd \
        --subst-var authModules \
        --subst-var viewcvs \
        --subst-var db4 \
        --subst-var libxslt \
        --subst-var-by SVN "$subversion" \
        --subst-var-by SHELL "$SHELL" \
        --subst-var-by PERL "$perl/bin/perl" \
        --subst-var-by PERLFLAGS "-I$perlBerkeleyDB/lib/site_perl" \
        # end

#        --subst-var-by DEFAULTPATH "$coreutils/bin:$gnutar/bin:$gzip/bin:$bzip2/bin:$diffutils/bin:$enscript/bin:$gnused/bin" \
}


serviceDir=$out/types/apache-httpd
ensureDir $serviceDir


doSub $conf $serviceDir/conf/subversion.conf
        
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
        ensureDir $out/$subDir/
        cp $i $out/$subDir/$(stripHash $i; echo $strippedName)
    fi
done
