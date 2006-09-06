#! /bin/sh -e

serverName=$1
type=$2
generation=$3
if test "$type" != "test" -a "$type" != "production" -o -z "$generation"; then
    echo "syntax: $0 NAME {test | production} GENERATION-NUMBER"
    exit 1
fi

profiles=/nix/var/nix/profiles
profileName=$serverName-$type-server


echo "stopping current server..."
$profiles/$profileName/bin/control stop || true
sleep 5


echo "rolling back..."
nix-env --profile "$profiles/$profileName" --switch-generation "$generation" 


echo "starting old server..."
$profiles/$profileName/bin/control start
