#!/usr/bin/env php
<?php
use Gaia\Test\Tap;
use Gaia\Store;

include __DIR__ . '/../common.php';
include __DIR__ . '/../assert/memcache_installed.php';
include __DIR__ . '/../assert/memcache_running.php';

$cache = new Store\Prefix(new Store\Memcache('127.0.0.1:11211'), md5( __FILE__ . '/' . microtime(TRUE) . '/' . php_uname()));
$skip_expiration_tests = TRUE;
include __DIR__ . '/generic_tests.php';