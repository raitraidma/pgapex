<?php
namespace App\Http\Controllers;

use App\Http\Request;
use App\Http\Response;
use App\Models\Database;
use App\Services\Validators\Application\ApplicationValidator;
use Exception;
use Interop\Container\ContainerInterface as ContainerInterface;
use App\Models\Application;

class ApplicationController extends Controller {
  private $application;

  public function __construct(ContainerInterface $container) {
    parent::__construct($container);
    $this->application = new Application($this->getContainer()['db']);
  }

  private function getApp() {
    return $this->application;
  }

  public function getApplications(Request $request, Response $response) {
    return $response->setApiDataAsJson($this->getApp()->getApplications())
      ->getApiResponse();
  }

  public function getApplication(Request $request, Response $response, $args) {
    return $response->setApiDataAsJson($this->getApp()->getApplication($args['id']))
      ->getApiResponse();
  }

  public function deleteApplication(Request $request, Response $response, $args) {
    return $response->setApiDataAsJson($this->getApp()->deleteApplication($args['id']))
      ->getApiResponse();
  }

  public function saveApplication(Request $request, Response $response) {
    $validator = new ApplicationValidator($this->getContainer()['db']);

    try {
      $validator->validate($request);
      if (!$validator->hasErrors()) {
        if(!$this->getApp()->saveApplication($request)) {
          throw new Exception('Could not create an application');
        } else {
          (new Database($this->getContainer()['db']))->refreshDatabaseObjects();
        }
      }
    } catch (Exception $e) {
      $response->addApiError('application.couldNotCreateAnApplication');
    }
    $validator->attachErrorsToResponse($response);

    return $response->getApiResponse();
  }

  public function getApplicationAuthentication(Request $request, Response $response, $args) {
    return $response->setApiDataAsJson($this->getApp()->getApplicationAuthentication($args['id']))
      ->getApiResponse();
  }

  public function saveApplicationAuthentication(Request $request, Response $response) {
    return $response->setApiDataAsJson($this->getApp()->saveApplicationAuthentication($request))
                    ->getApiResponse();
  }
}