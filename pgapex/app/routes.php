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
  $this->post('/auth/login', '\App\Http\Controllers\AuthController:login');

  $this->group('', function () {
    $this->get('/auth/logout', '\App\Http\Controllers\AuthController:logout');

    $this->get('/application/applications', '\App\Http\Controllers\ApplicationController:getApplications');
    $this->get('/application/applications/{id}', '\App\Http\Controllers\ApplicationController:getApplication');
    $this->post('/application/applications/{id}/delete', '\App\Http\Controllers\ApplicationController:deleteApplication');
    $this->post('/application/save', '\App\Http\Controllers\ApplicationController:saveApplication');
    $this->post('/application/applications/authentication/save', '\App\Http\Controllers\ApplicationController:saveApplicationAuthentication');
    $this->get('/application/applications/{id}/authentication', '\App\Http\Controllers\ApplicationController:getApplicationAuthentication');

    $this->get('/database/databases', '\App\Http\Controllers\DatabaseController:getDatabases');
    $this->get('/database/authentication-functions/{applicationId}', '\App\Http\Controllers\DatabaseController:getAuthenticationFunctions');

    $this->get('/template/login-templates', '\App\Http\Controllers\TemplateController:getLoginTemplates');
    $this->get('/template/page-templates', '\App\Http\Controllers\TemplateController:getPageTemplates');

    $this->get('/page/pages/{applicationId}', '\App\Http\Controllers\PageController:getPages');
    $this->post('/page/page/save', '\App\Http\Controllers\PageController:savePage');
    $this->get('/page/page/{id}', '\App\Http\Controllers\PageController:getPage');
    $this->post('/page/page/{id}/delete', '\App\Http\Controllers\PageController:deletePage');

    $this->get('/navigation/navigations/{applicationId}', '\App\Http\Controllers\NavigationController:getNavigations');
    $this->post('/navigation/navigation/save', '\App\Http\Controllers\NavigationController:saveNavigation');
    $this->get('/navigation/navigation/{id}', '\App\Http\Controllers\NavigationController:getNavigation');
    $this->post('/navigation/navigation/{id}/delete', '\App\Http\Controllers\NavigationController:deleteNavigation');
  })->add(new AuthMiddleware($this->getContainer()));

})->add(new ApiMiddleware($app->getContainer()));