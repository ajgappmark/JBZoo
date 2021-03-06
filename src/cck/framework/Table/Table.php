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

namespace JBZoo\CCK\Table;

use JBZoo\CCK\Entity\Entity;
use JBZoo\CrossCMS\AbstractDatabase;
use JBZoo\CCK\App;
use JBZoo\SqlBuilder\Query\Delete;
use JBZoo\SqlBuilder\Query\Insert;
use JBZoo\SqlBuilder\Query\Replace;
use JBZoo\SqlBuilder\Query\Select;
use JBZoo\SqlBuilder\Query\Update;
use JBZoo\Utils\Dates;
use JBZoo\Utils\Str;

/**
 * Class Table
 * @package JBZoo\CCK
 * @SuppressWarnings(PHPMD.CouplingBetweenObjects)
 */
abstract class Table
{
    /**
     * @var App
     */
    public $app;

    /**
     * @var string
     */
    public $entity = 'stdClass';

    /**
     * @var AbstractDatabase
     */
    protected $_db;

    /**
     * @var string
     */
    protected $_table = '';

    /**
     * @var string
     */
    protected $_key = 'id';

    /**
     * @var string
     */
    protected $_dbNow = '';

    /**
     * @var string
     */
    protected $_dbNull = Dates::SQL_NULL;

    /**
     * A list of the objects created from the records fetched from the database
     * @var array
     */
    protected $_objects = [];

    /**
     * A list of the objects created from the records fetched from the database
     * @var array
     */
    protected $_fields = [];

    /**
     * Table constructor.
     *
     * @param string $name
     * @param string $key
     */
    public function __construct($name = '', $key = 'id')
    {
        $this->app = App::getInstance();
        $this->_db = $this->app['db'];

        $this->_key   = $key;
        $this->_table = $name;
        $this->_dbNow = $this->_db->quote(Dates::sql(time()), false);

        $this->_id = Str::getClassName($this, true);
    }

    /**
     * Get table ID
     * @return string
     */
    public function getId()
    {
        return $this->_id;
    }

    /**
     * Init table object
     */
    public function init()
    {
        $this->app->trigger("table.{$this->_id}.init", [$this]);
    }

    /**
     * @return string
     */
    public function getTableName()
    {
        return $this->_table;
    }

    /**
     * @param array $rowData
     * @return mixed
     */
    protected function _fetchObject($rowData)
    {
        if (!$rowData) {
            return null;
        }

        $keyName = $this->_key;
        $class   = $this->entity;

        // Check store
        if (isset($rowData[$keyName]) && isset($this->_objects[$rowData[$keyName]]) && $rowData[$keyName] > 0) {
            return $this->_objects[$rowData[$keyName]];
        }

        /** @var Entity $object */
        $object = new $class($rowData);

        // Save to memory store (cache it)
        if ($object->$keyName && !key_exists($object->$keyName, $this->_objects)) {
            $this->_objects[$object->$keyName] = $object;
        }

        return $object;
    }

    /**
     * @param $rows
     * @return array
     */
    protected function _fetchObjectList($rows)
    {
        $result = [];
        foreach ($rows as $row) {
            $result[] = $this->_fetchObject($row);
        }

        return $result;
    }

    /**
     * Remove record from database table
     *
     * @param $entity
     * @return bool|int
     */
    public function removeEntity($entity)
    {
        if ($this->_key && $entity) {
            return $this->remove($entity->{$this->_key});
        }

        return false;
    }

    /**
     * Remove record from database table
     *
     * @param $id
     * @return bool|int
     */
    public function remove($id)
    {
        if ($id) {
            $sql = $this->_delete()
                ->where([$this->_key, ' = ?s'], $id);

            $this->unsetObject($id);
            $isRemoved = $this->_db->query($sql);

            return $isRemoved;
        }

        return false;
    }

    /**
     * Remove record from database table
     *
     * @param $entityId
     * @return Entity
     */
    public function get($entityId)
    {
        if ($this->hasObject($entityId)) {
            return $this->_objects[$entityId];
        }

        $sql = $this->_select()
            ->where($this->_key . ' = ?i', $entityId);

        $row    = $this->_db->fetchRow($sql);
        $object = $this->_fetchObject($row);

        return $object;
    }

    /**
     * Removes the object from the internal object storage.
     * @param string $key The key of the object to be removed
     */
    public function unsetObject($key)
    {
        if ($this->hasObject($key)) {
            unset($this->_objects[$key]);
        }
    }

