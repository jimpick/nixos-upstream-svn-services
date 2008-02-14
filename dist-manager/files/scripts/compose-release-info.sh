#! @shell@ -e

PATH=@defaultPath@

dir=$1
out=$2
depth=$3
depth=$(($depth + 1))

cat > $out <<EOF
<?xml version="1.0"?>
<releases>
EOF

find $dir \( -name "tmp-*" -prune \) -o \( -name release-info.xml -maxdepth $depth -print \) \
    | xargs cat >> $out

cat >> $out <<EOF
</releases>
EOF
