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
        --subst-var logDir \
        --subst-var reposDir \
        --subst-var dbDir \
        --subst-var distsDir \
        --subst-var tmpDir \
        --subst-var backupsDir \
        --subst-var apacheHttpd \
        --subst-var mod_python \
        --subst-var authModules \
        --subst-var viewcvs \
        --subst-var db4 \
        --subst-var libxslt \
        --subst-var subversion \
        --subst-var SHELL \
        --subst-var-by perl "$perl/bin/perl" \
        --subst-var-by perlFlags "-I$perlBerkeleyDB/lib/site_perl" \
        --subst-var defaultPath \
	--subst-var fsType \
	--subst-var autoVersioning \
        # end
}


defaultPath="$enscript/bin"
for i in ls tar gzip bzip2 diff sed; do
    defaultPath="$defaultPath:$(dirname $(type -tP $i))"
done


serviceDir=$out/types/apache-httpd
ensureDir $serviceDir


doSub $conf $serviceDir/conf/subversion.conf
doSub $confPre $serviceDir/conf-pre/subversion.conf
        
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

# !!! hack
ln -s $out/hooks/post-commit $out/bin/post-commit-hook

# mod_python's own Python modules must be in the initial Python path,
# they cannot be set through the PythonPath directive.
echo "PYTHONPATH=$mod_python/lib/python2.4/site-packages" > $serviceDir/extra-env