    /**
     * Checks if the object is already managed by the table.
     * @param string $key The key of the object
     * @return bool
     */
    public function hasObject($key)
    {
        return isset($this->_objects[$key]);
    }

    /**
     * Clean all cached objects
     */
    public function cleanObjects()
    {
        $this->_objects = [];
    }

    /**
     * Get the list of columns for the table
     * Retrieves field information about a given table.
     * @return array
     */
    public function getTableColumns()
    {
        if (empty($this->_fields)) {
            $this->_fields = $this->_db->getTableColumns($this->_table);
        }

        return $this->_fields;
    }

    /**
     * @param Entity $entity
     * @return int
     */
    public function saveEntity($entity)
    {
        // init vars
        $vars   = get_object_vars($entity);
        $fields = $this->getTableColumns();

        foreach (array_keys($fields) as $key) {
            $fields[$key] = array_key_exists($key, $vars) ? (string)$vars[$key] : null;
        }

        $tableKey = $this->_key;

        // insert or update database
        if (isset($fields[$tableKey]) && $fields[$tableKey] > 0) {

            $keyId = $fields[$tableKey];

            $sql = $this->_update($this->_table)
                ->set($fields)
                ->where($tableKey . ' = ?s', $keyId);

            $this->_db->query($sql);

            return $keyId;

        } else {
            $sql = $this->_insert($this->_table)
                ->row($fields);

            $this->_db->query($sql);

            return $this->_db->insertId();
        }
    }

    /**
     * @return string
     */
    public function getKey()
    {
        return $this->_key;
    }

    /**
     * Method to check if an alias already exists.
     *
     * @param string $newItemAlias
     * @param int    $itemId
     * @return bool
     */
    public function checkAlias($newItemAlias, $itemId)
    {
        $existedId = $this->aliasToId($newItemAlias);

        if ($existedId && $existedId != (int)$itemId) {
            return true;
        }

        return false;
    }

    /**
     * Convert item alias to id
     *
     * @param string $alias
     * @return string
     */
    public function aliasToId($alias)
    {
        $sql = $this->_select($this->_table)
            ->select('id')
            ->where('alias = ?s', $alias)
            ->limit(1);

        $row = $this->_db->fetchRow($sql);

        return $row['id'] ? $row['id'] : 0;
    }

    /**
     * Translate object id to alias.
     *
     * @param string $entityId
     * @return string
     */
    public function idToAlias($entityId)
    {
        if ($this->hasObject($entityId)) {
            return $this->get($entityId)->alias;
        }

        $sql = $this->_select($this->_table)
            ->select('alias')
            ->where('id = ?i', $entityId)
            ->limit(1);

        $row = $this->_db->fetchRow($sql);

        return $row ? $row['alias'] : null;
    }

    /**
     * Get unique object alias
     *
     * @param int    $id    Entity ID
     * @param string $alias Posible alias
     *
     * @return string
     */
    public function getUniqueAlias($id, $alias = '')
    {
        if ($id > 0 && empty($alias)) {
            $alias = Str::slug($this->get($id)->name);
        }

        if (!empty($alias)) {
            $newAlias = $alias;

            while ($this->checkAlias($newAlias, $id)) {
                $newAlias = Str::inc($newAlias, 'dash');
            }

            return $newAlias;
        }

        return $alias;
    }


    /**
     * @param string $tableName
     * @param null   $alias
     * @return Select
     */
    protected function _select($tableName = null, $alias = null)
    {
        $tableName = $tableName ?: $this->_table;
        return new Select($tableName, $alias);
    }

    /**
     * @param string $tableName
     * @return Replace
     */
    protected function _replace($tableName = null)
    {
        $tableName = $tableName ?: $this->_table;
        return new Replace($tableName);
    }

    /**
     * @param string $tableName
     * @return Insert
     */
    protected function _insert($tableName = null)
    {
        $tableName = $tableName ?: $this->_table;
        return new Insert($tableName);
    }

    /**
     * @param string $tableName
     * @return Update
     */
    protected function _update($tableName = null)
    {
        $tableName = $tableName ?: $this->_table;
        return new Update($tableName);
    }

    /**
     * @param string $tableName
     * @param null   $alias
     * @return Delete
     */
    protected function _delete($tableName = null, $alias = null)
    {
        $tableName = $tableName ?: $this->_table;
        return new Delete($tableName, $alias);
    }
}
