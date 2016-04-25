<?php
namespace App\Http\Controllers;

use Psr\Http\Message\ServerRequestInterface as Request;
use Psr\Http\Message\ResponseInterface as Response;
use Interop\Container\ContainerInterface as ContainerInterface;
use App\Models\Template;

class TemplateController extends Controller {
  private $template;

  public function __construct(ContainerInterface $container) {
    parent::__construct($container);
    $this->template = new Template($this->getContainer()['db']);
  }

  private function getTemplateModel() {
    return $this->template;
  }

  public function getLoginTemplates(Request $request, Response $response) {
    return $response->setApiDataAsJson($this->getTemplateModel()->getLoginTemplates())
      ->getApiResponse();
  }

  public function getPageTemplates(Request $request, Response $response) {
    return $response->setApiDataAsJson($this->getTemplateModel()->getPageTemplates())
      ->getApiResponse();
  }
}