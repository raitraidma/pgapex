<?php

namespace App\Http;

use Slim\Http\Response as SlimResponse;

class Response extends SlimResponse {
  private $id = null;
  private $type = null;
  private $attributes = null;
  private $errors = [];

  public function setApiAttributes($attributes) {
    $this->attributes = $attributes;
    return $this;
  }

  public function setApiId($id) {
    $this->id = $id;
    return $this;
  }

  public function setApiType($type) {
    $this->type = $type;
    return $this;
  }

  public function addApiError($detail) {
    $this->errors[]['detail'] = $detail;
    return $this;
  }

  public function addApiErrorWithPointer($detail, $pointer) {
    $error = [];
    $error['detail'] = $detail;
    $error['source']['pointer'] = $pointer;
    $this->errors[] = $error;
    return $this;
  }

  public function getApiCode() {
    return empty($this->errors) ? 200 : 403;
  }

  protected function createApiResponse() {
    $code = $this->getApiCode();
    $response = [];
    $response['meta']['status'] = static::$messages[$code];
    $response['meta']['code'] = $code;

    if (empty($this->errors)) {
      $response['data']['id'] = $this->id;
      $response['data']['type'] = $this->type;
      $response['data']['attributes'] = $this->attributes;
    } else {
      $response['errors'] = $this->errors;
    }

    return $response;
  }

  public function getApiResponse() {
    return $this->withJson($this->createApiResponse(), 200);
  }
}