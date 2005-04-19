. $stdenv/setup
. $substituter


doSub() {
    local src=$1
    local dst=$2
    ensureDir $(dirname $dst)
    substitute $src $dst \
        --subst-var out \
        --subst-var hostName \
        --subst-var httpPort \
        --subst-var httpsPort \
        --subst-var defaultPort \
        --subst-var adminAddr  \
        --subst-var logDir \
        --subst-var stateDir \
        --subst-var apacheHttpd \
        --subst-var SHELL \
        --subst-var defaultPath \
        --subst-var enableSSL \
        --subst-var sslServerCert \
        --subst-var sslServerKey \
        # end
}


#doSub $conf $out/conf/httpd.conf
        
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
for i in $substFiles; do
    if test "$(echo $i | cut -c1-2)" = "=>"; then
        subDir=$(echo $i | cut -c3-)
    else
        dst=$out/$subDir/$((stripHash $i; echo $strippedName) | sed 's/\.in//')
        doSub $i $dst
    fi
done

ln -s $out/conf/httpd-basics.conf $out/conf/httpd.conf

ensureDir $out/root
