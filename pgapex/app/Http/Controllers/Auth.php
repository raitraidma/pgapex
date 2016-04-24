<?php
namespace App\Http\Controllers;

use Psr\Http\Message\ServerRequestInterface as Request;
use Psr\Http\Message\ResponseInterface as Response;
use Interop\Container\ContainerInterface as ContainerInterface;
use App\Services\Validators\Auth\LoginValidator;

class Auth extends Controller {
  public function __construct(ContainerInterface $container) {
    parent::__construct($container);
  }

  public function login(Request $request, Response $response) {
    $validator = new LoginValidator();
    $validator->validate($request);

    if (!$validator->hasErrors()) {
      $username = $request->getApiAttribute('username');
      $password = $request->getApiAttribute('password');
      if(!$this->getContainer()->get('auth')->login($username, $password)) {
        $validator->addError('auth.wrongUsernameOrPassword', '/data/attributes/username');
      }
    }

    $validator->attachErrorsToResponse($response);

    return $response->getApiResponse();
  }

  public function logout(Request $request, Response $response) {
    return $response->getApiResponse();
  }
}