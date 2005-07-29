#! @shell@ -e

PATH=@defaultPath@

dir=$1
out=$2

cat > $out <<EOF
<?xml version="1.0"?>
<releases>
EOF

find $dir/ -name release-info.xml -mindepth 2 -maxdepth 2 \
    | xargs cat >> $out

cat >> $out <<EOF
</releases>
EOF
