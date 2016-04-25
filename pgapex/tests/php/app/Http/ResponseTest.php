<?php

namespace Tests\App\Http;

use App\Http\Response;

class ResponseTest extends \TestCase
{
  public function testSetApiData() {
    $response = new Response();
    $response->setApiData('api-data');
    $this->assertEquals('api-data', $this->getObjectProperty($response, 'data'));
  }

  public function testAddApiError() {
    $response = new Response();
    $response->addApiError('error-msg');
    $errors = $this->getObjectProperty($response, 'errors');
    $this->assertEquals('error-msg', $errors[0]['detail']);
  }

  public function testAddApiErrorWithPointer() {
    $response = new Response();
    $response->addApiErrorWithPointer('error-msg', 'source-pointer');
    $errors = $this->getObjectProperty($response, 'errors');
    $this->assertEquals('error-msg', $errors[0]['detail']);
    $this->assertEquals('source-pointer', $errors[0]['source']['pointer']);
  }

  public function testGetApiCodeReturns403WhenErrorsExist() {
    $errors = ['error1', 'error2'];
    $response = new Response();
    $this->makeClassPropertyAccessible($response, 'errors')
         ->setValue($response, $errors);
    $this->assertEquals(403, $response->getApiStatusCode());
  }

  public function testGetApiCodeReturns200WhenThereAreNoErrors() {
    $errors = ['error1', 'error2'];
    $response = new Response();
    $this->assertEquals(200, $response->getApiStatusCode());
  }

  public function testGetApiCodeReturnsManualySetCode() {
    $response = new Response();
    $response->setApiStatusCode(401);
    $this->assertEquals(401, $response->getApiStatusCode());
  }

  public function testCreateApiResponseWithErrors() {
    $response = new Response();
    $response->setApiData('api-data');

    $response->addApiError('error-msg1');
    $response->addApiErrorWithPointer('error-msg2', 'source-pointer2');
    
    $apiResponse = $this->invokeObjectMethod($response, 'createApiResponse');

    $this->assertEquals('Forbidden', $apiResponse['meta']['status']);
    $this->assertEquals(403, $apiResponse['meta']['code']);
    $this->assertEquals('error-msg1', $apiResponse['errors'][0]['detail']);
    $this->assertEquals('error-msg2', $apiResponse['errors'][1]['detail']);
    $this->assertEquals('source-pointer2', $apiResponse['errors'][1]['source']['pointer']);
  }

  public function testCreateApiResponseWithData() {
    $response = new Response();
    $response->setApiData('api-data');

    $apiResponse = $this->invokeObjectMethod($response, 'createApiResponse');

    $this->assertEquals('OK', $apiResponse['meta']['status']);
    $this->assertEquals(200, $apiResponse['meta']['code']);
    $this->assertEquals('api-data', $apiResponse['data']);
  }
}