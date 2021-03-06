#!/usr/bin/env php
<?php
use Gaia\Test\Tap;

$arg = array('test'=>'string', 'stdclass'=> new stdclass);
include __DIR__ . '/base.php';
Tap::plan(4);

Tap::is( $result_export_before_dispatch, $arg, 'export matches arg before dispatch');
Tap::is( $result_export_after_dispatch, $arg, 'export matches arg after dispatch');
Tap::is( $result_dispatch, 'hello', 'dispatch runs string, returns hello' );
Tap::is( $exception, NULL, 'no exception thrown' );
