<?php
namespace App\Http\Middleware;

use Psr\Http\Message\ServerRequestInterface as Request;
use Psr\Http\Message\ResponseInterface as Response;

class AuthMiddleware extends Middleware
{
  public function __invoke(Request $request, Response $response, $next) {
    $auth = $this->getContainer()['auth'];
    if ($auth->isLoggedIn()) {
      return $next($request, $response);
    }
    return $response->addApiError('Must be authenticated!')
                    ->setApiStatusCode(401)
                    ->getApiResponse(401);
  }
}