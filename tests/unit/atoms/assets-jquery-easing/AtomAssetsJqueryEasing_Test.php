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
 */

namespace JBZoo\PHPUnit;

/**
 * Class AtomAssetsJqueryEasing_Test
 * @package JBZoo\PHPUnit
 */
class AtomAssetsJqueryEasing_Test extends JBZooPHPUnit
{
    public function testJQueryEasing()
    {
        $result = $this->helper->request('test.index.assetsJQueryEasing');
        isContain("/jquery.js", $result->get('body'));
        isContain("/jquery.easing.min.js", $result->get('body'));
    }
}
