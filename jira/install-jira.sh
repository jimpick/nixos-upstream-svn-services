#! /bin/sh -e

nix-env -i -p /nix/var/nix/profiles/jira-server -f jira-instance.nix jira-instance
nix-env -i -p /nix/var/nix/profiles/jira-server -f jira-instance.nix jetty-instance
