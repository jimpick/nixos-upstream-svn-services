#! /bin/sh -e

set -x

type=$1
if test "$type" != "test" -a "$type" != "production"; then
    echo "syntax: $0 {test | production}"
    exit 1
fi

profiles=/nix/var/nix/profiles
profileName=svn-$type-server

if test "$type" = "test"; then
    isProduction=false
else
    isProduction=true
fi

# Build and install the new server.
oldServer=$(readlink -f $profiles/$profileName || true)

echo "building new server..."
nix-env -K -p $profiles/$profileName -f ./svn-server-conf.nix \
    -i -E "f: f {productionServer = $isProduction;}"

# Stop the old server.
if test -n "$oldServer"; then
    echo "stopping old server..."
    $oldServer/bin/ctl -k stop || true
fi

# Start the new server.
echo "starting new server..."
$profiles/$profileName/bin/ctl -k start
