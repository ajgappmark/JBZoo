<?php
/**
 * JBZoo CCK
 *
 * This file is part of the JBZoo CCK package.
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 *
 * @package    CCK
 * @license    Proprietary http://jbzoo.com/license
 * @copyright  Copyright (C) JBZoo.com,  All rights reserved.
 * @link       http://jbzoo.com
 * @codingStandardsIgnoreFile
 */

namespace JBZoo\CCK;

if (!defined('JBZOO')) {
    define('JBZOO', true);

    if ($composerPath = realpath(__DIR__ . '/vendor/autoload.php')) {
        require_once $composerPath;
    } else {
        throw new \Exception('Composer autoload not found!');
    }

    require_once __DIR__ . '/framework/defines.php';

    $app = App::getInstance();
    $app->init();

    return $app;
}
