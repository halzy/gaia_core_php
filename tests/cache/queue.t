#!/usr/bin/env php
<?php
include __DIR__ . '/../common.php';
use Gaia\Test\Tap;
use Gaia\Cache;

Tap::plan(17);

class TestData {

    protected $data = array();
    
    function fetch( array $ids ){
        $list = array();
        foreach( $ids as $id ) $list[ $id ] = mt_rand(1, 1000000);
        return $list;
    }
    
    function fetchEmpty( array $ids ){
        return array();
    }
    
    function set( $k, $v ){
        $this->data[ $k ] = $v;
    }
    
    function get(){
        return isset( $this->data[ $k ] ) ? $this->data[ $k ] : NULL;
    }
    
    function data(){
        return $this->data;
    }
    
    function clear(){
        $this->data = array();
    }
}

$ids = array('1', '2');

$m = new Cache\Queue( new Cache\Mock() );
$t = new TestData();

$options = array(
            'prefix'=> $prefix1 = 'test1_' . time(),
            'response_callback'=>array($t, 'set'),
            'missing_callback'=>array($t, 'fetch'),
            'timeout'=>5000,
            'compression'=>0
);

$m->queue( $ids, $options );
$res = $m->fetchAll();

Tap::ok(is_array($res), 'fetchall returned an array');
Tap::is( array_keys( $res ), array( $prefix1 . $ids[0], $prefix1 . $ids[1]), 'fetchall results keyed properly');
Tap::is( array_keys( $t->data() ), $ids, 'data populated into test object');
unset( $options['missing_callback'] );
$t->clear();
$m->queue( $ids, $options );
$res = $m->fetchall();

Tap::ok(is_array($res), 'fetchall returned an array from cache');
Tap::is( array_keys( $res ), array( $prefix1 . $ids[0], $prefix1 . $ids[1]), 'fetchall results keyed properly');
Tap::is( array_keys( $t->data() ), $ids, 'data populated into test object');

$t->clear();
$ids2 = array('3', '4');
$m->queue( $ids, $options );


$options = array(
            'prefix'=> $prefix2 = 'test2_' . time(),
            'response_callback'=>array($t, 'set'),
            'missing_callback'=>array($t, 'fetch'),
            'timeout'=>5000,
            'compression'=>0
);

$m->queue( $ids2, $options );
$res = $m->fetchall();

Tap::ok(is_array($res), 'fetchall returned an array from cache');
Tap::is( array_keys( $res ), array( $prefix1 . $ids[0], $prefix1 . $ids[1],  $prefix2 . $ids2[0], $prefix2 . $ids2[1], ), 'fetchall results keyed properly');
Tap::is( array_keys( $t->data() ), array_merge($ids, $ids2), 'data populated into test object');


$m = new Cache\Prefix( $m, 'blah' . time());
$t = new TestData();

$options = array(
            'prefix'=> $prefix1 = 'test1_' . time(),
            'response_callback'=>array($t, 'set'),
            'missing_callback'=>array($t, 'fetch'),
            'timeout'=>5000,
            'compression'=>0
);

$m->queue( $ids, $options );
$res = $m->fetchAll();

Tap::ok(is_array($res), 'Cache\Prefix fetchall returned an array');
Tap::is( array_keys( $res ), array( $prefix1 . $ids[0], $prefix1 . $ids[1]), 'Cache\Prefix fetchall results keyed properly');
Tap::is( array_keys( $t->data() ), $ids, 'data populated into test object');



$m = new Cache\Prefix( $m, 'blah' . time());
$t = new TestData();

$options = array(
            'prefix'=> $prefix1 = 'test1_' . time(),
            'response_callback'=>array($t, 'set'),
            'missing_callback'=>array($t, 'fetchEmpty'),
            'default'=>'test',
            'cache_missing'=>true,
            'timeout'=>5000,
);

$m->queue( $ids, $options );
$res = $m->fetchAll();

Tap::ok(is_array($res), 'Cache\Prefix fetchall with defaults returned an array');
Tap::is( array_keys( $res ), array( $prefix1 . $ids[0], $prefix1 . $ids[1]), 'Cache\Prefix fetchall results keyed with test values');
Tap::is( array_keys( $t->data() ), $ids, 'default data populated into test object');




$t = new TestData();

$options = array(
            'callback'=> function ( array $ids ){
                $list = array();
                foreach( $ids as $id ){
                    $list[ $id ] = $id;
                }
                return $list;
            },
            'default'=>'test',
            'cache_missing'=>true,
            'timeout'=>50,
);

$m = new Cache\Callback( new Cache\Prefix( new Cache\Mock, 'testdefaults-2-' . time()), $options);

$res = $m->get(array(1,2) );
Tap::is($res, array(1=>1, 2=>2), 'Cache\Callback returned expected results');


$m = new Cache\Callback( new Cache\Gate(new Cache\Prefix( new Cache\Mock, 'testdefaults-2-' . time())), $options);
$t = new TestData();

$res = $m->get(array(1,2) );
Tap::is($res, array(1=>1, 2=>2), 'Callback works when wrapping cache\gate');

