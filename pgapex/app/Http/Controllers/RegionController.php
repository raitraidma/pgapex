<?php
namespace App\Http\Controllers;

use App\Http\Request;
use App\Http\Response;
use Interop\Container\ContainerInterface as ContainerInterface;
use App\Models\Region;

class RegionController extends Controller {
  private $region;

  public function __construct(ContainerInterface $container) {
    parent::__construct($container);
    $this->region = new Region($this->getContainer()['db']);
  }

  private function getRegionModel() {
    return $this->region;
  }

  public function getDisplayPointsWithRegions(Request $request, Response $response, $args) {
    return $response->setApiDataAsJson($this->getRegionModel()->getDisplayPointsWithRegions($args['pageId']))
      ->getApiResponse();
  }

  public function getRegion(Request $request, Response $response, $args) {
    return $response->setApiDataAsJson($this->getRegionModel()->getRegion($args['id']))
      ->getApiResponse();
  }

  public function deleteRegion(Request $request, Response $response, $args) {
    return $response->setApiDataAsJson($this->getRegionModel()->deleteRegion($args['id']))
      ->getApiResponse();
  }

  public function saveHtmlRegion(Request $request, Response $response) {
    return $response->setApiDataAsJson($this->getRegionModel()->saveHtmlRegion($request))
      ->getApiResponse();
  }
}