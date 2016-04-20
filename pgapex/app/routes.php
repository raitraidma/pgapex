<?php
use Psr\Http\Message\ServerRequestInterface as Request;
use Psr\Http\Message\ResponseInterface as Response;
use App\Http\Middleware\ApiMiddleware;
use App\Http\Middleware\AuthMiddleware;

$app->any('/', function (Request $request, Response $response) {
  $content = file_get_contents(__DIR__ . '/views/index.html');
  return str_replace('{$pgApexPath}', $_SERVER['PHP_SELF'], $content);
});

$app->group('/api', function () {
  $this->post('/auth/login', '\App\Http\Controllers\Auth:login');

  $this->group('', function () {
    $this->get('/auth/logout', '\App\Http\Controllers\Auth:logout');
  })->add(new AuthMiddleware($this->getContainer()));

})->add(new ApiMiddleware($app->getContainer()));