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

import React, { Component } from 'react'

import Toggle   from 'material-ui/Toggle';

export default class FieldToggle extends Component {

    render() {

        var fieldId = 'field_' + this.props.name;

        return <Toggle
            id={fieldId}
            name={this.props.name}
            key={this.props.name}
            label={this.props.data.label}
            labelPosition="right"
            defaultToggled={this.props.data.default}
        />;
    }
}