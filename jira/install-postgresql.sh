#! /bin/sh

nix-env -i -p /nix/var/nix/profiles/jira-server -f postgresql-instance.nix postgresql-cluster
