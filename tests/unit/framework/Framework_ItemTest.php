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

use JBZoo\CCK\Element\Element;
use JBZoo\CCK\Entity\Item;

/**
 * Class Framework_ItemTest
 */
class Framework_ItemTest extends JBZooPHPUnit
{
    public function testCreateEmptyItem()
    {
        $item = new Item();

        is(0, $item->id);
        isClass('\JBZoo\Data\Data', $item->elements);
        isClass('\JBZoo\Data\Data', $item->params);
        isTrue(is_array($item->getElements()));
        isNull($item->getType());
    }

    public function testCheckExistsItem()
    {
        /** @var Item $item */
        $item = $this->app['models']['item']->get(1);

        is(1, $item->id);
        is('Item name', $item->name);
        is('post', $item->type);

        $type1 = $item->getType();
        $type2 = $item->getType();

        isClass('\JBZoo\CCK\Type\Type', $type1);
        isClass('\JBZoo\CCK\Type\Type', $type2);
        isSame($type1, $type2);
    }

    public function testGetElement()
    {
        /** @var Item $item */
        $item = $this->app['models']['item']->get(1);

        $element1 = $item->getElement('_name');
        $element2 = $item->getElement('_name');

        isClass('\JBZoo\CCK\Element\Element', $element1);
        isClass('\JBZoo\CCK\Element\Element', $element2);
        isSame($element1, $element2);
    }

    public function testGetUndefinedElement()
    {
        /** @var Item $item */
        $item = $this->app['models']['item']->get(1);

        $element = $item->getElement('undefined');

        isNull($element);
    }

    public function testGetElements()
    {
        /** @var Item $item */
        $item = $this->app['models']['item']->get(1);

        $elements1 = $item->getElements();
        $elements2 = $item->getElements(Element::TYPE_ALL);

        isTrue(is_array($elements1));
        isSame(11, count($elements1));
        isSame($elements1, $elements2);

        isSame($elements1['_name'], $item->getElement('_name'));
    }

    public function testGetCoreElements()
    {
        /** @var Item $item */
        $item = $this->app['models']['item']->get(1);

        $elements1 = $item->getElements(Element::TYPE_CORE);
        $elements2 = $item->getElements(Element::TYPE_CORE);

        isTrue(is_array($elements1));
        isSame(1, count($elements1));
        isSame($elements1, $elements2);

        isSame($elements1['_name'], $item->getElement('_name'));
    }

    public function testGetCustomElements()
    {
        /** @var Item $item */
        $item = $this->app['models']['item']->get(1);

        $elements1 = $item->getElements(Element::TYPE_CUSTOM);
        $elements2 = $item->getElements(Element::TYPE_CUSTOM);

        isTrue(is_array($elements1));
        isSame(10, count($elements1));
        isSame($elements1, $elements2);

        isSame($elements1['text-1'], $item->getElement('text-1'));
        isSame($elements1['text-2'], $item->getElement('text-2'));
    }

    public function testGetElementsByTypeCore()
    {
        /** @var Item $item */
        $item = $this->app['models']['item']->get(1);

        $elements1 = $item->getElementsByType('name');
        $elements2 = $item->getElementsByType('Name');

        isTrue(is_array($elements1));
        isSame(1, count($elements1));
        isSame($elements1, $elements2);

        isSame($elements1['_name'], $item->getElement('_name'));
    }

    public function testGetElementsByTypeCustom()
    {
        /** @var Item $item */
        $item = $this->app['models']['item']->get(1);

        $elements1 = $item->getElementsByType('text');
        $elements2 = $item->getElementsByType('text');

        isTrue(is_array($elements1));
        isSame(2, count($elements1));
        isSame($elements1, $elements2);

        isSame($elements1['text-1'], $item->getElement('text-1'));
        isSame($elements1['text-2'], $item->getElement('text-2'));
        isNotSame($elements1['text-1'], $elements1['text-2']);
    }
}
