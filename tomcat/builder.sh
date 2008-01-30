set -e

source $stdenv/setup

mkdir -p $out/bin

cat > $out/bin/control <<EOF
export PATH=$PATH:$su/bin

start()
{
  su $user -s /bin/sh -c "JAVA_HOME=$jdk CATALINA_BASE=$baseDir $tomcat6/bin/startup.sh"
}

stop()
{
  su $user -s /bin/sh -c "$tomcat6/bin/shutdown.sh"
}

if test "\$1" = start
then
  trap stop 15
  
  if ! test "$deployFrom" = ""
  then
    rm -rf $baseDir/webapps
    mkdir -p $baseDir/webapps
    for i in $deployFrom/*
    do
      ln -s \$i $baseDir/webapps/\`basename \$i\`
    done
    
    chown -R $user $baseDir
  else
    mkdir -p $baseDir/webapps
  fi
    
  start
elif test "\$1" = stop
then
  stop  
elif test "\$1" = init
then
  echo "Are you sure you want to create a new server instance (old server instance will be lost!)?"
  read answer

  if ! test \$answer = "yes"
  then
    exit 1
  fi
  
  rm -rf $baseDir
  mkdir -p $baseDir
  cp -av $tomcat6/{conf,temp,logs} $baseDir
  
  # Make files accessible for the server user
  
  chown -R $user $baseDir
  
  for i in \`find $baseDir -type d\`
  do
    chmod 755 \$i
  done
  for i in \`find $baseDir -type f\`
  do
    chmod 644 \$i
  done
fi
EOF

chmod +x $out/bin/*
