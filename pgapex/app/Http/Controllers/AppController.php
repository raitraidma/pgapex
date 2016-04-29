<?php
namespace App\Http\Controllers;

use App\Http\Request;
use App\Http\Response;
use Interop\Container\ContainerInterface as ContainerInterface;
use App\Models\App;

class AppController extends Controller {
  private $app;

  public function __construct(ContainerInterface $container) {
    parent::__construct($container);
    $this->app = new App($this->getContainer()['db']);
  }

  private function getAppModel() {
    return $this->app;
  }

  public function queryPage(Request $request, Response $response, $args) {
    $applicationId = $args['applicationId'];
    $pageId = isset($args['pageId']) ? $args['pageId'] : null;
    $method = $request->getMethod();
    $headers = json_encode($request->getHeaders());
    $getParams = json_encode($request->getQueryParams());
    $postParams = json_encode($request->getParsedBody());

    $queryResponse = json_decode($this->getAppModel()->queryPage($applicationId, $pageId, $method, $headers, $getParams, $postParams), true);

    $newResponse = $response;
    if ($queryResponse['headers'] !== null) {
      foreach ($queryResponse['headers'] as $key => $value) {
        $newResponse = $newResponse->withHeader($key, $value);
      }
    }
    $newResponse->getBody()->write($queryResponse['body']);
    return $newResponse;
  }
}