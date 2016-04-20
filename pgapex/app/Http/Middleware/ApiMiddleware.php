<?php
namespace App\Http\Middleware;

use Psr\Http\Message\ServerRequestInterface as Request;
use Psr\Http\Message\ResponseInterface as Response;

class ApiMiddleware extends Middleware
{
  public function __invoke(Request $request, Response $response, $next) {
    if ($request->isXhr()) {
      return $next($request, $response);
    }
    return $response
          ->write('Must be XMLHttpRequest!')
          ->withStatus(403);
  }
}