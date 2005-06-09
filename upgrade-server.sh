#! /bin/sh -e

serverName=$1
nixExpr=$2
type=$3
if test "$type" != "test" -a "$type" != "production"; then
    echo "syntax: $0 TYPE NIX-EXPR {test | production}"
    exit 1
fi

profiles=/nix/var/nix/profiles
profileName=$serverName-$type-server

if test "$type" = "test"; then
    isProduction=false
else
    isProduction=true
fi

# Build and install the new server.
oldServer=$(readlink -f $profiles/$profileName || true)

echo "building new server..."
nix-env -K -p $profiles/$profileName -f "$nixExpr" \
    -i -E "f: f {productionServer = $isProduction;}"

echo "creating start and stop scripts"
cat > start-$profileName <<EOF
#! /bin/sh
$profiles/$profileName/bin/control start
EOF
chmod +x start-$profileName

cat > stop-$profileName <<EOF
#! /bin/sh
$profiles/$profileName/bin/control stop
EOF
chmod +x stop-$profileName

# Stop the old server.
if test -n "$oldServer"; then
    echo "stopping old server..."
    $oldServer/bin/control stop || true
fi

# Start the new server.
echo "starting new server..."
$profiles/$profileName/bin/control start
