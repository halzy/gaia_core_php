<?php
use Gaia\Test\Tap;
use Gaia\Store;
use Gaia\Time;

if( ! isset( $skip_expiration_tests ) ) $skip_expiration_tests = FALSE;
Tap::plan(12);

$data = array();
for( $i = 1; $i <= 3; $i++){
    $data[ 'gaia/cache/test/' . microtime(TRUE) . '/' . mt_rand(1, 10000) ] = $i;
}

$res = FALSE;

$ret = array();
foreach( $data as $k => $v ) {
    if( $ret[ $k ] = $cache->get( $k ) ) $res = TRUE;
}

Tap::ok( ! $res, 'none of the data exists before I write it in the cache');
if( $res ) Tap::debug( $ret );

$res = TRUE;
$ret = array();
foreach( $data as $k => $v ){
    if( ! $ret[ $k ] = $cache->set( $k, $v, 10) ) $res = FALSE;
}
Tap::ok( $res, 'wrote all of my data into the cache');
if( ! $res ) Tap::debug( $ret );

$res = TRUE;
foreach( $data as $k => $v ){
   if(  $cache->get( $k ) != $v ) $res = FALSE;
}
Tap::ok( $res, 'checked each key and got back what I wrote');

$ret = $cache->get( array_keys( $data ) );
$res = TRUE;
foreach( $data as $k => $v ){
    if( $ret[ $k ] != $v ) $res = FALSE;
}
Tap::ok( $res, 'grabbed the keys all at once, got what I wrote');

$k = 'gaia/cache/test/' . microtime(TRUE) . '/' . mt_rand(1, 10000);
Tap::ok( $cache->add( $k, 1, 10), 'adding a non-existent key');
Tap::ok( ! $cache->add( $k, 1, 10), 'second time, the add fails');

if( $skip_expiration_tests || ! method_exists( $cache, 'ttlEnabled') || ! $cache->ttlEnabled() ){
    Tap::ok(TRUE, 'skipping expire test');
} else {
    Time::offset(11);    
    Tap::ok( $cache->add( $k, 1, 10), 'after expiration time, add works');
}
Tap::ok( $cache->replace( $k, 1, 10 ), 'replace works after the successful add');

Tap::ok( $cache->delete($k ), 'successfully deleted the key');

Tap::ok( ! $cache->replace( $k, 1, 10), 'replace fails after key deletion');
Tap::ok( $cache->add( $k, 1, 10), 'add works after key deletion');
Tap::ok( $cache->replace( $k, 1, 10), 'replace works after key is added');
