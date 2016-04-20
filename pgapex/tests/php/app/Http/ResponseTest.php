<?php

namespace Tests\App\Http;

use App\Http\Response;

class ResponseTest extends \TestCase
{
  public function testSetApiAttributes() {
    $response = new Response();
    $response->setApiAttributes('api-attributes');
    $this->assertEquals('api-attributes', $this->getObjectProperty($response, 'attributes'));
  }

  public function testSetApiId() {
    $response = new Response();
    $response->setApiId('api-id');
    $this->assertEquals('api-id', $this->getObjectProperty($response, 'id'));
  }

  public function testSetApiType() {
    $response = new Response();
    $response->setApiType('api-type');
    $this->assertEquals('api-type', $this->getObjectProperty($response, 'type'));
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
    $this->assertEquals(403, $response->getApiCode());
  }

  public function testGetApiCodeReturns200WhenThereAreNoErrors() {
    $errors = ['error1', 'error2'];
    $response = new Response();
    $this->assertEquals(200, $response->getApiCode());
  }

  public function testCreateApiResponseWithErrors() {
    $response = new Response();
    $response->setApiId('api-id');
    $response->setApiType('api-type');
    $response->setApiAttributes('api-attributes');

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
    $response->setApiId('api-id');
    $response->setApiType('api-type');
    $response->setApiAttributes('api-attributes');

    $apiResponse = $this->invokeObjectMethod($response, 'createApiResponse');

    $this->assertEquals('OK', $apiResponse['meta']['status']);
    $this->assertEquals(200, $apiResponse['meta']['code']);
    $this->assertEquals('api-id', $apiResponse['data']['id']);
    $this->assertEquals('api-type', $apiResponse['data']['type']);
    $this->assertEquals('api-attributes', $apiResponse['data']['attributes']);
  }
}