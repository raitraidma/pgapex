<?php
namespace App\Http\Controllers;

use App\Http\Request;
use App\Http\Response;
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

  public function getRegionTemplates(Request $request, Response $response) {
    return $response->setApiDataAsJson($this->getTemplateModel()->getRegionTemplates())
      ->getApiResponse();
  }

  public function getNavigationTemplates(Request $request, Response $response) {
    return $response->setApiDataAsJson($this->getTemplateModel()->getNavigationTemplates())
      ->getApiResponse();
  }

  public function getReportTemplates(Request $request, Response $response) {
    return $response->setApiDataAsJson($this->getTemplateModel()->getReportTemplates())
      ->getApiResponse();
  }

  public function getFormTemplates(Request $request, Response $response) {
    return $response->setApiDataAsJson($this->getTemplateModel()->getFormTemplates())
      ->getApiResponse();
  }

  public function getButtonTemplates(Request $request, Response $response) {
    return $response->setApiDataAsJson($this->getTemplateModel()->getButtonTemplates())
      ->getApiResponse();
  }

  public function getTextareaTemplates(Request $request, Response $response) {
    return $response->setApiDataAsJson($this->getTemplateModel()->getTextareaTemplates())
      ->getApiResponse();
  }

  public function getDropDownTemplates(Request $request, Response $response) {
    return $response->setApiDataAsJson($this->getTemplateModel()->getDropDownTemplates())
      ->getApiResponse();
  }

  public function getInputTemplates(Request $request, Response $response, $args) {
    return $response->setApiDataAsJson($this->getTemplateModel()->getInputTemplates($args['inputType']))
      ->getApiResponse();
  }
}