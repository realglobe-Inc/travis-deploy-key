#!/bin/bash
#
# Installation script for travis-deploy-key

curl -s https://raw.githubusercontent.com/realglobe-Inc/travis-deploy-key/master/travis-deploy-key.sh > travis-deploy-key
chmod +x travis-deploy-key

cat <<-EOM

travis-deploy-key has been downloaded to the current directory. You can run it with:

./travis-deploy-key

EOM