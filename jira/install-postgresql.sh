#! /bin/sh

mkdir -p ./server-profiles
nix-env -i -p ./server-profiles/profile -f postgresql-instance.nix postgresql-cluster
