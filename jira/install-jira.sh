#! /bin/sh

mkdir -p ./server-profiles
nix-env -i -p ./server-profiles/profile -f jira-instance.nix jira-instance
nix-env -i -p ./server-profiles/profile -f jira-instance.nix jetty-instance
