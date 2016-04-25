<?php
namespace App\Http\Controllers;

use App\Http\Request;
use App\Http\Response;
use Interop\Container\ContainerInterface as ContainerInterface;
use App\Models\Page;

class PageController extends Controller {
  private $page;

  public function __construct(ContainerInterface $container) {
    parent::__construct($container);
    $this->page = new Page($this->getContainer()['db']);
  }

  private function getPageModel() {
    return $this->page;
  }

  public function getPages(Request $request, Response $response, $args) {
    return $response->setApiDataAsJson($this->getPageModel()->getPages($args['applicationId']))
      ->getApiResponse();
  }

  public function getPage(Request $request, Response $response, $args) {
    return $response->setApiDataAsJson($this->getPageModel()->getPage($args['id']))
      ->getApiResponse();
  }

  public function deletePage(Request $request, Response $response, $args) {
    return $response->setApiDataAsJson($this->getPageModel()->deletePage($args['id']))
      ->getApiResponse();
  }

  public function savePage(Request $request, Response $response) {
    return $response->setApiDataAsJson($this->getPageModel()->savePage($request))
      ->getApiResponse();
  }
}