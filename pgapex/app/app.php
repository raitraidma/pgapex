<?php

require __DIR__ . '/../vendor/autoload.php';

$app = new \Slim\App;

$app->get('/', function ($request, $response) {
    return file_get_contents(__DIR__ . '/views/index.html');
});

$app->run();