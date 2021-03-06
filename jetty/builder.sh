. $stdenv/setup

ensureDir $out/bin
ensureDir $out/etc

cat >> $out/bin/control <<EOF
#! $SHELL

export CLASSPATH=
export JETTY_HOME=$jetty
export JAVA_HOME=$j2re
export LANG="en_US"

logfile=$logDir/jetty-\`date +"%Y-%m-%d-%H-%M-%S"\`

mkdir -p \$(dirname \$logfile)

if test "\$1" = start; then

    \$JAVA_HOME/bin/java -Xms$initHeapSize -Xmx$maxHeapSize -server \
        -DSTOP.PORT=$stopport -Djetty.home=\$JETTY_HOME \
        -jar \$JETTY_HOME/start.jar $out/etc/server.xml >>\$logfile 2>&1 &

elif test "\$1" = stop; then

    \$JAVA_HOME/bin/java -DSTOP.PORT=$stopport -Djetty.home=\$JETTY_HOME \
        -jar \$JETTY_HOME/stop.jar

fi

EOF

chmod a+x $out/bin/control

cat >> $out/etc/server.xml <<EOF
<?xml version="1.0"?>
<!DOCTYPE Configure PUBLIC "-//Mort Bay Consulting//DTD Configure 1.2//EN" "http://jetty.mortbay.org/configure_1_2.dtd">

<Configure class="org.mortbay.jetty.Server">
  <Call name="addListener">
    <Arg>
EOF

if test "$sslSupport"; then
cat >> $out/etc/server.xml <<EOF
      <New class="org.mortbay.http.SunJsseListener">
        <Set name="Port">$port</Set>
        <Set name="Keystore">$store</Set>
        <Set name="Password">$storepass</Set>
        <Set name="KeyPassword">$keypass</Set>
      </New>
EOF
else
cat >> $out/etc/server.xml <<EOF
      <New class="org.mortbay.http.SocketListener">
        <Set name="Port">$port</Set>
      </New>
EOF
fi

cat >> $out/etc/server.xml <<EOF
    </Arg>
  </Call>
EOF

i=0
for p in $paths
do
  path[i]=$p
  i=`expr $i + 1`
done

i=0
for w in $wars
do
  war[i]=$w
  i=`expr $i + 1`
done

echo "number of paths: ${#path[*]}"
echo "number of wars: ${#war[*]}"

i=0
while [ "$i" -lt "${#war[*]}" ]
do
cat >> $out/etc/server.xml <<EOF
  <Call name="addWebApplication">
    <Arg>${path[i]}</Arg>
    <Arg>${war[i]}</Arg>

    <Set name="extractWAR">true</Set>
    <Set name="defaultsDescriptor">org/mortbay/jetty/servlet/webdefault.xml</Set>
  </Call>
EOF
  i=`expr $i + 1`
done

cat >> $out/etc/server.xml <<EOF
  <Set name="statsOn">false</Set>
</Configure>
EOF


