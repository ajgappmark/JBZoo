#!/usr/bin/env sh

echo ""
echo ">>> >>> Update PHP libs"
composer config bin-dir     "../../bin"     --working-dir=./src/jbzoo
composer config vendor-dir  "vendor"        --working-dir=./src/jbzoo
composer update                             --working-dir=./src/jbzoo


echo ""
echo ">>> >>> Update JS libs"
NODE_ENV=development npm install

NODE_ENV=development ./node_modules/.bin/bower update

NODE_ENV=development ./node_modules/.bin/gulp update

NODE_ENV=development ./node_modules/.bin/webpack    \
     --watch-aggregate-timeout=100                  \
    --watch                                         \
    --progress                                      \
    --colors