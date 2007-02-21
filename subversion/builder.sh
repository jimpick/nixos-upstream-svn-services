. $stdenv/setup


doSub() {
    local src=$1
    local dst=$2
    ensureDir $(dirname $dst)
    substituteAll $src $dst
}


defaultPath="$enscript/bin"
for i in ls tar gzip bzip2 diff sed; do
    defaultPath="$defaultPath:$(dirname $(type -tP $i))"
done


serviceDir=$out/types/apache-httpd
ensureDir $serviceDir


doSub $conf $serviceDir/conf/subversion.conf
doSub $confPre $serviceDir/conf-pre/subversion.conf

orgLogoUrl=$((stripHash $orgLogoFile; echo $strippedName)

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
