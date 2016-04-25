<?php
namespace App\Http\Controllers;

use Psr\Http\Message\ServerRequestInterface as Request;
use Psr\Http\Message\ResponseInterface as Response;
use Interop\Container\ContainerInterface as ContainerInterface;
use App\Models\Template;

class TemplateController extends Controller {
  public function __construct(ContainerInterface $container) {
    parent::__construct($container);
  }

  public function getLoginTemplates(Request $request, Response $response) {
    $template = new Template($this->getContainer()['db']);
    return $response->setApiDataAsJson($template->getLoginTemplates())
                    ->getApiResponse();
  }
}