#
# JBZoo CCK
#
# This file is part of the JBZoo CCK package.
# For the full copyright and license information, please view the LICENSE
# file that was distributed with this source code.
#
# @package   CCK
# @license   Proprietary http://jbzoo.com/license
# @copyright Copyright (C) JBZoo.com,  All rights reserved.
# @link      http://jbzoo.com
#

.PHONY: build gulp logs tests tmp

#### Complex commands ##################################################################################################

build:
	@echo -e "\033[0;33m>>> >>> >>> >>> >>> >>> >>> >>> \033[0;30;46m Cleanup project & Rebuild ALL! \033[0m"
	@make clean
	@make update
	@make prepare-fs
	@make pack
	@make prepare-cms

update:
	@echo -e "\033[0;33m>>> >>> >>> >>> >>> >>> >>> >>> \033[0;30;46m Update Project for Developing \033[0m"
	@make update-composer
	@make update-npm
	@make update-bower
	@make update-gulp
	@make update-webpack

prepare-cms:
	@echo -e "\033[0;33m>>> >>> >>> >>> >>> >>> >>> >>> \033[0;30;46m Install & prepare all CMS \033[0m"
	@make prepare-joomla
	@make prepare-wordpress

prepare-fs:
	@make prepare-fs-build
	@make prepare-fs-joomla
	@make prepare-fs-wordpress

test:
	@echo -e "\033[0;33m>>> >>> >>> >>> >>> >>> >>> >>> \033[0;30;46m Run unit tests \033[0m"
	@make test-joomla
	@make test-wordpress
	@make test-codestyle

test-all:
	@echo -e "\033[0;33m>>> >>> >>> >>> >>> >>> >>> >>> \033[0;30;46m Run all tests \033[0m"
	@make validate-composer
	@make test
	@make phpmd
	@make phpcs
	@make phpcpd
	@make phploc

pack:
	@echo -e "\033[0;33m>>> >>> >>> >>> >>> >>> >>> >>> \033[0;30;46m Package: Create all \033[0m"
	@rm    -vfr ./build/packages
	@mkdir -vp  ./build/packages
	@make pack-joomla
	@make pack-joomla-unit
	@make pack-wordpress
	@make pack-wordpress-unit
	@ls -lAhv ./build/packages

start:
	@make start-http
	@make start-watch

start-http:
	@make start-http-joomla
	@make start-http-wordpress


#### Install and prepare CMS ###########################################################################################

prepare-joomla:
	@echo -e "\033[0;33m>>> >>> >>> >>> >>> >>> >>> >>> \033[0;30;46m Joomla: Prepare \033[0m"
	@mysql -e 'create database ci_test_j'
	@chmod +x ./scripts/prepare-joomla.sh
	@./scripts/prepare-joomla.sh "ci_test_j" "root" "" "127.0.0.1:8081"

prepare-wordpress:
	@echo -e "\033[0;33m>>> >>> >>> >>> >>> >>> >>> >>> \033[0;30;46m Wordpress: Prepare \033[0m"
	@mysql -e 'create database ci_test_wp'
	@chmod +x ./scripts/prepare-wordpress.sh
	@./scripts/prepare-wordpress.sh "ci_test_wp" "root" "" "127.0.0.1:8082"


#### Start servers #####################################################################################################

start-http-joomla:
	@echo -e "\033[0;33m>>> >>> >>> >>> >>> >>> >>> >>> \033[0;30;46m Server: HTTP for Joomla \033[0m"
	@chmod +x ./scripts/http-server.sh
	@./scripts/http-server.sh "cck-joomla" "127.0.0.1" "8081"

start-http-wordpress:
	@echo -e "\033[0;33m>>> >>> >>> >>> >>> >>> >>> >>> \033[0;30;46m Server: HTTP for Wordpress \033[0m"
	@chmod +x ./scripts/http-server.sh
	@./scripts/http-server.sh "cck-wordpress" "127.0.0.1" "8082"

start-watch:
	@echo -e "\033[0;33m>>> >>> >>> >>> >>> >>> >>> >>> \033[0;30;46m Server: Webpack Watcher \033[0m"
	@NODE_ENV=development ./node_modules/.bin/webpack   \
        --watch-aggregate-timeout=300                   \
        --watch                                         \
        --progress                                      \
        --colors


#### Create packages ###################################################################################################

