<?php
namespace App\Http\Controllers;

use Psr\Http\Message\ServerRequestInterface as Request;
use Psr\Http\Message\ResponseInterface as Response;
use Interop\Container\ContainerInterface as ContainerInterface;
use App\Models\Database;

class DatabaseController extends Controller {
  public function __construct(ContainerInterface $container) {
    parent::__construct($container);
  }

  public function getDatabases(Request $request, Response $response) {
    $database = new Database($this->getContainer()['db']);
    return $response->setApiDataAsJson($database->getDatabases())
                    ->getApiResponse();
  }

  public function getAuthenticationFunctions(Request $request, Response $response, $args) {
    $database = new Database($this->getContainer()['db']);
    return $response->setApiDataAsJson($database->getAuthenticationFunctions($args['applicationId']))
                    ->getApiResponse();
  }
}