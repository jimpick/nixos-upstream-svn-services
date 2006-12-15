#! /bin/sh -e

serverName=$1
nixExpr=$2
type=$3
if test "$type" != "test" -a "$type" != "production"; then
    echo "syntax: $0 NAME NIX-EXPR {test | production}"
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
    --set --arg productionServer "$isProduction" \*

# Stop the old server.
if test -n "$oldServer"; then
    echo "stopping old server..."
    $oldServer/bin/control stop || true
    sleep 2 # Hack!
fi

# Start the new server.
echo "starting new server..."
$profiles/$profileName/bin/control start