pack-joomla:
	@echo -e "\033[0;33m>>> >>> >>> >>> >>> >>> >>> >>> \033[0;30;46m Package: Joomla \033[0m"
	@mkdir -vp ./build/packages
	@cd ./src/joomla/pkg_jbzoocck;                          \
        rm  -f  ../../../build/packages/j_jbzoo.zip;        \
        zip -rq ../../../build/packages/j_jbzoo.zip *

pack-joomla-unit:
	@echo -e "\033[0;33m>>> >>> >>> >>> >>> >>> >>> >>> \033[0;30;46m Package: Joomla (PHPUnit-plugin) \033[0m"
	@mkdir -pv ./build/packages
	@cd tests/extentions/j_jbzoophpunit;                        \
        rm  -f  ../../../build/packages/j_jbzoophpunit.zip;     \
        zip -rq ../../../build/packages/j_jbzoophpunit.zip *

pack-wordpress:
	@echo -e "\033[0;33m>>> >>> >>> >>> >>> >>> >>> >>> \033[0;30;46m Package: Wordpress \033[0m"
	@mkdir -vp ./build/packages
	@cd src/wordpress;                                      \
        rm  -f  ../../build/packages/wp_jbzoo.zip;          \
        zip -rq ../../build/packages/wp_jbzoo.zip jbzoo

pack-wordpress-unit:
	@echo -e "\033[0;33m>>> >>> >>> >>> >>> >>> >>> >>> \033[0;30;46m Package: Wordpress (PHPUnit plugin) \033[0m"
	@mkdir -vp ./build/packages
	@cd tests/extentions;                                                   \
        rm  -f  ../../build/packages/wp_jbzoophpunit.zip;                   \
        zip -rq ../../build/packages/wp_jbzoophpunit.zip wp_jbzoophpunit


#### File system #######################################################################################################

prepare-fs-build:
	@echo -e "\033[0;33m>>> >>> >>> >>> >>> >>> >>> >>> \033[0;30;46m Prepare Filesystem: Build \033[0m"
	@mkdir -pv ./build/clover_xml
	@mkdir -pv ./build/clover_html
	@mkdir -pv ./build/browser_html
	@mkdir -pv ./build/logs
	@mkdir -pv ./build/misc
	@mkdir -pv ./build/screenshot
	@mkdir -pv ./build/phpcs

prepare-fs-joomla:
	@echo -e "\033[0;33m>>> >>> >>> >>> >>> >>> >>> >>> \033[0;30;46m Prepare Filesystem: Joomla \033[0m"
	@mkdir -vp    src/joomla/pkg_jbzoocck/packages
	@ln -vs `pwd`/src/cck/                            src/joomla/com_jbzoo/admin/cck
	@ln -vs `pwd`/src/joomla/com_jbzoo/               src/joomla/pkg_jbzoocck/packages/com_jbzoo
	@ln -vs `pwd`/src/joomla/plg_sys_jbzoocck/        src/joomla/pkg_jbzoocck/packages/plg_sys_jbzoocck

prepare-fs-wordpress:
	@echo -e "\033[0;33m>>> >>> >>> >>> >>> >>> >>> >>> \033[0;30;46m Prepare Filesystem: Wordpress \033[0m"
	@ln -vs `pwd`/src/cck/                            src/wordpress/jbzoo/cck


#### Updates ###########################################################################################################

update-composer:
	@echo -e "\033[0;33m>>> >>> >>> >>> >>> >>> >>> >>> \033[0;30;46m Update: Composer (DEV) \033[0m"
	@composer config bin-dir     "../../bin"     --working-dir=./src/cck
	@composer config vendor-dir  "../../vendor"  --working-dir=./src/cck
	@composer update                \
       --working-dir=./src/cck      \
       --optimize-autoloader        \
       --no-interaction             \
       --no-progress
	@echo ""

update-npm:
	@echo -e "\033[0;33m>>> >>> >>> >>> >>> >>> >>> >>> \033[0;30;46m Update: NPM (DEV) \033[0m"
	@NODE_ENV=development npm install --progress=false
	@echo ""

update-bower:
	@echo -e "\033[0;33m>>> >>> >>> >>> >>> >>> >>> >>> \033[0;30;46m Update: Bower (DEV) \033[0m"
	@NODE_ENV=development ./node_modules/.bin/bower update
	@echo ""

update-gulp:
	@echo -e "\033[0;33m>>> >>> >>> >>> >>> >>> >>> >>> \033[0;30;46m Update: Gulp (DEV) \033[0m"
	@NODE_ENV=development ./node_modules/.bin/gulp update
	@echo ""

