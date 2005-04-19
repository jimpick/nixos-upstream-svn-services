#! /bin/sh

mkdir -p ${TWIKI_HOME}/st/profiles
nix-env -i -p ${TWIKI_HOME}/st/profiles/current -f ${TWIKIS} st-wiki

mkdir -p ${TWIKI_HOME}/st-intra/profiles
nix-env -i -p ${TWIKI_HOME}/st-intra/profiles/current -f ${TWIKIS} st-intra-wiki

mkdir -p ${TWIKI_HOME}/pt/profiles
nix-env -i -p ${TWIKI_HOME}/pt/profiles/current -f ${TWIKIS} pt-wiki
