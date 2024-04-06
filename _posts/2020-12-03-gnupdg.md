---
title: GnuPG
date: 2020-12-03
---

<!--more-->

## installation

start by `brew install gpg2` and after that's done install `brew install --cask gpg-suite-pinentry pinentry-mac`

next up just add the pinentry to gnupg config `echo "pinentry-program $(which pinentry-mac)" > ~/.gnupg/gpg-agent.conf`

## keybase import

first import the public key `keybase pgp export | gpg --import`

after that the private key `keybase pgp export -s | gpg --allow-secret-key-import --import`
