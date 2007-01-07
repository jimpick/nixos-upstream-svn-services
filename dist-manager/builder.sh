source $stdenv/setup


doSub() {
    local src=$1
    local dst=$2
    ensureDir $(dirname $dst)
    substituteAll $src $dst
}


export defaultPath=
for i in ls tar gzip bzip2 diff sed find; do
    defaultPath="$defaultPath:$(dirname $(type -tP $i))"
done


serviceDir=$out/types/apache-httpd
ensureDir $serviceDir


doSub "$conf" "$serviceDir/conf/httpd.conf"
        
subDir=/
for i in $scripts; do
    if test "$(echo $i | cut -c1-2)" = "=>"; then
        subDir=$(echo $i | cut -c3-)
    else
        dst=$out/$subDir/$((stripHash $i; echo $strippedName) | sed 's/\.in//')
        doSub "$i" "$dst"
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
