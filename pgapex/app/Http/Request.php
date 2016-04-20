<?php

namespace App\Http;

use Slim\Http\Request as SlimRequest;

class Request extends SlimRequest {
  public function getApiAttribute($attribute, $defaultValue = null) {
    return $this->getApiAttributeFromParsedBody($this->getParsedBody(), $attribute, $defaultValue);
  }

  protected function getApiAttributeFromParsedBody($request, $attribute, $defaultValue) {
    if (isset($request) and isset($request['data']) and isset($request['data']['attributes'])
         and isset($request['data']['attributes'][$attribute])) {
      return $request['data']['attributes'][$attribute];
    }
    return $defaultValue;
  }
}