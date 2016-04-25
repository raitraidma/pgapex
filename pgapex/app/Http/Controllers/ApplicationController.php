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
  public function __construct(ContainerInterface $container) {
    parent::__construct($container);
  }

  public function getApplications(Request $request, Response $response) {
    $application = new Application($this->getContainer()['db']);
    return $response->setApiDataAsJson($application->getApplications())
      ->getApiResponse();
  }

  public function getApplication(Request $request, Response $response, $args) {
    $application = new Application($this->getContainer()['db']);
    return $response->setApiDataAsJson($application->getApplication($args['id']))
      ->getApiResponse();
  }

  public function deleteApplication(Request $request, Response $response, $args) {
    $application = new Application($this->getContainer()['db']);
    return $response->setApiDataAsJson($application->deleteApplication($args['id']))
      ->getApiResponse();
  }

  public function saveApplication(Request $request, Response $response) {
    $application = new Application($this->getContainer()['db']);
    $validator = new ApplicationValidator($this->getContainer()['db']);

    try {
      $validator->validate($request);
      if (!$validator->hasErrors()) {
        if(!$application->saveApplication($request)) {
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
    $application = new Application($this->getContainer()['db']);
    return $response->setApiDataAsJson($application->getApplicationAuthentication($args['id']))
      ->getApiResponse();
  }

  public function saveApplicationAuthentication(Request $request, Response $response) {
    $application = new Application($this->getContainer()['db']);
    return $response->setApiDataAsJson($application->saveApplicationAuthentication($request))
                    ->getApiResponse();
  }
}