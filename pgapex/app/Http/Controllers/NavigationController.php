<?php
namespace App\Http\Controllers;

use App\Http\Request;
use App\Http\Response;
use App\Models\Navigation;
use Interop\Container\ContainerInterface as ContainerInterface;

class NavigationController extends Controller {
  private $navigation;

  public function __construct(ContainerInterface $container) {
    parent::__construct($container);
    $this->navigation = new Navigation($this->getContainer()['db']);
  }

  private function getNavigationModel() {
    return $this->navigation;
  }

  public function getNavigations(Request $request, Response $response, $args) {
    return $response->setApiDataAsJson($this->getNavigationModel()->getNavigations($args['applicationId']))
      ->getApiResponse();
  }

  public function saveNavigation(Request $request, Response $response) {
    return $response->setApiDataAsJson($this->getNavigationModel()->saveNavigation($request))
      ->getApiResponse();
  }

  public function getNavigation(Request $request, Response $response, $args) {
    return $response->setApiDataAsJson($this->getNavigationModel()->getNavigation($args['id']))
      ->getApiResponse();
  }

  public function deleteNavigation(Request $request, Response $response, $args) {
    return $response->setApiDataAsJson($this->getNavigationModel()->deleteNavigation($args['id']))
      ->getApiResponse();
  }

  public function getNavigationItems(Request $request, Response $response, $args) {
    return $response->setApiDataAsJson($this->getNavigationModel()->getNavigationItems($args['id']))
      ->getApiResponse();
  }

  public function deleteNavigationItem(Request $request, Response $response, $args) {
    return $response->setApiDataAsJson($this->getNavigationModel()->deleteNavigationItem($args['id']))
      ->getApiResponse();
  }

  public function getNavigationItem(Request $request, Response $response, $args) {
    return $response->setApiDataAsJson($this->getNavigationModel()->getNavigationItem($args['id']))
      ->getApiResponse();
  }

  public function saveNavigationItem(Request $request, Response $response) {
    return $response->setApiDataAsJson($this->getNavigationModel()->saveNavigationItem($request))
      ->getApiResponse();
  }
}