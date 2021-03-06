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

'use strict';

import React, { Component } from 'react'
import { Link }             from 'react-router'

class NotFound extends Component {
    render() {
        return (
            <div>
                Page not found <Link to='/'>goto main</Link>?
            </div>
        )
    }
}

module.exports = NotFound;
