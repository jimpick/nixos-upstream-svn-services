source $stdenv/setup

ensureDir $out/types/apache-httpd/conf
cat > $out/types/apache-httpd/conf/static-files.conf <<EOF
Alias $urlPath $directory/

<Directory $directory>
   Order allow,deny
   Allow from all
   AllowOverride None
</Directory>
EOF
