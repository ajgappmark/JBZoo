#!/usr/bin/env sh

echo ""
echo ">>> >>> PHPUnit Joomla"
sh ./bin/phpunit   --configuration ./phpunit-joomla.xml.dist

echo ""
echo ">>> >>> PHPUnit Wordpress"
sh ./bin/phpunit   --configuration ./phpunit-wordpress.xml.dist

echo ""
echo ">>> >>> PHPUnit Utility"
sh ./bin/phpunit   --configuration ./phpunit-utility.xml.dist      ./tests/unit/utility/CodeStyleTest.php

echo ""
echo ">>> >>> PHP Statistics"
sh ./bin/phpmd  ./src/jbzoo                         \
    text                                            \
    ./src/jbzoo/vendor/jbzoo/misc/phpmd/jbzoo.xml   \
    --verbose

echo ">>> >>> PHP Code Style"
sh ./bin/phpcs  ./src/jbzoo                                             \
    --extensions=php                                                    \
    --standard=./src/jbzoo/vendor/jbzoo/misc/phpcs/JBZoo/ruleset.xml    \
    --report=full

echo ">>> >>> PHP Copy&Paste"
sh ./bin/phpcpd ./src/jbzoo

echo ">>> >>> PHP loc"
sh ./bin/phploc ./src/jbzoo --verbose
