<?php

namespace App\Http;

use Slim\Http\Response as SlimResponse;

class Response extends SlimResponse {
  private $data = null;
  private $errors = [];
  private $statusCode = null;

  public function setApiData($data) {
    $this->data = $data;
    return $this;
  }

  public function setApiDataAsJson($data) {
    $this->data = json_decode($data, true);
    return $this;
  }

  public function setApiStatusCode($statusCode) {
    $this->statusCode = $statusCode;
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

  public function getApiStatusCode() {
    if ($this->statusCode !== null) {
      return $this->statusCode;
    }
    return empty($this->errors) ? 200 : 403;
  }

  protected function createApiResponse() {
    $code = $this->getApiStatusCode();
    $response = [];
    $response['meta']['status'] = static::$messages[$code];
    $response['meta']['code'] = $code;

    if (empty($this->errors)) {
      $response['data'] = $this->data;
    } else {
      $response['errors'] = $this->errors;
    }

    return $response;
  }

  public function getApiResponse($status = 200) {
    return $this->withJson($this->createApiResponse(), $status);
  }
}