update-webpack:
	@echo -e "\033[0;33m>>> >>> >>> >>> >>> >>> >>> >>> \033[0;30;46m Update: Webpack (DEV) \033[0m"
	@NODE_ENV=development ./node_modules/.bin/webpack -v
	@echo ""


#### Cleanup ###########################################################################################################

clean:
	@echo -e "\033[0;33m>>> >>> >>> >>> >>> >>> >>> >>> \033[0;30;46m Cleanup project \033[0m"
	@rm -vfr ./bin
	@rm -vfr ./bower_components
	@rm -vfr ./node_modules
	@rm -vfr ./vendor
	@rm -vfr ./src/cck/libraries
	@rm -vf  ./src/cck/composer.lock
	@make clean-build
	@make prepare-fs-build

clean-build:
	@rm -vfr ./build

reset:
	@echo -e "\033[0;33m>>> >>> >>> >>> >>> >>> >>> >>> \033[0;30;46m Hard reset \033[0m"
	@git reset --hard


#### Tests #############################################################################################################

test-joomla:
	@echo -e "\033[0;33m>>> >>> >>> >>> >>> >>> >>> >>> \033[0;30;46m Run unit-tests for Joomla!CMS \033[0m"
	@php ./vendor/phpunit/phpunit/phpunit --configuration ./phpunit-joomla.xml.dist
	@echo ""

test-wordpress:
	@echo -e "\033[0;33m>>> >>> >>> >>> >>> >>> >>> >>> \033[0;30;46m Run unit-tests for Wordpress \033[0m"
	@php ./vendor/phpunit/phpunit/phpunit --configuration ./phpunit-wordpress.xml.dist
	@echo ""

test-codestyle:
	@echo -e "\033[0;33m>>> >>> >>> >>> >>> >>> >>> >>> \033[0;30;46m Check utilities and CodeStyle \033[0m"
	@php ./vendor/phpunit/phpunit/phpunit --configuration ./phpunit-utility.xml.dist
	@echo ""

validate-composer:
	@echo -e "\033[0;33m>>> >>> >>> >>> >>> >>> >>> >>> \033[0;30;46m Composer validate \033[0m"
	@composer validate --no-interaction --working-dir=./src/cck
	@echo ""

phpmd:
	@echo -e "\033[0;33m>>> >>> >>> >>> >>> >>> >>> >>> \033[0;30;46m Check PHPmd \033[0m"
	@php ./vendor/phpmd/phpmd/src/bin/phpmd ./src/cck text                          \
         ./vendor/jbzoo/misc/phpmd/jbzoo.xml --verbose                              \
        --exclude **/symfony/*,**/oyejorge/*,**/composer/,**/pimple/,**/jbdump/*

phpcs:
	@echo -e "\033[0;33m>>> >>> >>> >>> >>> >>> >>> >>> \033[0;30;46m Check Code Style \033[0m"
	@php ./vendor/squizlabs/php_codesniffer/scripts/phpcs       \
        --extensions=php                                        \
        --standard=./vendor/jbzoo/misc/phpcs/JBZoo/ruleset.xml  \
        --report-checkstyle=build/phpcs/report.xml              \
        --report=full                                           \
        --report-width=180                                      \
        --tab-width=4                                           \
        --report=full                                           \
        ./src/cck
	@echo ""

phpcpd:
	@echo -e "\033[0;33m>>> >>> >>> >>> >>> >>> >>> >>> \033[0;30;46m Check Copy&Paste \033[0m"
	@php ./vendor/sebastian/phpcpd/phpcpd ./src/cck --verbose
	@echo ""

phploc:
	@echo -e "\033[0;33m>>> >>> >>> >>> >>> >>> >>> >>> \033[0;30;46m Show stats \033[0m"
	@php ./vendor/phploc/phploc/phploc ./src/cck --verbose
	@echo ""


#### Autoload ##########################################################################################################

autoload:
	@echo -e "\033[0;33m>>> >>> >>> >>> >>> >>> >>> >>> \033[0;30;46m Composer autoload \033[0m"
	@composer dump-autoload --optimize --no-interaction
	@echo ""

coveralls:
	@echo -e "\033[0;33m>>> >>> >>> >>> >>> >>> >>> >>> \033[0;30;46m Send coverage to coveralls.io \033[0m"
	@php ./vendor/satooshi/php-coveralls/bin/coveralls --verbose
	@echo ""
